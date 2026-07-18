import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:spora_app/core/helper/app_methods.dart';
import 'package:spora_app/core/helper/app_pop_up.dart';
import 'package:spora_app/core/shared/custom_button.dart';
import 'package:spora_app/core/shared/image_manager.dart';
import 'package:spora_app/core/theme/app_colors.dart';
import 'package:spora_app/features/dashboard/cubits/get_profile_data/get_profile_cubit.dart';
import 'package:spora_app/features/dashboard/cubits/get_profile_data/get_profile_state.dart';
import 'package:spora_app/features/dashboard/data/models/user_model.dart';
import 'package:spora_app/features/profile/cubit/profile_image/profile_image_cubit.dart';
import 'package:spora_app/features/profile/cubit/profile_image/profile_image_state.dart';
import 'package:spora_app/features/profile/view/update_profile_screen.dart';
import 'package:spora_app/generated/locale_keys.g.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => GetProfileCubit()..getProfileData()),
        BlocProvider(create: (context) => ProfileImageCubit()),
      ],
      child: Scaffold(
        appBar: AppBar(title: Text(LocaleKeys.profile_title.tr())),
        body: BlocConsumer<ProfileImageCubit, ProfileImageState>(
          listener: (context, imageState) {
            if (imageState is ProfileImageSuccess) {
              SnackBarPopUp().show(
                context: context,
                message: 'Profile image updated',
                state: PopUpState.success,
              );
              GetProfileCubit.get(context).getProfileData();
            } else if (imageState is ProfileImageFailure) {
              SnackBarPopUp().show(
                context: context,
                message: imageState.message,
                state: PopUpState.error,
              );
            }
          },
          builder: (context, imageState) {
            return BlocBuilder<GetProfileCubit, GetProfileState>(
              builder: (context, state) {
                if (state is GetProfileLoadingState ||
                    imageState is ProfileImageLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is GetProfileErrorState) {
                  return Center(
                    child: Padding(
                      padding: EdgeInsets.all(24.w),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(state.error, textAlign: TextAlign.center),
                          SizedBox(height: 16.h),
                          AppButton(
                            text: LocaleKeys.retry.tr(),
                            onPressed: () {
                              GetProfileCubit.get(context).getProfileData();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is GetProfileSuccessState) {
                  final user = state.userModel;
                  final imageCubit = ProfileImageCubit.get(context);

                  return SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: 20.w,
                      vertical: 10.h,
                    ),
                    child: Column(
                      children: [
                        ProfileHeaderWidget(
                          user: user,
                          localImage: imageCubit.imagePath,
                          onImageSelected: (file) {
                            imageCubit.selectImage(file);
                          },
                        ),
                        if (imageCubit.imagePath != null) ...[
                          SizedBox(height: 12.h),
                          AppButton(
                            text: 'Upload Image',
                            onPressed: () {
                              imageCubit.uploadSelectedImage();
                            },
                          ),
                        ],
                        if (user.avatarUrl.isNotEmpty) ...[
                          SizedBox(height: 8.h),
                          TextButton(
                            onPressed: () {
                              imageCubit.deleteProfileImage();
                            },
                            child: const Text(
                              'Delete Image',
                              style: TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                        SizedBox(height: 24.h),
                        ProfileStatusBadgeWidget(isActive: user.isActive),
                        SizedBox(height: 24.h),
                        ProfileInfoCardWidget(user: user),
                        SizedBox(height: 20.h),
                        AppButton(
                          text: LocaleKeys.profile_update_profile.tr(),
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    UpdateProfileView(user: user),
                              ),
                            );

                            if (result == true && context.mounted) {
                              GetProfileCubit.get(context).getProfileData();
                            }
                          },
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }
}

class ProfileInfoCardWidget extends StatelessWidget {
  const ProfileInfoCardWidget({super.key, required this.user});

  final UserData user;

  @override
  Widget build(BuildContext context) {
    final joinDate =
        "${user.createdAt.year}-${user.createdAt.month.toString().padLeft(2, '0')}-${user.createdAt.day.toString().padLeft(2, '0')}";

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      color: Theme.of(context).brightness == Brightness.dark
          ? AppColors.black
          : AppColors.white,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            ProfileInfoTileWidget(
              icon: Icons.person_outline,
              label: LocaleKeys.full_name.tr(),
              value: '${user.firstName} ${user.lastName}',
            ),
            const Divider(height: 20),
            ProfileInfoTileWidget(
              icon: Icons.phone_android_outlined,
              label: LocaleKeys.phone_number.tr(),
              value: user.mobile.isNotEmpty
                  ? user.mobile
                  : LocaleKeys.unknown.tr(),
            ),
            const Divider(height: 20),
            ProfileInfoTileWidget(
              icon: Icons.language,
              label: LocaleKeys.language.tr(),
              value: user.locale.toUpperCase(),
            ),
            const Divider(height: 20),
            ProfileInfoTileWidget(
              icon: Icons.public,
              label: LocaleKeys.timezone.tr(),
              value: user.timezone.isEmpty ? 'Asia' : user.timezone,
            ),
            const Divider(height: 20),
            ProfileInfoTileWidget(
              icon: Icons.calendar_today_outlined,
              label: LocaleKeys.join_date.tr(),
              value: joinDate,
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileInfoTileWidget extends StatelessWidget {
  const ProfileInfoTileWidget({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.r),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, color: Theme.of(context).primaryColor, size: 20.r),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ProfileStatusBadgeWidget extends StatelessWidget {
  const ProfileStatusBadgeWidget({super.key, required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isActive
            ? Colors.green.withOpacity(0.12)
            : Colors.red.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive ? Icons.check_circle : Icons.error,
            color: isActive ? Colors.green : Colors.red,
            size: 18.r,
          ),
          SizedBox(width: 8.w),
          Text(
            isActive
                ? LocaleKeys.profile_active_account.tr()
                : LocaleKeys.profile_unactive_account.tr(),
            style: TextStyle(
              color: isActive ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
        ],
      ),
    );
  }
}

class ProfileHeaderWidget extends StatelessWidget {
  const ProfileHeaderWidget({
    super.key,
    required this.user,
    required this.onImageSelected,
    this.localImage,
  });

  final UserData user;
  final XFile? localImage;
  final Function(XFile pickedImage) onImageSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: ImageManager(
            localImage: localImage,
            onImageSelected: onImageSelected,
            selectedImageBuilder: (file) {
              return CircleAvatar(
                radius: 50.r,
                backgroundImage: FileImage(File(file.path)),
              );
            },
            networkImageBuilder: user.avatarUrl.isNotEmpty
                ? CircleAvatar(
                    radius: 50.r,
                    backgroundImage: NetworkImage(user.avatarUrl),
                  )
                : null,
            unselectedImageBuilder: CircleAvatar(
              radius: 50.r,
              child: Text(
                AppMethods.getInitials(user),
                style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Tap to change photo',
          style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
        ),
        SizedBox(height: 16.h),
        Text(user.displayName),
        SizedBox(height: 6.h),
        Text(user.email),
      ],
    );
  }
}
