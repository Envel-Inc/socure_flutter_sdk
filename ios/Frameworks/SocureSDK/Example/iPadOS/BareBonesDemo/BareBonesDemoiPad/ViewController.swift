//
//  ViewController.swift
//  BareBonesDemo
//
//  Created by Nicolas Dedual on 2/27/20.
//  Copyright © 2020 Socure Inc. All rights reserved.
//

import UIKit
import SocureSdk
import AVFoundation

class ViewController: UIViewController {
    
    @IBOutlet weak var captureButton:UIButton!
    let d​ocScanner​ = DocumentScanner()
    
    @IBOutlet weak var frontImageView: UIImageView!
    @IBOutlet weak var frontImageLabel: UILabel!
    @IBOutlet weak var backImageView: UIImageView!
    @IBOutlet weak var backImageLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    func requestCameraPermissions(requestStatus: @escaping (Bool) -> Void) {

        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) == AVAuthorizationStatus.authorized {
            requestStatus(true)
        } else {
            AVCaptureDevice.requestAccess(for: AVMediaType.video, completionHandler: { (granted: Bool) -> Void in
                if granted == true {
                    //User granted access. Let the app continue
                    requestStatus(true)

                } else {
                      
                    requestStatus(false)
        
                }
            })
        }
    }
    
    @IBAction func didCaptureButton(sender:UIButton) {
        
        DocumentScanner.requestCameraPermissions { (permissionsGranted) in
            
            DispatchQueue.main.async {
                
                if (permissionsGranted) {
                    self.d​ocScanner​.initiateLicenseFrontScan(ImageCallback: self)
                }
                else {
                    let alertController = UIAlertController(title:
                                "Permission Error", message: "This application requires access to the camera to fuction. Please grant camera permission for the application", preferredStyle: .alert)
                            alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
                                
                                UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    
                            }))
                            
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}

extension ViewController: ImageCallback  {
    func documentFrontCallBack(docScanResult: DocScanResult) {
        guard let imageData = docScanResult.imageData,
            let image = UIImage.init(data: imageData) else {
                return
        }
        
        frontImageView.image = image
    }
    
    func documentBackCallBack(docScanResult: DocScanResult) {
        guard let imageData = docScanResult.imageData,
            let image = UIImage.init(data: imageData) else {
                return
        }
        
        backImageView.image = image
    }
    
    func selfieCallBack(selfieScanResult: SelfieScanResult) {
        
    }
    
    func onScanCancelled() {
        
    }
    
    func onError(errorType: SocureSDKErrorType, errorMessage: String) {
        
    }
    

}

