import SwiftUI

struct SportsView: View {
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    @EnvironmentObject var calendarModel: CalendarViewModel
    @State private var selectedCategory: CalendarType? = nil
    
    var dateValue: Date
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        let color = loadColor() ?? Color.orange
        let isLight = color.isLight()
        let textColor: Color = darkMode ? .white : .black
        
        VStack(spacing: 0) {
            // Header with close button
            HStack {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                }
                .padding()
                Spacer()
            }
            
            // Category Filter Bar
            categoryFilterBar
            
            // Content
            ScrollView {
                VStack {
                    if let error = calendarModel.errorMessage {
                        ErrorView(error: error, color: color, textColor: textColor, isLight: isLight, darkMode: darkMode)
                    } else if calendarModel.isLoading && allEvents.isEmpty {
                        LoadingView(color: color, textColor: textColor)
                    } else {
                        let filteredEvents = getFilteredEvents()
                        
                        if filteredEvents.isEmpty {
                            EmptyEventsView(dateValue: dateValue, color: color, textColor: textColor, isLight: isLight, darkMode: darkMode)
                        } else {
                            EventsListView(
                                dateValue: dateValue,
                                filteredEvents: filteredEvents,
                                color: color,
                                textColor: textColor,
                                darkMode: darkMode
                            )
                        }
                    }
                }
                .padding(.top, 10)
            }
        }
        .navigationBarBackButtonHidden(true)
    }

    // MARK: - Computed Properties
    
    private var allEvents: [CalendarEvent] {
        var events: [CalendarEvent] = []
        events.append(contentsOf: calendarModel.athleticsEvents)
        events.append(contentsOf: calendarModel.artsEvents)
        events.append(contentsOf: calendarModel.importantDates)
        events.append(contentsOf: calendarModel.events)
        return events.sorted { $0.startDate < $1.startDate }
    }
    
    private var categoryFilterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                EventCategoryButton(
                    title: "All",
                    isSelected: selectedCategory == nil,
                    accentColor: loadColor() ?? Color.orange
                ) {
                    selectedCategory = nil
                }

                EventCategoryButton(
                    title: "Sports",
                    isSelected: selectedCategory == .athletics,
                    accentColor: loadColor() ?? Color.orange
                ) {
                    selectedCategory = .athletics
                }
                
                EventCategoryButton(
                    title: "Arts",
                    isSelected: selectedCategory == .arts,
                    accentColor: loadColor() ?? Color.orange
                ) {
                    selectedCategory = .arts
                }
                
                EventCategoryButton(
                    title: "Important Dates",
                    isSelected: selectedCategory == .importantDates,
                    accentColor: loadColor() ?? Color.orange
                ) {
                    selectedCategory = .importantDates
                }
                
                EventCategoryButton(
                    title: "Events",
                    isSelected: selectedCategory == .events,
                    accentColor: loadColor() ?? Color.orange
                ) {
                    selectedCategory = .events
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Helper Functions
    
    private func getFilteredEvents() -> [CalendarEvent] {
        let eventsForDate = allEvents.filter { event in
            isDateInEventRange(selectedDate: dateValue, event: event)
        }
        
        if let category = selectedCategory {
            return eventsForDate.filter { $0.type == category }
        }
        
        return eventsForDate
    }
    
    private func isDateInEventRange(selectedDate: Date, event: CalendarEvent) -> Bool {
        let calendar = Calendar.current
        
        // If there's no endDate, treat it as a single-day event
        guard let endDate = event.endDate else {
            return calendar.isDate(selectedDate, inSameDayAs: event.startDate)
        }
        
        // If startDate and endDate are the same day, it's a single-day event
        if calendar.isDate(event.startDate, inSameDayAs: endDate) {
            return calendar.isDate(selectedDate, inSameDayAs: event.startDate)
        }
        
        // For multi-day events, check if selectedDate falls within the range (inclusive)
        let startOfSelectedDay = calendar.startOfDay(for: selectedDate)
        let startOfEventStart = calendar.startOfDay(for: event.startDate)
        let startOfEventEnd = calendar.startOfDay(for: endDate)
        
        return startOfSelectedDay >= startOfEventStart && startOfSelectedDay <= startOfEventEnd
    }

    private func loadColor() -> Color? {
        do {
            if let uiColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: selectedColorData) {
                return Color(uiColor)
            }
        } catch {
            print("Failed to unarchive color: \(error)")
        }
        return nil
    }
}

