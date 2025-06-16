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
    
    func fetchCalendarEvent(date: Date) {
        let query = GTLRCalendarQuery_EventsList.query(withCalendarId: "primary")
        query.maxResults = 20
        query.timeMin = GTLRDateTime(date: Date())
        
        core.executeQuery(query) { ticket, what, err in
            
        }
    }
}
