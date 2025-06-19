//
//  String+Regular.swift
//  Meet_pilot
//
//  Created by 인스웨이브 on 6/19/25.
//

import Foundation

extension String {
    func getFirstParenthesesContent() -> String? {
        if let firstOpenParen = self.firstIndex(of: "("),
           let firstCloseParen = self.firstIndex(of: ")"),
           firstOpenParen < firstCloseParen {
            let start = self.index(after: firstOpenParen)
            let content = self[start..<firstCloseParen]
            return String(content)
        }
        return nil
    }
}
