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
}

struct ItemViewModel {
    let item: Item

    var id: NSManagedObjectID { item.objectID }

    var title: String { item.title ?? "" }

    var priority: Int { Int( item.priority ) }

    var completed: Bool { item.completed }
}
