//
//  AppVersionChecker.swift
//  NewMavApp
//
//  Created by Suman Muppavarapu on 8/28/25.
//


import Foundation

class AppVersionChecker: ObservableObject {
    @Published var updateRequired = false
    @Published var updateAvailable = false
    @Published var appStoreURL: String?
    
    private let appID = "6670142459" // Your app's ID from App Store Connect
    
    func checkForUpdate() {
        guard let url = URL(string: "https://itunes.apple.com/lookup?id=\(appID)") else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else { return }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
                let results = json?["results"] as? [[String: Any]]
                let appStoreVersion = results?.first?["version"] as? String
                let trackViewUrl = results?.first?["trackViewUrl"] as? String
                
                DispatchQueue.main.async {
                    self.appStoreURL = trackViewUrl
                    self.compareVersions(appStoreVersion: appStoreVersion)
                }
            } catch {
                print("Error parsing version data: \(error)")
            }
        }.resume()
    }
    
    private func compareVersions(appStoreVersion: String?) {
        guard let appStoreVersion = appStoreVersion,
              let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String else {
            return
        }
        
        let comparison = currentVersion.compare(appStoreVersion, options: .numeric)
        
        switch comparison {
        case .orderedAscending:
            // Current version is older
            updateAvailable = true
            // Set updateRequired based on your criteria (e.g., major version difference)
            updateRequired = shouldForceUpdate(current: currentVersion, store: appStoreVersion)
        case .orderedSame, .orderedDescending:
            // Current version is same or newer
            updateAvailable = false
            updateRequired = false
        }
    }
    
    private func shouldForceUpdate(current: String, store: String) -> Bool {
        // Example: Force update if major version is different
        let currentMajor = current.split(separator: ".").first
        let storeMajor = store.split(separator: ".").first
        
        return currentMajor != storeMajor
    }
}
