//
//  ViewController.swift
//  FiltersCameraMeetUp
//
//  Created by User on 13.07.21.
//

import UIKit

class MainViewController: UIViewController {
    // MARK: - @IBOutlets
    @IBOutlet private weak var allowButton: UIButton!
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
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
        if CameraAuthorizationManager.getCameraAuthorizationStatus() == .unauthorized {
            configureAllowButtonForDisabled()
        }
    }
    
    // MARK: - Logic
    func configureAllowButtonForDisabled() {
        allowButton.setTitle("Open Settings", for: .normal)
    }
    
    func openSettings() {
        let settingURLString = UIApplication.openSettingsURLString
        if let url = URL(string: settingURLString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    func makeRequest() {
        CameraAuthorizationManager.requestCameraAuthorization { [weak self] status in
            switch status {
            case .granted:
                self?.goToCamera()
            case .notRequested:
                break
            case .unauthorized:
                self?.configureAllowButtonForDisabled()
            }
        }
    }
    
    // MARK: - @IBActions
    @IBAction private func tappedAllowButton(_ sender: UIButton) {
        switch CameraAuthorizationManager.getCameraAuthorizationStatus() {
        case .granted:
            break
        case .notRequested:
            makeRequest()
        case .unauthorized:
            openSettings()
        }
    }
}
