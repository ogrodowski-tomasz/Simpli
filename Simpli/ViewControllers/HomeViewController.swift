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
        let tableView = UITableView()
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
    }

    private func layout() {
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 0),
            tableView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 0),
            tableView.bottomAnchor.constraint(equalToSystemSpacingBelow: view.bottomAnchor, multiplier: 0),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: tableView.trailingAnchor, multiplier: 0)
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
        tableView.deselectRow(at: indexPath, animated: true)
        let item = projects[indexPath.section].items[indexPath.row]
        print("DEBUG: Should go to editView of item with name: \(item.title)")
        projectService.switchItemCompletion(itemId: item.id)
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
        footer.configure(id: projects[section].id)
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
        let bgColor = project.color.withAlphaComponent(backgroundColorResolver(rowIndex: indexPath.row, numberOfRowsInSection: tableView.numberOfRows(inSection: indexPath.section)))
        let itemVM = project.items[indexPath.row]
        cell.configure(itemVM: itemVM, bgColor: bgColor)
        return cell
    }

    func backgroundColorResolver(rowIndex: Int, numberOfRowsInSection: Int) -> CGFloat {
        1 - ( CGFloat(rowIndex) / CGFloat(numberOfRowsInSection) )
    }
}

// MARK: - SectionHeaderDelegate

extension HomeViewController: SectionHeaderDelegate {
    func addItemButtonTapped(projectId: NSManagedObjectID) {
        print("DEBUG: HomeViewController should perform addition of item to project with id: \(projectId)")
        projectService.addItemToProject(projectId: projectId)
    }
}

// MARK: - SectionFooterDelegate

extension HomeViewController: SectionFooterDelegate {

    func editProjectTapped(projectID: NSManagedObjectID) {
        print("DEBUG: HomeViewController should navigate to editview of project with id: \(projectID)")
    }

    func deleteProjectTapped(projectID: NSManagedObjectID) {
        print("DEBUG: HomeViewController should perform deletion of project with id: \(projectID)")
        projectService.deleteProject(id: projectID)
    }
}


