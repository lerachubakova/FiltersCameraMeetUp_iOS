//
//  PhotoViewController.swift
//  FiltersCameraMeetUp
//
//  Created by User on 14.07.21.
//

import UIKit

class PhotoViewController: UIViewController {

    @IBOutlet private weak var photoImageView: UIImageView!
    
    private var photo: UIImage?
    
    func setImage(img: UIImage?) {
        self.photo = img
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        photoImageView.image = photo
    }
    
    private func configureNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }

}
