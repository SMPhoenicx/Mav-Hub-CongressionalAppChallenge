//
//  DayViews.swift
//  NewMavApp
//
//  Created by Suman Muppavarapu on 8/22/24.
//
import SwiftUI

struct OpenAssignmentsButton: View {
    // The date to pass to AssignmentsView
    let date: Date
    
    // Optional: Customize button appearance
    let label: String
    let buttonColor: Color
    @State var radii: [CGFloat] = [30, 30, 30, 30] //top left, bottom left, bottom right, top right
    // State to manage the presentation of AssignmentsView
    @State private var showAssignmentsView = false
    
    var body: some View {
        Button(action: {
            showAssignmentsView = true
        }) {
            HStack {
                Spacer()
                Image(systemName: "book")
                    .font(.system(size: 16, weight: .bold))
                Text(label)
                    .font(.headline)
                Spacer()
            }
            .foregroundColor(buttonColor.isLight() ? Color.black : Color.white)
            .padding()
            .background(buttonColor)
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
        .sheet(isPresented: $showAssignmentsView) {
            AssignmentsView(initialDate: date)
        }
    }
}

struct DayViews: View{
    @Binding var dayValue:String // deleted the binding thing for dateValue, let's see if that's an issue
    @AppStorage("sportsView") var sportsView: Bool = true
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    @AppStorage("schedules", store: defaults) private var schedulesData: Data = Data()
    @AppStorage("usingSchedule", store: defaults) private var usingSchedule:Int = 0
    
    @EnvironmentObject var calendarModel: CalendarViewModel
    
    @State private var currentDate = Date()
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
    
    var dateValue: Date
    var showAdds: Bool = true
    
