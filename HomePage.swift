//
//  CarrierViewWithCircle.swift
//  NewMavApp
//
//  Created by Suman Muppavarapu on 8/22/24.
//

import SwiftUI
import Foundation
import Combine
import WidgetKit

struct HomePageView: View {
    @EnvironmentObject private var calendarModel:CalendarViewModel
    @StateObject private var versionChecker = AppVersionChecker()
    @State private var showForceUpdate = false
    @State private var days:[String:String] = UserDefaults(suiteName:"group..com.jackrvu.mavhub.dayViews")!.dictionary(forKey: "daysDictionary") as? [String: String] ?? [:]

    @State private var scheduleArr: [Schedule] = []
    @State private var curSchedule: Schedule = Schedule(
        name: "",
        assignmentsLink: "",
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
        grade: 0,
        assignments: []
    )
    //passed to dropdownmenu, allows tap outside close
    @State var isMenuOpen = false
    //for date change updates
    @Environment(\.scenePhase) private var scenePhase
    @State private var currentDisplayDate = Date()
    
    @AppStorage("updatePage") private var updatePage: Bool = true
    @AppStorage("sportsView") var sportsView: Bool = true
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    @AppStorage("schedules", store: defaults) private var schedulesData: Data = Data()
    @AppStorage("usingSchedule", store: defaults) private var usingSchedule:Int = 0
    @Binding var navigationPath:NavigationPath
    
