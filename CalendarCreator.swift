//
//  CalendarCreator.swift
//  NewMavApp
//
//  Created by Suman Muppavarapu on 8/3/25.
//
import SwiftUI
import Foundation

// MARK: - Data Models
struct CalendarEvent: Codable, Identifiable {
    let id = UUID()
    var title: String
    var startDate: Date
    var endDate: Date?  // Optional for single-day events
    var type: CalendarType
    
    // Convenience computed property for backward compatibility
    var date: Date { startDate }
    
    // Check if event spans multiple days
    var isMultiDay: Bool {
        guard let endDate = endDate else { return false }
        let calendar = Calendar.current
        return !calendar.isDate(startDate, inSameDayAs: endDate)
    }
    
    // Duration in days (useful for multi-day events)
    var durationInDays: Int {
        guard let endDate = endDate else { return 1 }
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day], from: startDate, to: endDate)
        return max(1, components.day ?? 1)
    }
}

struct RotationDay: Codable, Identifiable {
    let id = UUID()
    let dayNumber: Int
    let date: Date
}
struct CachedCalendarData: Codable {
    let rotationDays: [RotationDay]
    let events: [CalendarEvent]
    let artsEvents: [CalendarEvent]
    let importantDates: [CalendarEvent]
    let athleticsEvents: [CalendarEvent]
    let lastRefresh: Date
}

enum CalendarType: String, CaseIterable, Codable {
    case schedule = "Schedule"
    case events = "Events"
    case arts = "Arts"
    case importantDates = "Important Dates"
    case athletics = "Athletics"
    
    var url: String {
        let baseURL = "https://sjs.myschoolapp.com/podium/feed/iCal.aspx?z="
        switch self {
        case .schedule, .events:
            return baseURL + "DDAr4MngSh%2FzItk0SVkyxFK2Cjh3b1P9NmMK2nLpKH5hbBJqTuUT0hRIyZgHc%2F4Mad2dsWy5vMerWPWrr%2FAd2w%3D%3D"
        case .arts:
            return baseURL + "VE%2fgYwYV1RMdtMskBx8W%2fRiZ8E3oMVAIDm%2fDsLzZydfWViD7YZvbjKDfpzbFgHPtW1HwgJgraIcoavpdwK0Z4g%3d%3d"
        case .importantDates:
            return baseURL + "ET4gPUqOQCFEGXE1tXVCR%2fnOVNJuzz%2bjxdsD%2fFKfJ%2fsDGxj0Mn26XxFzsUP0qllIlT7XXXeoGAkQybbvmTE3Cg%3d%3d"
        case .athletics:
            return baseURL + "2wOVsHM0jPLIA7myvstsbDib2Zf%2fuTPKcdiu3fYKMwtc%2fM1dQz7t9FTKUsIhVmL7VxEnBdYonZ4h0s1lhB8Npw%3d%3d"
        }
    }
}

// MARK: - Calendar Parser
class CalendarParser {
    
    // Shared headers for all requests
    private let headers = [
        "User-Agent": "Mozilla/5.0 (iPhone; CPU iPhone OS 17_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.0 Mobile/15E148 Safari/604.1",
        "Accept": "text/calendar,application/calendar,text/plain,*/*",
        "Accept-Language": "en-US,en;q=0.9",
        "Accept-Encoding": "gzip, deflate, br",
        "Connection": "keep-alive",
        "Upgrade-Insecure-Requests": "1"
    ]
    
    // MARK: - Public Methods
    
    func fetchRotationDays() async throws -> [RotationDay] {
        let events = try await fetchCalendarEvents(for: .schedule)
        return extractRotationDays(from: events)
    }
    
    func fetchNonDayEvents() async throws -> [CalendarEvent] {
        let events = try await fetchCalendarEvents(for: .events)
        return events.filter { !$0.title.hasPrefix("Day") }
    }
    
    func fetchArtsEvents() async throws -> [CalendarEvent] {
        return try await fetchCalendarEvents(for: .arts)
    }
    
    func fetchImportantDates() async throws -> [CalendarEvent] {
        return try await fetchCalendarEvents(for: .importantDates)
    }
    
