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
                        return MeetingRoom(name: summary, calendarID: calendarId)
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
