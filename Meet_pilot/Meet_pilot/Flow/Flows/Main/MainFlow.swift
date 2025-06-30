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
    
    private weak var current: UINavigationController?
    private weak var main: MainViewController?
    private weak var resVC: CreateReservationViewController?
    
    func navigate(to step: any Step) -> FlowContributors {
        guard let step = step as? PilotStep else { return .none }
        
        switch step {
        case .mainIsRequired(let meetingRooms):
            return headToMain(meetingRooms)
            
        case  .detailViewIsRequired(let eventData):
            return headToDetail(eventData)
        case .dismiss(let eventData):
            return dissmiss(eventData: eventData)
        case .reservationVCIsRequired(let resModel):
            return headToReservation(with: resModel)
        case .reserVationIsCompleted(let event):
            return ReservationIsCompleted(eventData: event)
        default:
            return .none
        }
    }
    
    private func ReservationIsCompleted(eventData: EventData) -> FlowContributors {
        main?.sendAddEvent(eventData)
        resVC?.dismiss(animated: true)
        resVC = nil
        return .none
    }
    
    private func headToReservation(with res: ReservationModel) -> FlowContributors {
        let vc = CreateReservationViewController(reservationModel: res)
        resVC = vc
        self.rootVC.present(vc, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: vc,
                                                 withNextStepper: vc,
                                                 allowStepWhenNotPresented: false,
                                                 allowStepWhenDismissed: false))
    }
    
    private func dissmiss(eventData: EventData?) -> FlowContributors {
        
        if let eventData = eventData {
            main?.sendEvent(eventData)
        }
        current?.dismiss(animated: true) { [weak self] in
            self?.current = nil
        }
        return .none
    }
    
    private func headToDetail(_ eventData: EventData) -> FlowContributors {
        let vc = ReserveViewController(eventData: eventData)
        let navi = UINavigationController(rootViewController: vc)
        current = navi
        navi.modalPresentationStyle = .pageSheet
        self.rootVC.present(navi, animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: vc,
                                                 withNextStepper: vc,
                                                 allowStepWhenNotPresented: false,
                                                 allowStepWhenDismissed: false))
    }
    
    private func headToMain(_ meetingRooms: MeetingRooms) -> FlowContributors {
        let vm = MainViewModel()
        let vc = MainViewController(datasource: meetingRooms)
        main = vc
        vc.reactor = vm
        self.rootVC.setViewControllers([vc], animated: true)
        return .one(flowContributor: .contribute(withNextPresentable: vc,
                                                 withNextStepper: vm,
                                                 allowStepWhenNotPresented: false,
                                                 allowStepWhenDismissed: false))
    }
}
