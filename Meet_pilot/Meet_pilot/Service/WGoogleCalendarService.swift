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
    
    func fetchMeetingRooms(completion: @escaping (Result<MeetingRooms, Error>) -> Void) {
        let query = GTLRCalendarQuery_CalendarListList.query()
        
        core.executeQuery(query) { (ticket, result, error) in
            if let error = error {
                print("Error fetching calendar list: \(error)")
                completion(.failure(NSError(domain: "MeetingRoomError", code: 33000)))
                return
            }
            
            guard let calendarList = result as? GTLRCalendar_CalendarList,
                  let calendars = calendarList.items else {
                completion(.failure(NSError(domain: "MeetingRoomError", code: 33000)))
                return
            }
            
            let meetingRooms = calendars.compactMap { calendar -> MeetingRoom? in
                guard let calendarId = calendar.identifier,
                      let summary = calendar.summary else { return nil }
               
                // Android 코드와 동일한 필터링 조건
                if calendarId.hasSuffix("@resource.calendar.google.com") ||
                    summary.contains("회의실") {
                    return MeetingRoom(name: summary, calendarID: calendarId)
                }
                return nil
            }.sorted { $0.name < $1.name }
            
            let result = MeetingRooms(data: meetingRooms)
            completion(.success(result))
            print(result)
            print("fetching meetingrooms done")
        }
        
        //    func fetchCalendarEvent(date: Date) {
        //        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: "primary")
        //        query.maxResults = 20
        //        query.timeMin = GTLRDateTime(date: Date())
        //
        //        core.executeQuery(query) { ticket, result, err in
        //            guard let events = result as? GTLRCalendar_Events else { return }
        //
        //              // 주요 프로퍼티들
        //              print("총 이벤트 수: \(events.items?.count ?? 0)")
        //              print("다음 페이지 토큰: \(events.nextPageToken ?? "없음")")
        //              print("요약: \(events.summary ?? "")")
        //              print("시간대: \(events.timeZone ?? "")")
        //
        //              // 개별 이벤트 접근
        //              events.items?.forEach { event in
        //                  // event는 GTLRCalendar_Event 타입
        //                  self.processEvent(event)
        //              }
        //        }
        //    }
        //
    }
}