    var body: some View {
        let color = loadColor() ?? Color.orange
        let isLight = color.isLight()
        let textColor:Color = darkMode ? .white:.black
        let middleSchoolMode = curSchedule.grade != 0
       
        NavigationStack(path: $navigationPath) {
            ZStack(alignment: .top){
                ScrollView {
                    VStack {
                        Text(curSchedule.name.isEmpty ? "Your Schedule" : curSchedule.name + "'s Schedule")
                            .foregroundStyle(darkMode ? .white:.black)
                            .fontWeight(.semibold)
                            .font(.largeTitle)
                            .fontDesign(.rounded)
                            .padding(.bottom, 5.0)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .truncationMode(.middle)
                        let day = updateDay()
                        Text("\(dayOfWeek(from: currentDisplayDate)),  \(monthDayString(from: currentDisplayDate))")
                            .font(.title2)
                            .fontDesign(.rounded)
                            .foregroundStyle(darkMode ? .white:.black)
                            .padding(.bottom, 5.0)
                        if !day.isEmpty{
                            Text("\(day)")
                                .font(.title2)
                                .fontDesign(.rounded)
                                .foregroundStyle(isLight == darkMode ? color:textColor)
                                .padding(.bottom, 5.0)
                        }
                        let dayValue = String(updateDay()).suffix(1)
                        if !middleSchoolMode {
                            switch dayValue {
                            case "1": day1Schedule()
                            case "2": day2Schedule()
                            case "3": day3Schedule()
                            case "4": day4Schedule()
                            case "5": day5Schedule()
                            case "6": day6Schedule()
                            case "7": day7Schedule()
                            default: noSchoolView()
                            }
                        } else {
                            switch dayValue {
                            case "1": msDay1Schedule()
                            case "2": msDay2Schedule()
                            case "3": msDay3Schedule()
                            case "4": msDay4Schedule()
                            case "5": msDay5Schedule()
                            case "6": msDay6Schedule()
                            case "7": msDay7Schedule()
                            default: noSchoolView()
                            }
                        }
                        if sportsView{
                            HStack(spacing: 2) {
                                    OpenAssignmentsButton(
                                        date: Date(),
                                        label: "Tasks",
                                        buttonColor: color, radii: [30, 30, 0, 0]
                                    )
                                    .frame(maxWidth: .infinity)
                                    SportsButtonView(
                                        title: "Events",
                                        defaultText: "Events",
                                        time: "",
                                        session: "sports",
                                        dateValue: Date(),
                                        isInNavigationView: false, radii: [0, 0, 30, 30]
                                    )
                                    .frame(maxWidth: .infinity)
                                }
                        } // in the future, I can allow the user to disable the assignments button
                        else {
                            OpenAssignmentsButton(
                                date: Date(),
                                label: "View Tasks",
                                buttonColor: color
                            )
                        }
                        
                        Color.clear.frame(height: 30)
                    }
                    .padding()
                    .padding(.bottom, 50)
                    .foregroundStyle(.white)
                    .navigationBarBackButtonHidden(true)
                }
                .offset(y: 45)
                .padding(.top, -10)
                if(isMenuOpen){
                    Color.black.opacity(0.3)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture {
                            withAnimation {
                                isMenuOpen = false
                            }
                        }
                }
                ZStack{
                    HStack(alignment: .center){
                        ExtraDropMenu(isMenuOpen: $isMenuOpen)
                        Spacer()
                        NavigationLink(destination: SettingsView()) {
                            ZStack{
                                Circle()
                                    .fill(color)
                                    .frame(width: 35, height: 35)
                                Image(systemName: "gear")
                                    .resizable()
                                    .frame(width: 25, height: 25)
                                    .foregroundStyle(isLight ? .black : .white)
                            }.frame(width: 64)
                                .padding(.leading)
                        }
                    }
                    Text("Today")
                        .foregroundStyle(isLight == darkMode ? color:textColor)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .font(.headline)
                        .padding(.horizontal, 10.0)
                }
                
                .padding(.top, -10)
            }
        }
        .tint(color)
        .onReceive(versionChecker.$updateRequired) { updateRequired in
                        showForceUpdate = updateRequired
                    }
        .onAppear {
            versionChecker.checkForUpdate()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                versionChecker.checkForUpdate()
            }
        }
        .alert("Update Available", isPresented: $showForceUpdate) {
            Button("Update Now") {
                if let appStoreURL = versionChecker.appStoreURL,
                   let url = URL(string: appStoreURL) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Later", role: .cancel) { }
                        
        } message: {
            Text("A new version of the app is available. Please update to continue using the app.")
        }
        .onAppear {
            scheduleArr = loadSchedules()
            if usingSchedule >= scheduleArr.count {
                usingSchedule = 0
            }
            if !scheduleArr.isEmpty {
                    curSchedule = scheduleArr[usingSchedule]
                }
            
            if days.isEmpty {
                Task{
                    await calendarModel.forceRefresh()
                }
            }
            
            days = UserDefaults(suiteName:"group..com.jackrvu.mavhub.dayViews")!.dictionary(forKey: "daysDictionary") as? [String: String] ?? [:]
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                // Refresh everything when app becomes active
                currentDisplayDate = Date()
                scheduleArr = loadSchedules()
                if usingSchedule >= scheduleArr.count {
                    usingSchedule = 0
                }
                if !scheduleArr.isEmpty && usingSchedule < scheduleArr.count {
                    curSchedule = scheduleArr[usingSchedule]
                }
                if days.isEmpty {
                    Task {
                        await calendarModel.forceRefresh()
                    }
                }

                days = UserDefaults(suiteName:"group..com.jackrvu.mavhub.dayViews")!.dictionary(forKey: "daysDictionary") as? [String: String] ?? [:]
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
        .sheet(isPresented: $updatePage) {
                UpdatePage()
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding()
        }
    }

    // Non-school day view
    @ViewBuilder
    func noSchoolView() -> some View {
        let soundPlayer = SoundPlayer()
        VStack {
            Text("No School Today!")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .foregroundStyle(darkMode ? .white : .black)
                .padding(.top, 10.0)
                .padding(.bottom, 5.0)
            Button(action: {
                soundPlayer.loadSound(named: "celebrate")
                soundPlayer.playSound()
            }) {
                Text("🎉")
                    .font(.system(size:50))
                    .fontWeight(.bold)
            }
        }
    }
    private func saveColor(color: Color) {
        let uiColor = UIColor(color) // Convert Color to UIColor
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false)
            let defaults = UserDefaults(suiteName: "group..com.jackrvu.mavhub.dayViews")!
            defaults.set(data, forKey: "selectedColor")
        } catch {
            print("Failed to archive color: \(error)")
        }
    }
    // Upper School Day Schedules
    @ViewBuilder
    func day1Schedule() -> some View {
        VStack {
            CarrierView(title: curSchedule.d1Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.aCarrier, time: "8:30-9:30", carrier: "A")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.cCarrier, time: "9:35-10:55", carrier: "C")
            grayDivider()
            CarrierView(title: curSchedule.d1Vinci, defaultText: "Da Vinci", time: "11:00-11:50", session: "davinci")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.bCarrier, time: "11:55-12:55", carrier: "B")
            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "1:00-1:25", session: "lunch", dateValue: Date(), isInNavigationView: false)
            CarrierViewWithCircle(carrierTitle: curSchedule.dCarrier, time: "1:30-2:30", carrier: "D")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.fCarrier, time: "2:35-3:35", carrier: "F")
            grayDivider()
        }
    }

    @ViewBuilder
    func day2Schedule() -> some View {
        VStack {
            CarrierView(title: curSchedule.d2Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.eCarrier, time: "8:30-9:30", carrier: "E")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.gCarrier, time: "9:35-10:55", carrier: "G")
            grayDivider()
            CarrierView(title: "Advisory", defaultText: "Advisory", time: "11:00-11:25", session: "advisory")
            grayDivider()
            CarrierView(title: "Tutorials & Meetings", defaultText: "Tutorials & Meetings", time: "11:25-11:40", session: "meetings")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.fCarrier, time: "11:45-12:45", carrier: "F")
            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "12:50-1:25", session: "lunch", dateValue: Date(), isInNavigationView: false)
            CarrierViewWithCircle(carrierTitle: curSchedule.bCarrier, time: "1:30-2:30", carrier: "B")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.cCarrier, time: "2:35-3:35", carrier: "C")
            grayDivider()
        }
    }

    @ViewBuilder
    func day3Schedule() -> some View {
        VStack {
            CarrierViewWithCircle(carrierTitle: curSchedule.dCarrier, time: "8:30-9:30", carrier: "D")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.aCarrier, time: "9:35-10:55", carrier: "A")
            grayDivider()
            CarrierView(title: curSchedule.d3Vinci, defaultText: "Da Vinci", time: "11:00-11:50", session: "davinci")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.eCarrier, time: "11:55-12:55", carrier: "E")
            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "1:00-1:25", session: "lunch", dateValue: Date(), isInNavigationView: false)
            CarrierViewWithCircle(carrierTitle: curSchedule.cCarrier, time: "1:30-2:30", carrier: "C")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.gCarrier, time: "2:35-3:35", carrier: "G")
            grayDivider()
        }
    }

    @ViewBuilder
    func day4Schedule() -> some View {
        VStack {
            CarrierView(title: curSchedule.d4Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.eCarrier, time: "8:30-9:30", carrier: "E")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.fCarrier, time: "9:35-10:55", carrier: "F")
            grayDivider()
            CarrierView(title: "Chapel / Advisory", defaultText: "Chapel / Advisory", time: "11:00-11:40", session: "chapel")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.bCarrier, time: "11:45-12:45", carrier: "B")
            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "12:50-1:25", session: "lunch", dateValue: Date(), isInNavigationView: false)
            CarrierViewWithCircle(carrierTitle: curSchedule.aCarrier, time: "1:30-2:30", carrier: "A")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.dCarrier, time: "2:35-3:35", carrier: "D")
            grayDivider()
        }
    }

    @ViewBuilder
    func day5Schedule() -> some View {
        VStack {
            CarrierView(title: curSchedule.d5Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.gCarrier, time: "8:30-9:30", carrier: "G")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.bCarrier, time: "9:35-10:55", carrier: "B")
            grayDivider()
            CarrierView(title: "Advisory", defaultText: "Advisory", time: "11:00-11:15", session: "advisory")
            grayDivider()
            CarrierView(title: "Tutorials & Meetings", defaultText: "Tutorials & Meetings", time: "11:15-11:40", session: "meetings")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.cCarrier, time: "11:45-12:45", carrier: "C")
            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "12:50-1:25", session: "lunch", dateValue: Date(), isInNavigationView: false)
            CarrierViewWithCircle(carrierTitle: curSchedule.fCarrier, time: "1:30-2:30", carrier: "F")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.aCarrier, time: "2:35-3:35", carrier: "A")
            grayDivider()
        }
    }

    @ViewBuilder
    func day6Schedule() -> some View {
        VStack {
            CarrierView(title: curSchedule.d6Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.cCarrier, time: "8:30-9:30", carrier: "C")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.dCarrier, time: "9:35-10:55", carrier: "D")
            grayDivider()
            CarrierView(title: curSchedule.d6Vinci, defaultText: "Da Vinci", time: "11:00-11:50", session: "davinci")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.bCarrier, time: "11:55-12:55", carrier: "B")
            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "1:00-1:25", session: "lunch", dateValue: Date(), isInNavigationView: false)
            CarrierViewWithCircle(carrierTitle: curSchedule.eCarrier, time: "1:30-2:30", carrier: "E")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.gCarrier, time: "2:35-3:35", carrier: "G")
            grayDivider()
        }
    }

    @ViewBuilder
    func day7Schedule() -> some View {
        VStack {
            CarrierView(title: curSchedule.d7Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.fCarrier, time: "8:30-9:30", carrier: "F")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.eCarrier, time: "9:35-10:55", carrier: "E")
            grayDivider()
            CarrierView(title: "Assembly / Advisory", defaultText: "Assembly / Advisory", time: "11:00-11:40", session: "assembly")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.aCarrier, time: "11:45-12:45", carrier: "A")
            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "12:55-1:25", session: "lunch", dateValue: Date(), isInNavigationView: false)
            CarrierViewWithCircle(carrierTitle: curSchedule.gCarrier, time: "1:30-2:30", carrier: "G")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.dCarrier, time: "2:35-3:35", carrier: "D")
            grayDivider()
        }
    }

    // Middle School Day Schedules
    @ViewBuilder
    func msDay1Schedule() -> some View {
        VStack {
            CarrierView(title: curSchedule.d1Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.dCarrier, time: "8:30-9:30", carrier: "D")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.cCarrier, time: "9:35-10:35", carrier: "C")
            grayDivider()
            CarrierView(title: "Break", defaultText: "Break", time: "10:35-11:00", session: "Break")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.fCarrier, time: "11:00-12:00", carrier: "F")
            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "12:00-12:40", session: "lunch", dateValue: Date(), isInNavigationView: false)
            CarrierView(title: curSchedule.d1Vinci, defaultText: "Da Vinci", time: "12:40-1:25", session: "davinci")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.aCarrier, time: "1:30-2:30", carrier: "A")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.eCarrier, time: "2:35-3:35", carrier: "E")
            grayDivider()
        }
    }

    @ViewBuilder
    func msDay2Schedule() -> some View {
        VStack {
            CarrierView(title: curSchedule.d2Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
            grayDivider()
            CarrierView(title: "Chapel / Advisory", defaultText: "Chapel / Advisory", time: "8:30-9:30", session: "chapel")
            grayDivider()
            if curSchedule.grade == 2 {
                CarrierView(title: "PE", defaultText:"PE", time: "9:30-10:30", session: "PE")
            } else {
                CarrierViewWithCircle(carrierTitle: curSchedule.aCarrier, time: "9:30-10:30", carrier: "A")
            }
            grayDivider()
            CarrierView(title: "Break", defaultText: "Break", time: "10:30-10:45", session: "Break")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.eCarrier, time: "10:45-11:45", carrier: "E")
            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "11:45-12:25", session: "lunch", dateValue: Date(), isInNavigationView: false)
            CarrierViewWithCircle(carrierTitle: curSchedule.bCarrier, time: "12:25-1:25", carrier: "B")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.cCarrier, time: "1:30-2:30", carrier: "C")
            grayDivider()
            if curSchedule.grade == 2 {
                CarrierViewWithCircle(carrierTitle: curSchedule.aCarrier, time: "2:35-3:35", carrier: "A")
            } else {
                CarrierView(title: "Athletics", defaultText: "Athletics", time: "2:35-3:45", session: "athletics")
            }
            grayDivider()
        }
    }

    @ViewBuilder
    func msDay3Schedule() -> some View {
        VStack {
            CarrierViewWithCircle(carrierTitle: curSchedule.bCarrier, time: "8:30-9:30", carrier: "B")
            grayDivider()
            if curSchedule.grade == 2 {
                CarrierView(title: "PE", defaultText:"PE", time: "9:35-10:35", session: "PE")
            } else {
                CarrierViewWithCircle(carrierTitle: curSchedule.dCarrier, time: "9:35-10:35", carrier: "D")
            }
            grayDivider()
            CarrierView(title: "Break", defaultText: "Break", time: "10:35-11:00", session: "Break")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.cCarrier, time: "11:00-12:00", carrier: "C")
            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "12:00-12:40", session: "lunch", dateValue: Date(), isInNavigationView: false)
            CarrierView(title: "Extended Advisory", defaultText: "Extended Advisory", time: "12:40-1:25", session: "advisory")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.fCarrier, time: "1:30-2:30", carrier: "F")
            grayDivider()
            if curSchedule.grade == 2 {
                CarrierViewWithCircle(carrierTitle: curSchedule.dCarrier, time: "2:35-3:35", carrier: "D")
            } else {
                CarrierView(title: "Athletics", defaultText: "Athletics", time: "2:35-3:45", session: "athletics")
            }
            grayDivider()
        }
    }

    @ViewBuilder
    func msDay4Schedule() -> some View {
        VStack {
            CarrierView(title: curSchedule.d4Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.eCarrier, time: "8:30-9:30", carrier: "E")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.bCarrier, time: "9:35-10:35", carrier: "B")
            grayDivider()
            CarrierView(title: "Break", defaultText: "Break", time: "10:35-11:00", session: "Break")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.fCarrier, time: "11:00-12:00", carrier: "F")
            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "12:00-12:40", session: "lunch", dateValue: Date(), isInNavigationView: false)
            CarrierView(title: curSchedule.d3Vinci, defaultText: "Da Vinci", time: "12:40-1:25", session: "davinci")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.aCarrier, time: "1:30-2:30", carrier: "A")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.dCarrier, time: "2:35-3:35", carrier: "D")
            grayDivider()
        }
    }

    @ViewBuilder
    func msDay5Schedule() -> some View {
        VStack {
            CarrierView(title: curSchedule.d5Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.fCarrier, time: "8:30-9:30", carrier: "F")
            grayDivider()
            if curSchedule.grade == 2 {
                CarrierView(title: "PE", defaultText:"PE", time: "9:35-10:35", session: "PE")
            } else {
                CarrierViewWithCircle(carrierTitle: curSchedule.aCarrier, time: "9:35-10:35", carrier: "A")
            }
            grayDivider()
            CarrierView(title: "Break", defaultText: "Break", time: "10:35-11:00", session: "Break")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.cCarrier, time: "11:00-12:00", carrier: "C")
            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "12:00-12:40", session: "lunch", dateValue: Date(), isInNavigationView: false)
            CarrierView(title: "SEL", defaultText: "SEL", time: "12:40-1:25", session: "advisory")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.eCarrier, time: "1:30-2:30", carrier: "E")
            grayDivider()
            if curSchedule.grade == 2 {
                CarrierViewWithCircle(carrierTitle: curSchedule.aCarrier, time: "2:35-3:35", carrier: "A")
            } else {
                CarrierView(title: "Athletics", defaultText: "Athletics", time: "2:35-3:45", session: "athletics")
            }
            grayDivider()
        }
    }

    @ViewBuilder
    func msDay6Schedule() -> some View {
        VStack {
            CarrierView(title: curSchedule.d6Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.cCarrier, time: "8:30-9:30", carrier: "C")
            grayDivider()
            if curSchedule.grade == 2 {
                CarrierView(title: "PE", defaultText:"PE", time: "9:35-10:35", session: "PE")
            } else {
                CarrierViewWithCircle(carrierTitle: curSchedule.bCarrier, time: "9:35-10:35", carrier: "B")
            }
            grayDivider()
            CarrierView(title: "Break", defaultText: "Break", time: "10:35-11:00", session: "Break")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.eCarrier, time: "11:00-12:00", carrier: "E")
            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "12:00-12:40", session: "lunch", dateValue: Date(), isInNavigationView: false)
            CarrierView(title: curSchedule.d6Vinci, defaultText: "Da Vinci", time: "12:40-1:25", session: "davinci")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.dCarrier, time: "1:30-2:30", carrier: "D")
            grayDivider()
            if curSchedule.grade == 2 {
                CarrierViewWithCircle(carrierTitle: curSchedule.bCarrier, time: "2:35-3:35", carrier: "B")
            } else {
                CarrierView(title: "Athletics", defaultText: "Athletics", time: "2:35-3:45", session: "athletics")
            }
            grayDivider()
        }
    }

    @ViewBuilder
    func msDay7Schedule() -> some View {
        VStack {
            CarrierView(title: curSchedule.d7Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.aCarrier, time: "8:30-9:30", carrier: "A")
            grayDivider()
            if curSchedule.grade == 2 {
                CarrierView(title: "PE", defaultText:"PE", time: "9:35-10:35", session: "PE")
            } else {
                CarrierViewWithCircle(carrierTitle: curSchedule.fCarrier, time: "9:35-10:35", carrier: "F")
            }
            grayDivider()
            CarrierView(title: "Break", defaultText: "Break", time: "10:35-11:00", session: "Break")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.dCarrier, time: "11:00-12:00", carrier: "D")
            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "12:00-12:40", session: "lunch", dateValue: Date(), isInNavigationView: false)
            CarrierView(title: "Assembly", defaultText: "Assembly", time: "12:40-1:25", session: "assembly")
            grayDivider()
            CarrierViewWithCircle(carrierTitle: curSchedule.bCarrier, time: "1:30-2:30", carrier: "B")
            grayDivider()
            if curSchedule.grade == 2 {
                CarrierViewWithCircle(carrierTitle: curSchedule.fCarrier, time: "2:35-3:35", carrier: "F")
            } else {
                CarrierView(title: "Athletics", defaultText: "Athletics", time: "2:35-3:45", session: "athletics")
            }
            grayDivider()
        }
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
    
    private func loadColor() -> Color? {
            guard !selectedColorData.isEmpty else {
                return nil
            }
            
            do {
                if let uiColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: selectedColorData) {
                    return Color(uiColor)
                }
            } catch {
                print("Failed to unarchive color: \(error)")
            }
            return nil
        }

    func dayOfWeek(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE" // "EEEE" gives the full name of the day (e.g., "Monday")
        return formatter.string(from: date)
    }
    
    func monthDayString(from date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d" // "MMMM" for full month name, "d" for day of the month
        return formatter.string(from: date)
    }
    func grayDivider() -> some View {
        Rectangle()
            .frame(height: 1)
            .foregroundStyle(Color(.gray))
            .padding(3)
    }

    func updateDay() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let announced_date = formatter.string(from: currentDisplayDate)
        
        return days[announced_date] ?? ""
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
    
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
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
        let textColor: Color = color.isLight() ? .black : .white
        NavigationLink(destination: LunchView(dateValue: dateValue)) {
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
        .onTapGesture{
            withAnimation(.easeInOut){}
        }
    }
}

