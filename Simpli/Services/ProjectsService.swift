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
        newProject.color = UIColor.systemPurple
        newProject.dateCreated = Date()
        newProject.closed = false
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
            newItem.completed = false
            newItem.priority = Int16.random(in: 1...3)
            applyChanges()
        } else {
            print("DEBUG: Couldn't find project")
        }
    }

    func switchItemCompletion(itemId: NSManagedObjectID) {
        if let item = Item.byId(id: itemId) as? Item {
            item.completed.toggle()
            applyChanges()
        } else {
            print("DEBUG: Cannot find this item in db")
        }
    }

    func updateProject(projectID: NSManagedObjectID, newName: String, newClosedStatus: Bool, newColor: UIColor) {
        if let project = Project.byId(id: projectID) as? Project {
            project.color = newColor
            project.title = newName
            project.closed = newClosedStatus
            applyChanges()
        } else {
            print("DEBUG: Project not found")
        }
    }

}
