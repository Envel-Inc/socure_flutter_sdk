//
//  AppDelegate.swift
//  BareBonesDemo
//
//  Created by Nicolas Dedual on 2/27/20.
//  Copyright © 2020 Socure Inc. All rights reserved.
//

import UIKit
import SocureSdk

@UIApplicationMain
class AppDelegate: UIResponder {
  // MARK: - properties -
  var window: UIWindow?
  var imageclear : String = ""
  var isCameraModeEnabled = false

  // MARK: - private methods -
  func setApplicationDefaults(){
    let stanDefaults = UserDefaults.standard
    let assessmentFlow = [DefaultKeys.privacyPreference: 0]
    let privacyPreference = [DefaultKeys.privacyPreference: 1]
    let documentBlur = [DefaultKeys.documentBlur: 1]
    let galleryimage = [DefaultKeys.galleryPassport : true]
    let faceDetection = [DefaultKeys.faceDetection: true]
    let barCodeDetection = [DefaultKeys.barCodeDetection : true]
    let captureIntensity = [DefaultKeys.captureIntensity : "Medium"]
    let selfieTimeout = [DefaultKeys.selfieTimeout : 10]
    let selfieBlur = [DefaultKeys.blurThreshold  : 5]
    let faceMotion = [DefaultKeys.faceMotion : 0.15]
    let eyeMotion = [DefaultKeys.eyeMotion : 0.05]
    let roiFocus = [DefaultKeys.roiFocus : 0]
    let eyeIntensity = [DefaultKeys.eyeIntensity : 10]
    let DocumentTimeout = [DefaultKeys.docTimeOut : 10]
    let showcropper = [DefaultKeys.showCropper : true]
    let LevellingLicense = [DefaultKeys.enableLevellingLicense : false]
    let flashcaptureLicense = [DefaultKeys.enableFlashCaptureLicense : true]
    let manualcaptureLicense = [DefaultKeys.enableManualOverlayLicense :false]//
    let initialoverlayLicense = [DefaultKeys.enableInitialOverlayLicense : false ]
    let glaredetectionLicense = [DefaultKeys.enableGlareDetectionLicense : false ]
    let focusdetectionLicense = [DefaultKeys.enableFocusDetectionLicense: false]
    let facedetectionFeedback = [DefaultKeys.enableFaceDetectionLicense : false]
    let faceCheckerLicense = [DefaultKeys.enableFaceCheckerLicense : true]
    let manualcapturelicense = [DefaultKeys.manualCaptureLicense : false]
    let manualcaptureSelfie = [DefaultKeys.manualCaptureSelfie : false]
    let orientation  = [DefaultKeys.orientation : false]
    let enableHelp  = [DefaultKeys.enableHelp : true]
    let showSelfieConfirmation  = [DefaultKeys.selfieShowConfirmation : false]
    let manualOverlaySelfie = [DefaultKeys.selfieManualOverlay : false]
    let enableHelpSelfie = [DefaultKeys.selfieEnableHelp : true]
    let initialOverlaySelfie = [DefaultKeys.selfieInitialOverlay : false]

    stanDefaults.register(defaults: assessmentFlow)
    stanDefaults.register(defaults: privacyPreference)
    stanDefaults.register(defaults: documentBlur)
    stanDefaults.register(defaults: galleryimage)
    stanDefaults.register(defaults: faceDetection)
    stanDefaults.register(defaults: barCodeDetection)
    stanDefaults.register(defaults: captureIntensity)
    stanDefaults.register(defaults: selfieTimeout)
    stanDefaults.register(defaults: selfieBlur)
    stanDefaults.register(defaults: faceMotion)
    stanDefaults.register(defaults: eyeMotion)
    stanDefaults.register(defaults: roiFocus)
    stanDefaults.register(defaults: eyeIntensity)
    stanDefaults.register(defaults: showcropper)
    stanDefaults.register(defaults: LevellingLicense)
    stanDefaults.register(defaults: flashcaptureLicense)
    stanDefaults.register(defaults: manualcaptureLicense)
    stanDefaults.register(defaults: initialoverlayLicense)
    stanDefaults.register(defaults: glaredetectionLicense)
    stanDefaults.register(defaults: focusdetectionLicense)
    stanDefaults.register(defaults: focusdetectionLicense)
    stanDefaults.register(defaults: orientation)
    stanDefaults.register(defaults: manualcapturelicense)
    stanDefaults.register(defaults: manualcaptureSelfie)
    stanDefaults.register(defaults: DocumentTimeout)
    stanDefaults.register(defaults: facedetectionFeedback)
    stanDefaults.register(defaults: enableHelp)
    stanDefaults.register(defaults: showSelfieConfirmation)
    stanDefaults.register(defaults: manualOverlaySelfie)
    stanDefaults.register(defaults: enableHelpSelfie)
    stanDefaults.register(defaults: initialOverlaySelfie)
    stanDefaults.register(defaults: faceCheckerLicense)
  }
}

// MARK: - UIApplicationDelegates -
extension AppDelegate: UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        setApplicationDefaults()
    
        SocureSDKConfigurator.shared.setPreferences()
    
        return true
  }
  /*  @objc private func deviceHasRotated() {
        
        UIDevice.current.setValue(Int(UIDevice.current.orientation.rawValue), forKey: "orientation")
    }
*/
  
    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) {}
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        
    }
    func applicationDidBecomeActive(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}


    
 /*   func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        if isCameraModeEnabled {
            // Unlock landscape view orientations for this view controller
            return .landscapeRight
        }
        
        // Only allow portrait (standard behaviour)
        return .portrait
    } */
}
