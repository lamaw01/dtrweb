import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionProvider with ChangeNotifier {
  var _version = '';
  String get version => _version;

  // get device version
  Future<void> getPackageInfo() async {
    try {
      await PackageInfo.fromPlatform().then((result) {
        _version = result.version;
        debugPrint('_appVersion $_version');
      });
      notifyListeners();
    } catch (e) {
      debugPrint('getPackageInfo $e');
      // errorString.value = e.toString();
    }
  }
}
