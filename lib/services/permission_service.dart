import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  Future<bool> requestMusicPermission() async {
    Permission permission;

    if (Platform.isAndroid) {
      if (await _isAndroid13OrAbove()) {
        permission = Permission.audio;
      } else {
        permission = Permission.storage;
      }
    } else {
      return true;
    }

    final status = await permission.status;

    if (status.isGranted) return true;

    final result = await permission.request();

    if (result.isPermanentlyDenied) {
      await openAppSettings();
      return false;
    }

    return result.isGranted;
  }

  Future<bool> _isAndroid13OrAbove() async {
    return (await Permission.audio.status) != PermissionStatus.denied;
  }
}
