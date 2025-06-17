//
//  UIKit+Rx.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/17/25.
//

import UIKit
import RxCocoa
import RxSwift

extension Reactive where Base: UIViewController {
    var viewWillAppear: Observable<Void> {
        return methodInvoked(#selector(Base.viewWillAppear(_:)))
            .map { $0.first as? Bool ?? false }
            .map { _ in }
    }
}
