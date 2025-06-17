//
//  Calendar+Rx.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/16/25.
//

import RxSwift
import RxCocoa
import FSCalendar

extension FSCalendar: @retroactive HasDelegate {
    public typealias Delegate = FSCalendarDelegate
}

class RXFSCalendarDelegateProxy: DelegateProxy<FSCalendar, FSCalendarDelegate>, DelegateProxyType, FSCalendarDelegate {
    
    weak private var calendar: FSCalendar?
    
    init(calendar: FSCalendar) {
        self.calendar = calendar
        super.init(parentObject: calendar, delegateProxy: RXFSCalendarDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register { RXFSCalendarDelegateProxy(calendar: $0) }
    }
}

extension Reactive where Base: FSCalendar {
    var delegate: DelegateProxy<FSCalendar, FSCalendarDelegate> {
        return RXFSCalendarDelegateProxy.proxy(for: base)
    }
    
      var tapDate: Observable<Date> {
          return delegate.methodInvoked(#selector(FSCalendarDelegate.calendar(_:didSelect:at:)))
              .map { parameters in
                  // parameters[1]이 선택된 Date 객체
                  return parameters[1] as! Date
              }
      }
    
    var swipe: Observable<CGRect> {
        return delegate.methodInvoked(#selector(FSCalendarDelegate.calendar(_:boundingRectWillChange:animated:)))
            .map { param in
                return param[1] as! CGRect
            }
    }
}
