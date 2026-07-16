abstract class UpdateProfileState {}

class UpdateProfileInitialState extends UpdateProfileState {}

class UpdateCompanyLoadingState extends UpdateProfileState {}

class UpdateProfileSuccessState extends UpdateProfileState {
  final String successMsg;
  UpdateProfileSuccessState(this.successMsg);
}

class UpdateProfileErrorState extends UpdateProfileState {
  final String errorMsg;
  UpdateProfileErrorState(this.errorMsg);
}

class UpdateProfileImagePicked extends UpdateProfileState {}
