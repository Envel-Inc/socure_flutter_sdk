import Flutter
import UIKit
import SocureSdk

var flutterResult: FlutterResult!
var firstPic: Data?
var secondPic: Data?
var selfiePic: Data?

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
        firstPic = docScanResult.imageData
    }

    public func documentBackCallBack(docScanResult: DocScanResult) {
        secondPic = docScanResult.imageData
    }

    public func selfieCallBack(selfieScanResult: SelfieScanResult) {
        selfiePic = selfieScanResult.imageData
                /* guard let imageData = docScanResult.imageData else { return } */

        let front = FlutterStandardTypedData.init(bytes: firstPic!)
        let back = FlutterStandardTypedData.init(bytes: secondPic!)
        let selfie = FlutterStandardTypedData.init(bytes: selfiePic!)
        flutterResult(FlutterStandardTypedData.init(bytes: firstPic!))
    }

    public func onScanCancelled() {
        flutterResult(nil)
    }

    public func onError(errorType: SocureSDKErrorType, errorMessage: String) {
      //  flutterResult(FlutterError(errorMessage))
    }

    public func handleMRZData(mrzData: MrzData?) {

    }
}
