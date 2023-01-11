import 'package:flutter/material.dart';
import 'package:socure_flutter_sdk/socure_flutter_sdk.dart';
import 'package:socure_flutter_sdk/socure_flutter_sdk_platform_interface.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ScanResult? _passportResult;
  ScanResult? _licenseResult;
  ScanResult? _selfieResult;
  String? deviceSessionId;
  UploadedDocument? _uploadResult;

  @override
  void initState() {
    super.initState();
  }

  initiatePassportScan() async {
    final res = await SocureFlutterSdk.instance.initiatePassportScan();
    setState(() => _passportResult = res);
  }

  initiateLicenseScan() async {
    final res = await SocureFlutterSdk.instance.initiateLicenseScan();
    setState(() => _licenseResult = res);
  }

  initiateSelfieScan() async {
    final res = await SocureFlutterSdk.instance.initiateSelfieScan();
    setState(() => _selfieResult = res);
  }

  initiateAndUploadDocumentScanAndSelfie() async {
    final res = await SocureFlutterSdk.instance.initiateAndUploadDocumentScanAndSelfie(ScanDocumentType.PASSPORT);
    setState(() => _uploadResult = res);
  }
  
  getDeviceSessionId() async {
    final deviceSessionId = await SocureFlutterSdk.instance.getDeviceSessionId();
    setState(() => this.deviceSessionId = deviceSessionId);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: ListView(
            children: [
              ElevatedButton(onPressed: () => getDeviceSessionId(), child: Text("Get Device Session ID")),
              Text(deviceSessionId ?? "No device session ID"),
              
              _passportResult != null ? Image.memory(_passportResult!.passportImage!) : Text("No passport scanned"),
              Text(_passportResult?.mrzData?.fullName ?? "No passport name"),
              ElevatedButton(onPressed: () => initiatePassportScan(), child: Text("Scan passport")),

              _licenseResult?.licenseFrontImage != null ? Image.memory(_licenseResult!.licenseFrontImage!) : Text("No license scanned"),
              _licenseResult?.licenseBackImage != null ? Image.memory(_licenseResult!.licenseBackImage!) : Text("No license scanned"),
              Text(_licenseResult?.mrzData?.fullName ?? "No passport name"),
              ElevatedButton(onPressed: () => initiateLicenseScan(), child: Text("Scan license")),

              _selfieResult?.selfieImage != null ? Image.memory(_selfieResult!.selfieImage!) : Text("No selfie scanned"),
              Text(_selfieResult?.mrzData?.fullName ?? "No selfie name"),
              ElevatedButton(onPressed: () => initiateSelfieScan(), child: Text("Scan selfie")),
  
  
              _uploadResult?.referenceId != null ? Text(_uploadResult!.referenceId!) : Text("No reference ID"),
              _uploadResult?.uuid != null ? Text(_uploadResult!.uuid!) : Text("No document UUID"),
              ElevatedButton(onPressed: () => initiateAndUploadDocumentScanAndSelfie(), child: Text("Scan passport and selfie and upload")),
            ],
          ),
        ),
      ),
    );
  }
}
