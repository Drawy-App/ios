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
    
    @IBOutlet weak var previewView: UIImageView!
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var request: VNCoreMLRequest?

    override func viewDidLoad() {
        super.viewDidLoad()
        initModel()
        initCamera()
        try? VNImageRequestHandler(
                ciImage: CIImage.init(image: UIImage.init(named: "test")!)!
            ).perform([request!])
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func initModel() {
        guard let model = try? VNCoreMLModel(for: realmodel().model) else {return}
        request = VNCoreMLRequest(model: model) { (finishedRequest, error) in
            let results = finishedRequest.results as! [VNClassificationObservation]
            print(results.first!.identifier, Int(results.first!.confidence * 100))
        }
        request!.imageCropAndScaleOption = .scaleFill
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

//
//        // executes request
//        try? VNImageRequestHandler(cvPixelBuffer: pixelBuffer, options: [:]).perform([request!])
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
            output.alwaysDiscardsLateVideoFrames = true
            print("available", output.availableVideoPixelFormatTypes)
            output.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String:output.availableVideoPixelFormatTypes[2]]
            print(output.videoSettings)
            
            let queue = DispatchQueue(label: "main")
            output.setSampleBufferDelegate(self, queue: queue)
            
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            captureSession?.addOutput(output)
            
            do {
                try captureDevice.lockForConfiguration()
                captureDevice.activeVideoMaxFrameDuration = CMTimeMake(1, 20)
                captureDevice.activeVideoMinFrameDuration = CMTimeMake(1, 20)
                captureDevice.unlockForConfiguration()
            } catch {
                print(error)
            }
            
//            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
//            videoPreviewLayer!.videoGravity = .resizeAspectFill
//            videoPreviewLayer!.frame = CGRect.init(x: 0, y: 0, width: 375, height: 375)
//            previewView.layer.addSublayer(videoPreviewLayer!)
            
            
            
            captureSession?.startRunning()
        } catch {
            print(error)
        }
    }
    

    override func viewDidDisappear(_ animated: Bool) {
        captureSession?.stopRunning()
    }

}
