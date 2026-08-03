// ignore_for_file: deprecated_member_use

import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.create_report_title.tr())),
      body: BlocProvider(
        create: (context) => CreateReportCubit(
          repository: ReportRepositoryImpl(
            localDataSource: LocalReportDataSourceImpl(),
            remoteDataSource: FakeReportRemoteDataSourceImpl(),
          ),
        ),
        child: BlocConsumer<CreateReportCubit, CreateReportState>(
          listener: (context, state) {
            if (state.isSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(LocaleKeys.report_saved_success.tr())),
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
                  DropdownButtonFormField<String>(
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
                  const SizedBox(height: 16),
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
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: state.isValid && !state.isSubmitting
                        ? () => cubit.submitReport()
                        : null,
                    child: state.isSubmitting
                        ? const CircularProgressIndicator()
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
}
