//
//  MainViewModel.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/13/25.
//

import Foundation
import ReactorKit
import RxSwift
import RxFlow
import RxRelay

final class MainViewModel: Reactor, Stepper {
    
    enum Action {
        case startInit
        case tapCalendar(Date)
        case tapSideMenu(String)
        case tapResBtn
        case tapCell
        case tapDropbox(MeetingRoom)
    }
    
    enum Mutation {
        case fetchMeetingRoomInfo(MeetingRooms)
        case fetchCalendarInfo // Google Calendar API
        case changeDate(Date)
        case setAlertMesg(String)
    }
    
    struct State {
        @Pulse var title: String = "회의실 현황"
        @Pulse var error: String?
        @Pulse var currentDate: Date?
        @Pulse var currentMeetingRoom: MeetingRoom?
        @Pulse var meetingRooms: MeetingRooms?
    }
    
    let steps: PublishRelay<any Step> = .init()
    let initialState: State = State()
    
    var initialStep: PilotStep {
        return .mainIsRequired
    }
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .startInit:
            return WGoogleCalendarService.shared.fetchMeetingRooms()
                .map { Mutation.fetchMeetingRoomInfo($0) }
                .asObservable()
                .catch(handleError)
        default:
            return Observable.empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setAlertMesg(let msg):
            newState.error = msg
        case .fetchMeetingRoomInfo(let rooms):
            newState.meetingRooms = rooms
        case .changeDate(let date):
            break
        case .fetchCalendarInfo:
            break
        }
        return newState
    }
    
    private func handleError(with error: Error) -> Observable<Mutation> {
        return Observable.just(.setAlertMesg("에러입니다."))
    }
}
