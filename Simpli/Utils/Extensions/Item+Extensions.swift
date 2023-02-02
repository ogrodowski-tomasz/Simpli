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

}
