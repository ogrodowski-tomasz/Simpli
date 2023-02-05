//
//  HomeViewController.swift
//  Simpli
//
//  Created by Tomasz Ogrodowski on 02/02/2023.
//

import Combine
import CoreData
import UIKit

class HomeViewController: UIViewController {

    // MARK: - View Components

    private let tableHeader = HomeTableHeaderView(frame: CGRect(x: 0, y: 0, width: 0, height: HomeTableHeaderView.height + 50))

    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = Constans.appColor
        tableView.register(ItemTableViewCell.self, forCellReuseIdentifier: ItemTableViewCell.id)
        tableView.register(HomeTableSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: HomeTableSectionHeaderView.id)
        tableView.register(HomeTableSectionFooterView.self, forHeaderFooterViewReuseIdentifier: HomeTableSectionFooterView.id)
        return tableView
    }()

    // MARK: - Properties

    private var cancellables = Set<AnyCancellable>()
    private let projectService = ProjectsService()

    private var projects = [ProjectViewModel]() {
        didSet { tableView.reloadData() }
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constans.appColor
        setupNavigationBar()
        setupTableView()
        layout()
        setupProjectSubscription()
    }

    // MARK: - Methods

    private func setupNavigationBar() {
        setTitle("Simpli", andImage: UIImage(systemName: "figure.wave.circle.fill")!)
        let rightButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .plain, target: self, action: #selector(plusButtonTapped))
        rightButton.tintColor = Constans.appFontColor

        navigationItem.setRightBarButton(rightButton, animated: true)
    }

    private func setupTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = tableHeader
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = Constans.appColor
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }

    private func layout() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 0),
            tableView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 0),
            tableView.bottomAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.bottomAnchor, multiplier: 0),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: tableView.trailingAnchor, multiplier: 0)
        ])
    }

    private func setupProjectSubscription() {
        projectService.subject
            .sink { completion in
                switch completion {
                case .finished:
                    print("DEBUG: Subscription finished successfully")
                case .failure(let error):
                    print("DEBUG: Subscription finished with failure: \(error)")
                }
            } receiveValue: { [weak self] fetchedProjects in
                print("DEBUG: Received new value!")
                self?.projects = fetchedProjects
            }
            .store(in: &cancellables)
    }

    // MARK: - Selectors

    @objc
    private func plusButtonTapped() {
        print("DEBUG: plus tapped")
        projectService.addProject()
        
    }
}

// MARK: - UITableViewDelegate

extension HomeViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        let item = projects[indexPath.section].items[indexPath.row]
        let editItemVC = EditItemViewController(item: item)
        editItemVC.delegate = self
        navigationController?.pushViewController(editItemVC, animated: true)
    }

    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let updateItemCompletionAction = UIContextualAction(style: .normal, title: "Switch Completion") { action, sourceView, completionHandler in
            let item = self.projects[indexPath.section].items[indexPath.row]
            self.projectService.switchItemCompletion(itemId: item.id)
            completionHandler(true)
        }
        updateItemCompletionAction.backgroundColor = .systemGreen
        updateItemCompletionAction.image = UIImage(systemName: "checkmark")

        let swipeAction = UISwipeActionsConfiguration(actions: [updateItemCompletionAction])

        return swipeAction
    }

    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteItemAction = UIContextualAction(style: .destructive, title: "Delete") { action, sourceView, completionHandler in
            let item = self.projects[indexPath.section].items[indexPath.row]
            self.projectService.deleteItem(id: item.id)
            completionHandler(true)
        }
        let swipeAction = UISwipeActionsConfiguration(actions: [deleteItemAction])
        return swipeAction
    }
}

// MARK: - UITableViewDataSource

extension HomeViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return projects.count
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: HomeTableSectionHeaderView.id) as? HomeTableSectionHeaderView else {
            return UIView()
        }
        header.delegate = self
        header.configure(projectVM: projects[section])

        return header
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        guard let footer = tableView.dequeueReusableHeaderFooterView(withIdentifier: HomeTableSectionFooterView.id) as? HomeTableSectionFooterView else {
            return UIView()
        }
        footer.delegate = self
        footer.configure(project: projects[section])
        return footer
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 50
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return projects[section].items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ItemTableViewCell.id, for: indexPath) as? ItemTableViewCell else {
            return UITableViewCell()
        }
        let project = projects[indexPath.section]
        let bgColor = project.color.withAlphaComponent(
            backgroundColorOpacityResolver(
                rowIndex: indexPath.row,
                numberOfRowsInSection: tableView.numberOfRows(inSection: indexPath.section)
            )
        )
        let itemVM = project.items[indexPath.row]
        cell.configure(itemVM: itemVM, bgColor: bgColor)
        return cell
    }

    func backgroundColorOpacityResolver(rowIndex: Int, numberOfRowsInSection: Int) -> CGFloat {
        1 - ( CGFloat(rowIndex) / CGFloat(numberOfRowsInSection) )
    }
}

// MARK: - SectionHeaderDelegate

extension HomeViewController: SectionHeaderDelegate {
    func addItemButtonTapped(projectId: NSManagedObjectID) {
        projectService.addItemToProject(projectId: projectId)
    }
}

// MARK: - SectionFooterDelegate

extension HomeViewController: SectionFooterDelegate {

    func editProjectTapped(project: ProjectViewModel) {
        let editProjectVc = EditProjectViewController(project: project)
        editProjectVc.delegate = self
        navigationController?.pushViewController(editProjectVc, animated: true)
    }

    func deleteProjectTapped(project: ProjectViewModel) {
        projectService.deleteProject(id: project.id)
    }
}

// MARK: - EditProjectViewDelegate
extension HomeViewController: EditProjectViewDelegate {
    func updateProject(projectID: NSManagedObjectID, newName: String, newClosedStatus: Bool, newColor: UIColor) {
        projectService.updateProject(projectID: projectID, newName: newName, newClosedStatus: newClosedStatus, newColor: newColor)
    }
}

// MARK: - EditItemDelegate

extension HomeViewController: EditItemDelegate {
    func updateItem(id: NSManagedObjectID, newName: String, newPriority: Int, newCompletionStatus: Bool) {
        projectService.updateItem(id: id, newName: newName, newPriority: newPriority, newCompletionStatus: newCompletionStatus)
    }
}
