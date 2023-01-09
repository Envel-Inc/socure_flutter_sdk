import Flutter
import UIKit
import SocureSdk
import DeviceRisk

public class SwiftSocureFlutterSdkPlugin: NSObject, FlutterPlugin, DeviceRiskUploadCallback {
  let docScanner = DocumentScanner()
  let selfieScanner = SelfieScanner()
  let deviceRiskManager = DeviceRiskManager.sharedInstance
  var flutterResult: FlutterResult?

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
        default:
            break
    }
  }
}

class SocureViewController: UIViewController, ImageCallback, MRZCallback, BarcodeCallback, UploadCallback {
    var flutterResult: FlutterResult?
    var onlyNeedFrontPicture: Bool = false
    var imageUploader = ImageUploader.init()
    
    var frontDocScanResult: DocScanResult?
    var backDocScanResult: DocScanResult?
    var selfieDocScanResult: SelfieScanResult?
    var mrz: MrzData?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    private func sendFlutterResult(documentType: String?, referenceId: String?, uuid: String?) {
        let docType = documentType ?? (onlyNeedFrontPicture ? "PASSPORT": "LICENSE")
        
        let licenseFront = (docType != "LICENSE" ? nil : (frontDocScanResult != nil ? FlutterStandardTypedData.init(bytes: frontDocScanResult!.imageData!) : nil))
        let licenseBack = (docType != "LICENSE" ? nil : (backDocScanResult != nil ? FlutterStandardTypedData.init(bytes: backDocScanResult!.imageData!) : nil))
        let selfie = (docType != "SELFIE" ? nil : (selfieDocScanResult != nil ? FlutterStandardTypedData.init(bytes: selfieDocScanResult!.imageData!) : nil))
        let passport = (docType != "PASSPORT" ? nil : (frontDocScanResult != nil ? FlutterStandardTypedData.init(bytes: frontDocScanResult!.imageData!) : nil))
        let autoCaptured: Bool = ((frontDocScanResult ?? backDocScanResult)?.metaData["autoCaptured"] as? Bool) == true
        
        var map: [String: Any?] = ["documentType": docType, "passportImage": passport, "licenseFrontImage": licenseFront, "licenseBackImage": licenseBack, "selfieImage": selfie, "referenceId": referenceId, "uuid": uuid, "autoCaptured": autoCaptured]
        
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
    
    public func documentUploadFinished(uploadResult: SocureSdk.UploadResult) {
        sendFlutterResult(documentType: nil, referenceId: uploadResult.referenceId, uuid: uploadResult.uuid)
    }

    public func onUploadError(errorType: SocureSdk.SocureSDKErrorType, errorMessage: String) {
        self.dismiss(animated: true, completion: nil)
        flutterResult?(FlutterError.init(code: "-2", message: errorMessage, details: nil))
        flutterResult = nil
    }
    
    public func documentFrontCallBack(docScanResult: DocScanResult) {
        frontDocScanResult = docScanResult
        if (onlyNeedFrontPicture) {
            imageUploader.uploadPassport(UploadCallback: self, front: docScanResult.imageData!)
        }
    }

    public func documentBackCallBack(docScanResult: DocScanResult) {
        backDocScanResult = docScanResult
        imageUploader.uploadLicense(UploadCallback: self, front: frontDocScanResult!.imageData!, back: docScanResult.imageData!);
    }

    public func selfieCallBack(selfieScanResult: SelfieScanResult) {
        selfieDocScanResult = selfieScanResult
        sendFlutterResult(documentType: "SELFIE", referenceId: nil, uuid: nil)
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
