//
//  GoogleCalendarService.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/16/25.
//

import Foundation
import GoogleAPIClientForREST_Calendar
import GoogleSignIn
import RxSwift

final class WGoogleCalendarService {
    
    static let shared = WGoogleCalendarService()
    private let core = GTLRCalendarService()
    private init() {}
    
    func setAuth(by user: GIDGoogleUser) {
        core.authorizer = user.fetcherAuthorizer
    }
    
    func cancelReservation(with model: EventData) -> Single<Void> {
        return Single.create { [weak self] single in
            print("cancel start")
            let query = GTLRCalendarQuery_EventsDelete.query(withCalendarId: "primary", eventId: model.eventID)
            self?.core.executeQuery(query) { ticket, _, error in
                if let _ = error {
                    print("cancel ERROR")
                    single(.failure(NSError(domain: "Cancel Error", code: 100001)))
                    return
                }
                single(.success(()))
                print("cancel DONE")
            }
            return Disposables.create()
        }
    }
    
    func makeReservation(with model: ReservationModel) -> Single<EventData> {
        return Single.create { [unowned self] single in
            print("res start")
            let event = GTLRCalendar_Event()
            event.summary = model.title
            event.descriptionProperty = model.description
            
            let startDateTime = GTLRDateTime(date: model.startTime)
            let eventStart = GTLRCalendar_EventDateTime()
            eventStart.dateTime = startDateTime
            eventStart.timeZone = TimeZone.current.identifier // 현재 기기의 시간대 사용
            event.start = eventStart
            
            let endDateTime = GTLRDateTime(date: model.endTime)
            let eventEnd = GTLRCalendar_EventDateTime()
            eventEnd.dateTime = endDateTime
            eventEnd.timeZone = TimeZone.current.identifier
            event.end = eventEnd
            
            // 참석자 추가
            
            let query = GTLRCalendarQuery_EventsInsert.query(withObject: event, calendarId: "primary")
            self.core.executeQuery(query) { ticket, result, error in
                if let error = error {
                    print("res ERRROR",error)
                    single(.failure(NSError(domain: "ResError", code: -1, userInfo: [NSLocalizedDescriptionKey: "예약에러"])))
                    return
                }
                
                guard let result = result as? GTLRCalendar_Event else {
                    print("res ERRROR2")
                    single(.failure(NSError(domain: "ResError", code: -1, userInfo: [NSLocalizedDescriptionKey: "예약에러"])))
                    return }
                let event = EventData(from: result, meetingRoomName: model.meetingRoomID)!
                single(.success(event))
            }
            return Disposables.create()
        }
    }
    
    func fetchMeetingInfo(meetingRoomID: String, targetDate: Date) -> Single<[EventData]> {
        return Single.create { [unowned self] single in
            
            let (monday, friday) = self.getMondayAndFriday(for: targetDate)
            let calendar = Calendar.current
            
            guard let monday9AM = calendar.date(byAdding: .hour, value: 9, to: calendar.startOfDay(for: monday)) else {
                single(.failure(NSError(domain: "DateError", code: -1, userInfo: [NSLocalizedDescriptionKey: "월요일 오전 9시 계산에 실패했습니다."])))
                return Disposables.create()
            }
            
            guard let friday6PM = calendar.date(byAdding: .hour, value: 18, to: calendar.startOfDay(for: friday)) else {
                single(.failure(NSError(domain: "DateError", code: -1, userInfo: [NSLocalizedDescriptionKey: "금요일 오후 6시 계산에 실패했습니다."])))
                return Disposables.create()
            }
            
            let query = GTLRCalendarQuery_EventsList.query(withCalendarId: meetingRoomID)
            query.timeMin = GTLRDateTime(date: monday9AM)
            query.timeMax = GTLRDateTime(date: friday6PM)
            query.singleEvents = true
            query.maxResults = 300
            query.orderBy = "startTime"
            
            self.core.executeQuery(query) { ticket, result, error in
                if let error = error {
                    single(.failure(error))
                    return
                }
                
                if let event = result as? GTLRCalendar_Events,
                   let items = event.items {
                    let eventDataList = items.compactMap { gtlrEvent -> EventData? in
                        return EventData(from: gtlrEvent, meetingRoomName: meetingRoomID)
                    }
                    
                    single(.success(eventDataList))
                }
            }
            return Disposables.create()
        }
    }
    
    
    private func getMondayAndFriday(for date: Date) -> (monday: Date, friday: Date) {
        let calendar = Calendar.current
        // 주의 시작을 월요일로 설정
        var adjustedCalendar = calendar
        adjustedCalendar.firstWeekday = 2 // 1: 일요일, 2: 월요일
        
        // 입력된 날짜의 주 시작일(월요일) 계산
        let components = adjustedCalendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: date)
        guard let monday = adjustedCalendar.date(from: components) else {
            fatalError("월요일 계산 실패")
        }
        
        // 금요일은 월요일에서 4일 후
        guard let friday = adjustedCalendar.date(byAdding: .day, value: 4, to: monday) else {
            fatalError("금요일 계산 실패")
        }
        return (monday, friday)
    }
    
    
    func fetchMeetingRooms() -> Single<MeetingRooms> {
        return Single.create { [weak self] single in
            print("start")
            let query = GTLRCalendarQuery_CalendarListList.query()
            
            self?.core.executeQuery(query) { (ticket, result, error) in
                if let error = error {
                    print("Error fetching calendar list: \(error)")
                    print("meetingroom in error1")
                    single(.failure(NSError(domain: "MeetingRoomError", code: 33000)))
                    return
                }
                
                guard let calendarList = result as? GTLRCalendar_CalendarList,
                      let calendars = calendarList.items else {
                    print("meetingroom in error2")
                    single(.failure(NSError(domain: "MeetingRoomError", code: 33000)))
                    return
                }
                
                let meetingRooms = calendars.compactMap { calendar -> MeetingRoom? in
                    guard let calendarId = calendar.identifier,
                          let summary = calendar.summary else { return nil }
                    
                    if calendarId.hasSuffix("@resource.calendar.google.com") ||
                        summary.contains("회의실") {
                        return MeetingRoom(name: summary.getFirstParenthesesContent() ?? "", calendarID: calendarId)
                    }
                    return nil
                }.sorted { $0.name < $1.name }
                
                print("meetingroom in done")
                single(.success(MeetingRooms(data: meetingRooms)))
            }
            return Disposables.create()
        }
    }
}

