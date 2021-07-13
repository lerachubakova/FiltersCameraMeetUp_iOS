//
//  SessionManager.swift
//  TestTaskTurkcell
//
//  Created by User on 6/28/21.
//

import AVFoundation
import UIKit

class SessionManager: NSObject {
    private let captureSession = AVCaptureSession()
    private let videoOutput = AVCaptureVideoDataOutput()
    private var videoInput: AVCaptureDeviceInput?
    private var videoConnection: AVCaptureConnection?
    private let outputQueue = DispatchQueue(label: "com.chubakova.output", attributes: [])

    // MARK: - Methods

    func getOutputQueue() -> DispatchQueue {
        return outputQueue
    }

    func getVideoOutput() -> AVCaptureVideoDataOutput {
        return videoOutput
    }

    override init() {
        super.init()
        initCaptureSession()
    }
    
    func startRunning() {
        guard !captureSession.isRunning else { return }
        captureSession.startRunning()
    }
    
    func stopRunning() {
        guard captureSession.isRunning else { return }
        captureSession.stopRunning()
    }

}

// MARK: - PrivateExtension
private extension SessionManager {
    func initCaptureSession() {
        captureSession.sessionPreset = .high
        
        guard let cameraDevice = getBackCaptureCameraDevice() else { return }
        
        guard let videoInput = getCaptureDeviceInput(captureDevice: cameraDevice) else { return }
        self.videoInput = videoInput
        
        guard captureSession.canAddInput(videoInput) else { return }
        captureSession.addInput(videoInput)
       
        guard captureSession.canAddOutput(videoOutput) else { return }
        captureSession.addOutput(videoOutput)
        
        videoConnection = videoOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait
    }
    
    func getBackCaptureCameraDevice() -> AVCaptureDevice? {
        if #available(iOS 13.0, *) {
            if let tripleCamera = AVCaptureDevice.default(.builtInTripleCamera, for: .video, position: .back) {
                return tripleCamera
            }
        
            if let dualWideCamera = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) {
                return dualWideCamera
            }
        }

        if let dualCamera = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
            return dualCamera
        }
        
        if let wideAngleCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
            return wideAngleCamera
        }
        
        return nil
        
    }

    func getCaptureDeviceInput(captureDevice: AVCaptureDevice) -> AVCaptureDeviceInput? {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            return captureDeviceInput
        } catch let error {
            print("### SessionManager: getCaptureDeviceInput: \(error)")
        }
        return nil
    }
}
