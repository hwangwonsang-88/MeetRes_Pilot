//
//  LoginFlow.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/17/25.
//

import UIKit
import RxFlow

final class LoginFlow: Flow {
    
    private let rootVC: UINavigationController = .init()
    
    var root: any Presentable {
        return rootVC
    }
    
    func navigate(to step: any Step) -> FlowContributors {
        guard let step = step as? PilotStep else { return .none }
        
        switch step {
        case .loginIsRequired:
            let vm = LoginViewModel()
            let vc = LoginViewController()
            vc.reactor = vm
            self.rootVC.pushViewController(vc, animated: true)
            return .one(flowContributor: .contribute(withNextPresentable: vc,
                                                     withNextStepper: vm))
        case .loginIsCompleted:
            return .end(forwardToParentFlowWithStep: PilotStep.mainIsRequired)
        default:
            return .none
        }
    }
    
}
