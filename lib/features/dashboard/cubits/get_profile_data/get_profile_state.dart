import 'package:spora_app/features/dashboard/data/models/user_model.dart';

abstract class GetProfileState {}

class GetProfileInitialState extends GetProfileState {}

class GetProfileLoadingState extends GetProfileState {}

class EmptyProfileState extends GetProfileState {}

class GetProfileSuccessState extends GetProfileState {
  UserData userModel;
  GetProfileSuccessState({required this.userModel});
}

class GetProfileErrorState extends GetProfileState {
  String error;
  GetProfileErrorState({required this.error});
}
