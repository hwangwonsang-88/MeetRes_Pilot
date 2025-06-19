//
//  ReserveViewController.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/19/25.
//

import UIKit

final class ReserveViewController: UIViewController {
    
    private let eventData: EventData
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    init(eventData: EventData) {
        self.eventData = eventData
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setupData()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "예약 정보"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeButtonTapped)
        )
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
    }
    
    private func createInfoRow(title: String, content: String) -> UIStackView {
        let titleLabel = UILabel()
        titleLabel.text = title
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        
        let contentLabel = UILabel()
        contentLabel.text = content
        contentLabel.font = .systemFont(ofSize: 16)
        contentLabel.textColor = .secondaryLabel
        contentLabel.numberOfLines = 0
        contentLabel.textAlignment = .right
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, contentLabel])
        stackView.axis = .horizontal
        stackView.spacing = 16
        stackView.alignment = .top
        stackView.distribution = .fill
        
        return stackView
    }
    
    private func setupLayout() {
        let creatorRow = createInfoRow(title: "주최자", content: eventData.creator.isEmpty ? eventData.creatorEmail : eventData.creator)
        let titleRow = createInfoRow(title: "제목", content: eventData.title)
        let timeRow = createInfoRow(title: "시간", content: "\(eventData.startTimeString) ~ \(eventData.endTimeString)")
        let attendeesRow = createInfoRow(title: "참석자", content: "\(eventData.attendees.count)명" )
        let descriptionRow = createInfoRow(title: "설명", content: eventData.description ?? "정보없음")
        
        let mainStackView = UIStackView(arrangedSubviews: [
            creatorRow, titleRow, timeRow, attendeesRow, descriptionRow
        ])
        mainStackView.axis = .vertical
        mainStackView.spacing = 20
        mainStackView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(mainStackView)
        
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
    
    private func setupData() {
        // 데이터는 이미 setupLayout에서 설정됨
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }
}
