//
//  ProjectsService.swift
//  Simpli
//
//  Created by Tomasz Ogrodowski on 02/02/2023.
//

import Combine
import CoreData
import Foundation
import UIKit

class ProjectsService {

    let subject = CurrentValueSubject<[ProjectViewModel], Error>([])

    init() {
        fetchProjects()
    }

    private func fetchProjects() {
        let request = Project.fetchRequest()
        do {
            let projects: [Project] = try CoreDataManager.shared.viewContext.fetch(request)
            subject.send(projects.map(ProjectViewModel.init))
        } catch  {
            print("DEBUG: error")
        }
    }

    func addProject() {
        let newProject = Project(context: CoreDataManager.shared.viewContext)
        newProject.title = "New Project"
        newProject.color = UIColor.systemTeal
        applyChanges()
    }

    func applyChanges() {
        try? CoreDataManager.shared.viewContext.save()
        fetchProjects()
    }

    func deleteProject(id: NSManagedObjectID) {
        if let project = Project.byId(id: id) as? Project {
            project.delete()
            applyChanges()
        } else {
            print("DEBUG: Cannot find this project in database")
        }
    }

    func addItemToProject(projectId: NSManagedObjectID) {
        if let project = Project.byId(id: projectId) as? Project {
            let newItem: Item = Item(context: CoreDataManager.shared.viewContext)
            newItem.title = "Item num #\(Int.random(in: 1...5))"
            newItem.project = project
            applyChanges()
        } else {
            print("DEBUG: Couldn't find project")
        }
    }

}
