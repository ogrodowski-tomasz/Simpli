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

    let projetsSubject = CurrentValueSubject<[ProjectViewModel], Error>([])
    let hotItemsSubject = CurrentValueSubject<[ItemViewModel], Error>([])

    init() {
        fetchData()
    }

    /// Container of methods fetching all data: Projects with its items and Hot Items.
    func fetchData() {
        fetchProjects()
        fetchHotItems()
    }


    /// Fetches projects from db and sends new value to the subscriber
    private func fetchProjects() {
        let request = Project.fetchRequest()
        do {
            let projects: [Project] = try CoreDataManager.shared.viewContext.fetch(request)
            projetsSubject.send(projects.map(ProjectViewModel.init))
        } catch {
            print("DEBUG: Error fetching project: \(error)")
        }
    }


    /// Fetch top 10 uncompleted items and sends them to the subscriber
    private func fetchHotItems() {
        let hotItems = Item.getTop10().map(ItemViewModel.init)
        hotItemsSubject.send(hotItems)
    }


    /// Add new project with default values
    func addProject() {
        let newProject = Project(context: CoreDataManager.shared.viewContext)
        newProject.title = "New Project"
        newProject.color = UIColor.systemPurple
        newProject.dateCreated = Date()
        newProject.closed = false
        applyChanges()
    }


    /// Save view context and fetch updated projects / hot items
    func applyChanges() {
        try? CoreDataManager.shared.viewContext.save()
        fetchData()
    }


    /// Delete certain project
    /// - Parameter id: id of project to delete
    func deleteProject(id: NSManagedObjectID) {
        if let project = Project.byId(id: id) as? Project {
            project.delete()
            applyChanges()
        } else {
            print("DEBUG: Cannot find this project")
        }
    }


    /// Add new item with default values to certain project
    /// - Parameter projectId: id of project to which item should be added to
    func addItemToProject(projectId: NSManagedObjectID) {
        if let project = Project.byId(id: projectId) as? Project {
            let newItem: Item = Item(context: CoreDataManager.shared.viewContext)
            newItem.title = "New Item"
            newItem.project = project
            newItem.completed = false
            newItem.priority = Int16.random(in: 0..<3)
            applyChanges()
        } else {
            print("DEBUG: Cannot find project")
        }
    }


    /// Toggle item completion
    /// - Parameter itemId: id of item which completion status is supposed to be toggled
    func switchItemCompletion(itemId: NSManagedObjectID) {
        if let item = Item.byId(id: itemId) as? Item {
            item.completed.toggle()
            applyChanges()
        } else {
            print("DEBUG: Cannot find this item in db")
        }
    }


    /// Update values of project
    /// - Parameters:
    ///   - projectID: id of project
    ///   - newName: new title for project
    ///   - newClosedStatus: new 'closed' status
    ///   - newColor: new color of project
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


    /// Delete item with certain id
    /// - Parameter id: item's id
    func deleteItem(id: NSManagedObjectID) {
        if let item = Item.byId(id: id) as? Item {
            item.delete()
            applyChanges()
        } else {
            print("DEBUG: Cannot find this item")
        }
    }


    /// Update item with certain parameters
    /// - Parameters:
    ///   - id: item's id (unchangable)
    ///   - newName: new item's title
    ///   - newPriority: new value of item's priority
    ///   - newCompletionStatus: new value of completion
    func updateItem(id: NSManagedObjectID, newName: String, newPriority: Int, newCompletionStatus: Bool) {
        if let item = Item.byId(id: id) as? Item {
            item.title = newName
            item.priority = Int16(newPriority)
            if item.completed != newCompletionStatus {
                item.completed = newCompletionStatus
                item.completionDate = Date()
            }
            applyChanges()
        } else {
            print("DEBUG: Cannot find this item")
        }
    }

}
