//
//  HomeTableSectionFooterView.swift
//  Simpli
//
//  Created by Tomasz Ogrodowski on 02/02/2023.
//

import CoreData
import Foundation
import UIKit

protocol SectionFooterDelegate: AnyObject {
    func editProjectTapped(projectID: NSManagedObjectID)
    func deleteProjectTapped(projectID: NSManagedObjectID)
}

class HomeTableSectionFooterView: UITableViewHeaderFooterView {

    static let id = "HomeTableSectionFooterView"

    static let buttonCornerRadius: CGFloat = 5
    static let buttonBorderWidth: CGFloat = 1

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

    private var projectId: NSManagedObjectID? = nil

    weak var delegate: SectionFooterDelegate?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

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
            bottomAnchor.constraint(equalToSystemSpacingBelow: deleteButton.bottomAnchor, multiplier: 1),
            deleteButton.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            editButton.leadingAnchor.constraint(equalToSystemSpacingAfter: deleteButton.trailingAnchor, multiplier: 1),

            editButton.widthAnchor.constraint(equalTo: deleteButton.widthAnchor, constant: 0),

            editButton.centerYAnchor.constraint(equalTo: deleteButton.centerYAnchor),
            trailingAnchor.constraint(equalToSystemSpacingAfter: editButton.trailingAnchor, multiplier: 1)
        ])
    }

    func configure(id: NSManagedObjectID) {
        projectId = id
    }

    @objc
    private func editButtonTapped() {
        print("DEBUG: Edit button tapped in footer")
        guard let projectId = projectId else { return }
        delegate?.editProjectTapped(projectID: projectId)
    }

    @objc
    private func deleteButtonTapped() {
        print("DEBUG: Delete button tapped in footer")
        guard let projectId = projectId else { return }
        delegate?.deleteProjectTapped(projectID: projectId)
    }
}
