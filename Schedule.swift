//
//  Schedule.swift
//  Schedule
//
//  Created by Jack Vu on 8/29/24.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<SimpleEntry> {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        return Timeline(entries: entries, policy: .atEnd)
    }
}


    
struct CarrierViewWithCircle: View {
    let carrierTitle: String
    let defaultText: String
    let time: String
    let carrier: String
    @AppStorage("selectedColor") var selectedColorData: Data = Data()
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
    var body: some View {
        let color = loadColor() ?? Color.orange
        let textColor: Color = .white
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading){
                HStack{
                    Text(carrierTitle.isEmpty ? defaultText : carrierTitle)
                        .font(.headline)
                        .foregroundStyle(.white)
                }
                HStack{
                    Text(time)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(textColor)
                        .padding(.horizontal, 5.0)
                        .background{
                            RoundedRectangle(cornerRadius: 5)
                            .foregroundStyle(color)
                        }
                }
            }.padding(.leading, 16)
            Spacer()
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color)
                    .frame(width: 40, height: 40)
                Text(String(carrier))
                    .font(.title3)
                    .fontWeight(.bold)
                    .fontDesign(.rounded)
                    .foregroundStyle(textColor)
            }
            .frame(width: 64)  // Ensures consistent spacing for the circle
        }

    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

struct CarrierView: View {
    var title: String
    var defaultText: String
    var time: String
    var session: String
    
    @AppStorage("selectedColor") var selectedColorData: Data = Data()
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
    
    func grayDivider() -> some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.gray)
            .padding(.vertical, 3)
    }
    var body: some View {
        let color = loadColor() ?? Color.orange
        let textColor: Color = .white
        if session == "ensembles" && title.isEmpty{}
        
        else{
            if session == "lunch"{
                grayDivider()
            }
            HStack(alignment: .center, spacing: 16) {
                VStack(alignment: .leading){
                    HStack{
                        Text(title.isEmpty ? defaultText : title)
                            .font(.headline)
                            .foregroundStyle(.white)
                    }
                    HStack{
                        Text(time)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 5.0)
                            .background{
                                RoundedRectangle(cornerRadius: 5)
                                .foregroundStyle(color)
                            }
                    }
                }.padding(.leading, 16)
                Spacer()
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(color)
                        .frame(width: 40, height: 40)
                    // Display appropriate icon based on session
                    Image(systemName: sessionIcon)
                        .resizable()
                        .frame(width: widthVal, height: heightVal)
                        .foregroundStyle(textColor)
                }
                .frame(width: 64)  // Ensures consistent spacing for the circle'
            }
            .background(Color.black)
            .cornerRadius(5)
            if session == "lunch"{
                grayDivider()
            }
        }
        
    }
    
    // Computed property to determine which icon to show
    private var sessionIcon: String {
        switch session.lowercased() {
        case "lunch":
            return "fork.knife" // Fork icon
        case "assembly":
            return "person.3"
        case "davinci":
            return "paintbrush" // Paintbrush icon
        case "ensembles":
            return "music.note" // Music note icon
        case "advisory":
            return "lightbulb.fill"
        case "meetings":
            return "book.fill"
        case "chapel":
            return "house.lodge.fill"
        default:
            return "questionmark" // Fallback icon (or leave blank)
        }
    }
    
    private var widthVal:CGFloat{
        switch session.lowercased() {
        case "lunch":
            return 15.0 // Fork icon
        case "assembly":
            return 32.0
        case "davinci":
            return 20.0 // Paintbrush icon
        case "ensembles":
            return 15.0 // Music note icon
        case "advisory":
            return 14.0
        case "meetings":
            return 20.0
        case "chapel":
            return 28.0
        default:
            return 20.0 // Fallback icon (or leave blank)
        }
    }
    private var heightVal:CGFloat{
        switch session.lowercased() {
        case "advisory":
            return 23.0
        case "assembly":
            return 20.0
        case "meetings":
            return 20.0
        case "chapel":
            return 24.0
        default:
            return 22.0 // Fallback icon (or leave blank)
        }
    }
}