    func fetchAthleticsEvents() async throws -> [CalendarEvent] {
        return try await fetchCalendarEvents(for: .athletics)
    }
    
    func fetchAllCalendars() async throws -> (
        rotationDays: [RotationDay],
        events: [CalendarEvent],
        arts: [CalendarEvent],
        importantDates: [CalendarEvent],
        athletics: [CalendarEvent]
    ) {
        async let rotationDays = fetchRotationDays()
        async let events = fetchNonDayEvents()
        async let arts = fetchArtsEvents()
        async let importantDates = fetchImportantDates()
        async let athletics = fetchAthleticsEvents()
        
        return try await (
            rotationDays: rotationDays,
            events: events,
            arts: arts,
            importantDates: importantDates,
            athletics: athletics
        )
    }
    
    // MARK: - Private Methods
    
    private func fetchCalendarEvents(for type: CalendarType) async throws -> [CalendarEvent] {
        print("🌐 Fetching calendar for type: \(type.rawValue)")
        print("🌐 URL: \(type.url)")
        
        guard let url = URL(string: type.url) else {
            print("❌ Invalid URL for type: \(type.rawValue)")
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        headers.forEach { request.setValue($1, forHTTPHeaderField: $0) }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid HTTP response")
            throw URLError(.badServerResponse)
        }
        
        print("📡 HTTP Status: \(httpResponse.statusCode)")
        
        guard 200...299 ~= httpResponse.statusCode else {
            print("❌ Bad status code: \(httpResponse.statusCode)")
            throw URLError(.badServerResponse)
        }
        
        guard let icsString = String(data: data, encoding: .utf8) else {
            print("❌ Could not decode data as UTF-8")
            throw NSError(domain: "ParsingError", code: 1,
                         userInfo: [NSLocalizedDescriptionKey: "Could not decode ICS data"])
        }
        
        print("📄 ICS data length: \(icsString.count) characters")
        print("📄 First 500 characters of ICS:")
        print(String(icsString.prefix(500)))
        print("📄 ---")
        
        let events = parseICSString(icsString, for: type)
        print("✅ Parsed \(events.count) events for \(type.rawValue)")
        
        return events
    }
    
    private func parseICSString(_ icsString: String, for type: CalendarType) -> [CalendarEvent] {
        var events: [CalendarEvent] = []
        let lines = icsString.components(separatedBy: .newlines)
        
        print("📝 Total lines in ICS: \(lines.count)")
        
        var currentEvent: [String: String] = [:]
        var inEvent = false
        var eventCount = 0
        
        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespacesAndNewlines)
            
