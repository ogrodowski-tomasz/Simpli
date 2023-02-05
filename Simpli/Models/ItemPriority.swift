//
//  ItemPriority.swift
//  Simpli
//
//  Created by Tomasz Ogrodowski on 05/02/2023.
//

import Foundation

enum ItemPriority: Int16, CaseIterable {
    case low = 0
    case medium = 1
    case high = 2

    var description: String {
        switch self {
        case .low: return "⭐️"
        case .medium: return "⭐️⭐️"
        case .high: return "⭐️⭐️⭐️"
        }
    }
}
