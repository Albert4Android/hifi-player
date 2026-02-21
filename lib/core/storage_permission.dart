import 'package:permission_handler/permission_handler.dart';

class StoragePermission {
  static Future<bool> requestAudio() async {
    final status = await Permission.audio.request();
    return status.isGranted;
  }
}
