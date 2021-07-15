//
//  SessionManager.swift
//  FiltersCameraMeetUp
//
//  Created by User on 13.07.21.
//

import AVFoundation
import UIKit

typealias ToggleCameraCompletionHandler = (CameraPosition) -> Void

enum CameraPosition {
    case front
    case back
}

class SessionManager: NSObject {
    private let captureSession = AVCaptureSession()
    
    private let videoOutput = AVCaptureVideoDataOutput()
    private let audioOutput = AVCaptureAudioDataOutput()
    
    private var videoInput: AVCaptureDeviceInput?
    private var audioInput: AVCaptureDeviceInput?
    
    private var videoConnection: AVCaptureConnection?
    private var audioConnection: AVCaptureConnection?
    
    private let outputQueue = DispatchQueue(label: "com.chubakova.output", attributes: [])
   
    private var outputURL: URL!
    
    // MARK: - Methods
    func getVideoConnection() -> AVCaptureConnection? {
        return videoConnection
    }
    
    func getAudioConnection() -> AVCaptureConnection? {
        return audioConnection
    }
    
    func getOutputQueue() -> DispatchQueue {
        return outputQueue
    }
    
    func getSession() -> AVCaptureSession {
        return captureSession
    }
    
    func getVideoOutput() -> AVCaptureVideoDataOutput {
        return videoOutput
    }
    
    func getAudioOutput() -> AVCaptureAudioDataOutput {
        return audioOutput
    }
    
    func getMovieURL() -> URL {
        outputURL = getVideoFileLocation()
        return outputURL
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
     
        guard let microphone = getMicrophoneDevice() else { return }
        guard let micInput = getCaptureDeviceInput(captureDevice: microphone) else { return }
        self.audioInput = micInput
        guard captureSession.canAddInput(micInput) else { return }
        captureSession.addInput(micInput)
        
        guard captureSession.canAddOutput(audioOutput) else { return }
        captureSession.addOutput(audioOutput)
        
        audioConnection = audioOutput.connection(with: .audio)
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
    
    func getMicrophoneDevice() -> AVCaptureDevice? {
        if let microphone = AVCaptureDevice.default(for: .audio) {
            return microphone
        }
        return nil
    }
    
    func getCaptureDeviceInput(captureDevice: AVCaptureDevice) -> AVCaptureDeviceInput? {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            return captureDeviceInput
        } catch let error {
            print("getCaptureDeviceInput: \(error.localizedDescription)")
        }
        return nil
    }
    
    func getVideoFileLocation() -> URL {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let videoOutputUrl = URL(fileURLWithPath: documentsPath.appendingPathComponent("videoFile")).appendingPathExtension("mov")
       
        if FileManager.default.fileExists(atPath: videoOutputUrl.path) {
            do {
                try FileManager.default.removeItem(at: videoOutputUrl)
            } catch {
                print("videoFileLocation: \(error.localizedDescription)")
            }
        }
        return videoOutputUrl
    }
    
}
