//
//  GridCollectionViewCell.swift
//  GridChallengeUIKit
//
//  Created by Alexey Yashin on 29.04.2021.
//

import UIKit

class GridCollectionViewCell: UICollectionViewCell {
    @IBOutlet var imageArray: [UIImageView]!
    
    func change(images: [UIImage?]) {
        for (i, image) in images.enumerated() {
            var startIndex = 0
            if (imageArray.count > images.count) {
                startIndex = (imageArray.count - images.count) / 2
            }
            let imageView = imageArray[i + startIndex]
            imageView.image = image
//            UIView.transition(
//                with: imageView,
//                duration: 1.0,
//                options: .transitionCrossDissolve,
//                animations: {
//                    imageView.image = image
//                },
//                completion: nil
//            )
        }
    }
}
