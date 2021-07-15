//
//  SceneDelegate.swift
//  FiltersCameraMeetUp
//
//  Created by User on 13.07.21.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let mainNavController = storyboard.instantiateInitialViewController() as! UINavigationController
        mainNavController.viewControllers.removeAll()
       
        var vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "AllowCameraViewController")

        if CameraAuthorizationManager.getCameraAuthorizationStatus() == .granted && MicrophoneAuthorizationManager.getMicrophoneAuthorizationStatus() == .granted {
           vc = UIStoryboard(name: "Camera", bundle: nil).instantiateViewController(identifier: "CameraViewController")
        }

        mainNavController.pushViewController(vc, animated: false)
        
        self.window?.rootViewController = mainNavController
        self.window?.makeKeyAndVisible()
        guard (scene as? UIWindowScene) != nil else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) { }

    func sceneDidBecomeActive(_ scene: UIScene) { }

    func sceneWillResignActive(_ scene: UIScene) { }

    func sceneWillEnterForeground(_ scene: UIScene) { }

    func sceneDidEnterBackground(_ scene: UIScene) { }

}
