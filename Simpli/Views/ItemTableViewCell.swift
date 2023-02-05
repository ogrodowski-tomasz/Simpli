//
//  ItemTableViewCell.swift
//  Simpli
//
//  Created by Tomasz Ogrodowski on 02/02/2023.
//

import Foundation
import UIKit

class ItemTableViewCell: UITableViewCell {
    static let id = "ItemTableViewCell"

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "<Item title here>"
        label.textColor = Constans.appFontColor
        return label
    }()

    let priorityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "⭐️⭐️⭐️"
        label.textColor = Constans.appFontColor
        return label
    }()

    let completedImage: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "checkmark")
        imageView.tintColor = UIColor.systemGreen
        return imageView
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    private func setup() {

    }

    private func layout() {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, priorityLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.alignment = .leading

        addSubview(stackView)
        addSubview(completedImage)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 2.5),
            stackView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            bottomAnchor.constraint(equalToSystemSpacingBelow: stackView.bottomAnchor, multiplier: 2.5),
            completedImage.leadingAnchor.constraint(equalToSystemSpacingAfter: stackView.trailingAnchor, multiplier: 1),

            completedImage.centerYAnchor.constraint(equalTo: stackView.centerYAnchor),
            trailingAnchor.constraint(equalToSystemSpacingAfter: completedImage.trailingAnchor, multiplier: 1)
        ])
    }

    func configure(itemVM: ItemViewModel, bgColor: UIColor) {
        titleLabel.text = itemVM.title
        priorityLabel.text = itemVM.priority.description
        completedImage.isHidden = !itemVM.completed
        backgroundColor = bgColor
    }

}