// MARK: - Category Button
struct EventCategoryButton: View {
    let title: String
    let isSelected: Bool
    let accentColor: Color
    let action: () -> Void
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? accentColor.opacity(0.15) : Color.clear)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .strokeBorder(isSelected ? accentColor : Color.gray.opacity(0.3), lineWidth: 1)
                )
        }
        .foregroundColor(isSelected ? (accentColor.isLight() == darkMode ? accentColor : .blue) : .primary)
    }
}

// MARK: - Subviews
struct LoadingView: View {
    let color: Color
    let textColor: Color
    
    var body: some View {
        VStack {
            ProgressView(progress: 0.5)
                .progressViewStyle(CircularProgressViewStyle(tint: color))
                .scaleEffect(1.5)
            
            Text("Loading Events...")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(textColor)
                .padding(.top, 10)
        }
        .padding()
    }
}

struct ErrorView: View {
    let error: String
    let color: Color
    let textColor: Color
    let isLight: Bool
    let darkMode: Bool

    var body: some View {
        VStack {
            Image(systemName: "exclamationmark.triangle")
                .font(.largeTitle)
                .foregroundColor(color)
                .padding(.bottom, 10)
            
            Text("Error")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(darkMode ? .white : .black)
                .padding(.bottom, 5)
            
            Text(error)
                .foregroundColor(darkMode == isLight ? color : textColor)
                .padding()
                .multilineTextAlignment(.center)
        }
    }
}

struct EmptyEventsView: View {
    let dateValue: Date
    let color: Color
    let textColor: Color
    let isLight: Bool
    let darkMode: Bool

    var body: some View {
        VStack {
            HStack {
                Rectangle()
                    .fill(color)
                    .frame(width: 5, height: 40)
                
                Text("Events")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(darkMode ? .white : .black)
                    .padding(.leading, 8)
                
                Spacer()
            }
            .padding(.horizontal)
            .padding(.top, 10)
            
            Text("No Events Found For \(formattedDate(from: dateValue))")
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(darkMode ? .white : .black)
                .padding(.horizontal)
                .padding(.bottom, 10)
        }
    }

    private func formattedDate(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
}

struct EventsListView: View {
    let dateValue: Date
    let filteredEvents: [CalendarEvent]
    let color: Color
    let textColor: Color
    let darkMode: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Rectangle()
                    .fill(color)
                    .frame(width: 5, height: 40)
                
                Text("Events")
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(darkMode ? .white : .black)
                    .padding(.leading, 8)

                Spacer()
            }
            .padding(.horizontal)

            Text("For \(formattedDate(from: dateValue))")
                .font(.system(size: 18, weight: .regular, design: .rounded))
                .foregroundColor(darkMode ? .white : .black)
                .padding(.horizontal)
                .padding(.bottom, 10)

            VStack(alignment: .leading, spacing: 15) {
                ForEach(filteredEvents, id: \.id) { event in
                    EventCardView(event: event, darkMode: darkMode, color: color, textColor: textColor)
                }
            }
            .padding(.horizontal)
        }
    }

    private func formattedDate(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
}

struct EventCardView: View {
    let event: CalendarEvent
    let darkMode: Bool
    let color: Color
    let textColor: Color

    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Logo
            Image(systemName: logoForEvent(event))
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .foregroundColor(color.isLight() == darkMode ? color:Color.blue)

