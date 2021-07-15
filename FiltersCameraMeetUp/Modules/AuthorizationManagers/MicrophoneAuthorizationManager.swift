//
//  RequestMicrophoneAuthorizationController.swift
//  TestTaskTurkcell
//
//  Created by User on 6/23/21.
//

import AVFoundation
import Foundation

enum MicrophoneAuthorizationStatus {
    case granted
    case notRequested
    case unauthorized
}

typealias RequestMicrophoneAuthCompletionHandler = (MicrophoneAuthorizationStatus) -> Void

class MicrophoneAuthorizationManager {
    
    static func requestMicrophoneAuthorization(completionHandler: @escaping RequestMicrophoneAuthCompletionHandler) {
        AVCaptureDevice.requestAccess(for: .audio, completionHandler: { granted in
            DispatchQueue.main.async {
                guard granted else {
                    completionHandler(.unauthorized)
                    return
                }
                completionHandler(.granted)
            }
        })
    }
    
    static func getMicrophoneAuthorizationStatus() -> MicrophoneAuthorizationStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        switch status {
        case .authorized: return .granted
        case .notDetermined: return .notRequested
        default: return .unauthorized
        }
    }
    
}
