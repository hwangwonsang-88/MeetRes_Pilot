//
//  DropDownDelegate.swift
//  Meet_pilot
//
//  Created by Wonsang Hwang on 6/17/25.
//

import UIKit

protocol DropDownDelegate: AnyObject {
    func dropDown(_ dropDownView: DropDownView, didSelectRowAt indexPath: IndexPath)
}
