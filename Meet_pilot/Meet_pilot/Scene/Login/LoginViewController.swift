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
    
    private lazy var testbu: UIButton = {
        let btn = UIButton(type: .system)
        btn.setTitle("test", for: .normal)
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.addTarget(self, action: #selector(test), for: .touchUpInside)
        return btn
    }()
    
    @objc
    func test() {
//        WGoogleCalendarService.shared.fetchCalendarEvent(date: .now)
    }
    
    private let dataSource = ["삼양라면", "신라면", "참깨라면", "열라면", "왕뚜껑"]
    private let dropDownButton = DropDownButton(title: "선택해주세요", option: .title)
    private lazy var dropDownView = DropDownView(anchorView: dropDownButton)
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        dropDownView.dataSource = dataSource
        dropDownView.delegate = self
        
        view.addSubview(dropDownView)
        dropDownView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dropDownView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            dropDownView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            dropDownView.widthAnchor.constraint(equalToConstant: 200),
            dropDownView.heightAnchor.constraint(equalToConstant: 40)
        ])
    }
    
    private func configureUI() {
        view.addSubview(testbu)
        
        view.addSubview(loginBtn)
        NSLayoutConstraint.activate([
            loginBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loginBtn.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            testbu.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            testbu.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
}

extension LoginViewController: DropDownDelegate {
    func dropDown(_ dropDownView: DropDownView, didSelectRowAt indexPath: IndexPath) {
        let title = dropDownView.dataSource[indexPath.row]
        dropDownButton.setTitle(title, for: .option)
    }
}
