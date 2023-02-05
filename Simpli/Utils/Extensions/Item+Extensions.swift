//
//  Item+Extensions.swift
//  Simpli
//
//  Created by Tomasz Ogrodowski on 02/02/2023.
//

import CoreData
import Foundation

extension Item: BaseModel {

    static func getItems(projectId: NSManagedObjectID) -> [Item] {
        let request = Item.fetchRequest()
        request.predicate = NSPredicate(format: "project = %@", projectId)
        do {
            return try Item.viewContext.fetch(request)
        } catch  {
            print("DEBUG: Failed to fetch items: \(error)")
            return []
        }
    }

    static func getTop10() -> [Item] {
        let request = Item.fetchRequest()
        request.predicate = NSPredicate(format: "%K = false", #keyPath(Item.completed))
        request.fetchLimit = 10
        do {
            let fetcheditems = try Item.viewContext.fetch(request)
            print("DEBUG: Fetched \(fetcheditems.count) items")
            return fetcheditems
        } catch {
            print("DEBUG: Failed to fetch top10 items: \(error)")
            return []
        }
    }

}
