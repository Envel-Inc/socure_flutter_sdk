import Flutter
import UIKit
import SocureSdk

var flutterResult: FlutterResult!

public class SwiftSocureSdkPlugin: NSObject, FlutterPlugin {
  let docScanner = DocumentScanner()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "socure_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftSocureSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch (call.method) {
        case "initiatePassportScan":
            let vc = UIApplication.shared.delegate!.window!!.rootViewController!
            flutterResult = result;
            docScanner.initiatePassportScan(ImageCallback: vc, MRZCallback: vc)
        default:
            break
    }
  }
}

extension UIViewController: ImageCallback, MRZCallback {
    public func documentFrontCallBack(docScanResult: DocScanResult) {
        guard let imageData = docScanResult.imageData else { return }
        flutterResult(imageData)
    }

    public func documentBackCallBack(docScanResult: DocScanResult) {

    }

    public func selfieCallBack(selfieScanResult: SelfieScanResult) {

    }

    public func onScanCancelled() {

    }

    public func onError(errorType: SocureSDKErrorType, errorMessage: String) {

    }

    public func handleMRZData(mrzData: MrzData?) {

    }
}
