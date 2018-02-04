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

class RecognizerViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    @IBOutlet weak var captionLabel: UILabel!
    @IBOutlet weak var backButtonLabel: UILabel!
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var previewView: UIImageView!
    @IBOutlet var backTapGesture: UITapGestureRecognizer!
    var level: Level?
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var request: VNCoreMLRequest?
    var queue: DispatchQueue?
    var lastFailureTime = NSDate().timeIntervalSince1970
    var hasFinished = false

    override func viewDidLoad() {
        super.viewDidLoad()
        self.queue = DispatchQueue.global(qos: .userInteractive)
        initModel()
        try? VNImageRequestHandler(
                ciImage: CIImage.init(image: UIImage.init(named: "test")!)!
            ).perform([request!])
        
        backTapGesture.addTarget(self, action: #selector(self.exit))
        
        self.backButtonLabel.text = NSLocalizedString("BACK_BUTTON", comment: "Back button")
        self.headerLabel.text = NSLocalizedString("RECOGNIZE_HEADER", comment: "Recognize screen header")
        self.captionLabel.text = NSLocalizedString("POINT_CAMERA", comment: "Ask for pointing camera")
        
        queue!.async {
            self.initCamera()
        }
    }
    
    @objc func exit() {
        self.navigationController?.popViewController(animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func initModel() {
        guard let model = try? VNCoreMLModel(for: realmodel().model) else {return}
        request = VNCoreMLRequest(model: model) { (finishedRequest, error) in
            let results = finishedRequest.results as! [VNClassificationObservation]
            let result = results.filter {$0.identifier == self.level!.name}.first!
            self.rate(Int(result.confidence * 100))
        }
        request!.imageCropAndScaleOption = .scaleFill
    }
    
    func rate(_ rate: Int) {
        let now = NSDate().timeIntervalSince1970
        if rate > 90 {
            let timeElapsed = now - lastFailureTime
            if timeElapsed > 0.33 {
                if timeElapsed > 3  {
                    self.success()
                } else {
                    DispatchQueue.main.async {
                        self.captionLabel.text = NSLocalizedString(
                            "FOUND_SOMETHING", comment: "Ask for pointing camera"
                        )
                    }
                    
                }
            }
        } else {
            lastFailureTime = now
            DispatchQueue.main.async {
                self.captionLabel.text = NSLocalizedString("POINT_CAMERA", comment: "Ask for pointing camera")
            }
        }
    }
    
    func success() {
        self.captureSession!.stopRunning()
        DispatchQueue.main.sync {
            autoreleasepool {
                self.level!.set(1)
            }
            performSegue(withIdentifier: "successSegue", sender: nil)
        }
    }
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly);
        var baseImg = CIImage.init(cvPixelBuffer: pixelBuffer)
        baseImg = cropCiImage(baseImg)
        DispatchQueue.main.async {
            self.previewView.image = UIImage.init(ciImage: baseImg)
        }
        try? VNImageRequestHandler(ciImage: baseImg, options: [:]).perform([request!])
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly);
    }
    
    func cropCiImage(_ ciImage: CIImage) -> CIImage {
        var newImage = ciImage
        newImage = newImage.oriented(.right)
        let imageSize = newImage.extent
        let targetSize = imageSize.width > imageSize.height ? imageSize.height : imageSize.width
        let targetRect = CGRect.init(x: 0, y: 0, width: targetSize, height: targetSize)
        
        return newImage.cropped(to: targetRect)
        
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
            
            do {
                try captureDevice.lockForConfiguration()
                captureDevice.activeVideoMinFrameDuration = CMTimeMake(1, 24)
                captureDevice.unlockForConfiguration()
            } catch {
                print(error)
            }
            
            
            
            captureSession?.startRunning()
        } catch {
            print(error)
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    override func viewDidDisappear(_ animated: Bool) {
        captureSession?.stopRunning()
    }

}
