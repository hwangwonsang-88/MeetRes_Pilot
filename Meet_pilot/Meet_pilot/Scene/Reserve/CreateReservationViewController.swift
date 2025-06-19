//
//  CreateReservationViewController.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/19/25.
//

import UIKit

final class CreateReservationViewController: UIViewController {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    private let mainStackView = UIStackView()
    
    // Form components
    private let hostTextField = UITextField()
    private let locationTextField = UITextField()
    private let titleTextField = UITextField()
    private let dateTextField = UITextField()
    private let startTimeTextField = UITextField()
    private let endTimeTextField = UITextField()
    private let roomDropdown = UIButton()
    private let attendeesContainer = UIView()
    private let attendeesScrollView = UIScrollView()
    private let attendeesStackView = UIStackView()
    private let addAttendeeButton = UIButton()
    private let descriptionTextView = UITextView()
    private let reserveButton = UIButton()
    
    // Attendee tags
    private var attendeeTags: [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setupActions()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "예약하기"
        
        // Navigation bar
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "chevron.left"),
            style: .plain,
            target: self,
            action: #selector(backButtonTapped)
        )
        
        // Scroll view setup
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(mainStackView)
        
        mainStackView.axis = .vertical
        mainStackView.spacing = 16
        mainStackView.distribution = .fill
        
        setupFormComponents()
    }
    
    private func setupFormComponents() {
// Title field
        let titleRow = createFormRow(title: "제목", textField: titleTextField)
        titleTextField.placeholder = "TITLE!!"
        
        // Date field
        let dateRow = createFormRow(title: "Date", textField: dateTextField)
        dateTextField.placeholder = "2025.05.14"
        
        // Time fields
        let timeContainer = createTimeSelectionRow()
        
        // Room dropdown
        let roomRow = createFormRow(title: "회의실", textField: titleTextField)
        titleTextField.placeholder = "TITLE!!"
        
        // Attendees section
        let attendeesRow = createAttendeesSection()
        
        // Description text view
        let descriptionRow = createDescriptionRow()
        
        // Reserve button
        setupReserveButton()
        
        // Add all components to main stack
        mainStackView.addArrangedSubview(titleRow)
        mainStackView.addArrangedSubview(dateRow)
        mainStackView.addArrangedSubview(timeContainer)
        mainStackView.addArrangedSubview(roomRow)
        mainStackView.addArrangedSubview(attendeesRow)
        mainStackView.addArrangedSubview(descriptionRow)
        mainStackView.addArrangedSubview(reserveButton)
    }
    
    private func createFormRow(title: String, textField: UITextField) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .systemGray6
        textField.font = .systemFont(ofSize: 16)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, textField])
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.distribution = .fill
        
        return stackView
    }
    
    private func createTimeSelectionRow() -> UIView {
        let container = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = "시간"
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        startTimeTextField.borderStyle = .roundedRect
        startTimeTextField.backgroundColor = .systemGray6
        startTimeTextField.placeholder = "10:00"
        startTimeTextField.textAlignment = .center
        startTimeTextField.translatesAutoresizingMaskIntoConstraints = false
        
        let dashLabel = UILabel()
        dashLabel.text = "-"
        dashLabel.font = .systemFont(ofSize: 16, weight: .medium)
        dashLabel.textAlignment = .center
        dashLabel.translatesAutoresizingMaskIntoConstraints = false
        
        endTimeTextField.borderStyle = .roundedRect
        endTimeTextField.backgroundColor = .systemGray6
        endTimeTextField.placeholder = "11:00"
        endTimeTextField.textAlignment = .center
        endTimeTextField.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        container.addSubview(startTimeTextField)
        container.addSubview(dashLabel)
        container.addSubview(endTimeTextField)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 80),
            
            startTimeTextField.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 16),
            startTimeTextField.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            startTimeTextField.widthAnchor.constraint(equalToConstant: 100),
            startTimeTextField.heightAnchor.constraint(equalToConstant: 44),
            
            dashLabel.leadingAnchor.constraint(equalTo: startTimeTextField.trailingAnchor, constant: 8),
            dashLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            dashLabel.widthAnchor.constraint(equalToConstant: 20),
            
            endTimeTextField.leadingAnchor.constraint(equalTo: dashLabel.trailingAnchor, constant: 8),
            endTimeTextField.centerYAnchor.constraint(equalTo: container.centerYAnchor),
            endTimeTextField.widthAnchor.constraint(equalToConstant: 100),
            endTimeTextField.heightAnchor.constraint(equalToConstant: 44),
            
            container.heightAnchor.constraint(equalToConstant: 44)
        ])
        
        return container
    }
    
    private func createRoomDropdownRow() -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = "회의실"
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        
        roomDropdown.setTitle("선택안함", for: .normal)
        roomDropdown.setTitleColor(.label, for: .normal)
        roomDropdown.backgroundColor = .systemGray6
        roomDropdown.layer.cornerRadius = 8
        roomDropdown.contentHorizontalAlignment = .left
        roomDropdown.titleEdgeInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        roomDropdown.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        // Dropdown arrow
        let arrowImageView = UIImageView(image: UIImage(systemName: "chevron.down"))
        arrowImageView.tintColor = .systemGray
        arrowImageView.translatesAutoresizingMaskIntoConstraints = false
        roomDropdown.addSubview(arrowImageView)
        
        NSLayoutConstraint.activate([
            arrowImageView.trailingAnchor.constraint(equalTo: roomDropdown.trailingAnchor, constant: -16),
            arrowImageView.centerYAnchor.constraint(equalTo: roomDropdown.centerYAnchor)
        ])
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, roomDropdown])
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .center
        stackView.distribution = .fill
        
        return stackView
    }
    
    private func createAttendeesSection() -> UIView {
        let container = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = "참석자"
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        // Attendees container with tags
        attendeesContainer.backgroundColor = .systemGray6
        attendeesContainer.layer.cornerRadius = 8
        attendeesContainer.translatesAutoresizingMaskIntoConstraints = false
        
        attendeesScrollView.translatesAutoresizingMaskIntoConstraints = false
        attendeesStackView.translatesAutoresizingMaskIntoConstraints = false
        attendeesStackView.axis = .horizontal
        attendeesStackView.spacing = 8
        attendeesStackView.alignment = .center
        
        attendeesContainer.addSubview(attendeesScrollView)
        attendeesScrollView.addSubview(attendeesStackView)
        
        // Add initial attendee tags
        addAttendeeTag("홍길동")
        addAttendeeTag("김길동")
        addAttendeeTag("이길동")
        
        container.addSubview(titleLabel)
        container.addSubview(attendeesContainer)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 80),
            
            attendeesContainer.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 16),
            attendeesContainer.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            attendeesContainer.topAnchor.constraint(equalTo: container.topAnchor),
            attendeesContainer.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            attendeesContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),
            
            attendeesScrollView.topAnchor.constraint(equalTo: attendeesContainer.topAnchor, constant: 8),
            attendeesScrollView.leadingAnchor.constraint(equalTo: attendeesContainer.leadingAnchor, constant: 16),
            attendeesScrollView.trailingAnchor.constraint(equalTo: attendeesContainer.trailingAnchor, constant: -16),
            attendeesScrollView.bottomAnchor.constraint(equalTo: attendeesContainer.bottomAnchor, constant: -8),
            
            attendeesStackView.topAnchor.constraint(equalTo: attendeesScrollView.topAnchor),
            attendeesStackView.leadingAnchor.constraint(equalTo: attendeesScrollView.leadingAnchor),
            attendeesStackView.trailingAnchor.constraint(equalTo: attendeesScrollView.trailingAnchor),
            attendeesStackView.bottomAnchor.constraint(equalTo: attendeesScrollView.bottomAnchor),
            attendeesStackView.heightAnchor.constraint(equalTo: attendeesScrollView.heightAnchor)
        ])
        
        return container
    }
    
    private func addAttendeeTag(_ name: String) {
        let tagContainer = UIView()
        tagContainer.backgroundColor = .systemBlue.withAlphaComponent(0.1)
        tagContainer.layer.cornerRadius = 16
        tagContainer.translatesAutoresizingMaskIntoConstraints = false
        
        let nameLabel = UILabel()
        nameLabel.text = name
        nameLabel.font = .systemFont(ofSize: 14)
        nameLabel.textColor = .systemBlue
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let removeButton = UIButton()
        removeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        removeButton.tintColor = .systemGray
        removeButton.translatesAutoresizingMaskIntoConstraints = false
        removeButton.widthAnchor.constraint(equalToConstant: 16).isActive = true
        removeButton.heightAnchor.constraint(equalToConstant: 16).isActive = true
        
        tagContainer.addSubview(nameLabel)
        tagContainer.addSubview(removeButton)
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: tagContainer.leadingAnchor, constant: 12),
            nameLabel.centerYAnchor.constraint(equalTo: tagContainer.centerYAnchor),
            
            removeButton.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
            removeButton.trailingAnchor.constraint(equalTo: tagContainer.trailingAnchor, constant: -12),
            removeButton.centerYAnchor.constraint(equalTo: tagContainer.centerYAnchor),
            
            tagContainer.heightAnchor.constraint(equalToConstant: 32)
        ])
        
        attendeesStackView.addArrangedSubview(tagContainer)
        attendeeTags.append(name)
    }
    
    private func createDescriptionRow() -> UIView {
        let container = UIView()
        
        let titleLabel = UILabel()
        titleLabel.text = "설명"
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        descriptionTextView.backgroundColor = .systemGray6
        descriptionTextView.layer.cornerRadius = 8
        descriptionTextView.font = .systemFont(ofSize: 16)
        descriptionTextView.textContainerInset = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        descriptionTextView.text = "가나다라\n마바사아\n자차카타\n파하"
        descriptionTextView.translatesAutoresizingMaskIntoConstraints = false
        
        container.addSubview(titleLabel)
        container.addSubview(descriptionTextView)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            titleLabel.topAnchor.constraint(equalTo: container.topAnchor),
            titleLabel.widthAnchor.constraint(equalToConstant: 80),
            
            descriptionTextView.leadingAnchor.constraint(equalTo: titleLabel.trailingAnchor, constant: 16),
            descriptionTextView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            descriptionTextView.topAnchor.constraint(equalTo: container.topAnchor),
            descriptionTextView.bottomAnchor.constraint(equalTo: container.bottomAnchor),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        return container
    }
    
    private func setupReserveButton() {
        reserveButton.setTitle("예약", for: .normal)
        reserveButton.backgroundColor = .systemBlue
        reserveButton.setTitleColor(.white, for: .normal)
        reserveButton.layer.cornerRadius = 12
        reserveButton.titleLabel?.font = .systemFont(ofSize: 18, weight: .semibold)
        reserveButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // Add some top margin
        mainStackView.setCustomSpacing(32, after: mainStackView.arrangedSubviews.last ?? UIView())
    }
    
    private func setupLayout() {
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            mainStackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            mainStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            mainStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            mainStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
    }
    
    private func setupActions() {
        reserveButton.addTarget(self, action: #selector(reserveButtonTapped), for: .touchUpInside)
        roomDropdown.addTarget(self, action: #selector(roomDropdownTapped), for: .touchUpInside)
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @objc private func reserveButtonTapped() {
        // Handle reservation logic
        print("예약 버튼 탭됨")
    }
    
    @objc private func roomDropdownTapped() {
        // Handle room selection
        print("회의실 선택")
    }
}
