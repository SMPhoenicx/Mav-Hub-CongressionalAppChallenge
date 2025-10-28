//
//  ClassWidget.swift
//  ClassWidget
//
//  Created by Suman Muppavarapu on 9/15/24.
// jvu was also here possibly

import WidgetKit
import SwiftUI

@available(iOSApplicationExtension 17.0, *)
struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> ClassEntry {
        ClassEntry(date: Date(), configuration: ConfigurationAppIntent())
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> ClassEntry {
        ClassEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<ClassEntry> {
        var entries: [ClassEntry] = []

        // Generate a timeline consisting of entries at one-minute intervals, starting from the current date.
        let currentDate = Date()
        for minuteOffset in 0 ..< 60 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            let entry = ClassEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        // Schedule the next update one minute after the last entry date
        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!

        return Timeline(entries: entries, policy: .after(nextUpdateDate))
    }
}

@available(iOSApplicationExtension 17.0, *)
struct ClassEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationAppIntent
}

@available(iOSApplicationExtension 17.0, *)
struct ClassWidgetEntryView : View {
    var entry: ClassEntry
    @State private var days: [String:String] = [:]
    
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    
    @AppStorage("schedules", store: defaults) private var schedulesData: Data = Data()
    @AppStorage("usingSchedule", store: defaults) private var usingSchedule:Int = 0
    
    @State private var scheduleArr: [Schedule] = []
    @State private var curSchedule: Schedule = Schedule(
        name: "",
        aCarrier: "",
        bCarrier: "",
        cCarrier: "",
        dCarrier: "",
        eCarrier: "",
        fCarrier: "",
        gCarrier: "",
        d1Morning: "",
        d1Vinci: "",
        d2Morning: "",
        d3Vinci: "",
        d4Morning: "",
        d5Morning: "",
        d6Morning: "",
        d6Vinci: "",
        d7Morning: "",
        grade: 0
    )
    
    private var sharedDefaults: UserDefaults? {
        UserDefaults(suiteName: "group..com.jackrvu.mavhub.dayViews")
    }
    
