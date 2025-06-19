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
import RxDataSources

fileprivate let calendarHeight: CGFloat = 300

final class MainViewController: UIViewController, View {
    
    private var sideMenuisOn:Bool = false
    private let sideMenu =  SideMenuViewController()
    private let dimmingView: UIView = UIView()
    private let calendar = FSCalendar()
    private var calendarHeightConstant: NSLayoutConstraint!
    private let dataSource: MeetingRooms
    private let dropDownButton = DropDownButton(title: "회의실", option: .title)
    private lazy var dropDownView = DropDownView(anchorView: dropDownButton)
    
    private let collectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0     // 시간대 간 구분을 위한 최소 간격
        layout.minimumInteritemSpacing = 0  // 요일 간 구분을 위한 최소 간격
        let v = UICollectionView(frame: .zero, collectionViewLayout: layout)
        return v
    }()
    
    init(datasource: MeetingRooms) {
        self.dataSource = datasource
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        configureUI()
        configureCalendar()
        configureCollectionView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        var calendarHeight = calendar.bounds.height + navigationController!.navigationBar.frame.maxY
        configureDropDown(startY: &calendarHeight)
        configureContainerView(height: calendarHeight)
        configureResBtn()
    }
    
    func bind(reactor: MainViewModel) {
        
        let dropDownStream = dropDownView.rx.didSelectRow
            .do(onNext: { [unowned self] idxPath in
                let title = self.dropDownView.dataSource[idxPath.row]
                self.dropDownButton.setTitle(title, for: .option)
            })
            .map { [unowned self] in self.dataSource.data[$0.row] }
        
        let calendarStream = calendar.rx.tapDate
            .do(onNext: { [unowned self] _ in
                if self.calendar.scope == .month {
                    self.calendar.scope = .week
                }
            })
            .startWith(.now)
        
        Observable.combineLatest(dropDownStream, calendarStream)
            .map { Reactor.Action.fetchMeetingSchedule(($0, $1)) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.pulse(\.$title)
            .bind(to: navigationItem.rx.title)
            .disposed(by: disposeBag)
        
        let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, DayTimeSlot>>(
            configureCell: { (dataSource, collectionView, indexPath, dayTimeSlot) in
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeSlotCell", for: indexPath) as! TimeSlotCell
                
                // 일요일 경우엔 시간을 나타냄
                if dayTimeSlot.dayIndex == 0 {
                    cell.configure(with: dayTimeSlot.time)
                }
                
                if !dayTimeSlot.isAvailable {
                    cell.contentView.backgroundColor = UIColor.init(hexCode: dayTimeSlot.color!).withAlphaComponent(0.3)
                }
                
                // checkedSchedules에 포함된 셀인지 확인하여 checkmark 표시
                let isChecked = reactor.currentState.checkedSchedules.contains { section in
                    section.time == dayTimeSlot.time &&
                    section.dayCells.contains { $0.dayIndex == dayTimeSlot.dayIndex }
                }
                
                if isChecked {
                    cell.showCheckMark()
                } else {
                    cell.hideCheckMark()
                }
                
                return cell
            }
        )
        
        Observable.combineLatest(
            reactor.state.map { $0.meetingSchedules },
            reactor.pulse(\.$checkedSchedules)
        )
        .map { schedules, _ in
            schedules.map { timeSlotSection in
                SectionModel(model: timeSlotSection.time, items: timeSlotSection.dayCells)
            }
        }
        .bind(to: collectionView.rx.items(dataSource: dataSource))
        .disposed(by: disposeBag)
        
        let itemSelected = collectionView.rx.itemSelected
            .map { [weak self] idxPath in
                return (self?.collectionView.cellForItem(at: idxPath) as? TimeSlotCell, idxPath)
                }
            .filter { $0.0 != nil }
            .filter { $0.0?.contentView.backgroundColor == .systemBackground }
            .map { ($1.row, $1.section) }
            .map { Reactor.Action.tapCell($0) }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        
//        Observable.combineLatest(itemSelected, calendarStream, calendarStream)
//            .map { Reactor.Action.tapCell(<#T##(Int, Int)#>) }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)

        collectionView.rx.setDelegate(self)
            .disposed(by: disposeBag)
    }
    
    private func configureCollectionView() {
        collectionView.register(TimeSlotCell.self, forCellWithReuseIdentifier: "TimeSlotCell")
    }
    
    private func configureDropDown(startY: inout CGFloat) {
        // calendar .scope 모드 아래에배치
        
        let height: CGFloat = 44
        let width: CGFloat = 150
        
        dropDownView.dataSource = dataSource.data.map(\.name)
        dropDownView.frame = CGRect(x: 8, y: startY, width: width, height: height)
        view.insertSubview(dropDownView, belowSubview: calendar)
        startY += height + 8
    }
    
    private func configureContainerView(height: CGFloat) {
        
        collectionView.frame = CGRect(x: 0,
                         y: height,
                         width: view.bounds.width,
                         height: view.bounds.height - height)
        
        view.insertSubview(collectionView, belowSubview: calendar)
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
        
        calendar.rx.swipe
            .subscribe { [weak self] g in
                self?.calendarHeightConstant.constant = g.element!.height
            }
            .disposed(by: disposeBag)
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
        
        let resBtn = UIBarButtonItem(title: "예약", style: .plain, target: self, action: nil)
        navigationItem.rightBarButtonItem = resBtn
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

extension MainViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalWidth = collectionView.frame.width
        let spacing: CGFloat = 0 // (7-1) * minimumInteritemSpacing
        let availableWidth = totalWidth - spacing
        let width = availableWidth / 7  // 7개 열 (일~토)
        let height: CGFloat = 50 // 30분 단위 높이
        return CGSize(width: width, height: height)
    }
}