            // Event Details
            VStack(alignment: .leading, spacing: 5) {
                Text(event.title)
                    .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(color.isLight() == darkMode ? color:Color.blue)
                    .lineLimit(nil)

                // Show date range for multi-day events, single date for single-day events
                if event.isMultiDay {
                    Text("Duration: \(formattedDate(from: event.startDate)) - \(formattedDate(from: event.endDate ?? event.startDate))")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(darkMode ? textColor.opacity(0.7) : .gray)
                } else {
                    Text("Date: \(formattedDate(from: event.startDate))")
                        .font(.system(size: 14, weight: .regular, design: .rounded))
                        .foregroundColor(darkMode ? textColor.opacity(0.7) : .gray)
                }
                
                if hasTime(date: event.startDate) || (event.endDate != nil && hasTime(date: event.endDate!)) {
                    if event.isMultiDay {
                        // For multi-day events, show start and end times if they exist
                        if hasTime(date: event.startDate) {
                            Text("Starts: \(formattedTime(from: event.startDate))")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(darkMode ? textColor.opacity(0.7) : .gray)
                        }
                        if let endDate = event.endDate, hasTime(date: endDate) {
                            Text("Ends: \(formattedTime(from: endDate))")
                                .font(.system(size: 14, weight: .regular, design: .rounded))
                                .foregroundColor(darkMode ? textColor.opacity(0.7) : .gray)
                        }
                    } else {
                        // For single-day events, show time as before
                        Text("Time: \(formattedTime(from: event.startDate))")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(darkMode ? textColor.opacity(0.7) : .gray)
                    }
                }
                
                Text(event.type.rawValue)
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(color.isLight() == darkMode ? color.opacity(0.8):Color.blue.opacity(0.8))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(color.isLight() == darkMode ? color.opacity(0.1):Color.blue.opacity(0.1))
                    )
            }

            Spacer()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(darkMode ? Color.black.opacity(0.4) : Color.white)
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(darkMode ? color.opacity(0.7) : color.opacity(0.3), lineWidth: 1)
        )
        .padding(.vertical, 5)
    }

    // Helper to format date
    private func formattedDate(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        return dateFormatter.string(from: date)
    }
    
    // Helper to format time
    private func formattedTime(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date)
    }
    
    // Helper to check if the date has a specific time (not just a date)
    private func hasTime(date: Date) -> Bool {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: date)
        return components.hour != 0 || components.minute != 0 || components.second != 0
    }

    // Helper to determine the appropriate logo based on event content
    private func logoForEvent(_ event: CalendarEvent) -> String {
        let eventTitle = event.title.lowercased()
        
        // Sports keywords
        let sportsKeywords: [String: String] = [
            "soccer": "soccerball",
            "basketball": "basketball",
            "tennis": "tennis.racket",
            "baseball": "baseball",
            "volleyball": "volleyball",
            "football": "american.football.circle",
            "hockey": "figure.field.hockey.circle",
            "golf": "figure.golf.circle",
            "swimming": "figure.pool.swim.circle",
            "track": "figure.track.and.field.circle",
            "cross country": "figure.run.circle",
            "wrestling": "figure.wrestling.circle",
            "lacrosse": "figure.lacrosse.circle",
            "field hockey": "figure.field.hockey.circle",
            "softball": "figure.softball.circle"
        ]
        
        // Fine arts keywords
        let artsKeywords: [String: String] = [
            "theatre": "theatermasks",
            "theater": "theatermasks",
            "play": "theatermasks",
            "drama": "theatermasks",
            "musical": "theatermasks",
            "orchestra": "music.note.list",
            "symphony": "music.note.list",
            "violin": "music.note.list",
            "cello": "music.note.list",
            "choir": "music.mic",
            "chorus": "music.mic",
            "singing": "music.mic",
            "vocal": "music.mic",
            "band": "music.quarternote.3",
            "concert": "music.quarternote.3",
            "piano": "pianokeys",
            "recital": "pianokeys"
        ]
        
        // Check sports keywords first
        for (keyword, logo) in sportsKeywords {
            if eventTitle.contains(keyword) {
                return logo
            }
        }
        
        // Check arts keywords
        for (keyword, logo) in artsKeywords {
            if eventTitle.contains(keyword) {
                return logo
            }
        }
        
        // Fall back to type-based icons
        switch event.type {
        case .athletics:
            return "sportscourt"
        case .arts:
            return "theatermasks"
        case .importantDates:
            return "calendar.badge.exclamationmark"
        case .events:
            return "calendar"
        case .schedule:
            return "calendar"
        }
    }
}

// MARK: - Preview
#Preview {
   TabControl()
}
