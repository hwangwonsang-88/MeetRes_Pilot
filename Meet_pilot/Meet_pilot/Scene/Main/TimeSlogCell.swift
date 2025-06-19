//
//  VerticalCell.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/18/25.
//

import UIKit

class TimeSlotCell: UICollectionViewCell {
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let checkMark: UIImageView = {
        let img = UIImageView(image: UIImage(systemName: "chevron.down.circle.fill"))
        img.translatesAutoresizingMaskIntoConstraints = false
        img.isHidden = true
        return img
    }()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        timeLabel.text = ""
        contentView.backgroundColor = .systemBackground
        checkMark.isHidden = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(timeLabel)
        contentView.addSubview(checkMark)
        
        contentView.backgroundColor = .systemBackground
        contentView.layer.borderWidth = 0.5
        contentView.layer.borderColor = UIColor.gray.cgColor
        
        NSLayoutConstraint.activate([
            timeLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            timeLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            checkMark.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            checkMark.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with time: String) {
        timeLabel.text = time
    }
    
    func toggleCheckMark() {
        checkMark.isHidden.toggle()
    }
    
    func showCheckMark() {
        checkMark.isHidden = false
    }
    
    func hideCheckMark() {
        checkMark.isHidden = true
    }
}
