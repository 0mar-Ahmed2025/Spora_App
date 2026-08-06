// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:spora_app/core/helper/app_pop_up.dart';
import 'package:spora_app/features/device_capabilities/services/location_service.dart';
import 'package:spora_app/features/reports/data/datasources/fake_report_remote_data_source.dart';
import 'package:spora_app/features/reports/data/datasources/local_report_data_source.dart';
import 'package:spora_app/features/reports/domain/models/report_enums.dart';
import 'package:spora_app/features/reports/domain/repositories/report_repository_impl.dart';
import 'package:spora_app/features/reports/presentation/cubits/create_report/create_report_cubit.dart';
import 'package:spora_app/features/reports/presentation/cubits/create_report/create_report_state.dart';
import 'package:spora_app/generated/locale_keys.g.dart';

class CreateReportPage extends StatelessWidget {
  const CreateReportPage({super.key});

  static const List<Map<String, String>> categories = [
    {'id': 'technical', 'nameKey': 'category_technical'},
    {'id': 'service', 'nameKey': 'category_service'},
    {'id': 'feedback', 'nameKey': 'category_feedback'},
    {'id': 'other', 'nameKey': 'category_other'},
  ];

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null && context.mounted) {
      context.read<CreateReportCubit>().imageSelected(pickedFile.path);
    }
  }

  Future<void> _fetchLocation(BuildContext context) async {
    final status = await Permission.location.request();
    if (!status.isGranted) {
      if (context.mounted) {
        SnackBarPopUp().show(
          context: context,
          message: LocaleKeys.device_capabilities_permission_denied_msg.tr(),
          state: PopUpState.warning,
        );
      }
      return;
    }

    try {
      final locationService = LocationServiceImpl();
      final locationData = await locationService.getCurrentLocation();
      if (context.mounted) {
        context.read<CreateReportCubit>().locationFetched(
          locationData.latitude,
          locationData.longitude,
        );
        SnackBarPopUp().show(
          context: context,
          message: LocaleKeys.location_fetched.tr(),
          state: PopUpState.success,
        );
      }
    } catch (e) {
      if (context.mounted) {
        SnackBarPopUp().show(
          context: context,
          message: LocaleKeys.device_capabilities_error_occurred.tr(),
          state: PopUpState.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.create_report_title.tr())),
      body: BlocProvider(
        create: (context) => CreateReportCubit(
          repository: ReportRepositoryImpl(
            localDataSource: LocalReportDataSourceImpl(),
            remoteDataSource: sharedFakeRemoteDataSource,
          ),
        ),
        child: BlocConsumer<CreateReportCubit, CreateReportState>(
          listener: (context, state) {
            if (state.isSuccess == true) {
              SnackBarPopUp().show(
                context: context,
                message: LocaleKeys.report_saved_success.tr(),
                state: PopUpState.success,
              );
              Navigator.pop(context);
            }
            if (state.errorMessage != null) {
              SnackBarPopUp().show(
                context: context,
                message: state.errorMessage ?? "",
                state: PopUpState.error,
              );
            }
          },
          builder: (context, state) {
            final cubit = context.read<CreateReportCubit>();

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    onChanged: cubit.titleChanged,
                    decoration: InputDecoration(
                      labelText: LocaleKeys.field_title.tr(),
                      errorText: state.title.isNotEmpty && !state.isTitleValid
                          ? LocaleKeys.error_title_invalid.tr()
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    onChanged: cubit.descriptionChanged,
                    maxLines: 4,
                    decoration: InputDecoration(
                      labelText: LocaleKeys.field_description.tr(),
                      errorText:
                          state.description.isNotEmpty &&
                              !state.isDescriptionValid
                          ? LocaleKeys.error_description_invalid.tr()
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<String>(
                          dropdownColor: Colors.deepPurple[200],
                          borderRadius: BorderRadius.circular(20),
                          value: state.categoryId,
                          hint: Text(LocaleKeys.field_category.tr()),
                          items: categories.map((cat) {
                            return DropdownMenuItem<String>(
                              value: cat['id'],
                              child: Text(cat['nameKey']!.tr()),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) cubit.categoryChanged(val);
                          },
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: DropdownButtonFormField<ReportPriorityEnum>(
                          dropdownColor: Colors.deepPurple[200],

                          borderRadius: BorderRadius.circular(20),
                          value: state.priority,
                          decoration: InputDecoration(
                            labelText: LocaleKeys.field_priority.tr(),
                          ),
                          items: ReportPriorityEnum.values.map((p) {
                            return DropdownMenuItem<ReportPriorityEnum>(
                              value: p,
                              child: Text('priority_${p.name}'.tr()),
                            );
                          }).toList(),
                          onChanged: (val) {
                            if (val != null) cubit.priorityChanged(val);
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _pickImage(context, ImageSource.camera),
                          icon: const Icon(Icons.camera_alt),
                          label: Text(LocaleKeys.btn_camera.tr()),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _pickImage(context, ImageSource.gallery),
                          icon: const Icon(Icons.photo_library),
                          label: Text(LocaleKeys.btn_gallery.tr()),
                        ),
                      ),
                    ],
                  ),
                  if (state.imagePath != null) ...[
                    const SizedBox(height: 12),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        File(state.imagePath!),
                        height: 150,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LocaleKeys.field_location.tr(),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (state.latitude != null &&
                            state.longitude != null) ...[
                          Text(
                            'Lat: ${state.latitude!.toStringAsFixed(6)}, Lng: ${state.longitude!.toStringAsFixed(6)}',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: AlignmentDirectional.centerEnd,
                            child: TextButton.icon(
                              onPressed: () {
                                cubit.locationCleared();
                                SnackBarPopUp().show(
                                  context: context,
                                  message: LocaleKeys.location_cleared.tr(),
                                  state: PopUpState.success,
                                );
                              },
                              icon: const Icon(Icons.clear, size: 16),
                              label: Text(LocaleKeys.cancel.tr()),
                            ),
                          ),
                        ] else
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () => _fetchLocation(context),
                              icon: const Icon(Icons.my_location),
                              label: Text(LocaleKeys.btn_get_location.tr()),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          onPressed: state.isValid && !state.isSubmitting
                              ? () => cubit.submitReport(saveAsDraft: false)
                              : null,
                          child: state.isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(LocaleKeys.btn_save.tr()),
                        ),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            fixedSize: Size(40, 50),
                            backgroundColor: Colors.orangeAccent,
                          ),
                          onPressed: state.isSubmitting
                              ? null
                              : () => cubit.submitReport(saveAsDraft: true),

                          child: state.isSubmitting
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(LocaleKeys.btn_save_as_draft.tr()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
