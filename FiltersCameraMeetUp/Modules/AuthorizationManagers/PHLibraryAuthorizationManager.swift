//
//  RequestPhotoLibraryAuthorizationController.swift
//  TestTaskTurkcell
//
//  Created by User on 6/23/21.
//

import Foundation
import Photos

enum PhotoLibraryAuthorizationStatus {
    case granted
    case notRequested
    case unauthorized
}

typealias RequestPhotoLibraryAuthCompletionHandler = (PhotoLibraryAuthorizationStatus) -> Void

class PHLibraryAuthorizationManager {
    
    static func requestPhotoLibraryAuthorization(completionHandler: @escaping RequestPhotoLibraryAuthCompletionHandler) {
        DispatchQueue.main.async {
            if #available(iOS 14, *) {
                PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
                    guard status == .authorized else {
                        completionHandler(.unauthorized)
                        return
                    }
                    completionHandler(.granted)
                }
            } else {
                print("requestPhotoLibraryAuthorization: old iOS version")
            }

        }
    }
    
    static func getPhotoLibraryAuthorizationStatus() -> PhotoLibraryAuthorizationStatus {
        if #available(iOS 14, *) {
            let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
            switch status {
            case .authorized: return .granted
            case .notDetermined: return .notRequested
            default: return .unauthorized
            }
        } else {
            print("requestPhotoLibraryAuthorization: old iOS version")
        }
        return .notRequested
    }
    
}
