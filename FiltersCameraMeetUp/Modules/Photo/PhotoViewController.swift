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
    
    @objc private func saveImageError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("# PhotoViewController: saveImageError: \(error.localizedDescription)")
        } else {
            print("# PhotoViewController: saveImageError: saved successful")
        }
    }
    
    @IBAction private func tappedSaveButton(_ sender: Any) {
        guard let img = photo else { return }
        UIImageWriteToSavedPhotosAlbum(img, self, #selector(saveImageError), nil)
    }
}