    var body: some View {
        let color = loadColor() ?? Color.orange
        let isInSameWeek = Calendar.current.isDate(dateValue, equalTo: Date(), toGranularity: .weekOfYear)
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
        VStack {
            let eventsForDate = getEventsForDate(dateValue)
            let eventTypes = getEventTypesForDate(dateValue)
            
            if !eventTypes.isEmpty {
                HStack(spacing: 0) {
                    ForEach(Array(eventTypes.sorted(by: { $0.rawValue < $1.rawValue })), id: \.self) { eventType in
                        Rectangle()
                            .fill(colorForEventType(eventType))
                            .frame(maxWidth: .infinity)
                    }
                }
                .frame(width: 80, height: 10) // or whatever height you want
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
            else {
                Text("No events today")
            }
            if !middleSchoolMode{
                switch dayValue {
                case "1":
                    Text("Day 1")
                        .font(.title2)
                        .foregroundStyle(darkMode ? Color.white:Color.black)
                    VStack {
                        CarrierView(title: d1Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: aCarrier, time: "8:30-9:30", carrier: "A")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: cCarrier, time: "9:35-10:55", carrier: "C")
                        grayDivider()
                        CarrierView(title: d1Vinci, defaultText: "Da Vinci", time: "11:00-11:50", session: "davinci")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: bCarrier, time: "11:55-12:55", carrier: "B")
                        if isInSameWeek && showAdds{
                            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "1:00-1:25", session: "lunch", dateValue: dateValue, isInNavigationView: false)
                                .padding(.horizontal, 5.0)
                        } else{
                            CarrierView(title: "Lunch", defaultText: "Lunch", time: "1:00-1:25", session: "lunch")
                        }
                        CarrierViewWithCircle(carrierTitle: dCarrier, time: "1:30-2:30", carrier: "D")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: fCarrier, time: "2:35-3:35", carrier: "F")
                        grayDivider()
                    }
                case "2":
                    Text("Day 2")
                        .font(.title2)
                        .foregroundStyle(darkMode ? Color.white:Color.black)
                    VStack {
                        CarrierView(title: d2Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: eCarrier, time: "8:30-9:30", carrier: "E")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: gCarrier, time: "9:35-10:55", carrier: "G")
                        grayDivider()
                        CarrierView(title: "Advisory", defaultText: "Advisory", time: "11:00-11:25", session: "advisory")
                        grayDivider()
                        CarrierView(title: "Tutorials & Meetings", defaultText: "Tutorials & Meetings", time: "11:25-11:40", session: "meetings")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: fCarrier, time: "11:45-12:45", carrier: "F")
                        if isInSameWeek && showAdds{
                            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "12:50-1:25", session: "lunch", dateValue: dateValue,isInNavigationView:  false)
                                .padding(.horizontal, 5.0)
                        } else{
                            CarrierView(title: "Lunch", defaultText: "Lunch", time: "12:50-1:25", session: "lunch")
                        }
                        CarrierViewWithCircle(carrierTitle: bCarrier, time: "1:30-2:30", carrier: "B")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: cCarrier, time: "2:35-3:35", carrier: "C")
                        grayDivider()
                    }
                    
                case "3":
                    Text("Day 3")
                        .font(.title2)
                        .foregroundStyle(darkMode ? Color.white:Color.black)
                    VStack {
                        CarrierViewWithCircle(carrierTitle: dCarrier, time: "8:30-9:30", carrier: "D")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: aCarrier, time: "9:35-10:55", carrier: "A")
                        grayDivider()
                        CarrierView(title: d3Vinci, defaultText: "Da Vinci", time: "11:00-11:50", session: "davinci")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: eCarrier, time: "11:55-12:55", carrier: "E")
                        if isInSameWeek && showAdds{
                            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "1:00-1:25", session: "lunch", dateValue: dateValue, isInNavigationView: false)
                                .padding(.horizontal, 5.0)
                        } else{
                            CarrierView(title: "Lunch", defaultText: "Lunch", time: "1:00-1:25", session: "lunch")
                        }
                        CarrierViewWithCircle(carrierTitle: cCarrier, time: "1:30-2:30", carrier: "C")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: gCarrier, time: "2:35-3:35", carrier: "G")
                        grayDivider()
                    }
                case "4":
                    Text("Day 4")
                        .font(.title2)
                        .foregroundStyle(darkMode ? Color.white:Color.black)
                    VStack {
                        CarrierView(title: d4Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: eCarrier, time: "8:30-9:30", carrier: "E")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: fCarrier, time: "9:35-10:55", carrier: "F")
                        grayDivider()
                        CarrierView(title: "Chapel / Advisory", defaultText: "Chapel / Advisory", time: "11:00-11:40", session: "chapel")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: bCarrier, time: "11:45-12:45", carrier: "B")
                        if isInSameWeek && showAdds{
                            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "12:50-1:25", session: "lunch", dateValue: dateValue, isInNavigationView: false)
                                .padding(.horizontal, 5.0)
                        } else{
                            CarrierView(title: "Lunch", defaultText: "Lunch", time: "12:50-1:25", session: "lunch")
                        }
                        CarrierViewWithCircle(carrierTitle: aCarrier, time: "1:30-2:30", carrier: "A")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: dCarrier, time: "2:35-3:35", carrier: "D")
                        grayDivider()
                    }
                case "5":
                    Text("Day 5")
                        .font(.title2)
                        .foregroundStyle(darkMode ? Color.white:Color.black)
                    VStack {
                        CarrierView(title: d5Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: gCarrier, time: "8:30-9:30", carrier: "G")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: bCarrier, time: "9:35-10:55", carrier: "B")
                        grayDivider()
                        CarrierView(title: "Advisory", defaultText: "Advisory", time: "11:00-11:15", session: "advisory")
                        grayDivider()
                        CarrierView(title: "Tutorials & Meetings", defaultText: "Tutorials & Meetings", time: "11:15-11:40", session: "meetings")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: cCarrier, time: "11:45-12:45", carrier: "C")
                        if isInSameWeek && showAdds{
                            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "12:50-1:25", session: "lunch", dateValue: dateValue, isInNavigationView: false)
                        } else{
                            CarrierView(title: "Lunch", defaultText: "Lunch", time: "12:50-1:25", session: "lunch")
                        }
                        CarrierViewWithCircle(carrierTitle: fCarrier, time: "1:30-2:30", carrier: "F")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: aCarrier, time: "2:35-3:35", carrier: "A")
                        grayDivider()
                    }
                case "6":
                    Text("Day 6")
                        .font(.title2)
                        .foregroundStyle(darkMode ? Color.white:Color.black)
                    VStack {
                        CarrierView(title: d6Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: cCarrier, time: "8:30-9:30", carrier: "C")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: dCarrier, time: "9:35-10:55", carrier: "D")
                        grayDivider()
                        CarrierView(title: d6Vinci, defaultText: "Da Vinci", time: "11:00-11:50", session: "davinci")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: bCarrier, time: "11:55-12:55", carrier: "B")
                        if isInSameWeek && showAdds{
                            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "1:00-1:25", session: "lunch", dateValue: dateValue, isInNavigationView: false)
                                .padding(.horizontal, 5.0)
                        } else{
                            CarrierView(title: "Lunch", defaultText: "Lunch", time: "1:00-1:25", session: "lunch")
                        }
                        CarrierViewWithCircle(carrierTitle: eCarrier, time: "1:30-2:30", carrier: "E")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: gCarrier, time: "2:35-3:35", carrier: "G")
                        grayDivider()
                    }
                case "7":
                    Text("Day 7")
                        .font(.title2)
                        .foregroundStyle(darkMode ? Color.white:Color.black)
                    VStack {
                        CarrierView(title: d7Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: fCarrier, time: "8:30-9:30", carrier: "F")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: eCarrier, time: "9:35-10:55", carrier: "E")
                        grayDivider()
                        CarrierView(title: "Assembly / Advisory", defaultText: "Assembly / Advisory", time: "11:00-11:40", session: "assembly")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: aCarrier, time: "11:45-12:45", carrier: "A")
                        if isInSameWeek && showAdds{
                            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "12:50-1:25", session: "lunch", dateValue: dateValue,isInNavigationView:  false)
                                .padding(.horizontal, 5.0)
                        } else{
                            CarrierView(title: "Lunch", defaultText: "Lunch", time: "12:55-1:25", session: "lunch")
                        }
                        CarrierViewWithCircle(carrierTitle: gCarrier, time: "1:30-2:30", carrier: "G")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: dCarrier, time: "2:35-3:35", carrier: "D")
                        grayDivider()
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
            } else{
                switch dayValue {
                case "1":
                    Text("Day 1")
                        .font(.title2)
                        .foregroundStyle(darkMode ? Color.white:Color.black)
                    VStack {
                        CarrierView(title: d1Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: dCarrier, time: "8:30-9:30", carrier: "D")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: cCarrier, time: "9:35-10:35", carrier: "C")
                        grayDivider()
                        CarrierView(title: "Break", defaultText: "Break", time: "10:35-11:00", session: "Break")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: fCarrier, time: "11:00-12:00", carrier: "F")
                        if isInSameWeek && showAdds{
                            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "12:00-12:40", session: "lunch", dateValue: dateValue, isInNavigationView: false)
                                .padding(.horizontal, 5.0)
                        } else{
                            CarrierView(title: "Lunch", defaultText: "Lunch", time: "12:00-12:40", session: "lunch")
                        }
                        CarrierView(title: d1Vinci, defaultText: "Da Vinci", time: "12:40-1:25", session: "davinci")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: aCarrier, time: "1:30-2:30", carrier: "A")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: eCarrier, time: "2:35-3:35", carrier: "E")
                        grayDivider()
                    }
                case "2":
                    Text("Day 2")
                        .font(.title2)
                        .foregroundStyle(darkMode ? Color.white:Color.black)
                    VStack {
                        CarrierView(title: d2Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                        grayDivider()
                        CarrierView(title: "Chapel / Advisory", defaultText: "Chapel / Advisory", time: "8:30-9:30", session: "chapel")
                        grayDivider()
                        if sixthGradeMode{
                            CarrierView(title: "PE", defaultText:"PE", time: "9:30-10:30", session: "PE")
                           }
                        else{
                            CarrierViewWithCircle(carrierTitle: aCarrier, time: "9:30-10:30", carrier: "A")
                        }
                        grayDivider()
                        CarrierView(title: "Break", defaultText: "Break", time: "10:30-10:45", session: "Break")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: eCarrier, time: "10:45-11:45", carrier: "E")
                        if isInSameWeek && showAdds{
                            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "11:45-12:25", session: "lunch", dateValue: dateValue, isInNavigationView: false)
                                .padding(.horizontal, 5.0)
                        } else{
                            CarrierView(title: "Lunch", defaultText: "Lunch", time: "11:45-12:25", session: "lunch")
                        }
                        CarrierViewWithCircle(carrierTitle: bCarrier, time: "12:25-1:25", carrier: "B")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: cCarrier, time: "1:30-2:30", carrier: "C")
                        grayDivider()
                        if sixthGradeMode{
                            CarrierViewWithCircle(carrierTitle: aCarrier, time: "2:35-3:35", carrier: "A")
                        }
                        else{
                            CarrierView(title: "Athletics", defaultText: "Athletics", time: "2:35-3:45", session: "athletics")
                        }
                        grayDivider()
                    }
                    
                case "3":
                    Text("Day 3")
                        .font(.title2)
                        .foregroundStyle(darkMode ? Color.white:Color.black)
                    VStack {
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: bCarrier, time: "8:30-9:30", carrier: "B")
                        grayDivider()
                        if sixthGradeMode{
                            CarrierView(title: "PE", defaultText:"PE", time: "9:35-10:35", session: "PE")
                           }
                        else{
                            CarrierViewWithCircle(carrierTitle: dCarrier, time: "9:35-10:35", carrier: "D")
                        }
                        grayDivider()
                        CarrierView(title: "Break", defaultText: "Break", time: "10:35-11:00", session: "Break")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: cCarrier, time: "11:00-12:00", carrier: "C")
                        if isInSameWeek && showAdds{
                            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "12:00-12:40", session: "lunch", dateValue: dateValue, isInNavigationView: false)
                                .padding(.horizontal, 5.0)
                        } else{
                            CarrierView(title: "Lunch", defaultText: "Lunch", time: "12:00-12:40", session: "lunch")
                        }
                        CarrierView(title: "Extended Advisory", defaultText: "Extended Advisory", time: "12:40-1:25", session: "advisory")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: fCarrier, time: "1:30-2:30", carrier: "F")
                        grayDivider()
                        if sixthGradeMode{
                            CarrierViewWithCircle(carrierTitle: dCarrier, time: "2:35-3:35", carrier: "D")
                        }
                        else{
                            CarrierView(title: "Athletics", defaultText: "Athletics", time: "2:35-3:45", session: "athletics")
                        }
                        grayDivider()
                    }
                case "4":
                    Text("Day 4")
                        .font(.title2)
                        .foregroundStyle(darkMode ? Color.white:Color.black)
                    VStack {
                        CarrierView(title: d4Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: eCarrier, time: "8:30-9:30", carrier: "E")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: bCarrier, time: "9:35-10:35", carrier: "B")
                        grayDivider()
                        CarrierView(title: "Break", defaultText: "Break", time: "10:35-11:00", session: "Break")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: fCarrier, time: "11:00-12:00", carrier: "F")
                        if isInSameWeek && showAdds{
                            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "12:00-12:40", session: "lunch", dateValue: dateValue, isInNavigationView: false)
                                .padding(.horizontal, 5.0)
                        } else{
                            CarrierView(title: "Lunch", defaultText: "Lunch", time: "12:00-12:40", session: "lunch")
                        }
                        CarrierView(title: d3Vinci, defaultText: "Da Vinci", time: "12:40-1:25", session: "davinci")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: aCarrier, time: "1:30-2:30", carrier: "A")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: dCarrier, time: "2:35-3:35", carrier: "D")
                        grayDivider()
                    }
                case "5":
                    Text("Day 5")
                        .font(.title2)
                        .foregroundStyle(darkMode ? Color.white:Color.black)
                    VStack {
                        CarrierView(title: d5Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: fCarrier, time: "8:30-9:30", carrier: "F")
                        grayDivider()
                        if sixthGradeMode{
                            CarrierView(title: "PE", defaultText:"PE", time: "9:35-10:35", session: "PE")
                           }
                        else{
                            CarrierViewWithCircle(carrierTitle: aCarrier, time: "9:35-10:35", carrier: "A")
                        }
                        grayDivider()
                        CarrierView(title: "Break", defaultText: "Break", time: "10:35-11:00", session: "Break")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: cCarrier, time: "11:00-12:00", carrier: "C")
                        if isInSameWeek && showAdds{
                            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "12:00-12:40", session: "lunch", dateValue: dateValue, isInNavigationView: false)
                                .padding(.horizontal, 5.0)
                        } else{
                            CarrierView(title: "Lunch", defaultText: "Lunch", time: "12:00-12:40", session: "lunch")
                        }
                        CarrierView(title: "SEL", defaultText: "SEL", time: "12:40-1:25", session: "advisory")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: eCarrier, time: "1:30-2:30", carrier: "E")
                        grayDivider()
                        if sixthGradeMode{
                            CarrierViewWithCircle(carrierTitle: aCarrier, time: "2:35-3:35", carrier: "A")
                        }
                        else{
                            CarrierView(title: "Athletics", defaultText: "Athletics", time: "2:35-3:45", session: "athletics")
                        }
                        grayDivider()
                    }
                case "6":
                    Text("Day 6")
                        .font(.title2)
                        .foregroundStyle(darkMode ? Color.white:Color.black)
                    VStack {
                        CarrierView(title: d6Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: cCarrier, time: "8:30-9:30", carrier: "C")
                        grayDivider()
                        if sixthGradeMode{
                            CarrierView(title: "PE", defaultText:"PE", time: "9:35-10:35", session: "PE")
                           }
                        else{
                            CarrierViewWithCircle(carrierTitle: bCarrier, time: "9:35-10:35", carrier: "B")
                        }
                        grayDivider()
                        CarrierView(title: "Break", defaultText: "Break", time: "10:35-11:00", session: "Break")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: eCarrier, time: "11:00-12:00", carrier: "E")
                        if isInSameWeek && showAdds{
                            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "12:00-12:40", session: "lunch", dateValue: dateValue, isInNavigationView: false)
                                .padding(.horizontal, 5.0)
                        } else{
                            CarrierView(title: "Lunch", defaultText: "Lunch", time: "12:00-12:40", session: "lunch")
                        }
                        CarrierView(title: d6Vinci, defaultText: "Da Vinci", time: "12:40-1:25", session: "davinci")
                        
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: dCarrier, time: "1:30-2:30", carrier: "D")
                        grayDivider()
                        if sixthGradeMode{
                            CarrierViewWithCircle(carrierTitle: bCarrier, time: "2:35-3:35", carrier: "B")
                        }
                        else{
                            CarrierView(title: "Athletics", defaultText: "Athletics", time: "2:35-3:45", session: "athletics")
                        }
                        grayDivider()
                    }
                case "7":
                    Text("Day 7")
                        .font(.title2)
                        .foregroundStyle(darkMode ? Color.white:Color.black)
                    VStack {
                        CarrierView(title: d7Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: aCarrier, time: "8:30-9:30", carrier: "A")
                        grayDivider()
                        if sixthGradeMode{
                            CarrierView(title: "PE", defaultText:"PE", time: "9:35-10:35", session: "PE")
                           }
                        else{
                            CarrierViewWithCircle(carrierTitle: fCarrier, time: "9:35-10:35", carrier: "F")
                        }
                        grayDivider()
                        CarrierView(title: "Break", defaultText: "Break", time: "10:35-11:00", session: "Break")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: dCarrier, time: "11:00-12:00", carrier: "D")
                        if isInSameWeek && showAdds{
                            LunchButtonView(title: "Lunch", defaultText: "Lunch", time: "12:00-12:40", session: "lunch", dateValue: dateValue, isInNavigationView: false)
                                .padding(.horizontal, 5.0)
                        } else{
                            CarrierView(title: "Lunch", defaultText: "Lunch", time: "12:00-12:40", session: "lunch")
                        }
                        CarrierView(title: "Assembly", defaultText: "Assembly", time: "12:40-1:25", session: "assembly")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: bCarrier, time: "1:30-2:30", carrier: "B")
                        grayDivider()
                        if sixthGradeMode{
                            CarrierViewWithCircle(carrierTitle: fCarrier, time: "2:35-3:35", carrier: "F")
                        }
                        else{
                            CarrierView(title: "Athletics", defaultText: "Athletics", time: "2:35-3:45", session: "athletics")
                        }
                        grayDivider()
                    }
                default:
                    VStack(){
                        Text("No School Today!")
                            .font(.title)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundStyle(darkMode ? Color.white:Color.black)
                            .padding(.top, 10.0)
                            .padding(.bottom, 5.0)
                        Text("🎉")
                            .font(.system(size:50))
                            .fontWeight(.bold)
                    }
                }
            }
            if showAdds && sportsView{
                HStack(spacing: 2) {
                            OpenAssignmentsButton(
                                date: dateValue,
                                label: "Tasks",
                                buttonColor: color, radii: [30, 30, 0, 0]
                            )
                            .frame(maxWidth: .infinity)

                            SportsButtonView(
                                title: "Events",
                                defaultText: "Events",
                                time: "",
                                session: "sports",
                                dateValue: dateValue,
                                isInNavigationView: false, radii: [0, 0, 30, 30]
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
            } else if showAdds{
                OpenAssignmentsButton(
                    date: dateValue,
                    label: "Tasks",
                    buttonColor: color
                )
                .padding()
            }
        }
        .onAppear {
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
        .foregroundColor(.white)
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
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
    func grayDivider() -> some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.gray)
            .padding(.vertical, 3)
    }
    
    // MARK: - Event Helper Functions

    private func getEventsForDate(_ date: Date) -> [CalendarEvent] {
        let allEvents = calendarModel.athleticsEvents +
                       calendarModel.artsEvents +
                       calendarModel.importantDates +
                       calendarModel.events
        
        return allEvents.filter { event in
            isDateInEventRange(selectedDate: date, event: event)
        }
    }

    private func isDateInEventRange(selectedDate: Date, event: CalendarEvent) -> Bool {
        let calendar = Calendar.current
        
        guard let endDate = event.endDate else {
            return calendar.isDate(selectedDate, inSameDayAs: event.startDate)
        }
        
        if calendar.isDate(event.startDate, inSameDayAs: endDate) {
            return calendar.isDate(selectedDate, inSameDayAs: event.startDate)
        }
        
        let startOfSelectedDay = calendar.startOfDay(for: selectedDate)
        let startOfEventStart = calendar.startOfDay(for: event.startDate)
        let startOfEventEnd = calendar.startOfDay(for: endDate)
        
        return startOfSelectedDay >= startOfEventStart && startOfSelectedDay <= startOfEventEnd
    }

    private func getEventTypesForDate(_ date: Date) -> Set<CalendarType> {
        let events = getEventsForDate(date)
        return Set(events.map { $0.type })
    }

    private func colorForEventType(_ type: CalendarType) -> Color {
        switch type {
        case .athletics:
            return .purple
        case .arts:
            return .orange
        case .importantDates:
            return .red
        case .events:
            return .green
        case .schedule:
            return .blue
        }
    }
}
#Preview{
   TabControl()
}