struct CarrierViewWithCircle: View {
    let carrierTitle: String
    let defaultText: String = "Free Carrier"
    let time: String
    let carrier: String
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
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
        let isLight = color.isLight()
        let textColor:Color = darkMode ? .white:.black
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading){
                HStack{
                    Text(carrierTitle.isEmpty ? defaultText : carrierTitle)
                        .font(.headline)
                        .foregroundStyle(darkMode ? .white:.black)
                }
                HStack{
                    Text(time)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundStyle(isLight == darkMode ? color:textColor)
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
                    .foregroundStyle(isLight ? .black:.white)
            }
            .frame(width: 64)  // Ensures consistent spacing for the circle
        }

    }
}

struct ChatButtonView: View {
    @State private var isActive: Bool = false
    @State var radii: [CGFloat] = [30, 30, 30, 30] //top left, bottom left, bottom right, top right
    
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()

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
        let textColor = color.isLight() ? Color.black : Color.white

        Button(action: {
            isActive = true
        }) {
            HStack(alignment: .center, spacing: 16) {
                Spacer()
                Image(systemName: "message")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(textColor)

                Text("Community Talk")
                    .font(.headline)
                    .foregroundColor(textColor)
                Spacer()
            }
            .padding()
            .background(color)
            .clipShape(
                .rect(
                    topLeadingRadius: radii[0],
                    bottomLeadingRadius: radii[1],
                    bottomTrailingRadius: radii[2],
                    topTrailingRadius: radii[3]
                )
            )
            .shadow(radius: 2)
        }
        .buttonStyle(PlainButtonStyle()) // Prevents default button styling
        .sheet(isPresented: $isActive) {
            ChatView()
        }
        .onTapGesture{
            withAnimation(.easeInOut){
        
            }
        }
    }
}
struct SportsButtonView: View {
    var title: String
    var defaultText: String
    var time: String
    var session: String
    var dateValue: Date
    var isInNavigationView: Bool
    @State private var isActive: Bool = false
    @State var radii: [CGFloat] = [30, 30, 30, 30] //top left, bottom left, bottom right, top right
    
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()

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
        let textColor = color.isLight() ? Color.black : Color.white

