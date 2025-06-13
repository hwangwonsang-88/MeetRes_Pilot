//
//  SideMenuViewController.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/12/25.
//

import UIKit

final class SideMenuViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    
         self.view.layer.cornerRadius = 20
         self.view.clipsToBounds = true
         self.view.backgroundColor = .blue.withAlphaComponent(0.3)
    }
}
