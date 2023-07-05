//
//  Format.swift
//  appStoreSearch
//
//  Created by 박병훈 on 2023/07/03.
//

import Foundation


func formatNumber(_ number: Int) -> String {
    let numberFormatter = NumberFormatter()
    
    if number < 1000 {
        return numberFormatter.string(from: NSNumber(value: number)) ?? ""
    } else if number < 10_000 {
        let formattedNumber = Double(number) / 1000.0
        return String(format: "%.1f천", formattedNumber)
    } else {
        let formattedNumber = Double(number) / 10_000.0
        return String(format: "%.1f만", formattedNumber)
    }
}
