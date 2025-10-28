//
//  Places.swift
//  NewMavApp
//
//  Created by Suman Muppavarapu on 8/23/24.
// jvu wasn't here this was just suman muppavarapu

import Foundation
import Combine

class Network: ObservableObject {
    @Published var rankings: [LeaderboardEntry] = [] //array to hold entries
    
    func getRankings() {
        guard let url = URL(string: "https://a0j9uy4izi.execute-api.us-east-2.amazonaws.com/Dev") else { //holds url for JSON
            fatalError("Missing URL")
        }
        
        let request = URLRequest(url: url) //url type request
        let dataTask = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in //retrieves data
            guard let self = self else { return } //captures weak request to 'self'
            
            if let error = error { //error message for error received from JSON
                print("Request error: ", error)
                return
            }

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else { //error message for proper response
                print("Invalid response or status code")
                return
            }

            guard let data = data else { //error message for data
                print("No data received")
                return
            }

            DispatchQueue.main.async { //asynchronously processes data on main thread
                self.processData(data)
            }
        }
        dataTask.resume() //starts task
    }
    
    private func processData(_ data: Data) {
        do {
            //decodes rankings from JSON
            let decodedRankings = try JSONDecoder().decode(Rankings.self, from: data)
            
            //converts decoded rankings to list entries
            let entries = convertToEntries(from: decodedRankings.body)
            
            //sorts entries
            let sortedEntries = entries.sorted {(first: LeaderboardEntry, second: LeaderboardEntry) -> Bool in
                if first.points == second.points {
                    return first.name < second.name
                } else {
                    return first.points > second.points
                }
            }
            //updates rankings with new entries
            self.rankings = sortedEntries
        } catch {
            print("Error decoding: ", error) //catch error
        }
    }
    
    private func convertToEntries(from body: Rankings.Body) -> [LeaderboardEntry] { //converts into entries
        let names = [ //dictionary of names
            "Chidsey": body.chidsey, //ON TOP
            "Claremont": body.claremont,
            "Hoodwink": body.hoodwink,
            "Mulligan": body.mulligan,
            "Taub": body.taub,
            "Winston": body.winston
        ]
        //creates a map with info
        return names.compactMap { name, locationData in
            guard let points = locationData?.points else { return nil }
            return LeaderboardEntry(name: name, points: points)
        }
    }
}

// struct for entry into leaderboard, allows ranking, conforming to equatable allows index of entry to be used

struct LeaderboardEntry: Identifiable, Equatable {
    var id: String { name }
    let name: String
    let points: Int
}




