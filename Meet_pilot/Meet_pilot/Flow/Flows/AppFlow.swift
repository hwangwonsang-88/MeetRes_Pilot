//
//  AppFlow.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/17/25.
//

import UIKit
import RxFlow
import RxCocoa
import RxSwift

struct AppStepper: Stepper {
    let steps: RxRelay.PublishRelay<any RxFlow.Step> = .init()
    private let disposeBag = DisposeBag()
    
    func readyToEmitSteps() {
        // 로그인 안된 경우
        WGoogleLoginService.shared.hasSignedIn()
            .filter {!$0}
            .map { _ in PilotStep.loginIsRequired}
            .bind(to: steps)
            .disposed(by: disposeBag)
        
        // 로그인 된 경우
        WGoogleLoginService.shared.hasSignedIn()
            .filter {$0}
            .flatMap { _ in WGoogleCalendarService.shared.fetchMeetingRooms() }
            .map { PilotStep.mainIsRequired($0) }
            .bind(to: steps)
            .disposed(by: disposeBag)
    }
}

final class AppFlow: Flow {
    
    private let window: UIWindow
    
    init(window: UIWindow) {
        self.window = window
    }
    
    var root: any Presentable {
        return window
    }
    
    func navigate(to step: any Step) -> FlowContributors {
        guard let step = step as? PilotStep else { return .none }
        
        switch step {
            
        case .loginIsRequired:
            let loginFlow = LoginFlow()
            Flows.use(loginFlow, when: .created) { [unowned self] vc in
                self.window.rootViewController = vc
            }
            
            let nextStep = OneStepper(withSingleStep: PilotStep.loginIsRequired)
            return .one(flowContributor: .contribute(withNextPresentable: loginFlow, withNextStepper: nextStep))
            
        case .mainIsRequired(let meetingRooms):
            let mainFlow = MainFlow()
            Flows.use(mainFlow, when: .created) { [unowned self] vc in
                self.window.rootViewController = vc
            }
            let nextStep = OneStepper(withSingleStep: PilotStep.mainIsRequired(meetingRooms))
            return .one(flowContributor: .contribute(withNextPresentable: mainFlow, withNextStepper: nextStep, allowStepWhenNotPresented: false, allowStepWhenDismissed: false))
            
        default:
            return .none
        }
    }
}
