//
//  Calendar+Rx.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/16/25.
//

import RxSwift
import RxCocoa
import FSCalendar
//
//// MARK: - FSCalendarRxWrapper
//class FSCalendarRxWrapper: NSObject, FSCalendarDelegate {
//    
//    let didSelectDate = PublishSubject<Date>()
//    let boundingRectWillChange = PublishSubject<CGRect>()
//    
//    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
//        didSelectDate.onNext(date)
//    }
//    
//    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
//        boundingRectWillChange.onNext(bounds)
//    }
//}
//
//// MARK: - Reactive Extension
//extension Reactive where Base: FSCalendar {
//    
//    var calendarDelegate: FSCalendarRxWrapper {
//        return synchronizedBag {
//            if let delegate = objc_getAssociatedObject(base, &AssociatedKeys.delegate) as? FSCalendarRxWrapper {
//                return delegate
//            }
//            
//            let delegate = FSCalendarRxWrapper()
//            objc_setAssociatedObject(base, &AssociatedKeys.delegate, delegate, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
//            base.delegate = delegate
//            return delegate
//        }
//    }
//    
//    var didSelectDate: Observable<Date> {
//        return calendarDelegate.didSelectDate.asObservable()
//    }
//    
//    var boundingRectWillChange: Observable<CGRect> {
//        return calendarDelegate.boundingRectWillChange.asObservable()
//    }
//}
//
//private struct AssociatedKeys {
//    static var delegate = "rx_delegate"
//}
