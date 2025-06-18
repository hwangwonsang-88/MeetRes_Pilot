//
//  DropDown+Rx.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/18/25.
//

import RxSwift
import RxCocoa
import UIKit

extension DropDownView: HasDelegate {
    public typealias Delegate = DropDownDelegate
}

// MARK: - DelegateProxy Implementation
final class RXDropDownDelegateProxy: DelegateProxy<DropDownView, DropDownDelegate>,
                                     DelegateProxyType,
                                     DropDownDelegate {
    
    // MARK: - Properties
    weak private var dropDownView: DropDownView?
    
    // MARK: - Subjects for Reactive Events
    fileprivate let _didSelectRowSubject = PublishSubject<IndexPath>()
    
    // MARK: - Initialization
    init(dropDownView: DropDownView) {
        self.dropDownView = dropDownView
        super.init(parentObject: dropDownView, delegateProxy: RXDropDownDelegateProxy.self)
    }
    
    // MARK: - DelegateProxyType
    static func registerKnownImplementations() {
        register { RXDropDownDelegateProxy(dropDownView: $0) }
    }
    
    // MARK: - DropDownDelegate Implementation
    func dropDown(_ dropDownView: DropDownView, didSelectRowAt indexPath: IndexPath) {
        // Emit event through Subject
        _didSelectRowSubject.onNext(indexPath)
        
        if let delegate = self._forwardToDelegate as? DropDownDelegate {
             delegate.dropDown(dropDownView, didSelectRowAt: indexPath)
         }
    }
    
    // MARK: - Memory Management
    deinit {
        _didSelectRowSubject.onCompleted()
    }
}

// MARK: - Reactive Extension
extension Reactive where Base: DropDownView {
    
    /// DelegateProxy for DropDownView
    var delegate: DelegateProxy<DropDownView, DropDownDelegate> {
        return RXDropDownDelegateProxy.proxy(for: base)
    }
    
    /// Observable for row selection events
    /// - Returns: Observable that emits IndexPath when a row is selected
    var didSelectRow: Observable<IndexPath> {
        return (delegate as! RXDropDownDelegateProxy)._didSelectRowSubject.asObservable()
    }
    
    /// Observable for selected row index (section ignored, only row)
    /// - Returns: Observable that emits Int representing the selected row
    var selectedRowIndex: Observable<Int> {
        return didSelectRow.map { $0.row }
    }
    
    /// Observable for selected item based on provided data array
    /// - Parameter items: Array of items corresponding to dropdown rows
    /// - Returns: Observable that emits the selected item
    func selectedItem<T>(from items: [T]) -> Observable<T> {
        return selectedRowIndex
            .filter { $0 < items.count && $0 >= 0 }
            .map { items[$0] }
    }
    
    /// Observable for selected item with validation
    /// - Parameter items: Array of items corresponding to dropdown rows
    /// - Returns: Observable that emits optional selected item (nil if invalid index)
    func selectedItemSafely<T>(from items: [T]) -> Observable<T?> {
        return selectedRowIndex
            .map { index in
                return (index >= 0 && index < items.count) ? items[index] : nil
            }
    }
}
