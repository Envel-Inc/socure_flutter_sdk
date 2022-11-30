
import 'socure_flutter_sdk_platform_interface.dart';

class SocureFlutterSdk {
  /// private constructor to not allow the object creation from outside.
  SocureFlutterSdk._();
  
  static final SocureFlutterSdk _instance = SocureFlutterSdk._();
  
  /// get the instance of the [SocureFlutterSdk].
  static SocureFlutterSdk get instance => _instance;
  
  /// Initiates a passport scan. The [passportImage] of the ScanResult will be populated with the image.
  /// If the user cancels the flow, then a [CancelledException] will be thrown.
  Future<ScanResult> initiatePassportScan() => SocureFlutterSdkPlatform.instance.initiatePassportScan();
  
  /// Initiates an ID / driver's licence scan. The [licenseFrontImage] and [licenseBackImage] of the ScanResult will be populated with the image.
  /// If the user cancels the flow, then a [CancelledException] will be thrown.
  Future<ScanResult> initiateLicenseScan() => SocureFlutterSdkPlatform.instance.initiateLicenseScan();

  /// Initiates a selfie scan. The [selfieImage] of the ScanResult will be populated with the image.
  /// If the user cancels the flow, then a [CancelledException] will be thrown.
  Future<ScanResult> initiateSelfieScan() => SocureFlutterSdkPlatform.instance.initiateSelfieScan();
  
  Future<void> setTracker() => SocureFlutterSdkPlatform.instance.setTracker();
  
  Future<String?> getDeviceSessionId() => SocureFlutterSdkPlatform.instance.getDeviceSessionId();
}