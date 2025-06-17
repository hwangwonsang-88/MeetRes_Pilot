//
//  PilotStep.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/17/25.
//

import RxFlow

enum PilotStep: Step {
    case dismiss
    
    case loginIsRequired
    case loginIsCompleted
    
    case mainIsRequired
}
