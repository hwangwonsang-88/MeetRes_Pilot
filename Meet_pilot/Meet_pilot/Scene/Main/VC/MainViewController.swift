//
//  ViewController.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/11/25.
//

import UIKit
import RxCocoa
import RxSwift
import ReactorKit
import FSCalendar

fileprivate let calendarHeight: CGFloat = 300

final class MainViewController: UIViewController, View {

    private var sideMenuisOn:Bool = false
    private let sideMenu =  SideMenuViewController()
    private let dimmingView: UIView = UIView()
    private let calendar = FSCalendar()
    private var calendarHeightConstant: NSLayoutConstraint!
    private let tableView = UITableView()
    
    private lazy var resBtn: UIButton = { [unowned self] in
        let btn = UIButton(type: .system)
        btn.setTitle("예약하기", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = .systemBlue.withAlphaComponent(0.6)
        btn.layer.cornerRadius = 10
        btn.translatesAutoresizingMaskIntoConstraints = false
        return btn
    }()
    
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        configureCalendar()
        
        calendar.rx.swipe
            .subscribe { [weak self] g in
                self?.calendarHeightConstant.constant = g.element!.height
            }
            .disposed(by: disposeBag)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        configureContainerView(height: calendar.bounds.height)
        configureResBtn()
    }
    
    func bind(reactor: MainViewModel) {
    
        calendar.rx.tapDate
            .map { Reactor.Action.tapCalendar($0) }
            .startWith(Reactor.Action.tapCalendar(.now))
            .do(onNext: { [weak self] _ in
                guard let self = self else { return }
                if self.calendar.scope == .month {
                    self.calendar.scope = .week
                }
            })
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        resBtn.rx.tap
            .subscribe { _ in
            }
            .disposed(by: disposeBag)
        
        
        reactor.pulse(\.$title)
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
    }
    
    private func configureTableView() {
        
    }
    
    private func configureContainerView(height: CGFloat) {
        let v = UIView()
 
        v.frame = CGRect(x: 0,
                         y: height + navigationController!.navigationBar.frame.maxY,
                         width: view.bounds.width,
                         height: view.bounds.height - height + navigationController!.navigationBar.frame.maxY )
        v.backgroundColor = .black
        view.insertSubview(v, belowSubview: calendar)
    }
    
    private func configureCalendar() {
        // 앞으로 배치
        calendar.scope = .week
        calendar.backgroundColor = .white
    
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeDown.direction = .down
        calendar.addGestureRecognizer(swipeDown)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeUp.direction = .up
        calendar.addGestureRecognizer(swipeUp)

        calendar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(calendar)
        
        calendarHeightConstant = NSLayoutConstraint(item: calendar,
                                                    attribute: .height,
                                                    relatedBy: .equal,
                                                    toItem: nil,
                                                    attribute: .notAnAttribute,
                                                    multiplier: 1,
                                                    constant: calendarHeight)
        
        NSLayoutConstraint.activate([
                    calendar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                    calendar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    calendar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    calendarHeightConstant
                ])
    }
    
    @objc
    private func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        switch gesture.direction {
        case .up:
            calendar.scope = .week
        case .down:
            calendar.scope = .month
        default:
            break
        }
    }
    
    private func configureResBtn() {
        view.addSubview(resBtn)
        NSLayoutConstraint.activate([
            resBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            resBtn.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.7),
            resBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func configureUI() {
        navigationController?.navigationBar.isHidden = false
        let menuBtn = UIBarButtonItem(image: UIImage(named: "menu-line"),
                                      style: .done,
                                      target: self,
                                      action: #selector(tapMenuBtn))
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = menuBtn
    }
    
    @objc
    private func tapMenuBtn() {
        if sideMenuisOn {
            tapDimmingView()
            return
        }
        
        configureDimmingView()

        self.addChild(sideMenu)
        self.view.addSubview(sideMenu.view)
             
        let menuWidth = self.view.frame.width * 0.8
        let menuHeight = self.view.frame.height - self.navigationController!.navigationBar.frame.maxY
        let yPos:CGFloat = self.navigationController!.navigationBar.frame.maxY
        
        sideMenu.view.frame = CGRect(x: -menuWidth,
                                     y: yPos,
                                     width: menuWidth,
                                     height: menuHeight)
             
         self.dimmingView.isHidden = false
         self.dimmingView.alpha = 0
         
         UIView.animate(withDuration: 0.3, animations: { [weak self] in
             guard let self = self else { return }
 
             sideMenu.view.frame = CGRect(x: 0,
                                          y: yPos,
                                          width: menuWidth,
                                          height: menuHeight)
    
             self.dimmingView.alpha = 0.5
             sideMenuisOn = true
             })
    }
    
    private func configureDimmingView() {
        dimmingView.frame = view.bounds
        dimmingView.backgroundColor = .clear
        dimmingView.isHidden = true
        view.addSubview(dimmingView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapDimmingView))
        dimmingView.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func tapDimmingView() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self = self else { return }
            
            let menuWidth = self.view.frame.width * 0.8
            let menuHeight = self.view.frame.height - self.navigationController!.navigationBar.frame.maxY
            let yPos:CGFloat = self.navigationController!.navigationBar.frame.maxY
            
            self.sideMenu.view.frame = CGRect(x: -menuWidth,
                                              y: yPos,
                                              width: menuWidth,
                                              height: menuHeight)
            self.dimmingView.alpha = 0
        }) { (finished) in
            self.sideMenu.view.removeFromSuperview()
            self.sideMenu.removeFromParent()
            self.dimmingView.isHidden = true
            self.sideMenuisOn = false
        }
    }
}

extension MainViewController {
    
}
