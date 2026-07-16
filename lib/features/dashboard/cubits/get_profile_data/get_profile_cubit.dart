// ignore_for_file: strict_top_level_inference

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:spora_app/features/dashboard/cubits/get_profile_data/get_profile_state.dart';
import 'package:spora_app/features/dashboard/data/repos/dashboard_repo.dart';

class GetProfileCubit extends Cubit<GetProfileState> {
  GetProfileCubit() : super(GetProfileInitialState());
  static GetProfileCubit get(context) => BlocProvider.of(context);

  void getProfileData() async {
    emit(GetProfileLoadingState());
    DashboardRepo repo = DashboardRepo();
    var result = await repo.getProfile();
    result.fold(
      (error) => emit(GetProfileErrorState(error: error)),
      (userModel) => emit(
  
            GetProfileSuccessState(userModel: userModel),
      ),
    );
  }
}
