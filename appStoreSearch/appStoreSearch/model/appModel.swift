//
//  appModel.swift
//  appStoreSearch
//
//  Created by 박병훈 on 2023/07/01.
//

import Foundation
import UIKit

struct App : Hashable{
    let name: String
    let rating: Double
    let userRatingCount : Int
    let iconImage: UIImage
    let screenshotImage: UIImage
    let screenshotImageUrls: [String]
    let releaseNotes: String
    let description: String
}

extension App : Equatable{
    static func ==(lhs: App, rhs: App) -> Bool {
        return lhs.name == rhs.name
    }
}
