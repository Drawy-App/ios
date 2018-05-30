//
//  Recognizer.swift
//  htd
//
//  Created by Alexey Landyrev on 07.02.2018.
//  Copyright © 2018 Alexey Landyrev. All rights reserved.
//

import UIKit
import CoreML
import AVFoundation
import Vision

enum State {
    case Nothing
    case Something
    case Success
}

class Recognizer {
    
    var request: VNCoreMLRequest?
    let level: Level
    var lastFailureTime = NSDate().timeIntervalSince1970
    let envParams: [String:String]
    var state = State.Nothing
    weak var delegate: RecognizerDelegate?
    
    init(level: Level, completed: (() -> ())?) {
        self.level = level
        self.envParams = [
            "name": self.level.name,
        ]
        
        guard let model = try? VNCoreMLModel(for: realmodel().model) else {return}
        request = VNCoreMLRequest(model: model) { (finishedRequest, error) in
            let results = finishedRequest.results as! [VNClassificationObservation]
            let result = results.filter {
                $0.identifier.replacingOccurrences(of: " ", with: "_") == self.level.name
            }.first!
            print("final: ", result.identifier)
            print("final: ", result.confidence)
            print(results.first!.identifier)
            print(results.first!.confidence)
            self.rate(Int(result.confidence * 100))
        }
        request!.imageCropAndScaleOption = .scaleFill
        if completed != nil { completed!() }
    }
    
    func cropCiImage(_ ciImage: CIImage) -> CIImage {
        var newImage = ciImage
        newImage = newImage.oriented(.right)
        
        let imageSize = newImage.extent
        let targetSize = imageSize.width > imageSize.height ? imageSize.height : imageSize.width
        let padding = abs(imageSize.width - imageSize.height) / 2
        let targetRect = CGRect.init(x: 0, y: padding, width: targetSize, height: targetSize)
        newImage = newImage.cropped(to: targetRect)
        
        let transformFilter = CIFilter.init(name: "CIAffineTransform")!
        let affineTransform = CGAffineTransform.init(translationX: 0, y: 0 - padding)
        transformFilter.setValue(newImage, forKey: "inputImage")
        transformFilter.setValue(affineTransform, forKey: "inputTransform")
        newImage = transformFilter.value(forKey: "outputImage") as! CIImage
        
        return newImage
        
    }
    
    func processImage(_ sampleBuffer: CMSampleBuffer) -> CIImage? {
        guard let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return nil }
        CVPixelBufferLockBaseAddress(pixelBuffer, .readOnly);
        var baseImg = CIImage.init(cvPixelBuffer: pixelBuffer)
        baseImg = cropCiImage(baseImg)
        try? VNImageRequestHandler(ciImage: baseImg, options: [:]).perform([request!])
        CVPixelBufferUnlockBaseAddress(pixelBuffer, .readOnly);
        return baseImg
    }
    
    func rate(_ rate: Int) {
        let now = NSDate().timeIntervalSince1970
        if rate > 75 {
            let timeElapsed = now - lastFailureTime
            if timeElapsed > 0.33 {
                if timeElapsed > 3  {
                    self.delegate?.recognizeDidSuccess()
                } else {
                    if self.state != .Something {
                        self.state = .Something
                        self.delegate?.recognizeDidFound()
                    }
                }
            }
        } else {
            lastFailureTime = now
            if self.state != .Nothing {
                self.state = .Nothing
                self.delegate?.recognizeDidLost()
                
            }
        }
    }
}

protocol RecognizerDelegate: AnyObject {
    func recognizeDidFound()
    func recognizeDidSuccess()
    func recognizeDidLost()
}
