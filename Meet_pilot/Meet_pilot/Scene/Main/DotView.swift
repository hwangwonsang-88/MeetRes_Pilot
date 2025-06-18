//
//  DotView.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/18/25.
//

import UIKit

final class DotView: UIView {
    override func awakeFromNib() {
        let borderLayer = CAShapeLayer()
        borderLayer.strokeColor = UIColor.systemGray2.cgColor
        borderLayer.lineDashPattern = [2, 2]
        borderLayer.frame = self.bounds
        borderLayer.fillColor = nil
        borderLayer.path = UIBezierPath(rect: self.bounds).cgPath
        
        self.layer.addSublayer(borderLayer)
    }
}
