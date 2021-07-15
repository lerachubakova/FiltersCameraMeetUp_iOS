//
//  PhotoViewController.swift
//  FiltersCameraMeetUp
//
//  Created by User on 14.07.21.
//

import AVFoundation
import Photos
import UIKit

enum PostType {
    case photo
    case video
}

class PhotoViewController: UIViewController {
    // MARK: - @IBOutlets
    @IBOutlet private weak var photoImageView: UIImageView!
    @IBOutlet private weak var videoPlayerView: UIView!
    
    private var postType: PostType = .photo
    
    private var videoURL: URL?
    private var filter: CIFilter?
    private var player: AVPlayer?
    
    private var photo: UIImage?
    
    func setImage(img: UIImage?) {
        self.postType = .photo
        self.photo = img
    }
    
    func setVideo(url: URL, filterName: String) {
        self.postType = .video
        self.videoURL = url
        self.filter = CIFilter(name: filterName)
    }
    
    // MARK: - LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        configureNavigationBar()
        if postType == .photo {
            configurePhotoScreen()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if postType == .video {
            configureVideoScreen()
        }
    }
    
    // MARK: - Setup
    private func configureNavigationBar() {
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        if PHLibraryAuthorizationManager.getPhotoLibraryAuthorizationStatus() != .granted {
            self.navigationItem.rightBarButtonItems?.removeAll()
        }
    }
    
    private func configurePhotoScreen() {
        photoImageView.isHidden = false
        photoImageView.image = photo
    }
    
    private func configureVideoScreen() {
        videoPlayerView.isHidden = false
        guard let inputURL = videoURL else { return }
        if let filter = filter {
            let asset = AVAsset(url: inputURL)
            if let composition = buildComposition(for: asset, with: filter) {
                configureFilteredPlayer(with: asset, composition)
            }
        } else {
            configurePlayer(url: inputURL)
        }
        player?.play()
        
    }
    
    private func configurePlayer(url: URL) {
        let player = AVPlayer(url: url)
        self.player = player
        
        let playerLayer = AVPlayerLayer(player: player)
        videoPlayerView.layer.addSublayer(playerLayer)
        playerLayer.frame = videoPlayerView.bounds
    }
    
    private func configureFilteredPlayer(with asset: AVAsset,_ composition: AVVideoComposition) {
        let item = AVPlayerItem(asset: asset)
        item.videoComposition = composition

        let player = AVPlayer(playerItem: item)
        self.player = player
        
        let playerLayer = AVPlayerLayer(player: player)
        videoPlayerView.layer.addSublayer(playerLayer)
        playerLayer.frame = videoPlayerView.bounds
    }
    
    private func buildComposition(for asset: AVAsset, with filter: CIFilter) -> AVVideoComposition? {
        AVVideoComposition(asset: asset) { (request) in
            let sourceImage = request.sourceImage.clampedToExtent()
            filter.setValue(sourceImage, forKey: kCIInputImageKey)
            request.finish(with: filter.outputImage!, context: nil)
        }
    }

    private func saveFilteredVideoInDirectoryAndLibrary(with asset: AVAsset,_ composition: AVVideoComposition, isFinal: Bool = false) {
        let exportPath = NSTemporaryDirectory().appendingFormat("/video.mov")
        let exportURL = URL(fileURLWithPath: exportPath)
        
        do {
            if FileManager.default.fileExists(atPath: exportURL.path) {
                try FileManager.default.removeItem(at: exportURL)
            }
        } catch {
            print("saveFilteredVideoInDirectoryAndLibrary: \(error.localizedDescription)")
        }

        guard let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else { return }
        exporter.outputURL = exportURL
        exporter.outputFileType = AVFileType.mov
        exporter.shouldOptimizeForNetworkUse = true
        exporter.videoComposition = composition

        exporter.exportAsynchronously { [weak self] in
            switch exporter.status {
            case .unknown, .waiting, .exporting, .failed, .cancelled:
                print("saveFilteredVideoInDirectoryAndLibrary: exportAsynchronously: status not completed")
            case .completed:
                self?.saveVideoInLibrary(url: exportURL)
            @unknown default:
                fatalError()
            }
        }
    }
    
    private func saveVideoInLibrary(url: URL) {
        PHPhotoLibrary.shared().performChanges {
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
        } completionHandler: { (_, error) in
            if let error = error {
                print("saveVideoInLibrary: \(error.localizedDescription)")
            } else {
                print("saveVideoInLibrary: saved successful")
            }
        }
    }
    
    private func saveImageInLibrary(_ img: UIImage) {
        UIImageWriteToSavedPhotosAlbum(img, self, #selector(saveImageError), nil)
    }

    // MARK: - @IBActions
    @objc private func saveImageError(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            print("saveImageError: \(error.localizedDescription)")
        } else {
            print("saveImageError: saved successful")
        }
    }
    
    @IBAction private func tappedSaveButton(_ sender: Any) {
        switch postType {
        case .photo:
            guard let img = photo else { return }
            saveImageInLibrary(img)
        case .video:
            guard let inputURL = videoURL else { return }
            if let filter = filter {
                let asset = AVAsset(url: inputURL)
                if let composition = buildComposition(for: asset, with: filter) {
                    saveFilteredVideoInDirectoryAndLibrary(with: asset, composition)
                }
            } else {
                saveVideoInLibrary(url: inputURL)
            }
        }
    }
}
