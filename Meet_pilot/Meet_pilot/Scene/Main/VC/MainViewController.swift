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
            layout.minimumLineSpacing = 1      // 시간대 간 구분을 위한 최소 간격
            layout.minimumInteritemSpacing = 1  // 요일 간 구분을 위한 최소 간격
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
                .do(onNext: { [weak self] _ in
                    guard let self = self else { return }
                    if self.calendar.scope == .month {
                        self.calendar.scope = .week
                    }
                })
                .startWith(.now)
            
           Observable.combineLatest(dropDownStream, calendarStream)
                .map { Reactor.Action.fetchMeetingSchedule(($0, $1)) }
                .debug()
                .bind(to: reactor.action)
                .disposed(by: disposeBag)
            
            reactor.pulse(\.$title)
                .bind(to: navigationItem.rx.title)
                .disposed(by: disposeBag)
            
            let dataSource = RxCollectionViewSectionedReloadDataSource<SectionModel<String, DayTimeSlot>>(
                    configureCell: { (dataSource, collectionView, indexPath, dayTimeSlot) in
                        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TimeSlotCell", for: indexPath) as! TimeSlotCell
                        
                        // 시간 정보만 표시 (각 셀은 해당 요일의 특정 시간대를 나타냄)
                        if dayTimeSlot.dayIndex == 0 {
                            cell.configure(with: dayTimeSlot.time)
                        }
                        return cell
                    }
                )
                
                // 상태 바인딩: 시간대별 섹션으로 변경
                reactor.state
                    .map { $0.meetingSchedules }
                    .map { schedules in
                        // 각 시간대를 섹션으로 변환
                        schedules.map { timeSlotSection in
                            SectionModel(model: timeSlotSection.time, items: timeSlotSection.dayCells)
                        }
                    }
                    .bind(to: collectionView.rx.items(dataSource: dataSource))
                    .disposed(by: disposeBag)
                
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
            
            dropDownView.frame = CGRect(x: 0, y: startY, width: width, height: height)
            view.insertSubview(dropDownView, belowSubview: calendar)
            startY += height
        }

        private func configureContainerView(height: CGFloat) {
            let v = UIView()
     
            v.frame = CGRect(x: 0,
                             y: height,
                             width: view.bounds.width,
                             height: view.bounds.height - height)
            v.backgroundColor = .black
            view.insertSubview(v, belowSubview: calendar)
            
            collectionView.frame = v.frame
            view.addSubview(collectionView)
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
        let spacing: CGFloat = 6 // (7-1) * minimumInteritemSpacing
        let availableWidth = totalWidth - spacing
        let width = availableWidth / 7  // 7개 열 (일~토)
        let height: CGFloat = 50 // 30분 단위 높이
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1 // 시간대별 행 간격
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1 // 요일별 열 간격
    }
}
