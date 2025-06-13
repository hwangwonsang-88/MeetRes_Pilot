//
//  LoginViewController.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/11/25.
//

import UIKit

final class LoginViewController: UIViewController {
    
    private lazy var loginBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setImage(UIImage(systemName: "wave.3.right.circle.fill"), for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(tapLoginBtn), for: .touchUpInside)
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(loginBtn)
        NSLayoutConstraint.activate([
            loginBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    @objc
    private func tapLoginBtn() {
        
    }
}
