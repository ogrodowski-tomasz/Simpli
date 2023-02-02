//
//  CoreDataManager.swift
//  Simpli
//
//  Created by Tomasz Ogrodowski on 02/02/2023.
//

import CoreData
import Foundation

class CoreDataManager {
    let persistentContainer: NSPersistentContainer

    static let shared = CoreDataManager()

    var viewContext: NSManagedObjectContext { persistentContainer.viewContext }

    private init() {
        ValueTransformer.setValueTransformer(UIColorTransformer(), forName: NSValueTransformerName("UIColorTransformer"))
        persistentContainer = NSPersistentContainer(name: "ProjectModel")

        persistentContainer.loadPersistentStores { storeDesc, error in
            if let error {
                fatalError("Error initializing Core Data: \(error)")
            }
        }
    }
}
