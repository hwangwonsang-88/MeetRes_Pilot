//
//  DropDownCell.swift
//  Meet_pilot
//
//  Created by Wonsang Hwang on 6/17/25.
//

import UIKit

final class DropDownCell: UITableViewCell {
    static let identifier = "Cell"
    
    override var isSelected: Bool {
        didSet {
            optionLabel.textColor = isSelected ? .black : .systemGray2
        }
    }
    
    // MARK: - UI Components
    private let optionLabel = UILabel()
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupUI()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    // MARK: - Configure
    func configure(with text: String) {
        optionLabel.text = text
    }
}

// MARK: - UI Methods
private extension DropDownCell {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        contentView.addSubview(optionLabel)
    }
    
    func setConstraints() {
        optionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            optionLabel.topAnchor.constraint(equalTo: optionLabel.superview!.topAnchor, constant: 8),
            optionLabel.leadingAnchor.constraint(equalTo: optionLabel.superview!.leadingAnchor, constant: 8),
            optionLabel.trailingAnchor.constraint(equalTo: optionLabel.superview!.trailingAnchor, constant: -8),
            optionLabel.bottomAnchor.constraint(equalTo: optionLabel.superview!.bottomAnchor, constant: -8)
        ])
    }
}

