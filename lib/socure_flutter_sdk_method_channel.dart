import 'dart:typed_data';

import 'package:flutter/services.dart';

import 'socure_flutter_sdk_platform_interface.dart';

/// An implementation of [SocureFlutterSdkPlatform] that uses method channels.
class MethodChannelSocureFlutterSdk extends SocureFlutterSdkPlatform {
  /// The method channel used to interact with the native platform.
  final _channel = const MethodChannel('socure_sdk');

  /// Initiates a passport scan. The [passportImage] of the ScanResult will be populated with the image.
  /// If the user cancels the flow, then a [CancelledException] will be thrown.
  @override
  Future<ScanResult> initiatePassportScan() async {
    final resultMap = await _channel.invokeMapMethod<String, dynamic>("initiatePassportScan");
    if (resultMap == null) throw CancelledException();

    return ScanResult.fromJson(resultMap);
  }

  /// Initiates an ID / driver's licence scan. The [licenseFrontImage] and [licenseBackImage] of the ScanResult will be populated with the image.
  /// If the user cancels the flow, then a [CancelledException] will be thrown.
  @override
  Future<ScanResult> initiateLicenseScan() async {
    final resultMap = await _channel.invokeMapMethod<String, dynamic>("initiateLicenseScan");
    if (resultMap == null) throw CancelledException();

    return ScanResult.fromJson(resultMap);
  }

  /// Initiates a selfie scan. The [selfieImage] of the ScanResult will be populated with the image.
  /// If the user cancels the flow, then a [CancelledException] will be thrown.
  @override
  Future<ScanResult> initiateSelfieScan() async {
    final resultMap = await _channel.invokeMapMethod<String, dynamic>("initiateSelfieScan");
    if (resultMap == null) throw CancelledException();

    return ScanResult.fromJson(resultMap);
  }

  @override
  Future<void> setTracker() async {
    await _channel.invokeMethod("setTracker");
  }

  @override
  Future<String?> getDeviceSessionId() async {
    final sessionId = await _channel.invokeMethod<String?>("getDeviceSessionId");
    return sessionId;
  }

  @override
  Future<UploadedDocument> uploadLicense(Uint8List front, Uint8List? back, Uint8List? selfie) async {
    final resultMap = await _channel.invokeMapMethod<String, dynamic>("uploadLicense", {"front": front, "back": back, "selfie": selfie});
    if (resultMap == null) throw CancelledException();

    return UploadedDocument.fromJson(resultMap);
  }

  @override
  Future<UploadedDocument> uploadPassport(Uint8List front, Uint8List? selfie) async {
    final resultMap = await _channel.invokeMapMethod<String, dynamic>("uploadPassport", {"front": front, "selfie": selfie});
    if (resultMap == null) throw CancelledException();
  
    return UploadedDocument.fromJson(resultMap);
  }

  @override
  Future<UploadedDocument> initiateAndUploadDocumentScanAndSelfie(ScanDocumentType documentType) async {
    final ScanResult result;
    if (documentType == ScanDocumentType.DRIVERS_LICENSE) {
      result = await initiateLicenseScan();
    } else {
      result = await initiatePassportScan();
    }

    final selfie = await initiateSelfieScan();

    if (documentType == ScanDocumentType.DRIVERS_LICENSE) {
      return await uploadLicense(result.licenseFrontImage!, result.licenseBackImage, selfie.selfieImage);
    } else {
      return await uploadPassport(result.passportImage!, selfie.selfieImage);
    }
  }
}