    var body: some View {
        let day = updateDay()
        let middleSchoolMode = curSchedule.grade != 0
        let sixthGradeMode = curSchedule.grade == 2
        
        let aCarrier = curSchedule.aCarrier
        let bCarrier = curSchedule.bCarrier
        let cCarrier = curSchedule.cCarrier
        let dCarrier = curSchedule.dCarrier
        let eCarrier = curSchedule.eCarrier
        let fCarrier = curSchedule.fCarrier
        let gCarrier = curSchedule.gCarrier
        let d1Morning = curSchedule.d1Morning
        let d2Morning = curSchedule.d2Morning
        let d4Morning = curSchedule.d4Morning
        let d5Morning = curSchedule.d5Morning
        let d6Morning = curSchedule.d6Morning
        let d7Morning = curSchedule.d7Morning
        let d1Vinci = curSchedule.d1Vinci
        let d3Vinci = curSchedule.d3Vinci
        let d6Vinci = curSchedule.d6Vinci
        ZStack{
            VStack {
                if !middleSchoolMode {
                    switch day{
                    case "Day 1":
                        Text("\(day)")
                        GeometryReader{ geometry in
                            let rowHeight = geometry.size.height / CGFloat(8)
                            VStack{
                                notCarrierView(image: "music.note", type: d1Morning, time:"7:30-8:15", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "A", carrier: aCarrier, time: "8:30-9:30", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "C", carrier: cCarrier, time: "9:35-10:55", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "paintbrush", type: d1Vinci, time: "11:00-11:50", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "B", carrier: bCarrier, time: "11:55-12:55", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "fork.knife", type: "Lunch", time:"1:00-1:25", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "D", carrier: dCarrier, time: "1:30-2:30", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "F", carrier: fCarrier, time: "2:35-3:35", rowHeight: rowHeight, darkMode: darkMode)
                            }
                            .padding(.horizontal)
                        }
                    case "Day 2":
                        Text("\(day)")
                        GeometryReader{ geometry in
                            let rowHeight = geometry.size.height / CGFloat(8)
                            VStack{
                                notCarrierView(image: "music.note", type: d2Morning, time:"7:30-8:15", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "E", carrier: eCarrier, time: "8:30-9:30", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "G", carrier: gCarrier, time: "9:35-10:55", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "lightbulb.fill", type: "Advisory, T & M", time: "11:00-11:40", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "F", carrier: fCarrier, time: "11:45-12:45", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "fork.knife", type: "Lunch", time:"12:50-1:25", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "B", carrier: bCarrier, time: "1:30-2:30", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "C", carrier: cCarrier, time: "2:35-3:35", rowHeight: rowHeight, darkMode: darkMode)
                            }
                            .padding(.horizontal)
                        }
                    case "Day 3":
                        Text("\(day)")
                        GeometryReader{ geometry in
                            let rowHeight = geometry.size.height / CGFloat(7)
                            VStack{
                                carrierView(letter: "D", carrier: dCarrier, time: "8:30-9:30", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "A", carrier: aCarrier, time: "9:35-10:55", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "paintbrush", type: d3Vinci, time: "11:00-11:50", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "E", carrier: eCarrier, time: "11:55-12:55", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "fork.knife", type: "Lunch", time:"1:00-1:25", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "C", carrier: cCarrier, time: "1:30-2:30", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "G", carrier: gCarrier, time: "2:35-3:35", rowHeight: rowHeight, darkMode: darkMode)
                            }
                            .padding(.horizontal)
                        }
                    case "Day 4":
                        Text("\(day)")
                        GeometryReader{ geometry in
                            let rowHeight = geometry.size.height / CGFloat(8)
                            VStack{
                                notCarrierView(image: "music.note", type: d4Morning, time:"7:30-8:15", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "E", carrier: eCarrier, time: "8:30-9:30", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "F", carrier: fCarrier, time: "9:35-10:55", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "house.lodge.fill", type: "Chapel", time: "11:00-11:40", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "B", carrier: bCarrier, time: "11:45-12:45", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "fork.knife", type: "Lunch", time:"12:50-1:25", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "A", carrier: aCarrier, time: "1:30-2:30", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "D", carrier: dCarrier, time: "2:35-3:35", rowHeight: rowHeight, darkMode: darkMode)
                            }
                            .padding(.horizontal)
                        }
                    case "Day 5":
                        Text("\(day)")
                        GeometryReader{ geometry in
                            let rowHeight = geometry.size.height / CGFloat(8)
                            VStack{
                                notCarrierView(image: "music.note", type: d5Morning, time:"7:30-8:15", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "G", carrier: gCarrier, time: "8:30-9:30", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "B", carrier: bCarrier, time: "9:35-10:55", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "lightbulb.fill", type: "Advisory, T & M", time: "11:00-11:40", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "C", carrier: cCarrier, time: "11:45-12:45", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "fork.knife", type: "Lunch", time:"12:50-1:25", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "F", carrier: fCarrier, time: "1:30-2:30", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "A", carrier: aCarrier, time: "2:35-3:35", rowHeight: rowHeight, darkMode: darkMode)
                            }
                            .padding(.horizontal)
                        }
                    case "Day 6":
                        Text("\(day)")
                        GeometryReader{ geometry in
                            let rowHeight = geometry.size.height / CGFloat(8)
                            VStack{
                                notCarrierView(image: "music.note", type: d6Morning, time:"7:30-8:15", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "C", carrier: cCarrier, time: "8:30-9:30", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "D", carrier: dCarrier, time: "9:35-10:55", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "paintbrush", type: d6Vinci, time: "11:00-11:50", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "B", carrier: bCarrier, time: "11:55-12:55", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "fork.knife", type: "Lunch", time:"1:00-1:25", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "E", carrier: eCarrier, time: "1:30-2:30", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "G", carrier: gCarrier, time: "2:35-3:35", rowHeight: rowHeight, darkMode: darkMode)
                            }
                            .padding(.horizontal)
                        }
                    case "Day 7":
                        Text("\(day)")
                        GeometryReader{ geometry in
                            let rowHeight = geometry.size.height / CGFloat(8)
                            VStack{
                                notCarrierView(image: "music.note", type: d7Morning, time:"7:30-8:15", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "F", carrier: fCarrier, time: "8:30-9:30", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "E", carrier: eCarrier, time: "9:35-10:55", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "lightbulb.fill", type: "Assembly / Advisory", time: "11:00-11:40", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "A", carrier: aCarrier, time: "11:45-12:45", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "fork.knife", type: "Lunch", time:"12:50-1:25", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "G", carrier: gCarrier, time: "1:30-2:30", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "D", carrier: dCarrier, time: "2:35-3:35", rowHeight: rowHeight, darkMode: darkMode)
                            }
                            .padding(.horizontal)
                        }
                    default:
                        Text("No School Today!")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .padding(.top, 5.0)
                            .padding(.bottom, 5.0)
                        Text("🎉")
                            .font(.system(size:40))
                            .fontWeight(.bold)
                    }
                        
                }
                else{
                    switch day
                    {
                    case "Day 1":
                        GeometryReader{ geometry in
                            let rowHeight = geometry.size.height / CGFloat(9)
                            VStack {
                                notCarrierView(image: "music.note", type: d1Morning, time:"7:30-8:15", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "D", carrier: dCarrier, time: "8:30-9:30", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "C", carrier: cCarrier, time: "9:35-10:35", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "cup.and.saucer", type: "Break", time:"10:35-11:00", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "F", carrier: fCarrier, time: "11:00-12:00", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "fork.knife", type: "Lunch", time:"12:00-12:40", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "paintbrush", type: d1Vinci, time:"12:40-1:25", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "A", carrier: aCarrier, time: "1:30-2:30", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "E", carrier: eCarrier, time: "2:35-3:35", rowHeight: rowHeight, darkMode: darkMode)
                            }
                        }
                    case "Day 2":
                        GeometryReader{ geometry in
                            let rowHeight = geometry.size.height / CGFloat(9)
                            VStack {
                                notCarrierView(image: "music.note", type: d2Morning, time:"7:30-8:15", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "house.lodge.fill", type: "Chapel", time: "8:30-9:30", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                if sixthGradeMode{
                                    notCarrierView(image: "baseball", type: "PE", time: "9:30-10:30", rowHeight: rowHeight, darkMode: darkMode)
                                }
                                else{
                                    carrierView(letter: "A", carrier: aCarrier, time: "9:30-10:30", rowHeight: rowHeight, darkMode: darkMode)
                                }
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "cup.and.saucer", type: "Break", time:"10:30-10:45", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "E", carrier: eCarrier, time: "10:45-11:45", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "fork.knife", type: "Lunch", time:"11:45-12:25", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "B", carrier: bCarrier, time: "12:25-1:25", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "C", carrier: cCarrier, time: "1:30-2:30", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                if sixthGradeMode{
                                    carrierView(letter: "A", carrier: aCarrier, time: "2:35-3:35", rowHeight: rowHeight, darkMode: darkMode)
                                }
                                else{
                                    notCarrierView(image: "figure.run", type: "Athletics", time:"2:35-3:45", rowHeight: rowHeight, darkMode: darkMode)
                                }
                            }
                        }
                    case "Day 3":
                        GeometryReader{ geometry in
                            let rowHeight = geometry.size.height / CGFloat(8)
                            VStack {
                                carrierView(letter: "B", carrier: bCarrier, time: "8:30-9:30", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                if sixthGradeMode{
                                    notCarrierView(image: "baseball", type: "PE", time: "9:35-10:35", rowHeight: rowHeight, darkMode: darkMode)
                                }
                                else{
                                    carrierView(letter: "D", carrier: dCarrier, time: "9:35-10:35", rowHeight: rowHeight, darkMode: darkMode)
                                }
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "cup.and.saucer", type: "Break", time:"10:35-11:00", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "C", carrier: cCarrier, time: "11:00-12:00", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "fork.knife", type: "Lunch", time:"12:00-12:40", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "lightbulb.fill", type: "Extended Advisory", time: "12:40-1:25", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "F", carrier: fCarrier, time: "1:30-2:30", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                if sixthGradeMode{
                                    carrierView(letter: "D", carrier: dCarrier, time: "2:35-3:35", rowHeight: rowHeight, darkMode: darkMode)
                                }
                                else{
                                    notCarrierView(image: "figure.run", type: "Athletics", time:"2:35-3:45", rowHeight: rowHeight, darkMode: darkMode)
                                }
                            }
                        }
                    case "Day 4":
                        GeometryReader{ geometry in
                            let rowHeight = geometry.size.height / CGFloat(9)
                            VStack {
                                notCarrierView(image: "music.note", type: d4Morning, time:"7:30-8:15", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "E", carrier: eCarrier, time: "8:30-9:30", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "B", carrier: bCarrier, time: "9:35-10:35", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "cup.and.saucer", type: "Break", time:"10:35-11:00", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "F", carrier: fCarrier, time: "11:00-12:00", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "fork.knife", type: "Lunch", time:"12:00-12:40", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "paintbrush", type: d3Vinci, time:"12:40-1:25", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "A", carrier: aCarrier, time: "1:30-2:30", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "D", carrier: dCarrier, time: "2:35-3:35", rowHeight: rowHeight, darkMode: darkMode)
                            }
                        }
                    case "Day 5":
                        GeometryReader{ geometry in
                            let rowHeight = geometry.size.height / CGFloat(9)
                            VStack {
                                notCarrierView(image: "music.note", type: d5Morning, time:"7:30-8:15", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "F", carrier: fCarrier, time: "8:30-9:30", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                if sixthGradeMode{
                                    notCarrierView(image: "baseball", type: "PE", time: "9:35-10:35", rowHeight: rowHeight, darkMode: darkMode)
                                }
                                else{
                                    carrierView(letter: "A", carrier: aCarrier, time: "9:35-10:35", rowHeight: rowHeight, darkMode: darkMode)
                                }
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "cup.and.saucer", type: "Break", time:"10:35-11:00", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "C", carrier: cCarrier, time: "11:00-12:00", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "fork.knife", type: "Lunch", time:"12:00-12:40", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "lightbulb.fill", type: "SEL", time:"12:40-1:25", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "E", carrier: eCarrier, time: "1:30-2:30", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                if sixthGradeMode{
                                    carrierView(letter: "A", carrier: aCarrier, time: "2:35-3:35", rowHeight: rowHeight, darkMode: darkMode)
                                }
                                else{
                                    notCarrierView(image: "figure.run", type: "Athletics", time:"2:35-3:45", rowHeight: rowHeight, darkMode: darkMode)
                                }
                            }
                        }
                    case "Day 6":
                        GeometryReader{ geometry in
                            let rowHeight = geometry.size.height / CGFloat(9)
                            VStack {
                                notCarrierView(image: "music.note", type: d6Morning, time:"7:30-8:15", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "C", carrier: cCarrier, time: "8:30-9:30", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                if sixthGradeMode{
                                    notCarrierView(image: "baseball", type: "PE", time: "9:35-10:35", rowHeight: rowHeight, darkMode: darkMode)
                                }
                                else{
                                    carrierView(letter: "B", carrier: bCarrier, time: "9:35-10:35", rowHeight: rowHeight, darkMode: darkMode)
                                }
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "cup.and.saucer", type: "Break", time:"10:35-11:00", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "E", carrier: eCarrier, time: "11:00-12:00", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "fork.knife", type: "Lunch", time:"12:00-12:40", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "paintbrush", type: d6Vinci, time:"12:40-1:25", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "D", carrier: dCarrier, time: "1:30-2:30", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                if sixthGradeMode{
                                    carrierView(letter: "B", carrier: bCarrier, time: "2:35-3:35", rowHeight: rowHeight, darkMode: darkMode)
                                }
                                else{
                                    notCarrierView(image: "figure.run", type: "Athletics", time:"2:35-3:45", rowHeight: rowHeight, darkMode: darkMode)
                                }
                            }
                        }
                    case "Day 7":
                        GeometryReader{ geometry in
                            let rowHeight = geometry.size.height / CGFloat(9)
                            VStack {
                                notCarrierView(image: "music.note", type: d7Morning, time:"7:30-8:15", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "A", carrier: aCarrier, time: "8:30-9:30", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                if sixthGradeMode{
                                    notCarrierView(image: "baseball", type: "PE", time: "9:35-10:35", rowHeight: rowHeight, darkMode: darkMode)
                                }
                                else{
                                    carrierView(letter: "F", carrier: fCarrier, time: "9:35-10:35", rowHeight: rowHeight, darkMode: darkMode)
                                }
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "cup.and.saucer", type: "Break", time:"10:35-11:00", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "D", carrier: dCarrier, time: "11:00-12:00", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "fork.knife", type: "Lunch", time:"12:00-12:40", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                notCarrierView(image: "lightbulb.fill", type: "Assembly", time: "12:40-1:25", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                carrierView(letter: "B", carrier: bCarrier, time: "1:30-2:30", rowHeight: rowHeight, darkMode: darkMode)
                                Divider()
                                    .overlay(Color(.systemGray))
                                if sixthGradeMode{
                                    carrierView(letter: "F", carrier: fCarrier, time: "2:35-3:35", rowHeight: rowHeight, darkMode: darkMode)
                                }
                                else{
                                    notCarrierView(image: "figure.run", type: "Athletics", time:"2:35-3:45", rowHeight: rowHeight, darkMode: darkMode)
                                }
                            }
                        }
                    default:
                        VStack(){
                            Text("No School Today!")
                                .font(.title)
                                .fontWeight(.semibold)
                                .fontDesign(.rounded)
                                .foregroundStyle(darkMode ? .white:.black)
                                .padding(.top, 10.0)
                                .padding(.bottom, 5.0)
                            Text("🎉")
                                .font(.system(size:50))
                                .fontWeight(.bold)
                        }
                    }
                    
                }
                Spacer()
            }
            .foregroundStyle(.white)
        }
        .onAppear {
            if let defaults = sharedDefaults {
                   days = defaults.dictionary(forKey: "daysDictionary") as? [String: String] ?? [:]
               }
            
            scheduleArr = loadSchedules()
            if usingSchedule >= scheduleArr.count {
                usingSchedule = 0
            }
            if !scheduleArr.isEmpty {
                curSchedule = scheduleArr[usingSchedule]
            }
        }
        .onChange(of: schedulesData) { _ in
            // Reload the schedules when schedulesData changes
            scheduleArr = loadSchedules()
            if usingSchedule >= scheduleArr.count {
                usingSchedule = 0
            }
            if !scheduleArr.isEmpty {
                curSchedule = scheduleArr[usingSchedule]
            }
        }
        .onChange(of: usingSchedule){ _ in
            scheduleArr = loadSchedules()
            if usingSchedule >= scheduleArr.count {
                usingSchedule = 0
            }
            if !scheduleArr.isEmpty {
                curSchedule = scheduleArr[usingSchedule]
            }
        }
    }
    private func loadColor() -> Color {
        do {
            if let uiColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: selectedColorData) {
                return Color(uiColor)
            }
        } catch {
            print("Failed to unarchive color: \(error)")
        }
        return Color.orange // Fallback color
    }
    
    func isLight(color: Color) -> Bool {
        guard let components = color.getRGBComponents() else {
            return false
        }
        
        let r = components.red
        let g = components.green
        let b = components.blue
        
        // Calculate the luminance
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        
        // Return true if the luminance is greater than 0.5 (light color), otherwise false (dark color)
        return luminance > 0.5
    }
    // Saving schedules
    func saveSchedules(schedules: [Schedule]) {
        if let encoded = try? JSONEncoder().encode(schedules) {
            schedulesData = encoded
        }
    }
    
    // Retrieving schedules
    func loadSchedules() -> [Schedule] {
        if let decoded = try? JSONDecoder().decode([Schedule].self, from: schedulesData) {
            return decoded
        }
        return []
    }
    func updateDay() -> String {
        guard let userDefaults = UserDefaults(suiteName: "group..com.jackrvu.mavhub.dayViews") else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let announced_date = formatter.string(from:  Date())
        return userDefaults.dictionary(forKey: "daysDictionary")?[announced_date] as? String ?? ""
    }
    
    func carrierView(letter: String, carrier: String, time: String, rowHeight: CGFloat, darkMode: Bool) -> some View {
        let color = loadColor()
        let isLightBackground = !isLight(color: color)
        let textColor = Color.white
        let fontSize = rowHeight * 0.4 // Adjust font size based on row height
        
        return HStack {
            ZStack {
                RoundedRectangle(cornerRadius: rowHeight * 0.2)
                    .fill(color)
                    .frame(width: rowHeight * 0.6, height: rowHeight * 0.6) // Scale rectangle size
                Text(" \(letter) ").bold()
                    .font(.system(size: fontSize))
                    .fontDesign(.rounded)
                    .foregroundColor(!isLightBackground ? .black : .white)
            }
            Text(carrier.isEmpty ? "Free" : carrier)
                .font(.system(size: fontSize))
                .foregroundStyle(textColor)
                .lineLimit(1) // Restrict to a single line
                .truncationMode(.tail)
            Spacer()
            Text(time)
                .font(.system(size: fontSize * 0.9)) // Slightly smaller for time
                .foregroundColor(textColor)
        }
        .padding(.horizontal)
    }

    
    func notCarrierView(image: String, type: String, time: String, rowHeight: CGFloat, darkMode: Bool) -> some View {
        let color = loadColor()
        let isLightBackground = !isLight(color: color)
        // let textColor: Color = isLightBackground ? .black : .white
        let textColor = Color.white
        let fontSize = rowHeight * 0.4 // Adjust font size based on row height
        
        // Dynamic image sizes
        let iconSize = rowHeight * 0.4
        
        return HStack {
            ZStack {
                RoundedRectangle(cornerRadius: rowHeight * 0.2)
                    .fill(color)
                    .frame(width: rowHeight * 0.6, height: rowHeight * 0.6) // Scale rectangle size
                Image(systemName: image)
                    .resizable()
                    .scaledToFit()
                    .foregroundStyle(!isLightBackground ? .black : .white)
                    .frame(width: iconSize, height: iconSize) // Scale image size dynamically
            }
            Text(type.isEmpty ? defaultType(for: image) : type)
                .font(.system(size: fontSize))
                .foregroundColor(textColor)
                .lineLimit(1) // Restrict to a single line
                .truncationMode(.tail)
            Spacer()
            Text(time)
                .font(.system(size: fontSize * 0.9)) // Slightly smaller for time
                .foregroundColor(textColor)
        }
        .padding(.horizontal)
    }
    
    // Helper to return default text for empty types
    func defaultType(for image: String) -> String {
        switch image {
        case "music.note":
            return "Ensemble"
        case "paintbrush":
            return "Da Vinci"
        default:
            return "N/A"
        }
    }
}

struct Schedule: Codable, Identifiable {
    var id: UUID = UUID()

    var name: String
    var aCarrier: String
    var bCarrier: String
    var cCarrier: String
    var dCarrier: String
    var eCarrier: String
    var fCarrier: String
    var gCarrier: String
    var d1Morning: String
    var d1Vinci: String
    var d2Morning: String
    var d3Vinci: String
    var d4Morning: String
    var d5Morning: String
    var d6Morning: String
    var d6Vinci: String
    var d7Morning: String
    var grade: Int
}

extension Color {
    func getRGBComponents() -> (red: CGFloat, green: CGFloat, blue: CGFloat, opacity: CGFloat)? {
        #if canImport(UIKit)
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0

        guard uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha) else {
            return nil
        }

        return (red, green, blue, alpha)
        #else
        return nil
        #endif
    }
}

let defaults = UserDefaults(suiteName: "group..com.jackrvu.mavhub.dayViews")!

@available(iOS 17.0, *)
struct ClassWidget: Widget {
    let kind: String = "ClassWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: ConfigurationAppIntent.self,
            provider: Provider()
        ) { entry in
            ClassWidgetEntryView(entry: entry)
                .containerBackground(.black, for: .widget)
        }
        .configurationDisplayName("Class Schedule")
        .description("View your daily class schedule")
        .supportedFamilies([.systemLarge])
    }
}

@available(iOSApplicationExtension 17.0, *)
extension ConfigurationAppIntent {
    fileprivate static var smiley: ConfigurationAppIntent {
        return ConfigurationAppIntent(favoriteEmoji: "😀")
    }
    
    fileprivate static var starEyes: ConfigurationAppIntent {
        return ConfigurationAppIntent(favoriteEmoji: "🤩")
    }
}

@available(iOS 17.0, *)
#Preview(as: .systemLarge) {
    ClassWidget()
} timeline: {
    ClassEntry(date:  Date(), configuration: .smiley)
}
