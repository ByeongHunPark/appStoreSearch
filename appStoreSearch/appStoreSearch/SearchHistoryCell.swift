//
//  RecentSearchCell.swift
//  appStoreSearch
//
//  Created by 박병훈 on 2023/07/03.
//

import Foundation
import UIKit

class SearchHistoryCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupCell()
    }
    
    private func setupCell() {
        self.selectionStyle = .none
        self.textLabel?.font = UIFont.systemFont(ofSize: 16)
        self.textLabel?.textColor = UIColor.blue
    }
}
