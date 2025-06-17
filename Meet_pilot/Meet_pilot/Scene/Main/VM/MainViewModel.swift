//
//  MainViewModel.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/13/25.
//

import Foundation
import ReactorKit
import RxSwift

final class MainViewModel: Reactor {
    
    enum Action {
        case tapCalendar(Date)
        case tapSideMenu(String)
        case tapResBtn
        case tapCell
        case tapDropbox(MeetingRoom)
    }
    
    enum Mutation {
        case fetchCalendarInfo // Google Calendar API
        case changeDate(Date)
    }
    
    struct State {
        @Pulse var title: String = "회의실 현황"
        @Pulse var error: Error?
        @Pulse var currentDate: Date?
        @Pulse var currentMeetingRoom: MeetingRoom?
    }
    
    let initialState: State = State()
}
