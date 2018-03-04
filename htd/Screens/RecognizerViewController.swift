//
//  RecognizerViewController.swift
//  htd
//
//  Created by Alexey Landyrev on 14.01.18.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import UIKit
import Metal
import AVFoundation
import Vision
import CoreGraphics

class RecognizerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, RecognizerDelegate {
    
    @IBOutlet weak var grantPermissionLabel: UIView!
    @IBOutlet weak var askPermissionButton: UIButton!
    @IBOutlet weak var askPermissionText: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var backButtonLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var previewView: UIImageView!
    @IBOutlet var backTapGesture: UITapGestureRecognizer!
    
    var recognizer: Recognizer?
    var level: Level?
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var queue: DispatchQueue?
    var hasFinished = false
    var envParams: [String:Any] = [:]
    var settingsUrl: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
        Colorize.sharedInstance.addColor(toView: self.view)
        
        envParams = [
            "name": self.level!.name,
        ]
        
        self.queue = DispatchQueue.global(qos: .userInteractive)
        
        recognizer = Recognizer.init(level: self.level!, completed: {
            #if IOS_SIMULATOR
                self.initEmulator()
            #else
                self.queue!.async {
                    self.checkPermissions(completed: self.initCamera)
                }
            #endif
        })
        recognizer!.delegate = self
        
        backTapGesture.addTarget(self, action: #selector(self.exit))
        
        self.askPermissionButton.addTarget(self, action: #selector(self.openSettings), for: .touchUpInside)
        
        self.askPermissionText.text = NSLocalizedString("ASK_REJECTED_PERMISSIONS", comment: "Ask rejected permissions")
        self.askPermissionButton.setTitle(NSLocalizedString("ASK_REJECTED_PERMISSIONS_BUTTON", comment: "Ask rejected permissions button"), for: .normal)
        self.backButtonLabel.text = NSLocalizedString("BACK_BUTTON", comment: "Back button")
        self.headerLabel.text = NSLocalizedString("RECOGNIZE_HEADER", comment: "Recognize screen header")
        self.captionLabel.text = NSLocalizedString("POINT_CAMERA", comment: "Ask for pointing camera")
    
    }
        
    func initEmulator() {
        NSLog("emulator mode")
        Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: {_ in
            self.recognizeDidSuccess()
        })
    }
    
    @objc func openSettings() {
        UIApplication.shared.open(self.settingsUrl!, options: [:], completionHandler: nil)
    }
    
    @objc func exit() {
        self.navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func checkPermissions(completed: (() -> ())?) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            if completed != nil { completed!() }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video, completionHandler: {_ in
                self.checkPermissions(completed: completed)
            })
            return
        default:
            self.onRejectedGrants()
            return
        }
        
    }
    
    func onRejectedGrants() {
        DispatchQueue.main.sync {
            self.grantPermissionLabel.isHidden = false
            self.settingsUrl = URL.init(string: UIApplicationOpenSettingsURLString)
            guard self.settingsUrl != nil else {
                return
            }
            if UIApplication.shared.canOpenURL(settingsUrl!) {
                self.askPermissionButton.isHidden = false
            }
        }
    }
    
    func recognizeDidFound() {
        DispatchQueue.main.async {
            self.captionLabel.text = NSLocalizedString(
                "FOUND_SOMETHING", comment: "Ask for pointing camera"
            )
            Analytics.sharedInstance.event("found_something", params: self.envParams)
        }
    }
    
    func recognizeDidLost() {
        DispatchQueue.main.async {
            self.captionLabel.text = NSLocalizedString("POINT_CAMERA", comment: "Ask for pointing camera")
            Analytics.sharedInstance.event("lost_something", params: self.envParams)
        }
    }
    
    func recognizeDidSuccess() {
        #if IOS_SIMULATOR
            self.level!.set(1)
            Analytics.sharedInstance.event("success_recognized", params: self.envParams)
            performSegue(withIdentifier: "successSegue", sender: nil)
            return
        #else
            self.captureSession!.stopRunning()
            DispatchQueue.main.sync {
                autoreleasepool {
                    self.level!.set(1)
                }
                Analytics.sharedInstance.event("success_recognized", params: self.envParams)
                performSegue(withIdentifier: "successSegue", sender: nil)
            }
        #endif
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "successSegue" {
            let dest = segue.destination as! SuccessScreenViewController
            dest.level = self.level
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let _ = self.recognizer?.processImage(sampleBuffer)
    }
    
    
    
    func initCamera() {
        
        let captureDevice = AVCaptureDevice.default(for: .video)!
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice)
            let output = AVCaptureVideoDataOutput()
            output.setSampleBufferDelegate(self, queue: self.queue)
            output.alwaysDiscardsLateVideoFrames = true
            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String:output.availableVideoPixelFormatTypes[2]]
            
            let queue = DispatchQueue(label: "main")
            output.setSampleBufferDelegate(self, queue: queue)
            
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            captureSession?.addOutput(output)
            
            let preview = AVCaptureVideoPreviewLayer.init(session: captureSession!)
            DispatchQueue.main.sync {
                preview.frame = self.previewView.bounds
                preview.videoGravity = .resizeAspectFill
                self.previewView.layer.addSublayer(preview)
            }
            
            do {
                try captureDevice.lockForConfiguration()
                captureDevice.activeVideoMinFrameDuration = CMTimeMake(1, 24)
                captureDevice.unlockForConfiguration()
            } catch {
                print(error)
            }
            
            
            
            captureSession!.startRunning()
            Analytics.sharedInstance.event("camera_init_success", params: envParams)
        } catch {
            print(error)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        Analytics.sharedInstance.navigate("recognizer", params: envParams)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    override func viewDidDisappear(_ animated: Bool) {
        captureSession?.stopRunning()
    }

}
