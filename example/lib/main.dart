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
  ScanResult? result;

  @override
  void initState() {
    super.initState();
    initiatePassportScan();
  }

  initiatePassportScan() async {
    final res = await SocureSdk.initiatePassportScan();
    setState(() => result = res);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Column(
            children: [
              result != null ? Image.memory(result!.passportImage!) : Text("No image yet"),
              Text(result?.mrzData?.fullName ?? "No name"),
            ],
          ),
        ),
      ),
    );
  }
}
