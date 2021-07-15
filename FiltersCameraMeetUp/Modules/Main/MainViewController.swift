//
//  ViewController.swift
//  FiltersCameraMeetUp
//
//  Created by User on 13.07.21.
//

import UIKit

enum Authorization {
    case camera
    case microphone
    case library
}

class MainViewController: UIViewController {
    // MARK: - @IBOutlets
    @IBOutlet private weak var authImageView: UIImageView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var messageLabel: UILabel!
    @IBOutlet private weak var allowButton: UIButton!
    
    private var authorization: Authorization = .camera
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
//        print("cameraStatus: \(CameraAuthorizationManager.getCameraAuthorizationStatus())")
//        print("microphoneStatus: \(MicrophoneAuthorizationManager.getMicrophoneAuthorizationStatus())")
//        print("auth: \(authorization)")
    }
    
    // MARK: - Navigation
    func goToCamera() {
        performSegue(withIdentifier: "toCameraSegue", sender: nil)
    }
    
    // MARK: - Setup
    func configureAppearance() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        allowButton.layer.shadowRadius = 10
        allowButton.layer.shadowOpacity = 0.3
        allowButton.layer.masksToBounds = false
        allowButton.layer.shadowOffset = CGSize(width: 5, height: 10)
        print(" camera: \(CameraAuthorizationManager.getCameraAuthorizationStatus())")
        print(" micro: \(MicrophoneAuthorizationManager.getMicrophoneAuthorizationStatus())")
        print(" library: \(PHLibraryAuthorizationManager.getPhotoLibraryAuthorizationStatus())")
        
        if CameraAuthorizationManager.getCameraAuthorizationStatus() == .unauthorized {
            configureAllowButtonForDisabled()
        } else if CameraAuthorizationManager.getCameraAuthorizationStatus() == .granted {
            authorization = .microphone
            configureMicrophoneView()
            if MicrophoneAuthorizationManager.getMicrophoneAuthorizationStatus() == .unauthorized {
                configureAllowButtonForDisabled()
            } else if MicrophoneAuthorizationManager.getMicrophoneAuthorizationStatus() == .granted {
                configureLibraryView()
                authorization = .library
            }
        }
    }
    
    // MARK: - Logic
    func configureAllowButtonForDisabled() {
        allowButton.setTitle("Open Settings", for: .normal)
    }
    
    func configureMicrophoneView() {
        titleLabel.text = "Microphone Authorization"
        authImageView.image = UIImage(systemName: "mic")
        messageLabel.text = "You will not be able to continue using applications if you do not allow access to the microphone"
    }
    
    func configureLibraryView() {
        titleLabel.text = "Library Authorization"
        authImageView.image = UIImage(systemName: "photo.on.rectangle.angled")
        messageLabel.text = "You can allow access to the library to save your photos and videos"
    }
    
    func openSettings() {
        let settingURLString = UIApplication.openSettingsURLString
        if let url = URL(string: settingURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func makeCameraRequest() {
        CameraAuthorizationManager.requestCameraAuthorization { [weak self] status in
            switch status {
            case .granted:
                self?.configureMicrophoneView()
                self?.authorization = .microphone
            case .notRequested:
                break
            case .unauthorized:
                self?.configureAllowButtonForDisabled()
            }
        }
    }
    
    func makeMicrophoneRequest() {
        MicrophoneAuthorizationManager.requestMicrophoneAuthorization { [weak self] status in
            switch status {
            case .granted:
                self?.configureLibraryView()
                self?.authorization = .library
            case .notRequested:
                break
            case .unauthorized:
                self?.configureAllowButtonForDisabled()
            }
        }
    }
    
    func makePHLibraryRequest() {
        PHLibraryAuthorizationManager.requestPhotoLibraryAuthorization { [weak self] status in
            switch status {
            case .granted,.unauthorized:
                DispatchQueue.main.async {
                    self?.goToCamera()
                }
            case .notRequested:
                break
            }
        }
    }
    
    // MARK: - @IBActions
    @IBAction private func tappedAllowButton(_ sender: UIButton) {
        switch authorization {
        case .camera:
            switch CameraAuthorizationManager.getCameraAuthorizationStatus() {
            case .granted:
                break
            case .notRequested:
                makeCameraRequest()
            case .unauthorized:
                openSettings()
            }
        case .microphone:
            switch MicrophoneAuthorizationManager.getMicrophoneAuthorizationStatus() {
            case .granted:
                break
            case .notRequested:
                makeMicrophoneRequest()
            case .unauthorized:
                openSettings()
            }
        case .library:
            switch PHLibraryAuthorizationManager.getPhotoLibraryAuthorizationStatus() {
            case .granted, .unauthorized:
               break
            case .notRequested:
                makePHLibraryRequest()
            }
        }
     
    }
}
