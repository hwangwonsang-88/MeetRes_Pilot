//
//  ReservationModel.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/20/25.
//

import Foundation

struct ReservationModel {
    var title: String?
    var description: String?
    let meetingRoomID: String
    let startTime: Date
    let endTime: Date
    let attendee = [String]()
}
