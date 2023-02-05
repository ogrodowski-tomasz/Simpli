//
//  HotItemCollectionViewCell.swift
//  Simpli
//
//  Created by Tomasz Ogrodowski on 06/02/2023.
//

import Foundation
import UIKit



class HotItemCollectionViewCell: UICollectionViewCell {

    // MARK: - Properties

    static let id = "HotItemCollectionViewCell"

    private var item: ItemViewModel? = nil {
        didSet {
            propagateItemData()
        }
    }

    // MARK: - View Components

    // titleLabel
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "<Item title here>"
        label.font = UIFont.preferredFont(forTextStyle: .headline)
        label.textAlignment = .center
        return label
    }()
    
    // priorityLabel
    private let priorityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "<Item priority here>"
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.textAlignment = .center
        return label
    }()

    // MARK: - Life cycle

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Helpers
    private func setup() {

    }

    private func layout() {
        addSubview(titleLabel)
        addSubview(priorityLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1),
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            trailingAnchor.constraint(equalToSystemSpacingAfter: titleLabel.trailingAnchor, multiplier: 1),

            priorityLabel.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 0.25),
            priorityLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            trailingAnchor.constraint(equalToSystemSpacingAfter: priorityLabel.trailingAnchor, multiplier: 1),
            bottomAnchor.constraint(equalToSystemSpacingBelow: priorityLabel.bottomAnchor, multiplier: 2)
        ])
    }

    func configure(item: ItemViewModel) {
        self.item = item
    }

    func propagateItemData() {
        guard let item = item else { return }
        titleLabel.text = item.title
        titleLabel.textColor = item.color
        layer.borderWidth = 2
        layer.borderColor = item.color.cgColor
        layer.cornerRadius = 10
        layer.masksToBounds = true
        priorityLabel.text = item.priority.description
    }

    // MARK: - Selectors

}
