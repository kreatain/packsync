//
//  PhotoFullScreenViewController.swift
//  Packsync
//
//  Created by 许多 on 11/17/24.
//

import UIKit

class PhotoFullScreenViewController: UIViewController {
    var photoImage: UIImage?

    private let imageView = UIImageView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupImageView()
    }

    private func setupImageView() {
        imageView.contentMode = .scaleAspectFit
        imageView.image = photoImage
        imageView.frame = view.bounds
        imageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(imageView)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissFullScreen))
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissFullScreen() {
        dismiss(animated: true)
    }
}
