//
//  DropDownView.swift
//  Meet_pilot
//
//  Created by Wonsang Hwang on 6/17/25.
//

import UIKit
import RxSwift
import RxCocoa

final class DropDownView: UIView {
    private enum DropDownMode {
        case display
        case hide
    }
    
    // MARK: - Properties
    weak var delegate: DropDownDelegate?
    
    /// DropDown을 띄울 Constraint를 적용합니다. default는 anchorView아래입니다.
    private var dropDownConstraints: ((UIView, UIView) -> [NSLayoutConstraint])?
    
    /// 현재 적용된 dropDown 제약조건들을 저장 (제거를 위해)
    private var activeDropDownConstraints: [NSLayoutConstraint] = []
    
    /// DropDown을 display여부를 확인 및 설정할 수 있습니다.
    var isDisplayed: Bool {
        get {
            dropDownMode == .display
        }
        set {
            if newValue {
                becomeFirstResponder()
            } else {
                resignFirstResponder()
            }
        }
    }
    
    /// DropDownView의 상태를 확인하는 private 변수입니다.
    private var dropDownMode: DropDownMode = .hide

    /// DropDown에 띄울 목록들을 정의합니다.
    var dataSource = [String]() {
        didSet { dropDownTableView.reloadData() }
    }
        
    /// DropDown의 현재 선택된 항목을 알 수 있습니다.
    private(set) var selectedOption: String?

    override var canBecomeFirstResponder: Bool { true }
    
    // MARK: - UI Components
    private let anchorView: UIView
    fileprivate let dropDownTableView = DropDownTableView()
    
    // MARK: - Initializers
    init(anchorView: UIView) {
        self.anchorView = anchorView
        super.init(frame: .zero)
        
        dropDownTableView.dataSource = self
        dropDownTableView.delegate = self
        
        setupUI()
    }
    
    convenience init(anchorView: UIView, selectedOption: String) {
        self.init(anchorView: anchorView)
        self.selectedOption = selectedOption
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIResponder Methods
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if dropDownMode == .display {
            resignFirstResponder()
        } else {
            becomeFirstResponder()
        }
    }
    
    @discardableResult
    override func becomeFirstResponder() -> Bool {
        super.becomeFirstResponder()

        dropDownMode = .display
        displayDropDown(with: dropDownConstraints)
        return true
    }
    
    @discardableResult
    override func resignFirstResponder() -> Bool {
        super.resignFirstResponder()

        dropDownMode = .hide
        hideDropDown()
        return true
    }
}

// MARK: - UI Method
private extension DropDownView {
    func setupUI() {
        // anchorView를 현재 뷰에 추가
        self.addSubview(anchorView)
        anchorView.translatesAutoresizingMaskIntoConstraints = false
        
        // anchorView의 제약조건 설정 (edges.equalToSuperview()와 동일)
        NSLayoutConstraint.activate([
            anchorView.topAnchor.constraint(equalTo: self.topAnchor),
            anchorView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            anchorView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            anchorView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        ])
        
        // 기본 제약조건 설정
        setConstraints { dropDownTableView, anchorView in
            return [
                dropDownTableView.leadingAnchor.constraint(equalTo: anchorView.leadingAnchor),
                dropDownTableView.trailingAnchor.constraint(equalTo: anchorView.trailingAnchor),
                dropDownTableView.topAnchor.constraint(equalTo: anchorView.bottomAnchor)
            ]
        }
    }
}

// MARK: - DropDown Logic
extension DropDownView {
    /// DropDownList를 보여줍니다.
    func displayDropDown(with constraintsBuilder: ((UIView, UIView) -> [NSLayoutConstraint])?) {
        guard let constraintsBuilder = constraintsBuilder else { return }
        
        // 기존 제약조건들을 먼저 제거
        NSLayoutConstraint.deactivate(activeDropDownConstraints)
        activeDropDownConstraints.removeAll()
        
        // dropDownTableView를 window에 추가
        window?.addSubview(dropDownTableView)
        dropDownTableView.translatesAutoresizingMaskIntoConstraints = false
        
        // 새로운 제약조건들을 생성하고 활성화
        let constraints = constraintsBuilder(dropDownTableView, anchorView)
        activeDropDownConstraints = constraints
        NSLayoutConstraint.activate(constraints)
    }
    
    /// DropDownList를 hide합니다.
    func hideDropDown() {
        // 제약조건들을 비활성화하고 제거
        NSLayoutConstraint.deactivate(activeDropDownConstraints)
        activeDropDownConstraints.removeAll()
        
        // tableView를 superview에서 제거
        dropDownTableView.removeFromSuperview()
    }
    
    /// 제약조건을 설정하는 메서드
    /// - Parameter closure: dropDownTableView와 anchorView를 받아서 제약조건 배열을 반환하는 클로저
    func setConstraints(_ closure: @escaping (_ dropDownTableView: UIView, _ anchorView: UIView) -> [NSLayoutConstraint]) {
        self.dropDownConstraints = closure
    }
}

// MARK: - UITableViewDataSource
extension DropDownView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: DropDownCell.identifier,
            for: indexPath
        ) as? DropDownCell
        else {
            return UITableViewCell()
        }
        
        /// selectedOption이라면 해당 cell의 textColor가 바뀌도록
        if let selectedOption = self.selectedOption,
             selectedOption == dataSource[indexPath.row] {
            cell.isSelected = true
        }
        
        cell.configure(with: dataSource[indexPath.row])
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension DropDownView: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedOption = dataSource[indexPath.row]
        delegate?.dropDown(self, didSelectRowAt: indexPath)
        dropDownTableView.selectRow(at: indexPath)
        resignFirstResponder()
    }
}

// MARK: - Reactive Extension
extension Reactive where Base: DropDownView {
    var selectedOption: ControlEvent<String> {
        let source = base.dropDownTableView.rx.itemSelected.map { base.dataSource[$0.row] }
        
        return ControlEvent(events: source)
    }
}

// MARK: - 사용 예시
/*
// 기본 사용법
let dropDown = DropDownView(anchorView: myButton)
dropDown.dataSource = ["Option 1", "Option 2", "Option 3"]

// 커스텀 제약조건 설정
dropDown.setConstraints { dropDownTableView, anchorView in
    return [
        dropDownTableView.leadingAnchor.constraint(equalTo: anchorView.leadingAnchor, constant: 10),
        dropDownTableView.trailingAnchor.constraint(equalTo: anchorView.trailingAnchor, constant: -10),
        dropDownTableView.topAnchor.constraint(equalTo: anchorView.bottomAnchor, constant: 5),
        dropDownTableView.heightAnchor.constraint(lessThanOrEqualToConstant: 200)
    ]
}
*/
