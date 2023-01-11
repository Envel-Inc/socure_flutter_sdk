import 'dart:typed_data';

import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'socure_flutter_sdk_method_channel.dart';

abstract class SocureFlutterSdkPlatform extends PlatformInterface {
  /// Constructs a SocureFlutterSdkPlatform.
  SocureFlutterSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static SocureFlutterSdkPlatform _instance = MethodChannelSocureFlutterSdk();

  /// The default instance of [SocureFlutterSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelSocureFlutterSdk].
  static SocureFlutterSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [SocureFlutterSdkPlatform] when
  /// they register themselves.
  static set instance(SocureFlutterSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  /// Initiates a passport scan. The [passportImage] of the ScanResult will be populated with the image.
  /// If the user cancels the flow, then a [CancelledException] will be thrown.
  ///
  /// On Web, this is not implemented.
  Future<ScanResult> initiatePassportScan();

  /// Initiates an ID / driver's licence scan. The [licenseFrontImage] and [licenseBackImage] of the ScanResult will be populated with the image.
  /// If the user cancels the flow, then a [CancelledException] will be thrown.
  ///
  /// On Web, this is not implemented.
  Future<ScanResult> initiateLicenseScan();

  /// Initiates a selfie scan. The [selfieImage] of the ScanResult will be populated with the image.
  /// If the user cancels the flow, then a [CancelledException] will be thrown.
  ///
  /// On Web, this is not implemented.
  Future<ScanResult> initiateSelfieScan();

  Future<UploadedDocument> initiateAndUploadDocumentScanAndSelfie(ScanDocumentType documentType);
  
  /// Only works on iOS and Android.
  Future<UploadedDocument> uploadPassport(Uint8List front, Uint8List? selfie);

  /// Only works on iOS and Android.
  Future<UploadedDocument> uploadLicense(Uint8List front, Uint8List? back, Uint8List? selfie);
  
  Future<void> setTracker();

  Future<String?> getDeviceSessionId();
}

class ScanResult {
  final String documentType;
  final Uint8List? passportImage;
  final Uint8List? licenseBackImage;
  final Uint8List? licenseFrontImage;
  final Uint8List? selfieImage;
  final MrzData? mrzData;
  final BarcodeData? barcodeData;
  final bool autoCaptured;
  
  const ScanResult(this.documentType, this.passportImage, this.licenseBackImage, this.licenseFrontImage, this.selfieImage, this.mrzData, this.barcodeData, this.autoCaptured);
  
  factory ScanResult.fromJson(Map<dynamic, dynamic> json) {
    return ScanResult(json["documentType"], json["passportImage"], json["licenseBackImage"], json["licenseFrontImage"], json["selfieImage"], json["mrzData"] != null ? MrzData.fromJson(json["mrzData"]) : null, json["barcodeData"] != null ? BarcodeData.fromJson(json["barcodeData"]) : null, json["autoCaptured"] == true);
  }
}

enum ScanDocumentType {
  PASSPORT, DRIVERS_LICENSE
}

class UploadedDocument {
  final String? documentType;
  final String? referenceId;
  final String? uuid;

  const UploadedDocument(this.documentType, this.referenceId, this.uuid);

  factory UploadedDocument.fromJson(Map<dynamic, dynamic> json) => UploadedDocument(json["documentType"], json["referenceId"], json["uuid"]);
}

class MrzData {
  final String? documentNumber;
  final String? fullName;
  final String? firstName;
  final String? surName;
  final String? nationality;
  final String? issuingCountry;
  final String? expirationDate;
  final String? sex;
  final String? city;
  final String? state;
  final String? address;
  final String? postalCode;
  final String? phone;
  
  const MrzData(this.documentNumber, this.fullName, this.firstName, this.surName, this.nationality, this.issuingCountry, this.expirationDate, this.sex, this.city, this.state, this.address, this.postalCode, this.phone);
  
  factory MrzData.fromJson(Map<dynamic, dynamic> json) {
    return MrzData(
        json["documentNumber"], json["fullName"], json["firstName"], json["surName"], json["nationality"], json["issuingCountry"], json["expirationDate"], json["sex"], json["city"], json["state"], json["address"], json["postalCode"], json["phone"]);
  }
}

class BarcodeData {
  final String? documentNumber;
  final String? fullName;
  final String? firstName;
  final String? surName;
  final String? city;
  final String? state;
  final String? address;
  final String? postalCode;
  final String? phone;
  final String? dob;
  final String? issueDate;
  final String? expirationDate;
  
  const BarcodeData(this.documentNumber, this.fullName, this.firstName, this.surName, this.city, this.state, this.address, this.postalCode, this.phone, this.dob, this.issueDate, this.expirationDate);
  
  factory BarcodeData.fromJson(Map<dynamic, dynamic> json) {
    return BarcodeData(
        json["documentNumber"], json["fullName"], json["firstName"], json["surName"], json["city"], json["state"], json["address"], json["postalCode"], json["phone"], json["dob"], json["issueDate"], json["expirationDate"]);
  }
}

class CancelledException implements Exception {}