// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:spora_app/features/device_capabilities/services/location_service.dart';
import 'package:spora_app/features/reports/data/datasources/fake_report_remote_data_source.dart';
import 'package:spora_app/features/reports/data/datasources/local_report_data_source.dart';
import 'package:spora_app/features/reports/domain/models/local_report_model.dart';
import 'package:spora_app/features/reports/domain/models/report_enums.dart';
import 'package:spora_app/features/reports/domain/repositories/report_repository_impl.dart';
import 'package:spora_app/features/reports/presentation/cubits/edit_report/edit_report_cubit.dart';
import 'package:spora_app/features/reports/presentation/cubits/edit_report/edit_report_state.dart';
import 'package:spora_app/generated/locale_keys.g.dart';

class EditReportPage extends StatefulWidget {
  const EditReportPage({super.key, required this.report});

  final LocalReportModel report;

  static const List<Map<String, String>> categories = [
    {'id': 'technical', 'nameKey': 'category_technical'},
    {'id': 'service', 'nameKey': 'category_service'},
    {'id': 'feedback', 'nameKey': 'category_feedback'},
    {'id': 'other', 'nameKey': 'category_other'},
  ];

  @override
  State<EditReportPage> createState() => _EditReportPageState();
}

class _EditReportPageState extends State<EditReportPage> {
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.report.title);
    _descriptionController = TextEditingController(
      text: widget.report.description,
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile != null && context.mounted) {
      context.read<EditReportCubit>().imageSelected(pickedFile.path);
    }
  }

  Future<void> _fetchLocation(BuildContext context) async {
    final status = await Permission.location.request();
    if (!status.isGranted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              LocaleKeys.device_capabilities_permission_denied_msg.tr(),
            ),
          ),
        );
      }
      return;
    }

    try {
      final locationService = LocationServiceImpl();
      final locationData = await locationService.getCurrentLocation();
      if (context.mounted) {
        context.read<EditReportCubit>().updateLocation(
          locationData.latitude,
          locationData.longitude,
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocaleKeys.location_fetched.tr())),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocaleKeys.device_capabilities_error_occurred.tr()),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.btn_edit.tr())),
      body: BlocProvider(
        create: (context) => EditReportCubit(
          repository: ReportRepositoryImpl(
            remoteDataSource: sharedFakeRemoteDataSource,
            localDataSource: LocalReportDataSourceImpl(),
          ),
        )..loadReport(widget.report),
        child: BlocConsumer<EditReportCubit, EditReportState>(
          listener: (context, state) {
            if (state.isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(LocaleKeys.report_updated_success.tr())),
              );
              Navigator.pop(context);
            }
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.errorMessage!.tr())));
            }
          },
          builder: (context, state) {
            final cubit = context.read<EditReportCubit>();

            return SingleChildScrollView(
              padding: REdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _titleController,
                    onChanged: cubit.titleChanged,
                    decoration: InputDecoration(
                      labelText: LocaleKeys.field_title.tr(),
                      errorText: state.title.isNotEmpty && !state.isTitleValid
                          ? LocaleKeys.error_title_invalid.tr()
                          : null,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: _descriptionController,
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
                  SizedBox(height: 16.h),
                  DropdownButtonFormField<String>(
                    value: state.categoryId,
                    hint: Text(LocaleKeys.field_category.tr()),
                    items: EditReportPage.categories.map((cat) {
                      return DropdownMenuItem<String>(
                        value: cat['id'],
                        child: Text(cat['nameKey']!.tr()),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) cubit.categoryChanged(val);
                    },
                  ),
                  SizedBox(height: 16.h),
                  DropdownButtonFormField<ReportPriorityEnum>(
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
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _pickImage(context, ImageSource.camera),
                          icon: Icon(Icons.camera_alt, size: 20.sp),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(LocaleKeys.btn_camera.tr()),
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () =>
                              _pickImage(context, ImageSource.gallery),
                          icon: Icon(Icons.photo_library, size: 20.sp),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(LocaleKeys.btn_gallery.tr()),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (state.imagePath != null) ...[
                    SizedBox(height: 12.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: Image.file(
                        File(state.imagePath!),
                        height: 150.h,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                  SizedBox(height: 16.h),
                  _buildLocationTile(context, state, cubit),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: state.isValid && !state.isSubmitting
                        ? () => cubit.updateReport()
                        : null,
                    child: state.isSubmitting
                        ? SizedBox(
                            height: 22.r,
                            width: 22.r,
                            child: const CircularProgressIndicator(),
                          )
                        : Text(LocaleKeys.btn_save.tr()),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLocationTile(
    BuildContext context,
    EditReportState state,
    EditReportCubit cubit,
  ) {
    return Container(
      padding: REdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            LocaleKeys.field_location.tr(),
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 8.h),
          if (state.latitude != null && state.longitude != null) ...[
            Text(
              'Lat: ${state.latitude!.toStringAsFixed(6)}, Lng: ${state.longitude!.toStringAsFixed(6)}',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 14.sp),
            ),
            SizedBox(height: 8.h),
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton.icon(
                onPressed: () {
                  cubit.locationCleared();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(LocaleKeys.location_cleared.tr())),
                  );
                },
                icon: Icon(Icons.clear, size: 16.sp),
                label: Text(LocaleKeys.cancel.tr()),
              ),
            ),
          ] else
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _fetchLocation(context),
                icon: Icon(Icons.my_location, size: 20.sp),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(LocaleKeys.btn_get_location.tr()),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
