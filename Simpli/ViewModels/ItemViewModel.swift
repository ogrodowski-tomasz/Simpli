//
//  ItemViewModel.swift
//  Simpli
//
//  Created by Tomasz Ogrodowski on 06/02/2023.
//

import CoreData
import Foundation
import UIKit

struct ItemViewModel {
    let item: Item

    var id: NSManagedObjectID { item.objectID }

    var title: String { item.title ?? "" }

    var priority: ItemPriority { ItemPriority(rawValue: item.priority) ?? ItemPriority.low }

    var completed: Bool { item.completed }

    var color: UIColor { item.project?.color ?? .white }
}
