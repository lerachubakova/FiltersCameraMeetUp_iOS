//
//  CameraViewController.swift
//  FiltersCameraMeetUp
//
//  Created by User on 13.07.21.
//

import UIKit

class CameraViewController: UIViewController {

    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureAppearance()
    }
 
    // MARK: - Setup
    func configureAppearance() {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

}