        Button(action: {
            isActive = true
        }) {
            HStack(alignment: .center, spacing: 8) {
                Spacer()
                Image(systemName: "calendar")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(textColor)

                Text(title.isEmpty ? defaultText : title)
                    .font(.headline)
                    .foregroundColor(textColor)
                Spacer()
            }
            .padding()
            .background(color)
            .clipShape(
                .rect(
                    topLeadingRadius: radii[0],
                    bottomLeadingRadius: radii[1],
                    bottomTrailingRadius: radii[2],
                    topTrailingRadius: radii[3]
                )
            )
            .shadow(radius: 2)
        }
        .buttonStyle(PlainButtonStyle()) // Prevents default button styling
        .sheet(isPresented: $isActive) {
            SportsView(dateValue: dateValue)
        }
        .onTapGesture{
            withAnimation(.easeInOut){
        
            }
        }
    }
}



struct CarrierView: View {
    var title: String
    var defaultText: String
    var time: String
    var session: String
    
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    
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
        let isLight = color.isLight()
        let textColor:Color = darkMode ? .white:.black
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
                            .foregroundStyle(darkMode ? .white:.black)
                    }
                    HStack{
                        Text(time)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(
                                isLight == darkMode ? color:textColor)
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
                        .foregroundStyle(isLight ? .black:.white)
                }
                .frame(width: 64)  // Ensures consistent spacing for the circle'
            }
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
            return "person.3.fill"
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
        case "athletics":
            return "figure.run"
        case "pe":
            return "baseball"
        case "break":
            return "cup.and.saucer"
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
        case "athletics":
            return 22.0
        case "pe":
            return 22.0
        case "break":
            return 25.0
        default:
            return 20.0 // Fallback icon (or leave blank)
        }
    }
    private var heightVal:CGFloat{
        switch session.lowercased() {
        case "advisory":
            return 23.0
        case "assembly":
            return 19.0
        case "meetings":
            return 20.0
        case "chapel":
            return 24.0
        case "athletics":
            return 25.0
        default:
            return 22.0 // Fallback icon (or leave blank)
        }
    }
}

#Preview{
    TabControl()
}