            if trimmedLine == "BEGIN:VEVENT" {
                inEvent = true
                currentEvent = [:]
                eventCount += 1
                print("📅 Found BEGIN:VEVENT #\(eventCount) at line \(index)")
            } else if trimmedLine == "END:VEVENT" {
                print("📅 Found END:VEVENT for event #\(eventCount)")
                print("📅 Event data: \(currentEvent)")
                
                if let event = createCalendarEvent(from: currentEvent, type: type) {
                    events.append(event)
                    print("✅ Successfully created event: \(event.title)")
                } else {
                    print("❌ Failed to create event from data: \(currentEvent)")
                }
                inEvent = false
            } else if inEvent {
                if let colonIndex = trimmedLine.firstIndex(of: ":") {
                    let key = String(trimmedLine[..<colonIndex])
                    let value = String(trimmedLine[trimmedLine.index(after: colonIndex)...])
                    currentEvent[key] = value
                    
                    if key == "SUMMARY" || key == "DTSTART" {
                        print("📋 \(key): \(value)")
                    }
                }
            }
        }
        
        print("📊 Total VEVENT blocks found: \(eventCount)")
        print("📊 Successfully parsed events: \(events.count)")
        
        return events
    }
    
    private func createCalendarEvent(from eventData: [String: String], type: CalendarType) -> CalendarEvent? {
        guard let summary = eventData["SUMMARY"] else {
            print("❌ No SUMMARY found in event data")
            return nil
        }
        
        // Look for various DTSTART formats
        var dtstart: String?
        var dtend: String?
        var dateFormat: String?
        
        if let dateValue = eventData["DTSTART;VALUE=DATE"] {
            dtstart = dateValue
            dtend = eventData["DTEND;VALUE=DATE"]
            dateFormat = "date"
            print("🕐 Found DTSTART;VALUE=DATE: \(dateValue)")
            if let endValue = dtend {
                print("🕐 Found DTEND;VALUE=DATE: \(endValue)")
            }
        } else if let tzValue = eventData["DTSTART;TZID=America/Chicago"] {
            dtstart = tzValue
            dtend = eventData["DTEND;TZID=America/Chicago"]
            dateFormat = "datetime"
            print("🕐 Found DTSTART;TZID=America/Chicago: \(tzValue)")
            if let endValue = dtend {
                print("🕐 Found DTEND;TZID=America/Chicago: \(endValue)")
            }
        } else if let basicValue = eventData["DTSTART"] {
            dtstart = basicValue
            dtend = eventData["DTEND"]
            dateFormat = "basic"
            print("🕐 Found DTSTART: \(basicValue)")
            if let endValue = dtend {
                print("🕐 Found DTEND: \(endValue)")
            }
        } else {
            print("❌ No DTSTART found in any format")
            print("❌ Available keys: \(eventData.keys.sorted())")
            return nil
        }
        
        guard let startDateString = dtstart else {
            print("❌ No valid DTSTART found")
            return nil
        }
        
        print("🕐 Parsing start date: \(startDateString) with format: \(dateFormat ?? "unknown")")
        guard let startDate = parseDate(from: startDateString, format: dateFormat) else {
            print("❌ Failed to parse start date: \(startDateString)")
            return nil
        }
        
        var endDate: Date?
        if let endDateString = dtend {
            print("🕐 Parsing end date: \(endDateString) with format: \(dateFormat ?? "unknown")")
            endDate = parseDate(from: endDateString, format: dateFormat)
            if endDate == nil {
                print("⚠️ Failed to parse end date, using start date only: \(endDateString)")
            }
        }
        
        let event = CalendarEvent(title: summary, startDate: startDate, endDate: endDate, type: type)
        
        if let endDate = endDate {
            if event.isMultiDay {
                print("✅ Created multi-day event: '\(summary)' from \(startDate) to \(endDate) (\(event.durationInDays) days)")
            } else {
                print("✅ Created single-day event: '\(summary)' on \(startDate)")
            }
        } else {
            print("✅ Created event: '\(summary)' on \(startDate)")
        }
        
        return event
    }
    
    private func extractRotationDays(from events: [CalendarEvent]) -> [RotationDay] {
        print("🔍 Extracting rotation days from \(events.count) events")
        
        let rotationDays: [RotationDay] = events.compactMap { event -> RotationDay? in
            print("🔍 Checking event: '\(event.title)'")
            
            guard event.title.contains("Day") else {
                print("❌ Event '\(event.title)' does not contain 'Day'")
                return nil
            }
            
            // Extract day number (similar to Python logic)
            if let dayRange = event.title.range(of: "Day") {
                let afterDay = event.title[dayRange.upperBound...]
                let dayNumberString = String(afterDay.prefix(2)).trimmingCharacters(in: .whitespaces)
                
                print("🔍 Day string after 'Day': '\(dayNumberString)'")
                
                // Extract only the numeric part
                let numericString = dayNumberString.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                
                print("🔍 Numeric string: '\(numericString)'")
                
                if let dayNumber = Int(numericString), dayNumber > 0 {
                    print("✅ Found rotation day \(dayNumber) on \(event.date)")
                    return RotationDay(dayNumber: dayNumber, date: event.date)
                } else {
                    print("❌ Could not parse day number from '\(numericString)'")
                }
            }
            return nil
        }
        
        print("📊 Extracted \(rotationDays.count) rotation days")
        return rotationDays
    }
    
    private func parseDate(from dateString: String, format: String? = nil) -> Date? {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        
        print("🕐 Parsing date string: '\(dateString)' with format hint: \(format ?? "auto")")
        
        // Try different date formats based on the format hint or auto-detect
        let formats: [String]
        
        if format == "date" {
            // All-day events: DTSTART;VALUE=DATE format
            formats = ["yyyyMMdd"]
        } else if format == "datetime" {
            // Timed events: DTSTART;TZID=America/Chicago format
            formats = ["yyyyMMdd'T'HHmmss"]
        } else {
            // Try all possible formats
            formats = [
                "yyyyMMdd'T'HHmmss",    // 20250819T090000
                "yyyyMMdd'T'HHmmssZ",   // 20250819T090000Z
                "yyyyMMdd"              // 20250819
            ]
        }
        
        for dateFormat in formats {
            formatter.dateFormat = dateFormat
            if let date = formatter.date(from: dateString) {
                print("✅ Parsed with format '\(dateFormat)': \(date)")
                return date
            }
        }
        
        print("❌ Failed to parse date with any format: '\(dateString)'")
        return nil
    }
}