struct DayViewsNoEvent: View{
    @Binding var dayValue:String // deleted the binding thing for dateValue, let's see if that's an issue
    @AppStorage("sportsView") var sportsView: Bool = true
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    @AppStorage("schedules", store: defaults) private var schedulesData: Data = Data()
    @AppStorage("usingSchedule", store: defaults) private var usingSchedule:Int = 0
    
    @State private var currentDate = Date()
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
    
    var showAdds: Bool = true
    
    var body: some View {
        let color = loadColor() ?? Color.orange
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
        VStack {
            
            if !middleSchoolMode{
                switch dayValue {
                case "1":
                    Text("Day 1")
                        .font(.title2)
                        .foregroundStyle(darkMode ? Color.white:Color.black)
                    VStack {
                        CarrierView(title: d1Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: aCarrier, time: "8:30-9:30", carrier: "A")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: cCarrier, time: "9:35-10:55", carrier: "C")
                        grayDivider()
                        CarrierView(title: d1Vinci, defaultText: "Da Vinci", time: "11:00-11:50", session: "davinci")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: bCarrier, time: "11:55-12:55", carrier: "B")
                        CarrierView(title: "Lunch", defaultText: "Lunch", time: "1:00-1:25", session: "lunch")
                        CarrierViewWithCircle(carrierTitle: dCarrier, time: "1:30-2:30", carrier: "D")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: fCarrier, time: "2:35-3:35", carrier: "F")
                        grayDivider()
                    }
                case "2":
                    Text("Day 2")
                        .font(.title2)
                        .foregroundStyle(darkMode ? Color.white:Color.black)
                    VStack {
                        CarrierView(title: d2Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: eCarrier, time: "8:30-9:30", carrier: "E")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: gCarrier, time: "9:35-10:55", carrier: "G")
                        grayDivider()
                        CarrierView(title: "Advisory", defaultText: "Advisory", time: "11:00-11:25", session: "advisory")
                        grayDivider()
                        CarrierView(title: "Tutorials & Meetings", defaultText: "Tutorials & Meetings", time: "11:25-11:40", session: "meetings")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: fCarrier, time: "11:45-12:45", carrier: "F")
                        CarrierView(title: "Lunch", defaultText: "Lunch", time: "12:50-1:25", session: "lunch")
                        CarrierViewWithCircle(carrierTitle: bCarrier, time: "1:30-2:30", carrier: "B")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: cCarrier, time: "2:35-3:35", carrier: "C")
                        grayDivider()
                    }
                    
                case "3":
                    Text("Day 3")
                        .font(.title2)
                        .foregroundStyle(darkMode ? Color.white:Color.black)
                    VStack {
                        CarrierViewWithCircle(carrierTitle: dCarrier, time: "8:30-9:30", carrier: "D")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: aCarrier, time: "9:35-10:55", carrier: "A")
                        grayDivider()
                        CarrierView(title: d3Vinci, defaultText: "Da Vinci", time: "11:00-11:50", session: "davinci")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: eCarrier, time: "11:55-12:55", carrier: "E")
                        CarrierView(title: "Lunch", defaultText: "Lunch", time: "1:00-1:25", session: "lunch")
                        CarrierViewWithCircle(carrierTitle: cCarrier, time: "1:30-2:30", carrier: "C")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: gCarrier, time: "2:35-3:35", carrier: "G")
                        grayDivider()
                    }
                case "4":
                    Text("Day 4")
                        .font(.title2)
                        .foregroundStyle(darkMode ? Color.white:Color.black)
                    VStack {
                        CarrierView(title: d4Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: eCarrier, time: "8:30-9:30", carrier: "E")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: fCarrier, time: "9:35-10:55", carrier: "F")
                        grayDivider()
                        CarrierView(title: "Chapel / Advisory", defaultText: "Chapel / Advisory", time: "11:00-11:40", session: "chapel")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: bCarrier, time: "11:45-12:45", carrier: "B")
                        CarrierView(title: "Lunch", defaultText: "Lunch", time: "12:50-1:25", session: "lunch")
                        CarrierViewWithCircle(carrierTitle: aCarrier, time: "1:30-2:30", carrier: "A")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: dCarrier, time: "2:35-3:35", carrier: "D")
                        grayDivider()
                    }
                case "5":
                    Text("Day 5")
                        .font(.title2)
                        .foregroundStyle(darkMode ? Color.white:Color.black)
                    VStack {
                        CarrierView(title: d5Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: gCarrier, time: "8:30-9:30", carrier: "G")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: bCarrier, time: "9:35-10:55", carrier: "B")
                        grayDivider()
                        CarrierView(title: "Advisory", defaultText: "Advisory", time: "11:00-11:15", session: "advisory")
                        grayDivider()
                        CarrierView(title: "Tutorials & Meetings", defaultText: "Tutorials & Meetings", time: "11:15-11:40", session: "meetings")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: cCarrier, time: "11:45-12:45", carrier: "C")
                        CarrierView(title: "Lunch", defaultText: "Lunch", time: "12:50-1:25", session: "lunch")
                        CarrierViewWithCircle(carrierTitle: fCarrier, time: "1:30-2:30", carrier: "F")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: aCarrier, time: "2:35-3:35", carrier: "A")
                        grayDivider()
                    }
                case "6":
                    Text("Day 6")
                        .font(.title2)
                        .foregroundStyle(darkMode ? Color.white:Color.black)
                    VStack {
                        CarrierView(title: d6Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: cCarrier, time: "8:30-9:30", carrier: "C")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: dCarrier, time: "9:35-10:55", carrier: "D")
                        grayDivider()
                        CarrierView(title: d6Vinci, defaultText: "Da Vinci", time: "11:00-11:50", session: "davinci")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: bCarrier, time: "11:55-12:55", carrier: "B")
                        CarrierView(title: "Lunch", defaultText: "Lunch", time: "1:00-1:25", session: "lunch")
                        CarrierViewWithCircle(carrierTitle: eCarrier, time: "1:30-2:30", carrier: "E")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: gCarrier, time: "2:35-3:35", carrier: "G")
                        grayDivider()
                    }
                case "7":
                    Text("Day 7")
                        .font(.title2)
                        .foregroundStyle(darkMode ? Color.white:Color.black)
                    VStack {
                        CarrierView(title: d7Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: fCarrier, time: "8:30-9:30", carrier: "F")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: eCarrier, time: "9:35-10:55", carrier: "E")
                        grayDivider()
                        CarrierView(title: "Assembly / Advisory", defaultText: "Assembly / Advisory", time: "11:00-11:40", session: "assembly")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: aCarrier, time: "11:45-12:45", carrier: "A")
                        CarrierView(title: "Lunch", defaultText: "Lunch", time: "12:55-1:25", session: "lunch")
                        CarrierViewWithCircle(carrierTitle: gCarrier, time: "1:30-2:30", carrier: "G")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: dCarrier, time: "2:35-3:35", carrier: "D")
                        grayDivider()
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
            } else{
                switch dayValue {
                case "1":
                    Text("Day 1")
                        .font(.title2)
                        .foregroundStyle(darkMode ? Color.white:Color.black)
                    VStack {
                        CarrierView(title: d1Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: dCarrier, time: "8:30-9:30", carrier: "D")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: cCarrier, time: "9:35-10:35", carrier: "C")
                        grayDivider()
                        CarrierView(title: "Break", defaultText: "Break", time: "10:35-11:00", session: "Break")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: fCarrier, time: "11:00-12:00", carrier: "F")
                        CarrierView(title: "Lunch", defaultText: "Lunch", time: "12:00-12:40", session: "lunch")
                        CarrierView(title: d1Vinci, defaultText: "Da Vinci", time: "12:40-1:25", session: "davinci")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: aCarrier, time: "1:30-2:30", carrier: "A")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: eCarrier, time: "2:35-3:35", carrier: "E")
                        grayDivider()
                    }
                case "2":
                    Text("Day 2")
                        .font(.title2)
                        .foregroundStyle(darkMode ? Color.white:Color.black)
                    VStack {
                        CarrierView(title: d2Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                        grayDivider()
                        CarrierView(title: "Chapel / Advisory", defaultText: "Chapel / Advisory", time: "8:30-9:30", session: "chapel")
                        grayDivider()
                        if sixthGradeMode{
                            CarrierView(title: "PE", defaultText:"PE", time: "9:30-10:30", session: "PE")
                           }
                        else{
                            CarrierViewWithCircle(carrierTitle: aCarrier, time: "9:30-10:30", carrier: "A")
                        }
                        grayDivider()
                        CarrierView(title: "Break", defaultText: "Break", time: "10:30-10:45", session: "Break")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: eCarrier, time: "10:45-11:45", carrier: "E")
                        CarrierView(title: "Lunch", defaultText: "Lunch", time: "11:45-12:25", session: "lunch")
                        CarrierViewWithCircle(carrierTitle: bCarrier, time: "12:25-1:25", carrier: "B")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: cCarrier, time: "1:30-2:30", carrier: "C")
                        grayDivider()
                        if sixthGradeMode{
                            CarrierViewWithCircle(carrierTitle: aCarrier, time: "2:35-3:35", carrier: "A")
                        }
                        else{
                            CarrierView(title: "Athletics", defaultText: "Athletics", time: "2:35-3:45", session: "athletics")
                        }
                        grayDivider()
                    }
                    
                case "3":
                    Text("Day 3")
                        .font(.title2)
                        .foregroundStyle(darkMode ? Color.white:Color.black)
                    VStack {
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: bCarrier, time: "8:30-9:30", carrier: "B")
                        grayDivider()
                        if sixthGradeMode{
                            CarrierView(title: "PE", defaultText:"PE", time: "9:35-10:35", session: "PE")
                           }
                        else{
                            CarrierViewWithCircle(carrierTitle: dCarrier, time: "9:35-10:35", carrier: "D")
                        }
                        grayDivider()
                        CarrierView(title: "Break", defaultText: "Break", time: "10:35-11:00", session: "Break")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: cCarrier, time: "11:00-12:00", carrier: "C")
                        CarrierView(title: "Lunch", defaultText: "Lunch", time: "12:00-12:40", session: "lunch")
                        CarrierView(title: "Extended Advisory", defaultText: "Extended Advisory", time: "12:40-1:25", session: "advisory")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: fCarrier, time: "1:30-2:30", carrier: "F")
                        grayDivider()
                        if sixthGradeMode{
                            CarrierViewWithCircle(carrierTitle: dCarrier, time: "2:35-3:35", carrier: "D")
                        }
                        else{
                            CarrierView(title: "Athletics", defaultText: "Athletics", time: "2:35-3:45", session: "athletics")
                        }
                        grayDivider()
                    }
                case "4":
                    Text("Day 4")
                        .font(.title2)
                        .foregroundStyle(darkMode ? Color.white:Color.black)
                    VStack {
                        CarrierView(title: d4Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: eCarrier, time: "8:30-9:30", carrier: "E")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: bCarrier, time: "9:35-10:35", carrier: "B")
                        grayDivider()
                        CarrierView(title: "Break", defaultText: "Break", time: "10:35-11:00", session: "Break")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: fCarrier, time: "11:00-12:00", carrier: "F")
                        CarrierView(title: "Lunch", defaultText: "Lunch", time: "12:00-12:40", session: "lunch")
                        CarrierView(title: d3Vinci, defaultText: "Da Vinci", time: "12:40-1:25", session: "davinci")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: aCarrier, time: "1:30-2:30", carrier: "A")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: dCarrier, time: "2:35-3:35", carrier: "D")
                        grayDivider()
                    }
                case "5":
                    Text("Day 5")
                        .font(.title2)
                        .foregroundStyle(darkMode ? Color.white:Color.black)
                    VStack {
                        CarrierView(title: d5Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: fCarrier, time: "8:30-9:30", carrier: "F")
                        grayDivider()
                        if sixthGradeMode{
                            CarrierView(title: "PE", defaultText:"PE", time: "9:35-10:35", session: "PE")
                           }
                        else{
                            CarrierViewWithCircle(carrierTitle: aCarrier, time: "9:35-10:35", carrier: "A")
                        }
                        grayDivider()
                        CarrierView(title: "Break", defaultText: "Break", time: "10:35-11:00", session: "Break")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: cCarrier, time: "11:00-12:00", carrier: "C")
                        CarrierView(title: "Lunch", defaultText: "Lunch", time: "12:00-12:40", session: "lunch")
                        CarrierView(title: "SEL", defaultText: "SEL", time: "12:40-1:25", session: "advisory")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: eCarrier, time: "1:30-2:30", carrier: "E")
                        grayDivider()
                        if sixthGradeMode{
                            CarrierViewWithCircle(carrierTitle: aCarrier, time: "2:35-3:35", carrier: "A")
                        }
                        else{
                            CarrierView(title: "Athletics", defaultText: "Athletics", time: "2:35-3:45", session: "athletics")
                        }
                        grayDivider()
                    }
                case "6":
                    Text("Day 6")
                        .font(.title2)
                        .foregroundStyle(darkMode ? Color.white:Color.black)
                    VStack {
                        CarrierView(title: d6Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: cCarrier, time: "8:30-9:30", carrier: "C")
                        grayDivider()
                        if sixthGradeMode{
                            CarrierView(title: "PE", defaultText:"PE", time: "9:35-10:35", session: "PE")
                           }
                        else{
                            CarrierViewWithCircle(carrierTitle: bCarrier, time: "9:35-10:35", carrier: "B")
                        }
                        grayDivider()
                        CarrierView(title: "Break", defaultText: "Break", time: "10:35-11:00", session: "Break")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: eCarrier, time: "11:00-12:00", carrier: "E")
                        CarrierView(title: "Lunch", defaultText: "Lunch", time: "12:00-12:40", session: "lunch")
                        CarrierView(title: d6Vinci, defaultText: "Da Vinci", time: "12:40-1:25", session: "davinci")
                        
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: dCarrier, time: "1:30-2:30", carrier: "D")
                        grayDivider()
                        if sixthGradeMode{
                            CarrierViewWithCircle(carrierTitle: bCarrier, time: "2:35-3:35", carrier: "B")
                        }
                        else{
                            CarrierView(title: "Athletics", defaultText: "Athletics", time: "2:35-3:45", session: "athletics")
                        }
                        grayDivider()
                    }
                case "7":
                    Text("Day 7")
                        .font(.title2)
                        .foregroundStyle(darkMode ? Color.white:Color.black)
                    VStack {
                        CarrierView(title: d7Morning, defaultText: "Morning Ensembles", time: "7:30-8:15", session: "ensembles")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: aCarrier, time: "8:30-9:30", carrier: "A")
                        grayDivider()
                        if sixthGradeMode{
                            CarrierView(title: "PE", defaultText:"PE", time: "9:35-10:35", session: "PE")
                           }
                        else{
                            CarrierViewWithCircle(carrierTitle: fCarrier, time: "9:35-10:35", carrier: "F")
                        }
                        grayDivider()
                        CarrierView(title: "Break", defaultText: "Break", time: "10:35-11:00", session: "Break")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: dCarrier, time: "11:00-12:00", carrier: "D")
                        CarrierView(title: "Lunch", defaultText: "Lunch", time: "12:00-12:40", session: "lunch")
                        CarrierView(title: "Assembly", defaultText: "Assembly", time: "12:40-1:25", session: "assembly")
                        grayDivider()
                        CarrierViewWithCircle(carrierTitle: bCarrier, time: "1:30-2:30", carrier: "B")
                        grayDivider()
                        if sixthGradeMode{
                            CarrierViewWithCircle(carrierTitle: fCarrier, time: "2:35-3:35", carrier: "F")
                        }
                        else{
                            CarrierView(title: "Athletics", defaultText: "Athletics", time: "2:35-3:45", session: "athletics")
                        }
                        grayDivider()
                    }
                default:
                    VStack(){
                        Text("No School Today!")
                            .font(.title)
                            .fontWeight(.semibold)
                            .fontDesign(.rounded)
                            .foregroundStyle(darkMode ? Color.white:Color.black)
                            .padding(.top, 10.0)
                            .padding(.bottom, 5.0)
                        Text("🎉")
                            .font(.system(size:50))
                            .fontWeight(.bold)
                    }
                }
            }
            if showAdds && sportsView{
                HStack(spacing: 2) {
                            OpenAssignmentsButton(
                                date: currentDate,
                                label: "Tasks",
                                buttonColor: color, radii: [30, 30, 0, 0]
                            )
                            .frame(maxWidth: .infinity)

                            SportsButtonView(
                                title: "Events",
                                defaultText: "Events",
                                time: "",
                                session: "sports",
                                dateValue: currentDate,
                                isInNavigationView: false, radii: [0, 0, 30, 30]
                            )
                            .frame(maxWidth: .infinity)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
            } else if showAdds{
                OpenAssignmentsButton(
                    date: currentDate,
                    label: "Tasks",
                    buttonColor: color
                )
                .padding()
            }
        }
        .onAppear {
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
        .foregroundColor(.white)
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
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
    func grayDivider() -> some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.gray)
            .padding(.vertical, 3)
    }
}
