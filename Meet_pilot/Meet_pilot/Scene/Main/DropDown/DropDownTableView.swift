//
//  DropDownTableView.swift
//  Meet_pilot
//
//  Created by Wonsang Hwang on 6/17/25.
//

import UIKit

final class DropDownTableView: UITableView {
    // MARK: - Properties
    private let itemHeight: CGFloat = 32
    private let minHeight: CGFloat = 0
    private let maxHeight: CGFloat = 192 // 32 * 6
    
    // MARK: - Initializers
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        rowHeight = itemHeight
        layer.cornerRadius = 4
        layer.borderWidth = 1
        layer.borderColor = UIColor.systemGray2.cgColor
        separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        register(
            DropDownCell.self,
            forCellReuseIdentifier: DropDownCell.identifier
        )
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - override Layout Methods
    override public func layoutSubviews() {
        super.layoutSubviews()
        if bounds.size != intrinsicContentSize {
            invalidateIntrinsicContentSize()
        }
    }
    
    override public var intrinsicContentSize: CGSize {
        layoutIfNeeded()
        if contentSize.height > maxHeight {
            return CGSize(width: contentSize.width, height: maxHeight)
        } else if contentSize.height < minHeight {
            return CGSize(width: contentSize.width, height: minHeight)
        } else {
            return contentSize
        }
    }
}

// MARK: - Internal Methods
extension DropDownTableView {
    func deselectAllCell() {
        self.visibleCells.forEach { $0.isSelected = false }
    }
    
    func selectRow(at indexPath: IndexPath) {
        deselectAllCell()
        (self.cellForRow(at: indexPath) as? DropDownCell)?.isSelected = true
    }
}


