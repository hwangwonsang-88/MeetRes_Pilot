//
//  PilotStep.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/17/25.
//

import RxFlow

enum PilotStep: Step {
    case dismiss(EventData?)
    
    case loginIsRequired
    case loginIsCompleted(MeetingRooms)
    
    case mainIsRequired(MeetingRooms)
    case detailViewIsRequired(EventData)
    case reservationVCIsRequired(ReservationModel)
    case reserVationIsCompleted(EventData)
}
