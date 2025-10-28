//
//  TabView.swift
//  NewMavApp
//
//  Created by Suman Muppavarapu on 9/1/24.
//
// jvu was here

import SwiftUI
@MainActor
struct TabControl: View {
    @State private var tabSelection: TabBarItem = .home
    @StateObject private var dismissalManager = TabDismissalManager()
    @StateObject var calendarModel = CalendarViewModel()
    // Individual paths for each tab
    @State private var homePath = NavigationPath()
    @State private var calendarPath = NavigationPath()

    @AppStorage("scheduleView") private var scheduleView: Bool = false
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true

    var body: some View {
        TabBarContainer(selection: $tabSelection) {
            HomePageView(navigationPath: $homePath)
                .tabBarItem(tab: .home, selection: $tabSelection)

            CalView(tabSelection: $tabSelection, navigationPath: $calendarPath)
                .tabBarItem(tab: .calendar, selection: $tabSelection)

            if !scheduleView {
                ScheduleHomeView(tabSelection: $tabSelection)
                    .tabBarItem(tab: .schedule, selection: $tabSelection)
            } else {
                WheelSchedule()
                    .tabBarItem(tab: .schedule, selection: $tabSelection)
            }
            
            ChatView()
                .tabBarItem(tab: .chat, selection: $tabSelection)
        }
        .preferredColorScheme(darkMode ? .dark : .light)
        .environmentObject(calendarModel)
        .environmentObject(dismissalManager)
        .onAppear {
            // Register all dismiss actions
            dismissalManager.registerDismissAction(for: .home) {
                homePath = NavigationPath()
            }
            dismissalManager.registerDismissAction(for: .calendar) {
                calendarPath = NavigationPath()
            }
        }
    }
}

#Preview {
    TabControl()
}
