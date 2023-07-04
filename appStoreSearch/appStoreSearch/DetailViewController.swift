//
//  DetailViewController.swift
//  appStoreSearch
//
//  Created by 박병훈 on 2023/07/01.
//

import Foundation
import UIKit
import Cosmos

class DetailViewController: UIViewController {
    @IBOutlet weak var appIconImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var noteView: UIView!
    @IBOutlet weak var noteLabel: UILabel!
    @IBOutlet weak var screenshotCollectionView: UICollectionView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var noteMoreBtn: UIButton!
    @IBOutlet weak var descriptionMoreBtn: UIView!
    @IBOutlet weak var descriptionView: UIView!
    
    var app: App!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.isNavigationBarHidden = false
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        screenshotCollectionView.isPagingEnabled = false
        
        appIconImageView.image = app.iconImage
        titleLabel.text = app.name
        ratingView.rating = app.rating
        
        noteLabel.text = truncatedText(app.releaseNotes, maxLines: 3)
        
        noteLabel.isUserInteractionEnabled = false
        noteView.heightAnchor.constraint(equalTo: noteLabel.heightAnchor).isActive = true
        
        screenshotCollectionView.dataSource = self
        screenshotCollectionView.delegate = self
        screenshotCollectionView.reloadData()
        
        descriptionLabel.text = truncatedText(app.description, maxLines: 3)
        descriptionLabel.isUserInteractionEnabled = false
        descriptionView.heightAnchor.constraint(equalTo: descriptionLabel.heightAnchor).isActive = true
        
        setupRationView()
    }
    
    func truncatedText(_ text: String, maxLines: Int) -> String {
        let lines = text.components(separatedBy: .newlines)
        let truncatedLines = Array(lines.prefix(maxLines))
        return truncatedLines.joined(separator: "\n")
    }
    
    private func setupRationView(){
        ratingView.settings.disablePanGestures = true
        ratingView.settings.filledColor = UIColor.systemGray2
        ratingView.settings.emptyBorderColor = UIColor.systemGray2
        ratingView.settings.filledBorderColor = UIColor.systemGray2
        ratingView.settings.fillMode = .precise
        ratingView.settings.starSize = 15
        ratingView.settings.starSize = 3
        
    }
    
    @IBAction func noteMoreBtnClicked(_ sender: Any) {
        noteLabel.text = app.releaseNotes
        noteMoreBtn.isHidden = true
    }
    
    @IBAction func descriptionMoreBtnClicked(_ sender: Any) {
        descriptionLabel.text = app.description
        descriptionMoreBtn.isHidden = true
    }
    
}

extension DetailViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return app.screenshotImageUrls.count
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
                    print("로드 성공")
                    
                    cell.configure(with: image)
//                    cell.setCornerRadius(8)
                } else {
                    print("로드 실패")
                }
            }
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let cellWidth = collectionView.bounds.width / 1.7
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
