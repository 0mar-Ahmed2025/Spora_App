// ignore_for_file: deprecated_member_use

import 'package:geolocator/geolocator.dart';
import '../models/location_data_model.dart';

abstract class LocationService {
  Future<bool> isLocationServiceEnabled();
  Future<LocationDataModel> getCurrentLocation();
}

class LocationServiceImpl implements LocationService {
  @override
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<LocationDataModel> getCurrentLocation() async {
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
      timeLimit: const Duration(seconds: 15),
    );

    return LocationDataModel(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      retrievalTime: DateTime.now(),
    );
  }
}