// MARK: - SwiftUI ViewModel
@MainActor
class CalendarViewModel: ObservableObject {
    @Published var rotationDays: [RotationDay] = []
    @Published var events: [CalendarEvent] = []
    @Published var artsEvents: [CalendarEvent] = []
    @Published var importantDates: [CalendarEvent] = []
    @Published var athleticsEvents: [CalendarEvent] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var lastRefreshDate: Date?
    
    private let parser = CalendarParser()
    private var refreshTimer: Timer?

    @AppStorage("CalendarCachedData", store: defaults) private var cachedDataStorage: Data = Data()
    private let userDefaults = UserDefaults.standard
    private let lastRefreshKey = "CalendarLastRefresh"
    
    // Refresh interval (48 hours in seconds)
    private let refreshInterval: TimeInterval = 24.0 * 60.0 * 60.0
    
    init() {
        loadCachedData()
        setupAutoRefresh()
    }
    
    deinit {
        refreshTimer?.invalidate()
    }
    
    // MARK: - Auto Refresh Setup
    
    private func setupAutoRefresh() {
        // Check if we need to refresh immediately
        if shouldRefresh() {
            Task {
                await fetchAllData()
            }
        }
        
        // Setup daily timer to check for refresh
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 12.0 * 60.0 * 60.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                if self?.shouldRefresh() == true {
                    await self?.fetchAllData()
                }
            }
        }
    }
    
    private func shouldRefresh() -> Bool {
        guard let lastRefresh = lastRefreshDate else {
            print("📅 No previous refresh found, refreshing now")
            return true
        }
        
        let timeSinceRefresh = Date().timeIntervalSince(lastRefresh)
        let shouldRefresh = timeSinceRefresh >= refreshInterval
        
        if shouldRefresh {
            print("📅 \(Int(timeSinceRefresh/3600)) hours since last refresh, refreshing now")
        } else {
            let hoursRemaining = Int((refreshInterval - timeSinceRefresh) / 3600)
            print("📅 Next refresh in \(hoursRemaining) hours")
        }
        
        return shouldRefresh
    }
    
    // MARK: - Data Persistence
    
    private func saveToCache() {
        let cacheData = CachedCalendarData(
            rotationDays: rotationDays,
            events: events,
            artsEvents: artsEvents,
            importantDates: importantDates,
            athleticsEvents: athleticsEvents,
            lastRefresh: lastRefreshDate ?? Date()
        )
        
        if let encoded = try? JSONEncoder().encode(cacheData) {
            cachedDataStorage = encoded  // AppStorage for widget
        }
        
        // Keep UserDefaults for refresh date
        userDefaults.set(lastRefreshDate, forKey: lastRefreshKey)
        
        // Update the UserDefaults dictionary whenever we save to cache
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.updateUserDefaultsDictionary()
        }
    }
    
    private func loadCachedData() {
        // Load refresh date from UserDefaults
        lastRefreshDate = userDefaults.object(forKey: lastRefreshKey) as? Date
        
        // Load calendar data from AppStorage
        guard !cachedDataStorage.isEmpty,
              let cached = try? JSONDecoder().decode(CachedCalendarData.self, from: cachedDataStorage) else {
            print("📱 No cached data found")
            return
        }
        
        rotationDays = cached.rotationDays
        events = cached.events
        artsEvents = cached.artsEvents
        importantDates = cached.importantDates
        athleticsEvents = cached.athleticsEvents
        
        // Update UserDefaults dictionary when loading cached data
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            self.updateUserDefaultsDictionary()
        }
    }
    
    // MARK: - Public Methods
    
    func fetchAllData() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let result = try await parser.fetchAllCalendars()
            
            rotationDays = result.rotationDays.sorted { $0.date < $1.date }
            events = result.events.sorted { $0.startDate < $1.startDate }
            artsEvents = result.arts.sorted { $0.startDate < $1.startDate }
            importantDates = result.importantDates.sorted { $0.startDate < $1.startDate }
            athleticsEvents = result.athletics.sorted { $0.startDate < $1.startDate }
            
            lastRefreshDate = Date()
            saveToCache()
            
            print("✅ Fetched \(rotationDays.count) rotation days")
            print("✅ Fetched \(events.count) general events")
            print("✅ Fetched \(artsEvents.count) arts events")
            print("✅ Fetched \(importantDates.count) important dates")
            print("✅ Fetched \(athleticsEvents.count) athletics events")
            
        } catch {
            errorMessage = "Failed to fetch calendar data: \(error.localizedDescription)"
            print("❌ Error: \(error)")
        }
        
        isLoading = false
    }
    
    func forceRefresh() async {
        print("🔄 Force refresh requested")
        await fetchAllData()
    }
    
    func fetchRotationDaysOnly() async {
        isLoading = true
        errorMessage = nil
        
        do {
            rotationDays = try await parser.fetchRotationDays().sorted { $0.date < $1.date }
            lastRefreshDate = Date()
            saveToCache()
            print("✅ Fetched \(rotationDays.count) rotation days")
        } catch {
            errorMessage = "Failed to fetch rotation days: \(error.localizedDescription)"
            print("❌ Error: \(error)")
        }
        
        isLoading = false
    }
    // Add this method to CalendarViewModel class
    private func updateUserDefaultsDictionary() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        var daysDictionary: [String: String] = [:]
        
        for rotationDay in rotationDays {
            let dateString = formatter.string(from: rotationDay.date)
            daysDictionary[dateString] = "Day \(rotationDay.dayNumber)"
        }
        
        // Update UserDefaults for widgets
        defaults.set(daysDictionary, forKey: "daysDictionary")
        
        print("✅ Updated UserDefaults with \(daysDictionary.count) rotation days")
    }
}
struct CalendarView: View
{
    @ObservedObject var calendarModel = CalendarViewModel()
    var body: some View
    {
        VStack{
            TabView {
                VStack{
                    List{
                        ForEach(calendarModel.artsEvents) { art in
                            VStack{
                                Text(art.title)
                                Text("\(art.startDate)")
                                Text("\(art.endDate ?? Date())")
                            }
                        }
                    }
                }
                VStack{
                    List{
                        ForEach(calendarModel.athleticsEvents) { art in
                            VStack{
                                Text(art.title)
                                Text("\(art.startDate)")
                                Text("\(art.endDate ?? Date())")
                            }
                        }
                    }
                }
                VStack{
                    List{
                        ForEach(calendarModel.importantDates) { art in
                            VStack{
                                Text(art.title)
                                Text("\(art.startDate)")
                                Text("\(art.endDate ?? Date())")
                            }
                        }
                    }
                }
                VStack{
                    List{
                        ForEach(calendarModel.rotationDays) { art in
                            Text("Day \(art.dayNumber)")
                        }
                    }
                }
                VStack{
                    List{
                        ForEach(calendarModel.events) { art in
                            VStack{
                                Text(art.title)
                                Text("\(art.startDate)")
                                Text("\(art.endDate ?? Date())")
                            }
                        }
                    }
                }
            }
            .tabViewStyle(.page)
            
        }
    }
}

#Preview {
    CalendarView()
}
