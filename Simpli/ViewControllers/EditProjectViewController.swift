//
//  EditProjectViewController.swift
//  Simpli
//
//  Created by Tomasz Ogrodowski on 02/02/2023.
//

import CoreData
import Foundation
import UIKit

/// Updated Project's information propagator
protocol EditProjectViewDelegate: AnyObject {
    func updateProject(projectID: NSManagedObjectID, newName: String, newClosedStatus: Bool, newColor: UIColor)
}

class EditProjectViewController: UIViewController {

    // MARK: - Properties

    let project: ProjectViewModel

    let possibleColors: [UIColor] = [.systemRed, .systemGreen, .systemBlue, .systemTeal, .systemBrown, .systemPurple]

    private var selectedColor = UIColor.systemBrown {
        didSet {
            print("DEBUG: new color selected to \(selectedColor.accessibilityName)")
            colorcCollectionView.reloadData()
        }
    }

    private var closed = false

    weak var delegate: EditProjectViewDelegate?

    // MARK: - View Components

    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "<Label title here>"
        label.textColor = Constans.appFontColor
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        return label
    }()

    let dismissButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "◁ Dismiss"
        button.tintColor = UIColor.systemRed.withAlphaComponent(0.85)
        return button
    }()

    let saveButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.title = "✓ Save"
        button.tintColor = .systemGreen
        return button
    }()

    let titleTextField: UITextField = {
        let txtField = UITextField()
        txtField.placeholder = "Enter new name"
        txtField.translatesAutoresizingMaskIntoConstraints = false
        txtField.textColor = Constans.appFontColor
        let titleLabel = UILabel()
        titleLabel.text = "Title: "
        titleLabel.textColor = Constans.appFontColor.withAlphaComponent(0.5)
        txtField.leftView = titleLabel
        txtField.leftViewMode = .always
        txtField.backgroundColor = Constans.appColor
        return txtField
    }()

    let colorcCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 50, height: 50)
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = Constans.appColor
        collectionView.isUserInteractionEnabled = true
        return collectionView
    }()

    let switchTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Constans.appFontColor
        label.text = "Mark this project as closed"
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()

    let closingSwitch: UISwitch = {
        let closingSwitch = UISwitch()
        closingSwitch.translatesAutoresizingMaskIntoConstraints = false
        closingSwitch.tintColor = Constans.appFontColor
        return closingSwitch
    }()

    // MARK: - Life Cycle

    init(project: ProjectViewModel) {
        self.project = project
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Constans.appColor

        setup()
        layout()

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBgTap(_:)))

        view.addGestureRecognizer(tapGesture)

    }

    // MARK: - Methods

    private func setup() {
        navigationItem.title = project.title
        dismissButton.target = self
        dismissButton.action = #selector(dismissButtonTapped)
        saveButton.target = self
        saveButton.action = #selector(saveButtonTapped)
        navigationItem.setLeftBarButton(dismissButton, animated: true)
        navigationItem.setRightBarButton(saveButton, animated: true)
        titleLabel.text = project.title
        titleTextField.text = project.title
        titleTextField.delegate = self
        colorcCollectionView.delegate = self
        colorcCollectionView.dataSource = self

        closed = project.closed
        closingSwitch.isOn = project.closed
        closingSwitch.addTarget(self, action: #selector(switchToogle(_:)), for: .valueChanged)
    }

    private func layout() {
        view.addSubview(titleTextField)
        view.addSubview(titleLabel)
        view.addSubview(colorcCollectionView)
        let switchStack = UIStackView(arrangedSubviews: [switchTitleLabel, closingSwitch])
        switchStack.translatesAutoresizingMaskIntoConstraints = false
        switchStack.axis = .horizontal
        switchStack.spacing = 0
        switchStack.alignment = .center
        switchStack.distribution = .fillProportionally
        view.addSubview(switchStack)

        NSLayoutConstraint.activate([

            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 2),
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: titleLabel.trailingAnchor, multiplier: 2),
            titleLabel.heightAnchor.constraint(equalToConstant: 50),

            titleTextField.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 5),
            titleTextField.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: titleTextField.trailingAnchor, multiplier: 2),
            titleTextField.heightAnchor.constraint(equalToConstant: 50),

            colorcCollectionView.topAnchor.constraint(equalToSystemSpacingBelow: titleTextField.bottomAnchor, multiplier: 1),
            colorcCollectionView.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 2),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: colorcCollectionView.trailingAnchor, multiplier: 2),
            colorcCollectionView.heightAnchor.constraint(equalToConstant: 55),

            switchStack.topAnchor.constraint(equalToSystemSpacingBelow: colorcCollectionView.bottomAnchor, multiplier: 2),
            switchStack.leadingAnchor.constraint(equalToSystemSpacingAfter: view.leadingAnchor, multiplier: 3),
            view.trailingAnchor.constraint(equalToSystemSpacingAfter: switchStack.trailingAnchor, multiplier: 3),
            switchStack.heightAnchor.constraint(equalToConstant: 55)
        ])
    }

    private func popVC() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Selectors

    @objc
    private func dismissButtonTapped() {
        popVC()
    }

    @objc
    private func saveButtonTapped() {
        guard let newName = titleTextField.text else { return }
        delegate?.updateProject(projectID: project.id, newName: newName, newClosedStatus: closed, newColor: selectedColor)
        popVC()
    }

    @objc
    private func switchToogle(_ sender: UISwitch) {
        closed = sender.isOn
    }

    @objc
    private func handleBgTap(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @objc
    private func handleColorSelection(_ sender: UITapGestureRecognizer) {
        if let indexPath = colorcCollectionView.indexPathForItem(at: sender.location(in: colorcCollectionView)) {
            let color = possibleColors[indexPath.row]
            selectedColor = color
        }
    }

}

// MARK: - UITextFieldDelegate

extension EditProjectViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }

}

// MARK: - UICollectionViewDataSource

extension EditProjectViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return possibleColors.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let color = possibleColors[indexPath.row]
        cell.backgroundColor = color
        if selectedColor == color {
            let checkmarkImageView = UIImageView()
            checkmarkImageView.tintColor = .black
            checkmarkImageView.translatesAutoresizingMaskIntoConstraints = false
            checkmarkImageView.image = UIImage(systemName: "checkmark.seal")
            cell.addSubview(checkmarkImageView)
            checkmarkImageView.centerYAnchor.constraint(equalTo: cell.centerYAnchor).isActive = true
            checkmarkImageView.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
        }

        let colorSelectionRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleColorSelection(_:)))
        cell.addGestureRecognizer(colorSelectionRecognizer)

        cell.isUserInteractionEnabled = true
        cell.layer.cornerRadius = 5
        cell.layer.masksToBounds = true
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension EditProjectViewController: UICollectionViewDelegate { }

