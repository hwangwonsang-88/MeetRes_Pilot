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
        case tapCalendar(String)
        case tapSideMenu(String)
        case tapResBtn
        case tapCell
    }
    
    enum Mutation {
        case fetchCalendarInfo // Google Calendar API
        
    }
    
    struct State {
        @Pulse var title: String = "예약"
        @Pulse var error: Error?
        // 예약 data
    }
    
    let initialState: State = State()
}
