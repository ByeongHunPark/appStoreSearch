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
    }
}

