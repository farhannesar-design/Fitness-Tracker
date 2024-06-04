//
//  CameraStream.swift
//  Future of Fit
//
//  Created by Seth Schofill on 3/3/24.
//

import Foundation
import AVKit


// Configures AVCaptureSession
class CameraStream: NSObject, ObservableObject, AVCaptureVideoDataOutputSampleBufferDelegate {
    @Published var luminosityReading : Double = 0.0
    @Published var cameraAccess = false
    
    public var session : AVCaptureSession!
    var configureAVCaptureSessionQueue = DispatchQueue(label: "ConfigureAVCaptureSessionQueue")
    
    override init() {
        super.init()
        configureAVCaptureSessionQueue.async {
           self.authorizeCapture() // this needs to be awaited
        }
    }
    
    // Checks for authorization and requests if not had.
    func authorizeCapture()  {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized: // The user has previously granted access to the camera.
            DispatchQueue.main.async {
                self.cameraAccess = true
            }
            beginCapture()
        case .notDetermined: // The user has not yet been asked for camera access.
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.cameraAccess = true
                    }
                    self.beginCapture()
                }
            }
            
        default:
            return
        }
    }
    //Searches for best camera device, sets as input, sets output for captureOutput and lux calc.
    func beginCapture() {
        session = AVCaptureSession()
        session.beginConfiguration()
        guard let videoDevice = AVCaptureDevice.default(for: .video) else {return}
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoInput) {
                session.addInput(videoInput)
            }
        } catch {
            print("Camera selection failed: \(error)")
            return
        }
        let videoOutput = AVCaptureVideoDataOutput()
        guard
            session.canAddOutput(videoOutput)
        else {
            print("Error creating video output")
            return
        }
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "CaptureOutputQueue"))
        session.addOutput(videoOutput)
        session.sessionPreset = .medium
        session.commitConfiguration()
        session.startRunning()
    }
    
    // Calculate lux
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let rawMetadata = CMCopyDictionaryOfAttachments(allocator: nil, target: sampleBuffer, attachmentMode: CMAttachmentMode(kCMAttachmentMode_ShouldPropagate))
        let metadata = CFDictionaryCreateMutableCopy(nil, 0, rawMetadata) as NSMutableDictionary
        let exifData = metadata.value(forKey: "{Exif}") as? NSMutableDictionary
        let FNumber : Double = exifData?["FNumber"] as! Double
        let ExposureTime : Double = exifData?["ExposureTime"] as! Double
        let ISOSpeedRatingsArray = exifData!["ISOSpeedRatings"] as? NSArray
        let ISOSpeedRatings : Double = ISOSpeedRatingsArray![0] as! Double
        let CalibrationConstant : Double = 50
        let luminosity : Double = (CalibrationConstant * FNumber * FNumber ) / ( ExposureTime * ISOSpeedRatings )
        DispatchQueue.main.async {
            self.luminosityReading = luminosity
        }
    }
}
