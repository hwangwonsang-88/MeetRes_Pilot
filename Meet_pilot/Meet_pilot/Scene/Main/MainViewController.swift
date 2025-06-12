//
//  ViewController.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/11/25.
//

import UIKit
import FSCalendar

#warning("Calendar .week height 계산 -> Container view Hegith")

fileprivate let calendarHeight: CGFloat = 150

final class MainViewController: UIViewController {
    
    private var sideMenuisOn:Bool = false
    private let sideMenu: SideMenuViewController = SideMenuViewController()
    private let dimmingView: UIView = UIView()
    private let calendar = FSCalendar()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "fadjsfl"
        configureUI()
//        configureContainerView()
        configureCalendar()
    }
    
    private func configureContainerView() {
        let v = UIView()
        v.backgroundColor = .black
        view.addSubview(v)
        v.translatesAutoresizingMaskIntoConstraints = false
        let safeLayout = view.safeAreaLayoutGuide
        
        NSLayoutConstraint.activate([
            v.topAnchor.constraint(equalTo: safeLayout.topAnchor),
            v.bottomAnchor.constraint(equalTo: safeLayout.bottomAnchor),
            v.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            v.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    private func configureCalendar() {
        // 앞으로 배치
        calendar.dataSource = self
        calendar.delegate = self
        calendar.scope = .week
        calendar.backgroundColor = .clear
    
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeDown.direction = .down
        calendar.addGestureRecognizer(swipeDown)
        
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        swipeUp.direction = .up
        calendar.addGestureRecognizer(swipeUp)

        calendar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(calendar)
        
        NSLayoutConstraint.activate([
                    calendar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
                    calendar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                    calendar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                    calendar.heightAnchor.constraint(greaterThanOrEqualToConstant: calendarHeight)
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
    
    private func configureUI() {
        
        navigationController?.navigationBar.isHidden = false
        let menuBtn = UIBarButtonItem(image: UIImage(systemName: "pencil"),
                                      style: .done,
                                      target: self,
                                      action: #selector(tapMenuBtn))
        navigationItem.hidesBackButton = true
        navigationItem.leftBarButtonItem = menuBtn
        addDimmingView()
    }
    
    @objc
    private func tapMenuBtn() {
        
        if sideMenuisOn {
            handleDimmingViewTap()
            return
        }
        
        self.addChild(sideMenu)
        self.view.addSubview(sideMenu.view)
             
         let menuWidth = self.view.frame.width * 0.8
         let menuHeight = self.view.frame.height
         let yPos = (self.view.frame.height / 2) - (menuHeight / 2)
        
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
    
    private func addDimmingView() {
        dimmingView.frame = view.bounds
        dimmingView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        dimmingView.isHidden = true
        view.addSubview(dimmingView)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDimmingViewTap))
        dimmingView.addGestureRecognizer(tapGesture)
    }
    
    @objc
    private func handleDimmingViewTap() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self = self else { return }
            self.sideMenu.view.frame = CGRect(x: -self.view.frame.width,
                                              y: 0,
                                              width: self.view.frame.width,
                                              height: self.view.frame.height)
            self.dimmingView.alpha = 0
        }) { (finished) in
            self.sideMenu.view.removeFromSuperview()
            self.sideMenu.removeFromParent()
            self.dimmingView.isHidden = true
            self.sideMenuisOn = false
        }
    }
}


extension MainViewController: FSCalendarDataSource, FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        // input action
        print(date)
        
        if calendar.scope == .month {
            calendar.scope = .week
        }
    }
}
