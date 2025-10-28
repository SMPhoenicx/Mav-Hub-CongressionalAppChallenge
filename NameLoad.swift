//
//  NameLoad.swift
//  NewMavApp
//
//  Created by Jack Vu on 1/20/25.
//

import Foundation

func loadStudentData() -> [String: String] {
    guard let url = Bundle.main.url(forResource: "students", withExtension: "csv"),
          let content = try? String(contentsOf: url) else {
        print("Failed to load students.csv")
        return [:]
    }

    var studentDict: [String: String] = [:]
    let lines = content.split(separator: "\r\n")
    
    for line in lines {
        // Ensure proper splitting of Name and Email fields
        let components = line.split(separator: ",", maxSplits: 1)
        guard components.count == 2 else {
            print("Invalid line format: \(line)")
            continue
        }

        let name = String(components[0]).trimmingCharacters(in: .whitespacesAndNewlines)
        let email = String(components[1]).trimmingCharacters(in: .whitespacesAndNewlines).lowercased() // Ensure email is lowercase

        studentDict[email] = name
    }

    return studentDict
}
