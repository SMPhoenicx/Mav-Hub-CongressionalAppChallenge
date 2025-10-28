//
//  Rankings.swift
//  NewMavApp
//
//  Created by Suman Muppavarapu on 8/23/24.
//
import Foundation
//Script to help network decode JSON
struct Rankings: Decodable {
    var body: Body
    
    struct Body: Decodable {
        var chidsey: LocationData?
        var claremont: LocationData?
        var hoodwink: LocationData?
        var mulligan: LocationData?
        var taub: LocationData?
        var winston: LocationData?
        
        enum CodingKeys: String, CodingKey {
            case chidsey = "Chidsey" //BEST
            case claremont = "Claremont"
            case hoodwink = "Hoodwink"
            case mulligan = "Mulligan"
            case taub = "Taub"
            case winston = "Winston"
        }
    }
    
    struct LocationData: Decodable {
        var points: Int
        
        enum CodingKeys: String, CodingKey {
            case points = "Points"
        }
    }
}


