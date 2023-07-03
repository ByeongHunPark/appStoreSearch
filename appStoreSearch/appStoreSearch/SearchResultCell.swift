//
//  SearchResultCell.swift
//  appStoreSearch
//
//  Created by 박병훈 on 2023/07/01.
//

import Foundation
import UIKit
import Cosmos

class SearchResultCell: UITableViewCell {
    @IBOutlet weak var appIconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var screenshotCollectionView: UICollectionView!
    
    var app: App?
    
    func configure(with app: App) {
        self.app = app
        setupRationView()
        
        print("rating \(app.rating)")
        print("ssimg \(self.app!.screenshotImageUrls) ")
        
        
        appIconImageView.image = app.iconImage
        titleLabel.text = app.name
        ratingView.rating = app.rating
        screenshotCollectionView.reloadData()
    }
    
    func setupRationView(){
        ratingView.settings.filledColor = UIColor.systemGray2
        ratingView.settings.emptyBorderColor = UIColor.systemGray2
        ratingView.settings.filledBorderColor = UIColor.systemGray2
        ratingView.settings.fillMode = .precise
        ratingView.settings.starSize = 5
        ratingView.settings.starMargin = 2
    }
    
}

extension SearchResultCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("count \(app!.screenshotImageUrls.count)")
        return app!.screenshotImageUrls.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScreenshotCell", for: indexPath) as? ScreenshotCell else {
            return UICollectionViewCell()
        }
        
        let screenshotUrlString = app!.screenshotImageUrls[indexPath.item]
        let screenshotUrl = URL(string: screenshotUrlString)
        let screenshotData = try? Data(contentsOf: screenshotUrl!)
        
        
        cell.screenshotImageView.image = UIImage(data: screenshotData!)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 컬렉션뷰 셀의 크기 설정
        let cellWidth = collectionView.bounds.width
        let cellHeight = collectionView.bounds.height
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
}
