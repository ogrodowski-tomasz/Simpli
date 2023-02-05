//
//  EditItemViewController.swift
//  Simpli
//
//  Created by Tomasz Ogrodowski on 05/02/2023.
//

import CoreData
import Foundation
import UIKit

protocol EditItemDelegate: AnyObject {
    func updateItem(id: NSManagedObjectID, newName: String, newPriority: Int, newCompletionStatus: Bool)
}

class EditItemViewController: UIViewController {

    // MARK: - Properties
    private let item: ItemViewModel

    private var newPriority = 0

    private var newCompletionStatus = false

    weak var delegate: EditItemDelegate?

    // MARK: - View Components

    // Title
    let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "<Item title here>"
        label.textColor = Constans.appFontColor
        label.textAlignment = .center
        label.font = UIFont.preferredFont(forTextStyle: .title1)
        return label
    }()

    let titleTextField: UITextField = {
        let txtField = UITextField()
        txtField.translatesAutoresizingMaskIntoConstraints = false
        txtField.backgroundColor = .white.withAlphaComponent(0.2)
        txtField.textColor = Constans.appFontColor
        txtField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 10)) // padding
        txtField.leftViewMode = .always
        let placeholder = NSAttributedString(string: "Provide item's name..", attributes: [NSAttributedString.Key.foregroundColor: Constans.appFontColor.withAlphaComponent(0.3)])
        txtField.attributedPlaceholder = placeholder
        txtField.layer.cornerRadius = 10
        txtField.layer.masksToBounds = true
        return txtField
    }()

    // Priority segmented picker
    private let priorityLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Priority"
        label.textColor = Constans.appFontColor.withAlphaComponent(0.4)
        label.textAlignment = .left
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        return label
    }()

    let prioritySegmentedControl: UISegmentedControl = {
        let control = UISegmentedControl()
        control.translatesAutoresizingMaskIntoConstraints = false
        control.tintColor = Constans.appFontColor
        let controlColor = UIColor.white
        control.backgroundColor = controlColor.withAlphaComponent(0.25)
        control.selectedSegmentTintColor = controlColor.withAlphaComponent(0.5)
        ItemPriority.allCases.forEach { priorityLevel in
            control.insertSegment(withTitle: priorityLevel.desctiption, at: Int(priorityLevel.rawValue), animated: true)
        }
        return control
    }()

    // completion switch

    private let switchLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Mark as completed"
        label.textColor = Constans.appFontColor
        label.textAlignment = .left
        label.font = UIFont.preferredFont(forTextStyle: .callout)
        return label
    }()

    private let completionSwitch: UISwitch = {
        let completionSwitch = UISwitch()
        completionSwitch.translatesAutoresizingMaskIntoConstraints = false
        completionSwitch.onTintColor = Constans.appFontColor
        return completionSwitch
    }()

    // Navigation bar items

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



    // MARK: - Life Cycle

    init(item: ItemViewModel) {
        self.item = item
        super.init(nibName: nil, bundle: nil)
        setup()
        layout()
    }

    required init?(coder: NSCoder) {
        fatalError()
    }

    // MARK: - Helpers
    private func setup() {
        // setupView
        setupView()
        setupComponents()
        setupButtons()
    }

    private func setupView() {
        view.backgroundColor = Constans.appColor

        navigationItem.setLeftBarButton(dismissButton, animated: true)
        navigationItem.setRightBarButton(saveButton, animated: true)

        let bgTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBgTap))
        view.addGestureRecognizer(bgTapGesture)
    }

    private func setupComponents() {
        newPriority = Int(item.priority.rawValue)
        titleLabel.text = item.title
        titleTextField.text = item.title
        prioritySegmentedControl.selectedSegmentIndex = Int(item.priority.rawValue)
        prioritySegmentedControl.addTarget(self, action: #selector(segmentChanged), for: .valueChanged)
        completionSwitch.isOn = item.completed
        completionSwitch.addTarget(self, action: #selector(completionSwitchChanged(_:)), for: .valueChanged)
    }

    private func setupButtons() {
        dismissButton.target = self
        dismissButton.action = #selector(handleDismiss)
        saveButton.target = self
        saveButton.action = #selector(handleSave)
    }

    private func layout() {
        view.addSubview(titleLabel)
        view.addSubview(titleTextField)
        view.addSubview(priorityLabel)
        view.addSubview(prioritySegmentedControl)


        let switchStack = UIStackView(arrangedSubviews: [switchLabel, completionSwitch])
        switchStack.translatesAutoresizingMaskIntoConstraints = false
        switchStack.axis = .horizontal
        switchStack.spacing = 5
        switchStack.distribution = .fill
        switchStack.alignment = .center
        view.addSubview(switchStack)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            titleLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 1),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: titleLabel.trailingAnchor, multiplier: 1),
            titleLabel.heightAnchor.constraint(equalToConstant: 150),

            titleTextField.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 2),
            titleTextField.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: titleTextField.trailingAnchor, multiplier: 2),
            titleTextField.heightAnchor.constraint(equalToConstant: 60),

            switchStack.topAnchor.constraint(equalToSystemSpacingBelow: titleTextField.bottomAnchor, multiplier: 1),
            switchStack.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: switchStack.trailingAnchor, multiplier: 2),
            switchStack.heightAnchor.constraint(equalToConstant: 60),

            priorityLabel.topAnchor.constraint(equalToSystemSpacingBelow: switchStack.bottomAnchor, multiplier: 2),
            priorityLabel.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: priorityLabel.trailingAnchor, multiplier: 2),
            

            prioritySegmentedControl.topAnchor.constraint(equalToSystemSpacingBelow: priorityLabel.bottomAnchor, multiplier: 2),
            prioritySegmentedControl.leadingAnchor.constraint(equalToSystemSpacingAfter: view.safeAreaLayoutGuide.leadingAnchor, multiplier: 2),
            view.safeAreaLayoutGuide.trailingAnchor.constraint(equalToSystemSpacingAfter: prioritySegmentedControl.trailingAnchor, multiplier: 2),
            prioritySegmentedControl.heightAnchor.constraint(equalToConstant: 44),
        ])
    }

    private func dismissView() {
        navigationController?.popViewController(animated: true)
    }

    // MARK: - Selectors
    @objc
    private func segmentChanged(_ sender: UISegmentedControl) {
        newPriority = sender.selectedSegmentIndex
        titleTextField.resignFirstResponder()
    }

    @objc
    private func completionSwitchChanged(_ uiSwitch: UISwitch) {
        newCompletionStatus = uiSwitch.isOn
        titleTextField.resignFirstResponder()
    }

    @objc
    private func handleBgTap() {
        titleTextField.resignFirstResponder()
    }

    @objc
    private func handleDismiss() {
        dismissView()
    }

    @objc
    private func handleSave() {
        guard let newName = titleTextField.text else { return }
        delegate?.updateItem(id: item.id, newName: newName, newPriority: newPriority, newCompletionStatus: newCompletionStatus)
        dismissView()
    }

}
