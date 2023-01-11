import Flutter
import UIKit
import SocureSdk
import DeviceRisk

public class SwiftSocureFlutterSdkPlugin: NSObject, FlutterPlugin, DeviceRiskUploadCallback, UploadCallback {
  let docScanner = DocumentScanner()
  let selfieScanner = SelfieScanner()
  let deviceRiskManager = DeviceRiskManager.sharedInstance
  var flutterResult: FlutterResult?
  var imageUploader = ImageUploader.init()

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "socure_sdk", binaryMessenger: registrar.messenger())
    let instance = SwiftSocureFlutterSdkPlugin()
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
    
    public func documentUploadFinished(uploadResult: SocureSdk.UploadResult) {
        let map: [String: Any?] = ["referenceId": uploadResult.referenceId, "uuid": uploadResult.uuid]
        flutterResult?(map)
        flutterResult = nil
    }

    public func onUploadError(errorType: SocureSdk.SocureSDKErrorType, errorMessage: String) {
        flutterResult?(FlutterError.init(code: "-2", message: errorMessage, details: nil))
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
            deviceRiskManager.setTracker(key: Bundle.main.object(forInfoDictionaryKey: "socurePublicKey") as! String, sources: [.device, .locale, .accessibility, .network, .location], existingUUID: deviceRiskManager.uuid, userConsent: true)
            result(nil)
            break
        case "uploadLicense":
            let args: [String: Any?] = call.arguments as! [String : Any?]
            let front = args["front"] as! FlutterStandardTypedData
            let back = args["back"] as! FlutterStandardTypedData
            let selfie = args["selfie"] as? FlutterStandardTypedData
        
            flutterResult = result
        
            if (selfie == nil) {
                imageUploader.uploadLicense(UploadCallback: self, front: front.data, back: back.data)
            } else {
                imageUploader.uploadLicense(UploadCallback: self, front: front.data, back: back.data, selfie: selfie!.data)
            }
        
            break
        case "uploadPassport":
            let args: [String: Any?] = call.arguments as! [String : Any?]
            let front = args["front"] as! FlutterStandardTypedData
            let selfie = args["selfie"] as? FlutterStandardTypedData
        
            flutterResult = result
        
            if (selfie == nil) {
                imageUploader.uploadPassport(UploadCallback: self, front: front.data)
            } else {
                imageUploader.uploadPassport(UploadCallback: self, front: front.data, selfie: selfie!.data)
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
    
    
    var frontDocScanResult: DocScanResult?
    var backDocScanResult: DocScanResult?
    var selfieDocScanResult: SelfieScanResult?
    var mrz: MrzData?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private func sendFlutterResult(documentType: String? = nil) {
        let docType = documentType ?? (onlyNeedFrontPicture ? "PASSPORT": "LICENSE")
        
        let licenseFront = (docType != "LICENSE" ? nil : (frontDocScanResult != nil ? FlutterStandardTypedData.init(bytes: frontDocScanResult!.imageData!) : nil))
        let licenseBack = (docType != "LICENSE" ? nil : (backDocScanResult != nil ? FlutterStandardTypedData.init(bytes: backDocScanResult!.imageData!) : nil))
        let selfie = (docType != "SELFIE" ? nil : (selfieDocScanResult != nil ? FlutterStandardTypedData.init(bytes: selfieDocScanResult!.imageData!) : nil))
        let passport = (docType != "PASSPORT" ? nil : (frontDocScanResult != nil ? FlutterStandardTypedData.init(bytes: frontDocScanResult!.imageData!) : nil))
        let autoCaptured: Bool = ((frontDocScanResult ?? backDocScanResult)?.metaData["autoCaptured"] as? Bool) == true
        
        var map: [String: Any?] = ["documentType": docType, "passportImage": passport, "licenseFrontImage": licenseFront, "licenseBackImage": licenseBack, "selfieImage": selfie, "autoCaptured": autoCaptured]
        
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
        frontDocScanResult = docScanResult
        if (onlyNeedFrontPicture) {
            sendFlutterResult()
        }
    }

    public func documentBackCallBack(docScanResult: DocScanResult) {
        backDocScanResult = docScanResult
        sendFlutterResult()
    }

    public func selfieCallBack(selfieScanResult: SelfieScanResult) {
        selfieDocScanResult = selfieScanResult
        sendFlutterResult(documentType: "SELFIE")
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
