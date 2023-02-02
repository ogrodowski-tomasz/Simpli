//
//  HomeViewController.swift
//  Simpli
//
//  Created by Tomasz Ogrodowski on 02/02/2023.
//

import CoreData
import UIKit

class HomeViewController: UIViewController {

    private let tableHeader = HomeTableHeaderView(frame: CGRect(x: 0, y: 0, width: 0, height: HomeTableHeaderView.height + 50))

    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = Constans.appColor
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.register(HomeTableSectionHeaderView.self, forHeaderFooterViewReuseIdentifier: HomeTableSectionHeaderView.id)
        tableView.register(HomeTableSectionFooterView.self, forHeaderFooterViewReuseIdentifier: HomeTableSectionFooterView.id)
        return tableView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constans.appColor
        setupNavigationBar()
        setupTableView()
        layout()
        fetchData()
    }

    private var projects = [ProjectViewModel]() {
        didSet { tableView.reloadData() }
    }

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

    @objc
    private func plusButtonTapped() {
        print("DEBUG: plus tapped")
        let newProject = Project(context: CoreDataManager.shared.viewContext)
        newProject.title = "New Project"
        newProject.color = UIColor.systemTeal
        try? CoreDataManager.shared.viewContext.save()
        fetchData()
    }

    private func fetchData() {
        let request = Project.fetchRequest()
        do {
            let projects: [Project] = try CoreDataManager.shared.viewContext.fetch(request)
            self.projects = projects.map(ProjectViewModel.init)
        } catch  {
            print("DEBUG: error")
        }
    }
}

extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

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
        return 10
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.textColor = Constans.appFontColor
//        let project = projects[indexPath.row]
        cell.backgroundColor = .systemRed.withAlphaComponent(1 - (CGFloat(indexPath.row) / CGFloat(tableView.numberOfRows(inSection: indexPath.section))))
        cell.textLabel?.text = "Cell #\(indexPath.row)"
        return cell
    }
}

extension HomeViewController: SectionHeaderDelegate {
    func addItemButtonTapped(projectId: NSManagedObjectID) {
        print("DEBUG: HomeViewController should perform addition of item to project with id: \(projectId)")
    }

}

extension HomeViewController: FooterDelegate {

    func editProjectTapped(projectID: NSManagedObjectID) {
        print("DEBUG: HomeViewController should navigate to editview of project with id: \(projectID)")
    }

    func deleteProjectTapped(projectID: NSManagedObjectID) {
        print("DEBUG: HomeViewController should perform deletion of project with id: \(projectID)")
    }
}


