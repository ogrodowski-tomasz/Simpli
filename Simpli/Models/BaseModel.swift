//
//  BaseModel.swift
//  Simpli
//
//  Created by Tomasz Ogrodowski on 02/02/2023.
//

import CoreData
import Foundation

protocol BaseModel: NSManagedObject where Self: NSManagedObject {
    func save()
    func delete()
    static func byId<T: NSManagedObject>(id: NSManagedObjectID) -> T?
    static func all<T: NSManagedObject>() -> [T]
}

extension BaseModel {

    static var viewContext: NSManagedObjectContext { CoreDataManager.shared.viewContext }

    func save() {
        do {
            try Self.viewContext.save()
        } catch  {
            Self.viewContext.rollback()
            print("DEBUG: Error saving context: \(error)")
        }
    }

    func delete() {
        Self.viewContext.delete(self)
        save()
    }

    static func all<T: NSManagedObject>() -> [T] {
        let fetchRequest: NSFetchRequest<T> = NSFetchRequest(entityName: String(describing: T.self))
        do {
            return try viewContext.fetch(fetchRequest)
        } catch  {
            print("DEBUG: Failed to fetch all: \(error)")
            return []
        }
    }

    static func byId<T: NSManagedObject>(id: NSManagedObjectID) -> T? {
        do {
            return try CoreDataManager.shared.viewContext.existingObject(with: id) as? T
        } catch  {
            print("DEBUG: Error fetching object by id (\(id)) : \(error)")
            return nil
        }
    }



}
