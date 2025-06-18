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
        case tapSideMenu(String)
        case tapResBtn
        case tapCell
        case fetchMeetingSchedule((MeetingRoom, Date))
    }
    
    enum Mutation {
        case setMeetingRoom(MeetingRoom)
        case setAlertMesg(String)
        case setLoading(Bool)
    }
    
    struct State {
        @Pulse var title: String = "회의실 현황"
        @Pulse var error: String?
        @Pulse var isLoading = false
        @Pulse var meetingSchedules = [TimeSlotSection]()
        
        init() {
            // 시간대별로 섹션을 구성
            meetingSchedules = Self.generateTimeSlotSections()
        }
        
        // 시간대별 섹션 생성 (각 시간대가 하나의 섹션)
        private static func generateTimeSlotSections() -> [TimeSlotSection] {
            var sections: [TimeSlotSection] = []
            let calendar = Calendar.current
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "HH:mm"
            
            var currentTime = calendar.date(bySettingHour: 9, minute: 0, second: 0, of: Date())!
            let endTime = calendar.date(bySettingHour: 18, minute: 0, second: 0, of: Date())!
            
            while currentTime <= endTime {
                let timeString = dateFormatter.string(from: currentTime)
                
                // 각 시간대마다 7개 요일의 셀을 생성
                let dayCells = (0..<7).map { dayIndex in
                    let dayNames = ["일", "월", "화", "수", "목", "금", "토"]
                    return DayTimeSlot(
                        day: dayNames[dayIndex],
                        time: timeString,
                        dayIndex: dayIndex,
                        isAvailable: true // 실제로는 서버 데이터에 따라 결정
                    )
                }
                
                sections.append(TimeSlotSection(time: timeString, dayCells: dayCells))
                currentTime = calendar.date(byAdding: .minute, value: 30, to: currentTime)!
            }
            
            return sections
        }
    }
    
    let steps: PublishRelay<any Step> = .init()
    let initialState: State = State()
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .fetchMeetingSchedule((let meetingRoom, let date)):
            return .empty()
        default:
            return Observable.empty()
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        switch mutation {
        case .setAlertMesg(let msg):
            newState.error = msg
        case .setLoading(let bool):
            newState.isLoading = bool
        default:
            break
        }
        return newState
    }
    
    private func handleError(with error: Error) -> Observable<Mutation> {
        return Observable.just(.setAlertMesg("에러입니다."))
    }
}

// 새로운 데이터 구조: 시간대별 섹션
struct TimeSlotSection {
    let time: String // 예: "09:00"
    let dayCells: [DayTimeSlot] // 해당 시간대의 7개 요일 셀
}

// 개별 셀 데이터
struct DayTimeSlot {
    let day: String // 예: "월"
    let time: String // 예: "09:00"
    let dayIndex: Int // 0: 일요일, 1: 월요일, ..., 6: 토요일
    let isAvailable: Bool // 예약 가능 여부
}

