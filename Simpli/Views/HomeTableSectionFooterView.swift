//
//  HomeTableSectionFooterView.swift
//  Simpli
//
//  Created by Tomasz Ogrodowski on 02/02/2023.
//

import CoreData
import Foundation
import UIKit

/// Footer buttons actions propagator
protocol SectionFooterDelegate: AnyObject {
    /// 'Edit project button' tapped -> should navigate to Edit Item View
    func editProjectTapped(project: ProjectViewModel)
    /// 'Delete project button' tapped -> should delete project from db
    func deleteProjectTapped(project: ProjectViewModel)
}

class HomeTableSectionFooterView: UITableViewHeaderFooterView {

    // MARK: - Properties

    static let id = "HomeTableSectionFooterView"

    static let buttonCornerRadius: CGFloat = 5

    static let buttonBorderWidth: CGFloat = 1

    private var project: ProjectViewModel? = nil

    weak var delegate: SectionFooterDelegate?

    // MARK: - View Components

    private let deleteButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Delete", for: .normal)
        button.setTitleColor(.systemRed, for: .normal)
        let padding = 10.0
        button.layoutMargins = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        button.layer.borderWidth = buttonBorderWidth
        button.layer.borderColor = UIColor.systemRed.cgColor
        button.layer.cornerRadius = buttonCornerRadius
        button.layer.masksToBounds = true
        return button
    }()

    private let editButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Edit", for: .normal)
        button.setTitleColor(Constans.appFontColor, for: .normal)
        let padding = 10.0
        button.layoutMargins = UIEdgeInsets(top: padding, left: padding, bottom: padding, right: padding)
        button.layer.borderWidth = buttonBorderWidth
        button.layer.borderColor = Constans.appFontColor.cgColor
        button.layer.cornerRadius = buttonCornerRadius
        button.layer.masksToBounds = true
        return button
    }()

    // MARK: - Life cycle

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Helpers

    private func setup() {
        backgroundColor = Constans.appColor
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
    }

    private func layout() {
        addSubview(deleteButton)
        addSubview(editButton)

        NSLayoutConstraint.activate([
            deleteButton.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1),
            deleteButton.heightAnchor.constraint(equalToConstant: 50),
            deleteButton.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            editButton.leadingAnchor.constraint(equalToSystemSpacingAfter: deleteButton.trailingAnchor, multiplier: 1),

            editButton.widthAnchor.constraint(equalTo: deleteButton.widthAnchor, constant: 0),
            editButton.heightAnchor.constraint(equalTo: deleteButton.heightAnchor, constant: 0),

            editButton.centerYAnchor.constraint(equalTo: deleteButton.centerYAnchor),
            trailingAnchor.constraint(equalToSystemSpacingAfter: editButton.trailingAnchor, multiplier: 1)
        ])
    }

    func configure(project: ProjectViewModel) {
        self.project = project
    }

    // MARK: - Selectors

    @objc
    private func editButtonTapped() {
        guard let project = project else { return }
        delegate?.editProjectTapped(project: project)
    }

    @objc
    private func deleteButtonTapped() {
        guard let project = project else { return }
        delegate?.deleteProjectTapped(project: project)
    }
}
