//
//  Project+Extensions.swift
//  Simpli
//
//  Created by Tomasz Ogrodowski on 02/02/2023.
//

import CoreData
import Foundation

extension Project: BaseModel {

    static var all: NSFetchRequest<Project> {
        let request = Project.fetchRequest()

        return request
    }

}
