//
//  LoginViewModel.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/16/25.
//

import Foundation
import ReactorKit
import RxRelay
import RxFlow

// 로그인 -> 성공 -> 화면이동 실패 -> Alert

final class LoginViewModel: Reactor, Stepper {
    var steps: RxRelay.PublishRelay<Step> = .init()
    var disposeBag = DisposeBag()
    
    weak var vc: LoginViewController?
    
    enum Action {
        case tapLoginBtn
    }
    
    enum Mutation {
        case signIn
        case fetchMeetingRooms(MeetingRooms)
        case setAlertMessage(String)
    }
    
    struct State {
        @Pulse var errorMsg: String? = nil
        @Pulse var isSignedIn: Bool = false
    }

    var initialState: State = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .tapLoginBtn:
            return Observable.concat([
                WGoogleLoginService.shared.singIn()
                    .map { Mutation.signIn }
                    .asObservable()
                    .catch(handleError),
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var state = state
        switch mutation {
        case .setAlertMessage(let string):
            state.errorMsg = string
        case .signIn:
            state.isSignedIn = true
        default:
            break
        }
        
        return state
    }
    
    
    func transform(state: Observable<State>) -> Observable<State> {
        return state.do { state in
            if state.isSignedIn {
        
            }
        }
    }

    private func handleError(with error: any Error) -> Observable<Mutation> {
        return Observable.just(.setAlertMessage("에러입니다.\n" + error.localizedDescription))
    }
}
