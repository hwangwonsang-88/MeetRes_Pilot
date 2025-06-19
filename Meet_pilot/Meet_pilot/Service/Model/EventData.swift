//
//  EventData.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/17/25.
//

import GoogleAPIClientForREST_Calendar
import Foundation

struct EventData {
    // 기존 String 프로퍼티를 Date 객체로 변경합니다.
    let startDateTime: Date
    let endDateTime: Date
    
    let creator: String
    let creatorEmail: String
    let description: String?
    let attendees: [String]
    let eventID: String
    let title: String
    let meetingRoomName: String

    // 기존의 String 프로퍼티들은 필요할 때 계산해서 쓸 수 있도록 '계산 프로퍼티'로 만듭니다.
    var startTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: startDateTime)
    }
    
    var endTimeString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: endDateTime)
    }
    
    // 파싱 이니셜라이저도 Date 객체를 저장하도록 수정합니다.
    init?(from event: GTLRCalendar_Event, meetingRoomName: String) {
        guard let start = event.start?.dateTime?.date, // GTLRDateTime이 아닌 Date 객체
              let end = event.end?.dateTime?.date,
              let eventID = event.identifier,
              let title = event.summary else {
            return nil
        }
        
        // Date 객체를 그대로 저장합니다.
        self.startDateTime = start
        self.endDateTime = end
        
        self.eventID = eventID
        self.title = title
        self.description = event.descriptionProperty
        self.creator = event.creator?.displayName ?? "정보 없음"
        self.creatorEmail = event.creator?.email ?? "정보 없음"
        
        if let attendeesList = event.attendees {
            self.attendees = attendeesList.compactMap { $0.email }
        } else {
            self.attendees = []
        }
        
        self.meetingRoomName = meetingRoomName
    }
}
