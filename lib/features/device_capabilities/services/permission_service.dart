import 'package:permission_handler/permission_handler.dart';

abstract class PermissionService {
  Future<PermissionStatus> checkPermission(Permission permission);
  Future<PermissionStatus> requestPermission(Permission permission);
  Future<bool> openSettings();
}

class PermissionServiceImpl implements PermissionService {
  @override
  Future<PermissionStatus> checkPermission(Permission permission) async {
    return await permission.status;
  }

  @override
  Future<PermissionStatus> requestPermission(Permission permission) async {
    return await permission.request();
  }

  @override
  Future<bool> openSettings() async {
    return await openAppSettings();
  }
}
