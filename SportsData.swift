//
//  SportsData.swift
//  NewMavApp
//
//  Created by Jack Vu on 9/2/24.
//

import Foundation
import Combine

struct SportDetails: Codable {
    let event: String
    let time: String

    private enum CodingKeys: String, CodingKey {
        case event = "Event"
        case time = "Time"
    }
}

struct SportsResponse: Codable {
    let statusCode: Int
    let body: [SportDetails] // List of sports
}

class SportsData: ObservableObject {
    @Published var events: [SportDetails] = []
    @Published var error: String?

    func fetchData(from urlString: String) {
        guard let url = URL(string: urlString) else {
            error = "Invalid URL"
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, err in
            if let err = err {
                DispatchQueue.main.async {
                    self.error = "Error: \(err.localizedDescription)"
                }
                return
            }

            guard let data = data else {
                DispatchQueue.main.async {
                    self.error = "No data"
                }
                return
            }

            do {
                let response = try JSONDecoder().decode(SportsResponse.self, from: data)
                DispatchQueue.main.async {
                    self.events = response.body
                }
            } catch {
                DispatchQueue.main.async {
                    self.error = "Decoding error: \(error.localizedDescription)"
                }
                print("Decoding error: \(error)")
            }
        }
        .resume()
    }
}
