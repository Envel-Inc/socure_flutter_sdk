import Flutter
import UIKit
import SocureSdk

var flutterResult: FlutterResult?
var frontPicture: Data?
var onlyNeedFrontPicture: Bool = false

public class SwiftSocureSdkPlugin: NSObject, FlutterPlugin {
  let docScanner = DocumentScanner()
  let selfieScanner = SelfieScanner()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "socure_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftSocureSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let vc = UIApplication.shared.delegate!.window!!.rootViewController!
    flutterResult = result;

    switch (call.method) {
        case "initiatePassportScan":
            onlyNeedFrontPicture = true
            docScanner.initiatePassportScan(ImageCallback: vc, MRZCallback: vc)
            break
        case "initiateLicenseScan":
            onlyNeedFrontPicture = false
            docScanner.initiateLicenseScan(ImageCallback: vc, BarcodeCallback: vc, MRZCallback: vc)
            break
        case "initiateSelfieScan":
            onlyNeedFrontPicture = true
            selfieScanner.initiateSelfieScan(ImageCallback: vc)
            break
        default:
            break
    }
  }
}

extension UIViewController: ImageCallback, MRZCallback, BarcodeCallback {
    private func sendFlutterResult(documentType: String, frontPicture: Data?, backPicture: Data?, passportPicture: Data?, selfiePicture: Data?, autoCaptured: Bool) {
        let front = frontPicture != nil ? FlutterStandardTypedData.init(bytes: frontPicture!) : nil
        let back = backPicture != nil ? FlutterStandardTypedData.init(bytes: backPicture!) : nil
        let selfie = selfiePicture != nil ? FlutterStandardTypedData.init(bytes: selfiePicture!) : nil
        let passport = passportPicture != nil ? FlutterStandardTypedData.init(bytes: passportPicture!) : nil
        
        
        let map: [String: Any?] = ["documentType": documentType, "passportImage": passport, "licenseFrontImage": front, "licenseBackImage": back, "selfieImage": selfie, "autoCaptured": autoCaptured ]
        
        self.dismiss(animated: true, completion: nil)
        flutterResult?(map)
    }
    
    public func documentFrontCallBack(docScanResult: DocScanResult) {
        frontPicture = docScanResult.imageData
        if (onlyNeedFrontPicture) {
            let autoCaptured: Bool = (docScanResult.metaData["autoCaptured"] as? Bool) == true;
            
            sendFlutterResult(documentType: "PASSPORT", frontPicture: nil, backPicture: nil, passportPicture: frontPicture, selfiePicture: nil, autoCaptured: autoCaptured)
        }
    }

    public func documentBackCallBack(docScanResult: DocScanResult) {
        let autoCaptured: Bool = (docScanResult.metaData["autoCaptured"] as? Bool) == true;
        
        sendFlutterResult(documentType: "LICENSE", frontPicture: frontPicture, backPicture: docScanResult.imageData, passportPicture: nil, selfiePicture: nil, autoCaptured: autoCaptured)
    }

    public func selfieCallBack(selfieScanResult: SelfieScanResult) {
        let autoCaptured: Bool = (selfieScanResult.metaData["autoCaptured"] as? Bool) == true;
        
        sendFlutterResult(documentType: "SELFIE", frontPicture: nil, backPicture: nil, passportPicture: nil, selfiePicture: selfieScanResult.imageData, autoCaptured: autoCaptured)
    }

    public func onScanCancelled() {
        self.dismiss(animated: true, completion: nil)
        flutterResult?(nil)
    }

    public func onError(errorType: SocureSDKErrorType, errorMessage: String) {
        self.dismiss(animated: true, completion: nil)
        flutterResult?(FlutterError.init(code: "-1", message: errorMessage, details: nil))
    }

    public func handleMRZData(mrzData: MrzData?) {

    }

    public func handleBarcodeData(barcodeData: BarcodeData?) {

    }
}
