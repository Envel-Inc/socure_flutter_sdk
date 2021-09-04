import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';

class SocureSdk {
  static const MethodChannel _channel = const MethodChannel('socure_sdk');

  /// Initiates a passport scan. The [passportImage] of the ScanResult will be populated with the image.
  /// If the user cancels the flow, then a [CancelledException] will be thrown.
  static Future<ScanResult> initiatePassportScan() async {
    final resultMap = await _channel.invokeMapMethod<String, dynamic>("initiatePassportScan");
    if (resultMap == null) throw CancelledException();

    return ScanResult.fromJson(resultMap);
  }

  /// Initiates an ID / driver's licence scan. The [licenseFrontImage] and [licenseBackImage] of the ScanResult will be populated with the image.
  /// If the user cancels the flow, then a [CancelledException] will be thrown.
  static Future<ScanResult> initiateLicenseScan() async {
    final resultMap = await _channel.invokeMapMethod<String, dynamic>("initiateLicenseScan");
    if (resultMap == null) throw CancelledException();

    return ScanResult.fromJson(resultMap);
  }

  /// Initiates a selfie scan. The [selfieImage] of the ScanResult will be populated with the image.
  /// If the user cancels the flow, then a [CancelledException] will be thrown.
  static Future<ScanResult> initiateSelfieScan() async {
    final resultMap = await _channel.invokeMapMethod<String, dynamic>("initiateSelfieScan");
    if (resultMap == null) throw CancelledException();

    return ScanResult.fromJson(resultMap);
  }
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

class CancelledException implements Exception {
}
