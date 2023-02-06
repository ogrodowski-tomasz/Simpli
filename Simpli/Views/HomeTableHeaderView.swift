//
//  HomeTableHeaderView.swift
//  Simpli
//
//  Created by Tomasz Ogrodowski on 02/02/2023.
//

import Foundation
import UIKit


/// Hot item selection propagator
protocol HotItemCellDelegate: AnyObject {
    func didSelectHotItem(item: ItemViewModel)
}

class HomeTableHeaderView: UIView {

    // MARK: - Properties

    static let height: CGFloat = 100

    private var hotItems: [ItemViewModel] = [] {
        didSet { collectionView.reloadData() }
    }

    weak var delegate: HotItemCellDelegate?

    // MARK: - View Components

    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Hot items right now"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = Constans.appFontColor
        label.textAlignment = .left
        return label
    }()

    let collectionView: UICollectionView =  {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 200, height: HomeTableHeaderView.height)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = Constans.appColor
        collectionView.register(HotItemCollectionViewCell.self, forCellWithReuseIdentifier: HotItemCollectionViewCell.id)
        return collectionView
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
        collectionView.delegate = self
        collectionView.dataSource = self
    }

    private func layout() {
        addSubview(titleLabel)
        addSubview(collectionView)

        NSLayoutConstraint.activate([

            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: topAnchor, multiplier: 1),
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            collectionView.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1),
            trailingAnchor.constraint(equalToSystemSpacingAfter: titleLabel.trailingAnchor, multiplier: 1),

            collectionView.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 1),
            collectionView.leadingAnchor.constraint(equalToSystemSpacingAfter: leadingAnchor, multiplier: 1),
            bottomAnchor.constraint(equalToSystemSpacingBelow: collectionView.bottomAnchor, multiplier: 1),
            trailingAnchor.constraint(equalToSystemSpacingAfter: collectionView.trailingAnchor, multiplier: 1)
        ])
    }

    func configure(hotItems: [ItemViewModel]) {
        self.hotItems = hotItems
    }

    // MARK: - Selectors

}

// MARK: - UICollectionViewDelegate

extension HomeTableHeaderView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        delegate?.didSelectHotItem(item: hotItems[indexPath.row])
    }
}

// MARK: - UICollectionViewDataSource

extension HomeTableHeaderView: UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hotItems.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: HotItemCollectionViewCell.id, for: indexPath) as? HotItemCollectionViewCell else {
            return UICollectionViewCell()
        }
        cell.configure(item: hotItems[indexPath.row])
        return cell
    }
}
