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
    
    var CosmosSetting = CosmosSettings()
    
    weak var delegate: SearchResultCellDelegate?

    func configure(with app: App) {
        self.app = app
        
        setupRationView()
        setupUI()
        
        screenshotCollectionView.dataSource = self
        screenshotCollectionView.delegate = self
        
        appIconImageView.image = app.iconImage
        titleLabel.text = app.name
        ratingView.rating = app.rating
        ratingView.text = formatNumber(app.userRatingCount)
        screenshotCollectionView.reloadData()
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0))
    }

    
    
    private func setupUI(){
        appIconImageView.layer.cornerRadius = appIconImageView.frame.width/5
        appIconImageView.layer.borderWidth = 0.1
        appIconImageView.layer.borderColor = UIColor.systemGray3.cgColor
        
        downloadBtn.titleLabel?.textColor = UIColor.systemBlue
        downloadBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .bold)
        downloadBtn.backgroundColor = UIColor.systemGray6
        downloadBtn.isUserInteractionEnabled = false
        downloadBtn.layer.cornerRadius = 10
    }
    
    private func setupRationView(){
        CosmosSetting.updateOnTouch = false
        CosmosSetting.filledColor = UIColor.systemGray2
        CosmosSetting.emptyBorderColor = UIColor.systemGray2
        CosmosSetting.filledBorderColor = UIColor.systemGray2
        CosmosSetting.fillMode = .precise
        CosmosSetting.starSize = 13
        CosmosSetting.starMargin = 1
        
        CosmosSetting.textFont = UIFont.systemFont(ofSize: 13)
        
        ratingView.settings = CosmosSetting
    }
    
}

extension SearchResultCell: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
{
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if app!.screenshotImageUrls.count > 2{
            return 3
        }else{
            return app!.screenshotImageUrls.count
        }
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("collectionView click")
        
        delegate?.searchResultCell(self, didSelectItemAt: indexPath)
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = collectionView.bounds.width / 3.2
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

protocol SearchResultCellDelegate: AnyObject {
    func searchResultCell(_ cell: SearchResultCell, didSelectItemAt indexPath: IndexPath)
}
