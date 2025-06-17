//
//  DropDownButton.swift
//  Meet_pilot
//
//  Created by Wonsang Hwang on 6/17/25.
//

import UIKit
import RxSwift
import RxCocoa

// MARK: - DropDownTextMode
enum DropDownTextMode {
    case title
    case option
}

final class DropDownButton: UIView {
    // MARK: - Properties
    var textMode: DropDownTextMode = .title {
        didSet {
            switch textMode {
            case .title:
                label.textColor = .systemGray2
            case .option:
                label.textColor = .black
            }
        }
    }
    
    // MARK: - UI Components
    private let label = UILabel()
    private let downImage = UIImageView(
        image: UIImage(systemName: "chevron.down")
    )
    
    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        self.layer.cornerRadius = 4
        self.layer.borderWidth = 1.2
        self.layer.borderColor = UIColor.black.cgColor
        
        setupUI()
    }
    
    convenience init(title: String?, option: DropDownTextMode) {
        self.init()
        setTitle(title, for: option)
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - UI Methods
private extension DropDownButton {
    func setupUI() {
        setViewHierarchy()
        setConstraints()
    }
    
    func setViewHierarchy() {
        addSubview(label)
        addSubview(downImage)
    }
    
    func setConstraints() {
        label.translatesAutoresizingMaskIntoConstraints = false
        downImage.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 4),
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            label.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),
            
            downImage.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            downImage.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12)
        ])
    }
}

// MARK: - Internal Methods
extension DropDownButton {
    func setTitle(_ title: String?, for mode: DropDownTextMode) {
        self.textMode = mode
        self.label.text = title
    }
}

// MARK: - Reactive Extension
extension Reactive where Base: DropDownButton {
    var title: Binder<(title: String?, mode: DropDownTextMode)> {
        return Binder(self.base) { button, arguments in
            button.setTitle(arguments.title, for: arguments.mode)
        }
    }
}
