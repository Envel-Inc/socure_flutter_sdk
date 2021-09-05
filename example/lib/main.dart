import 'package:flutter/material.dart';
import 'package:socure_sdk/socure_sdk.dart';

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

  @override
  void initState() {
    super.initState();
  }

  initiatePassportScan() async {
    final res = await SocureSdk.initiatePassportScan();
    setState(() => _passportResult = res);
  }

  initiateLicenseScan() async {
    final res = await SocureSdk.initiateLicenseScan();
    setState(() => _licenseResult = res);
  }

  initiateSelfieScan() async {
    final res = await SocureSdk.initiateSelfieScan();
    setState(() => _selfieResult = res);
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
              _passportResult != null ? Image.memory(_passportResult!.passportImage!) : Text("No passport scanned"),
              Text(_passportResult?.mrzData?.fullName ?? "No passport name"),
              ElevatedButton(onPressed: () => initiatePassportScan(), child: Text("Scan passport")),

              _licenseResult != null ? Image.memory(_licenseResult!.licenseFrontImage!) : Text("No license scanned"),
              _licenseResult != null ? Image.memory(_licenseResult!.licenseBackImage!) : Text("No license scanned"),
              Text(_licenseResult?.mrzData?.fullName ?? "No passport name"),
              ElevatedButton(onPressed: () => initiateLicenseScan(), child: Text("Scan license")),

              _selfieResult != null ? Image.memory(_selfieResult!.selfieImage!) : Text("No selfie scanned"),
              Text(_selfieResult?.mrzData?.fullName ?? "No selfie name"),
              ElevatedButton(onPressed: () => initiateSelfieScan(), child: Text("Scan selfie")),
            ],
          ),
        ),
      ),
    );
  }
}
