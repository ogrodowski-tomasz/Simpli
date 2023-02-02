//
//  HomeTableSectionHeaderView.swift
//  Simpli
//
//  Created by Tomasz Ogrodowski on 02/02/2023.
//

import CoreData
import Foundation
import UIKit

protocol SectionHeaderDelegate: AnyObject {
    func addItemButtonTapped(projectId: NSManagedObjectID)
}

class HomeTableSectionHeaderView: UITableViewHeaderFooterView {
    static let id = "HomeTableSectionHeaderView"

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "<Section title>"
        label.textColor = Constans.appFontColor
        label.textAlignment = .left
        return label
    }()

    let addItemButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    weak var delegate: SectionHeaderDelegate?

    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private var projectVM: ProjectViewModel? = nil {
        didSet {
            if let projectVM {
                titleLabel.text = projectVM.title
            }
        }
    }

    private func setup() {
        addItemButton.addTarget(self, action: #selector(addItemButtonTapped), for: .touchUpInside)
    }

    private func layout() {
        addSubview(titleLabel)
        addSubview(addItemButton)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1),
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            addItemButton.leadingAnchor.constraint(equalToSystemSpacingAfter: titleLabel.trailingAnchor, multiplier: 1),
            bottomAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1),


            addItemButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
            trailingAnchor.constraint(equalToSystemSpacingAfter: addItemButton.trailingAnchor, multiplier: 1)
        ])
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
    }

    func configure(projectVM: ProjectViewModel) {
        self.projectVM = projectVM
    }

    @objc
    private func addItemButtonTapped() {
        print("DEBUG: Add item button tapped in HomeTableSectionHeaderView")
        guard let projectId = projectVM?.id else { return }
        delegate?.addItemButtonTapped(projectId: projectId)
    }
}
