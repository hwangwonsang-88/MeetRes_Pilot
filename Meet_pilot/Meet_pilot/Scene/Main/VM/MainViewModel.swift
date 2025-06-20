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
        case tapCell((Int, Int))
        case fetchMeetingSchedule((MeetingRoom, Date))
        case makeReservation(MeetingRoom, Date)
    }
    
    enum Mutation {
        case setSchedules([EventData])
        case setCheckedPeriod(DayTimeSlot)
        case setAlertMesg(String)
        case setLoading(Bool)
        case makeReservation(EventData)
    }
    
    struct State {
        @Pulse var title: String = "회의실 현황"
        @Pulse var error: String?
        @Pulse var isLoading = false
        @Pulse var meetingSchedules = [TimeSlotSection]()
        var googleEvents = [EventData]()
        @Pulse var checkedSchedules = [TimeSlotSection]()
        
        init() {
            meetingSchedules = Self.generateTimeSlotSections()
        }
        
        static func generateTimeSlotSections() -> [TimeSlotSection] {
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
                        isAvailable: true
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
            return WGoogleCalendarService.shared.fetchMeetingInfo(meetingRoomID: meetingRoom.calendarID,
                                                                  targetDate: date)
            .map { .setSchedules($0) }
            .asObservable()
            .catch(handleError)
            
        case .tapCell((let row, let section)):
            let timeSlotSection = currentState.meetingSchedules[section]
            let dayTimeSlot = timeSlotSection.dayCells[row]
            return Observable.just(.setCheckedPeriod(dayTimeSlot))
            
        case .makeReservation(let meetingRoom, let date):
            var resModel = createReservationModel(date: date, meetingRoomID: meetingRoom.calendarID)
            resModel.title = "ios 테스트입니다."
            resModel.description = "ios 테스트입니다."
            
            return Observable.concat([
                WGoogleCalendarService.shared.makeReservation(with: resModel)
                    .map { Mutation.makeReservation($0) }
                    .asObservable(),
            ])
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
            
        case .setLoading(let bool):
            newState.isLoading = bool
            
        case .setSchedules(let events):
            // 초기화
            let renewal = State.generateTimeSlotSections()
            newState.meetingSchedules = renewal
            newState.googleEvents = []
            newState.checkedSchedules = []
            // event를 파싱해서 적용한다
            newState.googleEvents = events
            newState.meetingSchedules = updateSlots(with: events, on: newState.meetingSchedules)
            
        case .setCheckedPeriod(let dayTimeSlot):
            
            // 이미 체크된 스케줄인지 확인
            if let existingIndex = newState.checkedSchedules.firstIndex(where: { section in
                section.time == dayTimeSlot.time &&
                section.dayCells.contains { $0.dayIndex == dayTimeSlot.dayIndex }
            }) {
                // 이미 존재하면 제거 (toggle)
                newState.checkedSchedules.remove(at: existingIndex)
            } else {
                // 존재하지 않으면 추가
                let checkedSection = TimeSlotSection(time: dayTimeSlot.time, dayCells: [dayTimeSlot])
                newState.checkedSchedules.append(checkedSection)
            }
            
        case .makeReservation(let event):
            newState.checkedSchedules = []
            var renewedEvents = newState.googleEvents
            renewedEvents.append(event)
            newState.googleEvents = renewedEvents
            newState.meetingSchedules = updateSlots(with: renewedEvents, on: newState.meetingSchedules)
        }
        return newState
    }
    
    private func updateSlots(with events: [EventData], on sections: [TimeSlotSection]) -> [TimeSlotSection] {
        var updatedSections = sections
        let calendar = Calendar.current
        let timeToSectionIndex = Dictionary(uniqueKeysWithValues: sections.enumerated().map { ($0.element.time, $0.offset) })

        for event in events {
            let dayIndex = calendar.component(.weekday, from: event.startDateTime) - 1
            var currentTimeInSlot = event.startDateTime
            let randomColor = getRandomColor()
            while currentTimeInSlot < event.endDateTime {
                let hour = calendar.component(.hour, from: currentTimeInSlot)
                let minute = calendar.component(.minute, from: currentTimeInSlot)
                let slotMinute = (minute / 30) * 30 // 30분 단위로 내림
                let timeString = String(format: "%02d:%02d", hour, slotMinute)
                if let sectionIndex = timeToSectionIndex[timeString] {
                    if updatedSections[sectionIndex].dayCells.indices.contains(dayIndex) {
                        updatedSections[sectionIndex].dayCells[dayIndex].isAvailable = false
                        updatedSections[sectionIndex].dayCells[dayIndex].event = event
                        updatedSections[sectionIndex].dayCells[dayIndex].color = randomColor
                    }
                }
                currentTimeInSlot = calendar.date(byAdding: .minute, value: 30, to: currentTimeInSlot)!
            }
        }
        return updatedSections
    }
    
    private func handleError(with error: Error) -> Observable<Mutation> {
        return Observable.just(.setAlertMesg("에러입니다."))
    }
    
    private func getRandomColor() -> String {
        let hexStrings = [
              "#FF0000", // Red
              "#00FF00", // Lime
              "#0000FF", // Blue
              "#FFFF00", // Yellow
              "#FF00FF", // Magenta
              "#00FFFF", // Cyan
              "#FFA500", // Orange
              "#800080", // Purple
              "#008000", // Green
              "#FFC0CB", // Pink
              "#FFD700", // Gold
              "#4B0082", // Indigo
              "#FF4500", // OrangeRed
              "#00CED1", // DarkTurquoise
              "#228B22", // ForestGreen
              "#DC143C", // Crimson
              "#9932CC", // DarkOrchid
              "#20B2AA", // LightSeaGreen
              "#FF69B4", // HotPink
              "#4682B4"  // SteelBlue
          ]
        return hexStrings.randomElement() ?? "#000000"
    }
    
    private func createReservationModel(date: Date, meetingRoomID: String) -> ReservationModel {
        var checked = currentState.checkedSchedules.sorted{ $0.time < $1.time}
        let week = getDateForWeekday(from: date, targetWeekday: checked[0].dayCells[0].dayIndex)!
        let start = addTime(timeString: checked.first!.time, target: week)!
        if checked.count == 1 {
            let end = start.adding30MinutesSafe()
            return ReservationModel(meetingRoomID: meetingRoomID, startTime: start, endTime: end)
        }
        let end = addTime(timeString: checked.last!.time, target: week)!.adding30MinutesSafe()
        return ReservationModel(meetingRoomID: meetingRoomID, startTime: start, endTime: end)
        
    }
    
    func addTime(timeString: String, target: Date) -> Date? {
        let calendar = Calendar.current
        
        // 1. 시간 문자열 파싱 ("HH:mm" 형식)
        guard let timeComponents = parseTimeString(timeString) else {
            print("잘못된 시간 형식입니다. 'HH:mm' 형식을 사용해주세요. (예: '09:00', '13:30')")
            return nil
        }
        
        // 2. target 날짜의 년/월/일 정보 추출
        let dateComponents = calendar.dateComponents([.year, .month, .day], from: target)
        
        // 3. 새로운 DateComponents 생성 (날짜 + 시간)
        var newComponents = DateComponents()
        newComponents.year = dateComponents.year
        newComponents.month = dateComponents.month
        newComponents.day = dateComponents.day
        newComponents.hour = timeComponents.hour
        newComponents.minute = timeComponents.minute
        newComponents.second = 0 // 초는 0으로 설정
        
        // 4. 최종 Date 객체 생성
        guard let resultDate = calendar.date(from: newComponents) else {
            print("날짜 생성에 실패했습니다.")
            return nil
        }
        
        return resultDate
    }

    // MARK: - 헬퍼 함수: 시간 문자열 파싱
    private func parseTimeString(_ timeString: String) -> (hour: Int, minute: Int)? {
        // 1. 공백 제거
        let trimmedString = timeString.trimmingCharacters(in: .whitespaces)
        
        // 2. ":" 기준으로 분리
        let components = trimmedString.split(separator: ":")
        
        // 3. 정확히 2개 구성요소가 있는지 확인 (시간:분)
        guard components.count == 2 else {
            return nil
        }
        
        // 4. 시간과 분을 정수로 변환
        guard let hour = Int(components[0]),
              let minute = Int(components[1]) else {
            return nil
        }
        
        // 5. 유효성 검사
        guard hour >= 0 && hour <= 23,
              minute >= 0 && minute <= 59 else {
            return nil
        }
        
        return (hour: hour, minute: minute)
    }
    
    func getDateForWeekday(from inputDate: Date, targetWeekday: Int) -> Date? {
        let calendar = Calendar.current
        
        // 1. 입력된 날짜가 속한 주의 시작일(일요일) 구하기
        // dateInterval(of:for:)는 해당 날짜가 속한 주의 시작과 끝을 반환
        guard let weekInterval = calendar.dateInterval(of: .weekOfYear, for: inputDate) else {
            print("주 간격을 계산할 수 없습니다.")
            return nil
        }
    
        let daysToAdd = targetWeekday
        
        // 3. 시작일에 일수를 더해서 목표 요일의 날짜 계산
        let targetDate = calendar.date(byAdding: .day, value: daysToAdd, to: weekInterval.start)
        
        return targetDate
    }
}

// 새로운 데이터 구조: 시간대별 섹션
struct TimeSlotSection {
    let time: String // 예: "09:00"
    var dayCells: [DayTimeSlot] // 해당 시간대의 7개 요일 셀
}

// 개별 셀 데이터
struct DayTimeSlot {
    let day: String // 예: "월"
    let time: String // 예: "09:00"
    let dayIndex: Int // 0: 일요일, 1: 월요일, ..., 6: 토요일
    var isAvailable: Bool = true
    var event: EventData? = nil
    var color: String? = nil
}

