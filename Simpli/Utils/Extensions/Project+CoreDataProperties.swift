//
//  Project+CoreDataProperties.swift
//  Simpli
//
//  Created by Tomasz Ogrodowski on 02/02/2023.
//

import CoreData
import Foundation
import UIKit

extension Project {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Project> {
        return NSFetchRequest<Project>(entityName: "Project")
    }

    @NSManaged public var color: UIColor?
    @NSManaged public var closed: Bool
    @NSManaged public var title: String?
    @NSManaged public var dateCreated: Date?

}

@objc(Project)
public class Project: NSManagedObject { }
