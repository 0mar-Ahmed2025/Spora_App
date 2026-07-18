abstract class ProfileImageState {}

class ProfileImageInitial extends ProfileImageState {}

class ProfileImageSelected extends ProfileImageState {}

class ProfileImageLoading extends ProfileImageState {}

class ProfileImageSuccess extends ProfileImageState {}

class ProfileImageFailure extends ProfileImageState {
  final String message;

  ProfileImageFailure(this.message);
}
