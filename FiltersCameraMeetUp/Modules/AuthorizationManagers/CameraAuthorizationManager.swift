//
//  CameraAuthorizationController.swift
//  TestTaskTurkcell
//
//  Created by User on 6/23/21.
//

import Foundation
import AVFoundation

enum CameraAuthorizationStatus {
    case granted
    case notRequested
    case unauthorized
}

typealias RequestCameraAuthCompletionHandler = (CameraAuthorizationStatus) -> Void

class CameraAuthorizationManager {
    
    static func requestCameraAuthorization(completionHandler: @escaping RequestCameraAuthCompletionHandler) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            DispatchQueue.main.async {
                guard granted else {
                    completionHandler(.unauthorized)
                    return
                }
                completionHandler(.granted)
            }
        }
    }
    
    static func getCameraAuthorizationStatus() -> CameraAuthorizationStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized: return .granted
        case .notDetermined: return .notRequested
        default: return .unauthorized
        }
    }
    
}
