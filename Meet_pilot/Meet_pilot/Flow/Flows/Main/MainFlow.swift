//
//  MainFlow.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/17/25.
//

import UIKit
import RxSwift
import RxFlow

final class MainFlow: Flow {
    private let rootVC: UINavigationController = .init()
    private let bag = DisposeBag()
    
    var root: any Presentable {
        return rootVC
    }
    
    func navigate(to step: any Step) -> FlowContributors {
        guard let step = step as? PilotStep else { return .none }
        
        switch step {
        case .mainIsRequired(let meetingRooms):
            return headToMain(meetingRooms)
            
        default:
            return .none
        }
    }
    
    private func headToMain(_ meetingRooms: MeetingRooms) -> FlowContributors {
        let vm = MainViewModel()
        let vc = MainViewController(datasource: meetingRooms)
        vc.reactor = vm
        self.rootVC.setViewControllers([vc], animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: vc,
                                                 withNextStepper: vm,
                                                 allowStepWhenNotPresented: false,
                                                 allowStepWhenDismissed: false))
    }
}
