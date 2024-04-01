//
//  ScreenshotCell.swift
//  appStoreSearch
//
//  Created by 박병훈 on 2023/07/03.
//

import Foundation
import UIKit

class ScreenshotCell: UICollectionViewCell {
    @IBOutlet weak var screenshotImageView: UIImageView!
    
    func configure(with screenshot: UIImage) {
            screenshotImageView.image = screenshot
            applyShadowAndCornerRadius()
        }
        
        private func applyShadowAndCornerRadius() {
            applyCornerRadius(15)
            applyShadow()
        }
        
        private func applyCornerRadius(_ radius: CGFloat) {
            screenshotImageView.layer.cornerRadius = radius
            screenshotImageView.layer.borderWidth = 0.1
            screenshotImageView.layer.borderColor = UIColor.systemGray3.cgColor
            screenshotImageView.layer.masksToBounds = true
        }
        
        private func applyShadow() {
            screenshotImageView.layer.shadowColor = UIColor.systemGray2.cgColor
            screenshotImageView.layer.shadowOpacity = 0.8
            screenshotImageView.layer.shadowRadius = 15
        }
}

