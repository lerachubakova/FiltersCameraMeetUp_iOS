//
//  PhotoViewController.swift
//  FiltersCameraMeetUp
//
//  Created by User on 14.07.21.
//

import UIKit

enum PostType {
    case photo
    case video
}

class PhotoViewController: UIViewController {
    // MARK: - @IBOutlets
    @IBOutlet private weak var photoImageView: UIImageView!
    
    private var postType: PostType = .photo
    private var videoURL: URL?
    private var photo: UIImage?
    
    func setImage(img: UIImage?) {
        self.postType = .photo
        self.photo = img
    }
    
    func setURL(url: URL) {
        self.postType = .video
        self.videoURL = url
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        configureScreen()
    }
    
    // MARK: - Setup
    private func configureNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    private func configureScreen() {
        switch postType {
        case .photo:
            photoImageView.isHidden = false
            photoImageView.image = photo
        case .video:
            print("url: \(videoURL)")
        }
    }
    
    // MARK: - @IBActions
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
