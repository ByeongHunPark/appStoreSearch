//
//  SearchResultCell.swift
//  appStoreSearch
//
//  Created by 박병훈 on 2023/07/01.
//

import Foundation
import UIKit

class SearchResultCell: UITableViewCell {
    @IBOutlet weak var appIconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingLabel: UILabel!
    @IBOutlet weak var screenshotImageView1: UIImageView!
    @IBOutlet weak var screenshotImageView2: UIImageView!
    
    func configure(with app: App) {
        titleLabel.text = app.name
        ratingLabel.text = "⭐️ \(app.rating)"
        // 이미지 및 다른 정보 설정
        // ...
    }
}
