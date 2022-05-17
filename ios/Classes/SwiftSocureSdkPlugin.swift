import Flutter
import UIKit
import SocureSdk
import DeviceRisk

public class SwiftSocureSdkPlugin: NSObject, FlutterPlugin, DeviceRiskUploadCallback {
  let docScanner = DocumentScanner()
  let selfieScanner = SelfieScanner()
  let deviceRiskManager = DeviceRiskManager.sharedInstance
  var flutterResult: FlutterResult?

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "socure_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftSocureSdkPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

    public func dataUploadFinished(uploadResult: DeviceRiskUploadResult) {
        if let uuid = uploadResult.uuid {
            flutterResult?(uuid)
        } else {
            flutterResult?(FlutterError.init(code: "-2", message: "Failed to obtain Socure session ID", details: nil))
        }

        flutterResult = nil
    }

    public func onError(errorType: DeviceRiskErrorType, errorMessage: String) {
        flutterResult?(FlutterError.init(code: "-1", message: errorMessage, details: nil))
        flutterResult = nil
    }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let rootVc = UIApplication.shared.delegate!.window!!.rootViewController!

    switch (call.method) {
        case "initiatePassportScan":
            let socureVc = SocureViewController()
            socureVc.onlyNeedFrontPicture = true
            socureVc.flutterResult = result
            socureVc.modalPresentationStyle = .fullScreen
            rootVc.present(socureVc, animated: false, completion: nil)
            docScanner.initiatePassportScan(ImageCallback: socureVc, MRZCallback: socureVc)
            break
        case "initiateLicenseScan":
            let socureVc = SocureViewController()
            socureVc.onlyNeedFrontPicture = false
            socureVc.flutterResult = result
            socureVc.modalPresentationStyle = .fullScreen
            rootVc.present(socureVc, animated: false, completion: nil)
            docScanner.initiateLicenseScan(ImageCallback: socureVc, BarcodeCallback: socureVc, MRZCallback: socureVc)
            break
        case "initiateSelfieScan":
            let socureVc = SocureViewController()
            socureVc.onlyNeedFrontPicture = true
            socureVc.flutterResult = result
            socureVc.modalPresentationStyle = .fullScreen
            rootVc.present(socureVc, animated: false, completion: nil)
            selfieScanner.initiateSelfieScan(ImageCallback: socureVc)
            break
        case "getDeviceSessionId":
            flutterResult = result
            deviceRiskManager.delegate = self
            deviceRiskManager.sendData(context: .signup)
            break
        case "setTracker":
            if let args = call.arguments as? [String] {
                deviceRiskManager.setTracker(key: args[0], sources: [.device, .locale, .accessibility, .network, .location], existingUUID: deviceRiskManager.uuid, userConsent: true)
                
                result(nil)
            } else {
                result(FlutterError.init(code: "-1", message: "API key must be specified.", details: nil))
            }

            break
        default:
            break
    }
  }
}

class SocureViewController: UIViewController, ImageCallback, MRZCallback, BarcodeCallback {
    var flutterResult: FlutterResult?
    var onlyNeedFrontPicture: Bool = false
    
    var frontPicture: Data?
    var mrz: MrzData?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private func sendFlutterResult(documentType: String, frontPicture: Data?, backPicture: Data?, passportPicture: Data?, selfiePicture: Data?, autoCaptured: Bool) {
        let front = frontPicture != nil ? FlutterStandardTypedData.init(bytes: frontPicture!) : nil
        let back = backPicture != nil ? FlutterStandardTypedData.init(bytes: backPicture!) : nil
        let selfie = selfiePicture != nil ? FlutterStandardTypedData.init(bytes: selfiePicture!) : nil
        let passport = passportPicture != nil ? FlutterStandardTypedData.init(bytes: passportPicture!) : nil
        
        var map: [String: Any?] = ["documentType": documentType, "passportImage": passport, "licenseFrontImage": front, "licenseBackImage": back, "selfieImage": selfie, "autoCaptured": autoCaptured ]
        
        if (mrz != nil) {
            let mrzDataMap: [String: String?] = [
                "documentNumber": mrz!.documentNumber,
                "fullName": mrz!.fullName,
                "firstName": mrz!.firstName,
                "surName": mrz!.surName,
                "nationality": mrz!.nationality,
                "issuingCountry": mrz!.issuingCountry,
                "sex": mrz!.sex,
                "expirationDate": mrz!.expirationDate,
                "dob": mrz!.dob,
            ]
            
            map["mrzData"] = mrzDataMap
        }
        
        self.dismiss(animated: false, completion: nil)
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
        flutterResult = nil
    }

    public func onError(errorType: SocureSDKErrorType, errorMessage: String) {
        self.dismiss(animated: true, completion: nil)
        flutterResult?(FlutterError.init(code: "-1", message: errorMessage, details: nil))
        flutterResult = nil
    }

    public func handleMRZData(mrzData: MrzData?) {
        mrz = mrzData
    }

    public func handleBarcodeData(barcodeData: BarcodeData?) {

    }
}
