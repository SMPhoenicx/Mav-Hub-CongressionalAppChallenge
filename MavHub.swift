//
//  MavHub.swift
//  MavHubApp
//
//  Created by Jack Vu & Suman Muppavarapu on YYYY-MM-DD.
//  Consolidated final version
//

import SwiftUI
import Foundation
import Amplify
import FirebaseCore
import AppAuth
import FirebaseFirestore
// Make sure you have something like this:
// let defaults = UserDefaults(suiteName: "group..com.jackrvu.mavhub.dayViews")!
// or set your own UserDefaults references as needed

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        // Handle OAuth redirect
        if let authFlow = AuthManager.shared.currentAuthorizationFlow,
           authFlow.resumeExternalUserAgentFlow(with: url) {
            AuthManager.shared.currentAuthorizationFlow = nil
            return true
        }
        return false
    }
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure() // Loads the default using GoogleService-Info.plist

        if let path = Bundle.main.path(forResource: "FirebaseSecondary", ofType: "plist"),
              let options = FirebaseOptions(contentsOfFile: path) {
               FirebaseApp.configure(name: "SecondaryApp", options: options)
               print("✅ Secondary Firebase app configured.")
           } else {
               print("❌ Failed to configure Secondary Firebase app")
           }

        return true
    }

}
extension AuthManager {
    var userEmail: String {
        defaults.string(forKey: userEmailKey) ?? "unknown"
    }
}
class AuthManager: ObservableObject {
    static let shared = AuthManager()

    @Published var isAuthenticated: Bool = false
    @Published var userID: String = "unknown" // Cognito userID (the "sub")

    var currentAuthorizationFlow: OIDExternalUserAgentSession?
    
    // MARK: - New: Email key
    private let userEmailKey = "userEmail"

    private let tokenKey = "authToken"
    private let userIDKey = "userID"
    private let defaults = UserDefaults.standard

    init() {
        checkAuthentication()
    }

