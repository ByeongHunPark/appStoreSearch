//
//  RatingView.swift
//  appStoreSearch
//
//  Created by 박병훈 on 2023/07/03.
//

import Foundation
import UIKit

class RatingView: UIView {
    private var ratingImageViews: [UIImageView] = []
    
    var rating: Double = 0 {
        didSet {
            updateRating()
        }
    }
    
    var labelHeight : CGFloat = 15
    
    private let maxRating: Double = 5
    private let starImage: UIImage = UIImage(systemName: "star")!
    private let starHalfFilledImage: UIImage = UIImage(systemName: "star.leadinghalf.filled")!
    private let starFilledImage: UIImage = UIImage(systemName: "star.fill")!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupRatingImageViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupRatingImageViews()
    }
    
    private func setupRatingImageViews() {
        for _ in 0..<Int(maxRating) {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            addSubview(imageView)
            ratingImageViews.append(imageView)
        }
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: labelHeight)
        ])
    }
    
    private func updateRating() {
        for (index, imageView) in ratingImageViews.enumerated() {
            if Double(index) < rating {
                imageView.image = starFilledImage
            } else {
                imageView.image = starImage
            }
        }
    }
    
    func setRating(_ rating: Double) {
        self.rating = rating
    }
}