struct ScheduleEntryView : View {
    @State private var currentDate = Date()
    @State private var days:[String:String] = UserDefaults(suiteName:"group..com.jackrvu.mavhub.dayViews")!.dictionary(forKey: "daysDictionary") as? [String: String] ?? [:]
    @AppStorage("selectedColor") var selectedColorData: Data = Data()
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
    
    func updateDay() -> String {
        
        """
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let announced_date = formatter.string(from: currentDate)
        
        return days[announced_date] ?? ""
        """
        return "2"
    }
    
    func grayDivider() -> some View {
        Rectangle()
            .frame(height: 1)
            .foregroundStyle(Color(.gray))
            .padding(.vertical, 3)
    }
    
    
    let defaults = UserDefaults(suiteName: "group..com.jackrvu.mavhub.dayViews")!
    
    
    var entry: Provider.Entry
    var body: some View {
        let color = loadColor() ?? .orange
        let name = defaults.string(forKey: "name") ?? ""
        let aCarrier = defaults.string(forKey: "aCarrier") ?? ""
        let bCarrier = defaults.string(forKey: "bCarrier") ?? ""
        let cCarrier = defaults.string(forKey: "cCarrier") ?? ""
        let dCarrier = defaults.string(forKey: "dCarrier") ?? ""
        let eCarrier = defaults.string(forKey: "eCarrier") ?? ""
        let fCarrier = defaults.string(forKey: "fCarrier") ?? ""
        let gCarrier = defaults.string(forKey: "gCarrier") ?? ""
        let d1Morning = defaults.string(forKey: "d1Morning") ?? ""
        let d1Vinci = defaults.string(forKey: "d1Vinci") ?? ""
        let d2Morning = defaults.string(forKey: "d2Morning") ?? ""
        let d3Vinci = defaults.string(forKey: "d3Vinci") ?? ""
        let d4Morning = defaults.string(forKey: "d4Morning") ?? ""
        let d5Morning = defaults.string(forKey: "d5Morning") ?? ""
        let d6Morning = defaults.string(forKey: "d6Morning") ?? ""
        let d6Vinci = defaults.string(forKey: "d6Vinci") ?? ""
        let d7Morning = defaults.string(forKey: "d7Morning") ?? ""
        
        switch String(updateDay()).suffix(1) {
        case "1":
            VStack {
                CarrierView(title: d1Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                
                CarrierViewWithCircle(carrierTitle: aCarrier, defaultText: "Free Carrier", time: "8:30-9:30", carrier: "A")
                grayDivider()
                CarrierViewWithCircle(carrierTitle: cCarrier, defaultText: "Free Carrier", time: "9:35-10:55", carrier: "C")
                grayDivider()
                CarrierView(title: d1Vinci, defaultText: "Da Vinci", time: "11:00-11:50", session: "davinci")
                grayDivider()
                CarrierViewWithCircle(carrierTitle: bCarrier, defaultText: "Free Carrier", time: "11:55-12:55", carrier: "B")
                LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "1:00-1:25", session: "lunch", dateValue: Date(), isInNavigationView: false)
                CarrierViewWithCircle(carrierTitle: dCarrier, defaultText: "Free Carrier", time: "1:30-2:30", carrier: "D")
                grayDivider()
                CarrierViewWithCircle(carrierTitle: fCarrier, defaultText: "Free Carrier", time: "2:35-3:35", carrier: "F")
            }
        case "2":
            VStack {
                CarrierView(title: d1Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                CarrierViewWithCircle(carrierTitle: eCarrier, defaultText: "Free Carrier", time: "8:30-9:30", carrier: "E")
                grayDivider()
                CarrierViewWithCircle(carrierTitle: gCarrier, defaultText: "Free Carrier", time: "9:35-10:55", carrier: "G")
                grayDivider()
                CarrierView(title: "Advisory", defaultText: "Advisory", time: "11:00-11:25", session: "advisory")
                grayDivider()
                CarrierView(title: "Tutorials & Meetings", defaultText: "Tutorials & Meetings", time: "11:25-11:40", session: "meetings")
                grayDivider()
                CarrierViewWithCircle(carrierTitle: bCarrier, defaultText: "Free Carrier", time: "11:45-12:45", carrier: "F")
                LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "12:50-1:25", session: "lunch", dateValue: Date(),isInNavigationView:  false)
                CarrierViewWithCircle(carrierTitle: bCarrier, defaultText: "Free Carrier", time: "1:30-2:30", carrier: "B")
                grayDivider()
                CarrierViewWithCircle(carrierTitle: cCarrier, defaultText: "Free Carrier", time: "2:35-3:35", carrier: "C")
            }
            
        case "3":
            VStack {
                CarrierViewWithCircle(carrierTitle: dCarrier, defaultText: "Free Carrier", time: "8:30-9:30", carrier: "D")
                grayDivider()
                CarrierViewWithCircle(carrierTitle: aCarrier, defaultText: "Free Carrier", time: "9:35-10:55", carrier: "A")
                grayDivider()
                CarrierView(title: d3Vinci, defaultText: "Da Vinci", time: "11:00-11:50", session: "davinci")
                grayDivider()
                CarrierViewWithCircle(carrierTitle: eCarrier, defaultText: "Free Carrier", time: "11:55-12:55", carrier: "E")
                grayDivider()
                LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "1:00-1:25", session: "lunch", dateValue: Date(), isInNavigationView: false)
                CarrierViewWithCircle(carrierTitle: cCarrier, defaultText: "Free Carrier", time: "1:30-2:30", carrier: "C")
                CarrierViewWithCircle(carrierTitle: gCarrier, defaultText: "Free Carrier", time: "2:35-3:35", carrier: "G")
            }
        case "4":
            VStack {
                CarrierView(title: d4Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                
                CarrierViewWithCircle(carrierTitle: eCarrier, defaultText: "Free Carrier", time: "8:30-9:30", carrier: "E")
                grayDivider()
                CarrierViewWithCircle(carrierTitle: fCarrier, defaultText: "Free Carrier", time: "9:35-10:55", carrier: "F")
                grayDivider()
                CarrierView(title: "Chapel / Advisory", defaultText: "Chapel / Advisory", time: "11:00-11:40", session: "chapel")
                grayDivider()
                CarrierViewWithCircle(carrierTitle: bCarrier, defaultText: "Free Carrier", time: "11:45-12:45", carrier: "B")
                LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "12:50-1:25", session: "lunch", dateValue: Date(), isInNavigationView: false)
                CarrierViewWithCircle(carrierTitle: aCarrier, defaultText: "Free Carrier", time: "1:30-2:30", carrier: "A")
                grayDivider()
                CarrierViewWithCircle(carrierTitle: dCarrier, defaultText: "Free Carrier", time: "2:35-3:35", carrier: "D")
            }
        case "5":
            VStack {
                CarrierView(title: d5Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                
                CarrierViewWithCircle(carrierTitle: gCarrier, defaultText: "Free Carrier", time: "8:30-9:30", carrier: "G")
                grayDivider()
                CarrierViewWithCircle(carrierTitle: bCarrier, defaultText: "Free Carrier", time: "9:35-10:55", carrier: "B")
                grayDivider()
                CarrierView(title: "Advisory", defaultText: "Advisory", time: "11:00-11:15", session: "advisory")
                grayDivider()
                CarrierView(title: "Tutorials & Meetings", defaultText: "Tutorials & Meetings", time: "11:15-11:40", session: "meetings")
                grayDivider()
                CarrierViewWithCircle(carrierTitle: cCarrier, defaultText: "Free Carrier", time: "11:45-12:45", carrier: "C")
                LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "12:50-1:25", session: "lunch", dateValue: Date(), isInNavigationView: false)
                CarrierViewWithCircle(carrierTitle: fCarrier, defaultText: "Free Carrier", time: "1:30-2:30", carrier: "F")
                grayDivider()
                CarrierViewWithCircle(carrierTitle: aCarrier, defaultText: "Free Carrier", time: "2:35-3:35", carrier: "A")
            }
        case "6":
            VStack {
                CarrierView(title: d6Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                
                CarrierViewWithCircle(carrierTitle: cCarrier, defaultText: "Free Carrier", time: "8:30-9:30", carrier: "C")
                grayDivider()
                CarrierViewWithCircle(carrierTitle: dCarrier, defaultText: "Free Carrier", time: "9:35-10:55", carrier: "D")
                grayDivider()
                CarrierView(title: d6Vinci, defaultText: "Da Vinci", time: "11:00-11:50", session: "davinci")
                grayDivider()
                CarrierViewWithCircle(carrierTitle: bCarrier, defaultText: "Free Carrier", time: "11:55-12:55", carrier: "B")
                LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "1:00-1:25", session: "lunch", dateValue: Date(), isInNavigationView: false)
                CarrierViewWithCircle(carrierTitle: eCarrier, defaultText: "Free Carrier", time: "1:30-2:30", carrier: "E")
                grayDivider()
                CarrierViewWithCircle(carrierTitle: gCarrier, defaultText: "Free Carrier", time: "2:35-3:35", carrier: "G")
            }
        case "7":VStack {
            CarrierView(title: d7Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
            
            CarrierViewWithCircle(carrierTitle: fCarrier, defaultText: "Free Carrier", time: "8:30-9:30", carrier: "F")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: eCarrier, defaultText: "Free Carrier", time: "9:35-10:55", carrier: "E")
            grayDivider()
            CarrierView(title: "Assembly / Advisory", defaultText: "Assembly / Advisory", time: "11:00-11:40", session: "assembly")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: aCarrier, defaultText: "Free Carrier", time: "11:45-12:45", carrier: "A")
            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "12:55-1:25", session: "lunch", dateValue: Date(),isInNavigationView:  false)
            CarrierViewWithCircle(carrierTitle: gCarrier, defaultText: "Free Carrier", time: "1:30-2:30", carrier: "G")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: dCarrier, defaultText: "Free Carrier", time: "2:35-3:35", carrier: "D")
        }
        default:
            VStack(){
                Text("No School Today!")
                    .font(.largeTitle)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .padding(.top, 10.0)
                    .padding(.bottom, 5.0)
                Text("🎉")
                    .font(.system(size:50))
                    .fontWeight(.bold)
            }
        }
    }
    struct LunchButtonView: View {
        var title: String
        var defaultText: String
        var time: String
        var session: String
        var dateValue: Date
        var isInNavigationView: Bool
        @State private var isActive: Bool = false
        
        @AppStorage("selectedColor") var selectedColorData: Data = Data()
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
        
        var body: some View {
            let color = loadColor() ?? Color.orange
            let textColor: Color = .white
                    HStack(alignment: .center, spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(textColor)
                                .frame(width: 40, height: 40)
                            
                            Image(systemName: "fork.knife")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(color)
                        }
                        .padding(.leading, -4)
                        
                        Text(title.isEmpty ? defaultText : title)
                            .font(.headline)
                            .foregroundStyle(textColor)
                            .padding(.leading, 13)
                        
                        Spacer()
                        
                        Text(time)
                            .font(.headline)
                            .foregroundStyle(textColor.opacity(0.8))
                    }
                    .padding(.vertical, 8) // Reduced vertical padding
                    .padding(.horizontal) // Keep the horizontal padding as it is
                    .background(color)
                    .cornerRadius(32)
                    .shadow(color: Color.black.opacity(0.2), radius: 4, x: 0, y: 2)
        }
    }
}

struct Schedule: Widget {
    let kind: String = "Schedule"

    var body: some WidgetConfiguration {
           AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
               ScheduleEntryView(entry: entry)
                   .containerBackground(.fill.tertiary, for: .widget)
           }
           .supportedFamilies([.systemMedium])
       }
}

extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "😀"
        return intent
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        let intent = ConfigurationAppIntent()
        intent.favoriteEmoji = "🤩"
        return intent
    }
}

#Preview(as: .systemSmall) {
    Schedule()
} timeline: {
    SimpleEntry(date: .now, configuration: .smiley)
    SimpleEntry(date: .now, configuration: .starEyes)
}
