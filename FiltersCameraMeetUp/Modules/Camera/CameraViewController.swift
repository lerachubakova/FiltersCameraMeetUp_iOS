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
    @IBOutlet private weak var cameraImageView: UIImageView!
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    private var sessionManager = SessionManager()
    
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

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
        setupSession()
        addGestureRecognizer()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async { [weak self] in
            self?.sessionManager.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async { [weak self] in
            self?.sessionManager.stopRunning()
        }
    }
 
    // MARK: - Setup
    private func configureAppearance() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupSession() {
        sessionManager.getVideoOutput().setSampleBufferDelegate(self, queue: sessionManager.getOutputQueue())
    }
    
    private func addGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(tappedImageView(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    // MARK: - Logic
    private func changeFilter() {
        let index = (filterIndex + 1) % CIFilterNames.count
        filterIndex = index
        filterName = CIFilterNames[index]
    }
    
    // MARK: - @IBActions
    @IBAction private func tappedImageView(_ sender: UITapGestureRecognizer) {
        changeFilter()
    }
}

// MARK: - AVCaptureAudioDataOutputSampleBufferDelegate
extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
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
    }
}
