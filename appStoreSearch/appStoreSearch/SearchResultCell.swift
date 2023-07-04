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
    @IBOutlet weak var downloadBtn: UIButton!
    
    var app: App?
    
    func configure(with app: App) {
        self.app = app
        
        setupRationView()
        
        screenshotCollectionView.dataSource = self
        screenshotCollectionView.delegate = self
        
        appIconImageView.layer.cornerRadius = appIconImageView.frame.width/8
        
        appIconImageView.image = app.iconImage
        titleLabel.text = app.name
        ratingView.rating = app.rating
        ratingView.text = formatNumber(app.userRatingCount)
        screenshotCollectionView.reloadData()
        
        setupUI()
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 12, right: 0))
    }
    
    private func setupUI(){
        downloadBtn.titleLabel?.textColor = UIColor.systemBlue
        downloadBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        downloadBtn.backgroundColor = UIColor.systemGray6
        
        downloadBtn.layer.cornerRadius = 10
    }
    
    private func setupRationView(){
        ratingView.settings.disablePanGestures = true
        ratingView.settings.filledColor = UIColor.systemGray2
        ratingView.settings.emptyBorderColor = UIColor.systemGray2
        ratingView.settings.filledBorderColor = UIColor.systemGray2
        ratingView.settings.fillMode = .precise
        ratingView.settings.starSize = 13
        ratingView.settings.starMargin = 1
        
        ratingView.settings.textFont = UIFont.systemFont(ofSize: 13)
        
    }
    
}

extension SearchResultCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("count \(app!.screenshotImageUrls.count)")
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScreenshotCell", for: indexPath) as? ScreenshotCell else {
            return UICollectionViewCell()
        }
        
        let screenshotUrlString = app!.screenshotImageUrls[indexPath.item]
        let screenshotUrl = URL(string: screenshotUrlString)
        
        fetchScreenshotImage(from: screenshotUrl!) { image in
            DispatchQueue.main.async {
                if let image = image {
                    cell.configure(with: image)
                } else {
                    print("로드 실패!!!")
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 컬렉션뷰 셀의 크기 설정
        
        let cellWidth = collectionView.bounds.width / 3.5
        let cellHeight = collectionView.bounds.height
        return CGSize(width: cellWidth, height: cellHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    private func fetchScreenshotImage(from url: URL, completion: @escaping (UIImage?) -> Void) {
        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                print("Error loading screenshot image: \(error)")
                completion(nil)
                return
            }
            
            if let data = data, let image = UIImage(data: data) {
                completion(image)
            } else {
                completion(nil)
            }
        }.resume()
    }
    
}

