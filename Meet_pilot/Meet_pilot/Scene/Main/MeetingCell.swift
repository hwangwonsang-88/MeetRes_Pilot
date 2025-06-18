//
//  MeetingCell.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/16/25.
//

import UIKit

fileprivate let timeFontSize: CGFloat = 20
fileprivate let meetingFontSize: CGFloat = 10
fileprivate let hostFontSize: CGFloat = 10

final class MeetingCell: UICollectionViewCell {
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var hoistLabel: UILabel!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        topicLabel.text = ""
        hoistLabel.text = ""
    }
    
    func setCell(topic: String, host: String) {
        topicLabel.text = topic
        hoistLabel.text = host
    }
}
