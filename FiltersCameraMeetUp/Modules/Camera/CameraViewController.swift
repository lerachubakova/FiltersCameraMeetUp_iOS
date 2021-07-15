//
//  CameraViewController.swift
//  FiltersCameraMeetUp
//
//  Created by User on 13.07.21.
//

import AVFoundation
import UIKit

class CameraViewController: UIViewController {
    // MARK: - @IBOutlets
    @IBOutlet private weak var recordButton: UIButton!
    @IBOutlet private weak var cameraImageView: UIImageView!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private var sessionManager = SessionManager()
    private var postType: PostType = .photo
    
    private var filterIndex = 0
    private var filterName = ""
    
    private let CIFilterNames = [
       "",
       "CIPhotoEffectChrome",
       "CIPhotoEffectFade",
       "CIPhotoEffectInstant",
       "CIPhotoEffectNoir",
       "CIPhotoEffectProcess",
       "CIPhotoEffectTonal",
       "CIPhotoEffectTransfer",
       "CISepiaTone"
    ]
    
    // MARK: - ForVideo
    private var outputFileLocation: URL?
    private var videoWriter: AVAssetWriter!
    private var videoWriterInput: AVAssetWriterInput!
    private var audioWriterInput: AVAssetWriterInput!
    private var videoStarted: Bool = false

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSession()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar()
        startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
    }
    
    // MARK: - Navigation
    private func goToPhoto() {
        self.performSegue(withIdentifier: "toPhotoVCSegue", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPhotoVCSegue", let photoVC = segue.destination as? PhotoViewController {
            switch postType {
            case .photo:
                photoVC.setImage(img: cameraImageView.image)
            case .video:
                if let path = outputFileLocation {
                    photoVC.setVideo(url: path, filterName: filterName)
                }
            }
        }
    }
 
    // MARK: - Setup
    private func setupSession() {
        sessionManager.getVideoOutput().setSampleBufferDelegate(self, queue: sessionManager.getOutputQueue())
        sessionManager.getAudioOutput().setSampleBufferDelegate(self, queue: sessionManager.getOutputQueue())
    }
    
    private func configureNavigationBar() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    // MARK: - Logic
    private func startSession() {
        DispatchQueue.main.async { [weak self] in
            self?.sessionManager.startRunning()
        }
    }
    
    private func stopSession() {
        DispatchQueue.main.async { [weak self] in
            self?.sessionManager.stopRunning()
        }
    }
    
    private func changeFilter() {
        let index = (filterIndex + 1) % CIFilterNames.count
        filterIndex = index
        filterName = CIFilterNames[index]
    }

    // MARK: - VideoFunctions
    func videoFileLocation() -> URL {
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        let videoOutputUrl = URL(fileURLWithPath: documentsPath.appendingPathComponent("videoFile")).appendingPathExtension("mov")
        do {
            if FileManager.default.fileExists(atPath: videoOutputUrl.path) {
                try FileManager.default.removeItem(at: videoOutputUrl)
            }
        } catch {
            print("videoFileLocation: \(error)")
        }
        return videoOutputUrl
    }
    
    func startVideo() {
        do {
            let path = videoFileLocation()
            self.outputFileLocation = path
            videoWriter = try AVAssetWriter(outputURL: path, fileType: AVFileType.mov)
        } catch let error {
            print("startVideo: \(error.localizedDescription)")
        }

        let videoSettings: [String : Any] = [
            AVVideoCodecKey : AVVideoCodecType.h264,
            AVVideoWidthKey : 720,
            AVVideoHeightKey : 1280
        ]
        
        videoWriterInput = AVAssetWriterInput(mediaType: AVMediaType.video, outputSettings: videoSettings)

        videoWriterInput.expectsMediaDataInRealTime = true
        guard videoWriter.canAdd(videoWriterInput) else { return }
        videoWriter.add(videoWriterInput)

        let audioSettings: [String : Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100.0,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
         ]
        
        audioWriterInput = AVAssetWriterInput(mediaType: AVMediaType.audio, outputSettings: audioSettings )
        audioWriterInput.expectsMediaDataInRealTime = true
        guard videoWriter.canAdd(audioWriterInput) else { return }
        videoWriter.add(audioWriterInput)
    
        if let assetWriter = videoWriter, assetWriter.status == .unknown {
            guard let recordingClock = self.sessionManager.getSession().masterClock else { return }
            videoWriter.startWriting()
            videoWriter.startSession(atSourceTime: CMClockGetTime(recordingClock))
            videoStarted = true
        }
    
    }

    func stopVideo() {
        guard videoStarted == true else { return }
        if let videoWriter = videoWriter {
            if let videoWriterInput = videoWriterInput {
                videoWriterInput.markAsFinished()
            }
            if let audioWriterInput = audioWriterInput {
                audioWriterInput.markAsFinished()
            }
            videoWriter.finishWriting {}
            videoStarted = false
        }
        postType = .video
        self.goToPhoto()
    }

    // MARK: - @IBActions
    @IBAction private func tappedChangeFilterButton(_ sender: Any) {
        changeFilter()
    }
    
    @IBAction private func tappedCameraButton(_ sender: Any) {
        postType = .photo
        goToPhoto()
    }
    
    @IBAction private func longTappedForVideo(_ gestureRecognizer: UILongPressGestureRecognizer) {
        switch gestureRecognizer.state {
        case .possible, .changed, .failed, .cancelled:
            break
        case .began:
            startVideo()
            recordButton.setImage(UIImage(named: "icCameraButtonHighlighted"), for: .normal)
        case .ended:
            stopVideo()
            recordButton.setImage(UIImage(named: "icCameraButton"), for: .normal)
        @unknown default:
            break
        }
    }
}

// MARK: - AVCaptureAudioDataOutputSampleBufferDelegate
extension CameraViewController: AVCaptureAudioDataOutputSampleBufferDelegate, AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        if let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
            let cameraImage = CIImage(cvImageBuffer: pixelBuffer)
            
            let context = CIContext()
            
            var cgImage = context.createCGImage(cameraImage, from: cameraImage.extent)
        
            if let effect = CIFilter(name: filterName) {
                effect.setValue(cameraImage, forKey: kCIInputImageKey)
                guard let effectImage = effect.outputImage else { return }
                cgImage = context.createCGImage( effectImage, from: cameraImage.extent)
            }
            
            guard let finalImage = cgImage else { return }
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.cameraImageView.image = UIImage(cgImage: finalImage)
            }
        }
        
        guard videoStarted else { return }
        objc_sync_enter(self)
        sessionManager.getOutputQueue().async { [weak self] in
            guard let self = self else { return }
            if connection == self.sessionManager.getVideoConnection() {
                if let videoWriterInput = self.videoWriterInput, videoWriterInput.isReadyForMoreMediaData {
                    videoWriterInput.append(sampleBuffer)
                }
            } else if connection == self.sessionManager.getAudioConnection() {
                if let audioWriterInput = self.audioWriterInput, audioWriterInput.isReadyForMoreMediaData {
                    audioWriterInput.append(sampleBuffer)
                }
            }
        }
        objc_sync_exit(self)
    }
}