    /// Starts the login process using AWS Cognito.
    func startLogin() {
        guard let authEndpoint = URL(string: "https://us-east-2rbumpl07q.auth.us-east-2.amazoncognito.com/oauth2/authorize"),
              let tokenEndpoint = URL(string: "https://us-east-2rbumpl07q.auth.us-east-2.amazoncognito.com/oauth2/token") else {
            print("Invalid endpoints")
            return
        }

        let configuration = OIDServiceConfiguration(
            authorizationEndpoint: authEndpoint,
            tokenEndpoint: tokenEndpoint
        )

        let request = OIDAuthorizationRequest(
            configuration: configuration,
            clientId: "6o5gf195gcfgbtuqc4vl6ck105", // Replace with your Cognito app client ID
            clientSecret: nil,
            scopes: ["openid", "profile", "email"],
            redirectURL: URL(string: "com.jvu.Buzz://oauth2redirect")!,
            responseType: OIDResponseTypeCode,
            additionalParameters: nil
        )

        guard let rootViewController = getRootViewController() else {
            print("Unable to access root view controller")
            return
        }

        currentAuthorizationFlow = OIDAuthState.authState(
            byPresenting: request,
            presenting: rootViewController
        ) { [weak self] authState, error in
            if let authState = authState {
                print("Successfully authenticated: \(authState)")
                DispatchQueue.main.async {
                    if let idToken = authState.lastTokenResponse?.idToken {
                        let (userSub, userEmail) = self?.parseIdTokenClaims(idToken: idToken) ?? ("", "")
                        
                        // Save user details
                        self?.userID = userSub
                        self?.saveSession(authToken: idToken, userID: userSub, email: userEmail)
                        self?.createUserDocument(userID: userSub, email: userEmail)
                        // Indicate user is authenticated
                        self?.isAuthenticated = true
                    }
                }
            } else {
                print("Authentication error: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }


    /// Logs the user out by clearing saved session data.
    // MARK: - Updated logout
        func logout() {
            defaults.removeObject(forKey: tokenKey)
            defaults.removeObject(forKey: userIDKey)
            defaults.removeObject(forKey: userEmailKey)
            defaults.removeObject(forKey: userNameKey) // Remove the name
            
            isAuthenticated = false
            userID = "unknown"
        }

        func checkAuthentication() {
            if let savedToken = defaults.string(forKey: tokenKey),
               let savedUserID = defaults.string(forKey: userIDKey) {
                
                // Optionally validate the token
                userID = savedUserID
                isAuthenticated = true
            } else {
                isAuthenticated = false
            }
        }

        // MARK: - Updated saveSession to include email
        private let userNameKey = "userName"

        private func saveSession(authToken: String, userID: String, email: String) {
            defaults.set(authToken, forKey: tokenKey)
            defaults.set(userID, forKey: userIDKey)
            defaults.set(email, forKey: userEmailKey)

            // Load student data and fetch the name
            let studentData = loadStudentData()
            let lookupEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            
            print("Loaded student data: \(studentData)")
            print("Looking up email: \(lookupEmail)")
            
            if let userName = studentData[lookupEmail] {
                defaults.set(userName, forKey: userNameKey)
                print("Stored user name: \(userName)")
            } else {
                print("Name not found for email: \(lookupEmail)")
                defaults.set("Unknown User", forKey: userNameKey) // Set a default fallback
            }
        }



        var userName: String {
            defaults.string(forKey: userNameKey) ?? "unknown"
        }
        
        // MARK: - Parse ID token for sub & email
        private func parseIdTokenClaims(idToken: String) -> (String, String) {
            let segments = idToken.split(separator: ".")
            guard segments.count == 3 else { return ("", "") }

            let payloadSegment = segments[1]
            var base64 = payloadSegment
                .replacingOccurrences(of: "-", with: "+")
                .replacingOccurrences(of: "_", with: "/")
            while base64.count % 4 != 0 {
                base64 += "="
            }

            guard
                let payloadData = Data(base64Encoded: base64),
                let json = try? JSONSerialization.jsonObject(with: payloadData, options: []),
                let payloadDict = json as? [String: Any]
            else {
                return ("", "")
            }

            // Cognito user’s unique ID ("sub") and email
            let userSub = payloadDict["sub"] as? String ?? ""
            let email = payloadDict["email"] as? String ?? ""

            return (userSub, email)
        }

    /// Retrieves the root view controller for presenting the authentication UI.
    private func getRootViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first(where: { $0 is UIWindowScene }) as? UIWindowScene,
              let window = scene.windows.first(where: { $0.isKeyWindow }) else {
            return nil
        }
        return window.rootViewController
    }

    /// Decodes the ID token's payload and returns the "sub" value (Cognito userID).
    private func parseIdTokenForSub(idToken: String) -> String? {
        // Split the token into its 3 parts: header, payload, signature
        let segments = idToken.split(separator: ".")
        guard segments.count == 3 else { return nil }

        // The middle segment is the payload we want to decode
        let payloadSegment = segments[1]

        // JWT uses base64Url encoding, convert to standard base64
        var base64 = payloadSegment
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        // Pad with '=' if necessary
        while base64.count % 4 != 0 {
            base64 += "="
        }

        // Decode the payload into a Data object
        guard let payloadData = Data(base64Encoded: base64) else { return nil }

        // Convert the payload JSON to a dictionary
        guard let json = try? JSONSerialization.jsonObject(with: payloadData, options: []),
              let payloadDict = json as? [String: Any] else {
            return nil
        }

        // Return the "sub" field (user’s unique ID in Cognito)
        return payloadDict["sub"] as? String
    }
    private func createUserDocument(userID: String, email: String) {
        let db = Firestore.firestore()
        let userRef = db.collection("users").document(userID)

        // Check if the document already exists
        userRef.getDocument { [weak self] (document, error) in
            if let error = error {
                print("Error checking for user document: \(error)")
                return
            }

            if let document = document, document.exists {
                // Document already exists, no need to create it
                print("User document already exists for userID: \(userID)")
            } else {
                // Create a new document since it doesn't exist
                let data: [String: Any] = [
                    "userID": userID,
                    "username": self?.defaults.string(forKey: self?.userNameKey ?? "") ?? "Unknown User",
                    "email": email,
                    "karma": 0,
                    "numPosts": 0,
                    "profileImageURL": "" // Empty by default
                ]

                userRef.setData(data, merge: true) { error in
                    if let error = error {
                        print("Error creating user document: \(error)")
                    } else {
                        print("User document created successfully for userID: \(userID)")
                    }
                }
            }
        }
    }

}


@main
struct MavHub: App {
    
    // MARK: - State & AppStorage
    @State private var importedSchedule: Schedule?
    @State private var showScheduleAlert = false
    @State private var importedScheduleName = ""
    @State private var openedBySimpleLink = false
    
    @AppStorage("hasOpenedBefore") private var hasOpenedBefore: Bool = false
    @AppStorage("appVersion") private var storedVersion: String = ""
    @AppStorage("updatePage") private var updatePage: Bool = true
    @AppStorage("assignmentSharing") var assignmentSharing: Bool = false
    
    @AppStorage("name", store: defaults) private var name = ""
    @AppStorage("aCarrier", store: defaults) private var aCarrier = ""
    @AppStorage("bCarrier", store: defaults) private var bCarrier = ""
    @AppStorage("cCarrier", store: defaults) private var cCarrier = ""
    @AppStorage("dCarrier", store: defaults) private var dCarrier = ""
    @AppStorage("eCarrier", store: defaults) private var eCarrier = ""
    @AppStorage("fCarrier", store: defaults) private var fCarrier = ""
    @AppStorage("gCarrier", store: defaults) private var gCarrier = ""
    @AppStorage("d1Morning", store: defaults) private var d1Morning = ""
    @AppStorage("d1Vinci", store: defaults) private var d1Vinci = ""
    @AppStorage("d2Morning", store: defaults) private var d2Morning = ""
    @AppStorage("d3Vinci", store: defaults) private var d3Vinci = ""
    @AppStorage("d4Morning", store: defaults) private var d4Morning = ""
    @AppStorage("d5Morning", store: defaults) private var d5Morning = ""
    @AppStorage("d6Morning", store: defaults) private var d6Morning = ""
    @AppStorage("d6Vinci", store: defaults) private var d6Vinci = ""
    @AppStorage("d7Morning", store: defaults) private var d7Morning = ""
    @AppStorage("middleSchoolMode") var middleSchoolMode: Bool = false
    @AppStorage("selectedColor") var selectedColorData: Data = Data()
    @AppStorage("darkMode") private var darkMode: Bool = true
    @AppStorage("sixthGradeMode") var sixthGradeMode: Bool = false
    @AppStorage("schedules", store: defaults) private var schedulesData: Data = Data()
    @AppStorage("selectedColor", store: defaults) var newSelectedColorData: Data = Data()
    @AppStorage("darkMode", store: defaults) private var newDarkMode: Bool = true
    @AppStorage("multiSchedRedo") private var multiSchedRedo: Bool = false
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var authManager = AuthManager.shared // Shared auth manager
    // MARK: - Init
    init() {
        checkForAppUpdate()
    }
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            if hasOpenedBefore {
                TabControl() // Your main tabbed view
                    // Show an alert when a schedule is successfully added
                    .alert(isPresented: $showScheduleAlert) {
                        Alert(
                            title: Text("Schedule Added"),
                            message: Text("You’ve successfully added \(importedScheduleName)’s schedule."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                    .onAppear {
                        setupInitialSchedules()
                    }
                    .onOpenURL { url in
                        handleIncomingURL(url)
                    }
            } else {
                IntroPageView() // Your intro/onboarding view
                    .onAppear {
                        multiSchedRedo = true
                    }
            }
        }
    }

    // MARK: - Version Check
    func getCurrentAppVersion() -> String? {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    func checkForAppUpdate() {
        if let currentVersion = getCurrentAppVersion() {
            if storedVersion != currentVersion {
                updatePage = true
                storedVersion = currentVersion
            }
        }
    }

    // MARK: - Schedules
    func saveSchedules(schedules: [Schedule]) {
        if let encoded = try? JSONEncoder().encode(schedules) {
            schedulesData = encoded
        }
    }

    func loadSchedules() -> [Schedule] {
        if let decoded = try? JSONDecoder().decode([Schedule].self, from: schedulesData) {
            return decoded
        }
        return []
    }
    
    // MARK: - Setup Initial Schedules
    func setupInitialSchedules() {
        if !multiSchedRedo {
            var scheduleArr = loadSchedules()
            
            // Your logic for determining the grade
            let grade = middleSchoolMode ? (sixthGradeMode ? 2 : 1) : 0
            
            // Create an initial schedule
            
            let initialSchedule = Schedule(
                name: name,
                assignmentsLink: "",
                aCarrier: aCarrier,
                bCarrier: bCarrier,
                cCarrier: cCarrier,
                dCarrier: dCarrier,
                eCarrier: eCarrier,
                fCarrier: fCarrier,
                gCarrier: gCarrier,
                d1Morning: d1Morning,
                d1Vinci: d1Vinci,
                d2Morning: d2Morning,
                d3Vinci: d3Vinci,
                d4Morning: d4Morning,
                d5Morning: d5Morning,
                d6Morning: d6Morning,
                d6Vinci: d6Vinci,
                d7Morning: d7Morning,
                grade: grade,
                assignments: []
            )
            scheduleArr.append(initialSchedule)
            saveSchedules(schedules: scheduleArr)
            
            multiSchedRedo = true
        }
    }

    // MARK: - URL Handling
    func handleIncomingURL(_ url: URL) {
        guard url.scheme == "mavhub" else {
            print("Invalid URL scheme: \(url.scheme ?? "nil")")
            return
        }
        
        let host = url.host ?? ""
        
        // Simple link: mavhub:// or mavhub://open
        if host.isEmpty || host == "open" {
            openedBySimpleLink = true
            print("Opened by a simple link: \(url.absoluteString)")
            return
        }
        
        // If it's "schedule", attempt to import the schedule
        if host == "schedule" {
            guard
                let queryItems = URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems,
                let base64Data = queryItems.first(where: { $0.name == "data" })?.value,
                let jsonData = Data(base64Encoded: base64Data)
            else {
                print("Missing/invalid query for schedule in URL: \(url)")
                return
            }

            do {
                let schedule = try JSONDecoder().decode(Schedule.self, from: jsonData)
                print("Successfully imported schedule: \(schedule)")
                
                
                let newSchedule = Schedule(
                            name: schedule.name,
                            assignmentsLink: schedule.assignmentsLink,
                            aCarrier: schedule.aCarrier,
                            bCarrier: schedule.bCarrier,
                            cCarrier: schedule.cCarrier,
                            dCarrier: schedule.dCarrier,
                            eCarrier: schedule.eCarrier,
                            fCarrier: schedule.fCarrier,
                            gCarrier: schedule.gCarrier,
                            d1Morning: schedule.d1Morning,
                            d1Vinci: schedule.d1Vinci,
                            d2Morning: schedule.d2Morning,
                            d3Vinci: schedule.d3Vinci,
                            d4Morning: schedule.d4Morning,
                            d5Morning: schedule.d5Morning,
                            d6Morning: schedule.d6Morning,
                            d6Vinci: schedule.d6Vinci,
                            d7Morning: schedule.d7Morning,
                            grade: schedule.grade,
                            assignments: schedule.assignments
                        )

                // Save the newly created schedule
                var schedules = loadSchedules()
                schedules.append(newSchedule)
                saveSchedules(schedules: schedules)

                // Update UI on the main thread
                DispatchQueue.main.async {
                    importedSchedule = schedule
                    importedScheduleName = schedule.name
                    showScheduleAlert = true
                }
            } catch {
                print("Failed to decode schedule: \(error)")
            }
        } else {
            print("Unknown host (\(host)) in URL: \(url.absoluteString)")
        }
    }
}
