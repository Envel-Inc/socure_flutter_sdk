import 'dart:async';

import 'package:flutter/services.dart';

class SocureSdk {
  static const MethodChannel _channel = const MethodChannel('socure_sdk');

  static Future initiatePassportScan() async {
    await _channel.invokeMethod("initiatePassportScan");
  }
}
