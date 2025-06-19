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
                HStack {
                    Text("호스트")
                    TextField("fkljas", text: $text)
                }
                HStack {
                    Text("호스트")
                    TextField("fkljas", text: $text)
                }
                HStack {
                    Text("호스트")
                    TextField("fkljas", text: $text)
                }
                
            }
        }
    }
}

#Preview {
    ResVC()
}
