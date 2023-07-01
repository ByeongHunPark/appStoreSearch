//
//  DetailViewController.swift
//  appStoreSearch
//
//  Created by 박병훈 on 2023/07/01.
//

import Foundation
import UIKit

class DetailViewController: UIViewController {
    @IBOutlet weak var appIconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var screenshotImageView: UIImageView!
    @IBOutlet weak var descriptionLabel: UILabel!
    
    var app: App!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 앱 정보 표시
        appIconImageView.image = app.iconImage
        titleLabel.text = app.name
        screenshotImageView.image = app.screenshotImage
        descriptionLabel.text = app.description
    }
}
