//
//  ProjectViewModel.swift
//  Simpli
//
//  Created by Tomasz Ogrodowski on 02/02/2023.
//

import CoreData
import Foundation
import UIKit

struct ProjectViewModel {
    let project: Project

    var id: NSManagedObjectID { project.objectID }

    var title: String { project.title ?? "" }

    var color: UIColor { project.color ?? .clear }

    var items: [ItemViewModel] {
        Item.getItems(projectId: project.objectID).map(ItemViewModel.init)
    }

    var completionStatus: Float {
        var itemsCompleted = 0
        if items.count == 0 {
            return 0
        }
        for item in items {
            if item.completed {
                itemsCompleted += 1
            }
        }

        return Float(itemsCompleted) / Float(items.count)
    }

    var closed: Bool { project.closed }
}

struct ItemViewModel {
    let item: Item

    var id: NSManagedObjectID { item.objectID }

    var title: String { item.title ?? "" }

    var priority: ItemPriority { ItemPriority(rawValue: item.priority) ?? ItemPriority.low }

    var completed: Bool { item.completed }
}
