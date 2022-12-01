// In order to *not* need this ignore, consider extracting the "web" version
// of your plugin as a separate package, instead of inlining it in the same
// package as the core of your plugin.
// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:html' as html show window;
import 'dart:js';
import 'dart:js_util';

import 'package:flutter/foundation.dart';
import 'package:flutter_web_plugins/flutter_web_plugins.dart';
import 'package:socure_flutter_sdk/socure_js.dart';

import 'socure_flutter_sdk_platform_interface.dart';

/// A web implementation of the SocureFlutterSdkPlatform of the SocureFlutterSdk plugin.
class SocureFlutterSdkWeb extends SocureFlutterSdkPlatform {
  final Devicer devicer;
  SocureDocV? socureDocV;

  /// Constructs a SocureFlutterSdkWeb
  SocureFlutterSdkWeb() : devicer = (html.window as JSWindow).devicer;

  static void registerWith(Registrar registrar) {
    SocureFlutterSdkPlatform.instance = SocureFlutterSdkWeb();
  }

  @override
  Future<String?> getDeviceSessionId() async {
    final Completer<String?> completer = Completer();

    devicer.run(SocureFPOptions(publicKey: (html.window as JSWindow).socurePublicKey, userConsent: true, context: 'signup'), allowInterop((response) {
      if (response.result == "Captured")
        completer.complete(response.sessionId);
      else
        completer.completeError(Exception("Socure error"));
    }));

    return completer.future;
  }

  @override
  Future<ScanResult> initiateLicenseScan() => _initiateScan();

  @override
  Future<ScanResult> initiatePassportScan() => _initiateScan();

  @override
  Future<ScanResult> initiateSelfieScan() => _initiateScan();

  Future<ScanResult> _initiateScan() async {
    final Completer<ScanResult> completer = Completer();

    await _initSocureDocv(onSuccess: (successResponse) {
      print("onSuccess");
      completer.complete(ScanResult(successResponse.verifyResult!.documentVerification.documentType.type, null, null, null, null, null, null, false,
          successResponse.referenceId));
    }, onError: (errorResponse) {
      print("onError");
      completer.completeError(Exception("Scan failed"));
    }, onProgress: (progress) {
      print("onProgress");
    });

    socureDocV?.start(2, null);

    return completer.future;
  }

  _initSocureDocv({required Function(SocureDocResponse) onSuccess, required Function(SocureDocResponse) onError, required Function(String) onProgress}) async {
    final socurePublicKey = (html.window as JSWindow).socurePublicKey;

    if (socureDocV == null) {
      socureDocV = (await promiseToFuture(initSocureDocV(socurePublicKey))) as SocureDocV;
    }

    html.window.document.getElementById("socureDiv")?.style.display = "block";

    await promiseToFuture(socureDocV!.init(
        socurePublicKey,
        "#socureDiv",
        SocureDocVConfig(
            qrCodeNeeded: true,
            onSuccess: allowInterop((r) {
              socureReset();
              html.window.document.getElementById("socureDiv")?.style.display = "none";
              onSuccess(r);
            }),
            onError: allowInterop((r) {
              socureReset();
              html.window.document.getElementById("socureDiv")?.style.display = "none";
              onError(r);
            }),
            onProgress: allowInterop(onProgress))));
  }

  @override
  Future<void> setTracker() async {}
}
