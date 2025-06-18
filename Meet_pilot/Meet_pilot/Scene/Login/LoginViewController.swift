//
//  LoginViewController.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/11/25.
//

import UIKit
import ReactorKit

final class LoginViewController: UIViewController, View {
    
    var disposeBag: DisposeBag = .init()
    
    func bind(reactor: LoginViewModel) {
        loginBtn.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .map { LoginViewModel.Action.tapLoginBtn }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)   
    }
    
    private lazy var loginBtn: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("로그인", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
    }
    
    private func configureUI() {
        view.addSubview(loginBtn)
        NSLayoutConstraint.activate([
            loginBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }
}
