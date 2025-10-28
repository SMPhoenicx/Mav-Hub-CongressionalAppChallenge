import Foundation
import Combine

struct LunchDetails: Codable {
    let soupOfTheDay: String?
    let todaysVegetarianEntree: String?
    let todaysSides: [String]?
    let featureOfTheDay: String?
    let entreeOfTheDay: String?
    let actionStation: String?

    private enum CodingKeys: String, CodingKey {
        case soupOfTheDay = "Soup of the Day"
        case todaysVegetarianEntree = "Today's Vegetarian Entree"
        case todaysSides = "Today's Sides"
        case featureOfTheDay = "Feature of the Day"
        case entreeOfTheDay = "Entree of the Day"
        case actionStation = "Action Station"
    }
}


struct LunchResponse: Codable {
    let statusCode: Int
    let body: [String: LunchDetails] // Dictionary with days of the week as keys
}

class LunchData: ObservableObject {
    @Published var lunchItems: [String: LunchDetails] = [:]
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
            
            // Print raw JSON data for debugging

            do {
                let response = try JSONDecoder().decode(LunchResponse.self, from: data)
                DispatchQueue.main.async {
                    self.lunchItems = response.body
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

