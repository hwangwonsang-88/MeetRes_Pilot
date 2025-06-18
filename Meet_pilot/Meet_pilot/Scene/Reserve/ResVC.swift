//
//  ResVC.swift
//  Meet_pilot
//
//  Created by Wonsang Hwang on 6/18/25.
//

import SwiftUI

struct ResVC: View {
    
    @State private var text = ""
    
    var body: some View {
        Form {
            Section {
                TextField("입력", text: $text)
            }
        }
    }
}

#Preview {
    ResVC()
}
