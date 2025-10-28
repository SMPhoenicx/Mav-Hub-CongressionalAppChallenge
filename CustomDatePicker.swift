//
//  CustomDatePicker.swift
//  NewMavApp
//
//  Created by Suman Muppavarapu on 9/1/24.
//
// jvu was here

import SwiftUI

struct DateValue: Identifiable {
    var id = UUID().uuidString
    var day: Int
    var date: Date
}

struct CustomDatePicker: View{
    @Binding var currentDate: Date
    
    @Binding var tabSelection: TabBarItem
    
    @State var monthDate: Date = Date()
    @State var index: String = "0"
    
    @State var curMonth: Int = 0
    
    // Use CalendarViewModel instead of CSV data
    @EnvironmentObject var calendarModel: CalendarViewModel
    
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
    
    var body: some View{
        let color = loadColor() ?? Color.orange
        ScrollView{
            VStack{
                VStack(spacing: 15){
                    
                    let days : [String] = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
                    // Define the range from July 2025 to September 2026
                    let calendar = Calendar.current
                    let startOfRange = calendar.date(from: DateComponents(year: 2025, month: 7))!
                    let endOfRange = calendar.date(from: DateComponents(year: 2026, month: 9))!
                    
                    let isPreviousDisabled = calendar.date(byAdding: .month, value: curMonth - 1, to: Date())! < startOfRange
                    let isNextDisabled = calendar.date(byAdding: .month, value: curMonth + 1, to: Date())! > endOfRange
                    
                    HStack(spacing: 20) {
                        VStack(alignment: .leading) {
                            Text(extraDate()[0])
                                .font(.caption)
                                .fontWeight(.semibold)
                            Text(extraDate()[1])
                                .font(.title2.bold())
                        }
                        Spacer(minLength: 0)
                        
                        Button {
                            withAnimation {
                                curMonth -= 1
                            }
                        } label: {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundStyle(color.isLight() == darkMode ? color: Color.blue)
                        }
                        .disabled(isPreviousDisabled)
                        
                        Button {
                            withAnimation {
                                curMonth += 1
                            }
                        } label: {
                            Image(systemName: "chevron.right")
                                .font(.title2)
                                .foregroundStyle(color.isLight() == darkMode ? color: Color.blue)
                        }
                        .disabled(isNextDisabled)
                    }
                    .padding(.top, 30)
                    .padding(.horizontal)
                    
                    HStack(spacing: 0) {
                        ForEach(days, id: \.self){ day in
                            if(day != "Sun" && day != "Sat"){
                                Text(day)
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                            }
                            else{
                                Text(day)
                                    .font(.callout)
                                    .fontWeight(.semibold)
                                    .foregroundStyle(Color(.gray))
                                    .frame(maxWidth: .infinity)
                            }
                        }
                    }
                    .padding(.top, -10)
                    
                    let columns = Array(repeating: GridItem(.flexible()), count: 7)
                    
                    LazyVGrid(columns: columns, spacing: 2) {
                        ForEach(extractDate()){value in
                            if value.day != -1{
                                CardView(value: value)
                                    .background(
                                        RoundedRectangle(cornerRadius: 10.0)
                                            .fill(color.gradient)
                                            .padding(.horizontal, 8)
                                            .opacity(isSameDay(date1: value.date, date2: currentDate) ? 1: 0)
                                    )
                                    .onTapGesture{
                                        currentDate = value.date
                                        index = getRotateDay(date: value.date)
                                    }
                            }
                            else{
                                CardView(value: value)
                            }
                        }
                    }
                    
                }
                .background{
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(.systemGray5))
                        .padding(.top, 20)
                }
                .padding(.horizontal)
                .onChange(of: curMonth) { val in
                    monthDate = getCurrentMonth()
                }
                let day = Calendar.current.component(.day, from: currentDate)
                let month = getMonth(date: currentDate)
                Text("\(month) \(day)")
                    .font(.title3)
                DayViews(dayValue: $index, dateValue: currentDate)
                Color.clear.frame(height: 30)
            }
            .padding(.top, 5)
            .padding(.bottom, 60)
            .onChange(of: tabSelection) { newTab in
                if newTab != .schedule {
                    currentDate = Date()
                    curMonth = 0
                    index = getRotateDay(date: currentDate)
                }
            }
        }
        .onAppear{
            // Update index when view appears and set initial month
            index = getRotateDay(date: currentDate)
            monthDate = getCurrentMonth()
        }
        .toolbarBackground(.hidden, for: .tabBar)
    }
    func getMonth(date:Date) -> String{
        let monthFormat = DateFormatter()
        monthFormat.dateFormat = "MMMM"
        return monthFormat.string(from: date)
    }
    @ViewBuilder
    func CardView(value: DateValue)-> some View{
        let color = loadColor() ?? Color.orange
        let text2Color: Color = color.isLight() ? .black:.white
        let textColor: Color = darkMode ? .white:.black
        VStack{
            let index = getRotateDay(date: value.date)
            if value.day != -1{
                if isWeekend(date: value.date) || index.isEmpty {
                    Text("\(value.day)")
                        .font(.headline.bold())
                        .foregroundStyle(
                            (isSameDay(date1: Date(), date2: value.date) && !isSameDay(date1: value.date, date2: currentDate)) ? color :
                                        (isSameDay(date1: value.date, date2: currentDate) ? text2Color : Color.gray)
                                    )
                        .frame(maxWidth: .infinity)
                }
                else if value.day != -1{
                    ZStack{
                        Text("\(value.day)")
                            .font(.headline.bold())
                            .foregroundStyle(
                                (isSameDay(date1: Date(), date2: value.date) && !isSameDay(date1: value.date, date2: currentDate)) ? (color.isLight() == darkMode) ? color:textColor :
                                            (isSameDay(date1: value.date, date2: currentDate) ? text2Color : textColor)
                                        )
                            .frame(maxWidth: .infinity)
                        RoundedRectangle(cornerRadius: 5)
                            .fill(isSameDay(date1: value.date, date2: currentDate) ? text2Color.gradient:color.gradient)
                            .frame(width: 20, height: 20)
                            .offset(y: 25)
                        Text("\(index)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(isSameDay(date1: value.date, date2: currentDate) ? color.gradient: text2Color.gradient)
                            .offset(y: 25)
                    }
                }
            }
        }
        .frame(width: 50, height: 50, alignment: .top)
    }
    
    func isWeekend(date: Date) -> Bool {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 || weekday == 7
    }
    func extraDate()->[String]{
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY MMMM"
        
        let date = formatter.string(from: monthDate)
        
        return date.components(separatedBy: " ")
    }
    
    func isSameDay(date1: Date, date2: Date)->Bool{
        let calendar = Calendar.current
        
        return calendar.isDate(date1, inSameDayAs: date2)
    }
    
    func getCurrentMonth() -> Date {
        let calendar = Calendar.current

        // Define the range from July 2025 to September 2026
        let startOfRange = calendar.date(from: DateComponents(year: 2025, month: 7))!
        let endOfRange = calendar.date(from: DateComponents(year: 2026, month: 9))!

        guard let currentMonth = calendar.date(byAdding: .month, value: self.curMonth, to: Date()) else {
            return Date()
        }

        if currentMonth < startOfRange {
            self.curMonth = calendar.dateComponents([.month], from: Date(), to: startOfRange).month ?? 0
            return startOfRange
        } else if currentMonth > endOfRange {
            self.curMonth = calendar.dateComponents([.month], from: Date(), to: endOfRange).month ?? 0
            return endOfRange
        }

        return currentMonth
    }

    func extractDate() -> [DateValue] {
        let calendar = Calendar.current
        
        let currentMonth = getCurrentMonth()
        
        var days = currentMonth.getAllDatesInMonth().compactMap { date -> DateValue in
            let day = calendar.component(.day, from: date)
            return DateValue(day: day, date: date)
        }
        
        let firstWeekDay = calendar.component(.weekday, from: days.first?.date ?? Date())
        
        for _ in 0..<firstWeekDay - 1 {
            days.insert(DateValue(day: -1, date: Date()), at: 0)
        }
        
        return days
    }

    // Updated function to use CalendarViewModel's rotation days
    func getRotateDay(date: Date) -> String {
        let calendar = Calendar.current
        
        // Find the rotation day that matches this date
        for rotationDay in calendarModel.rotationDays {
            if calendar.isDate(rotationDay.date, inSameDayAs: date) {
                return "\(rotationDay.dayNumber)"
            }
        }
        
        return ""
    }
}

extension Date {
    func getAllDatesInMonth() -> [Date] {
        let calendar = Calendar.current
        
        let startOfMonth = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
        
        let dateRange = calendar.range(of: .day, in: .month, for: startOfMonth)!
        
        return dateRange.compactMap { day -> Date? in
            return calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)
        }
    }
    
    func getDates(in range: ClosedRange<Date>) -> [Date] {
        let calendar = Calendar.current
        
        let startDate = calendar.date(from: Calendar.current.dateComponents([.year, .month], from: self))!
        
        let dateRange = calendar.range(of: .day, in: .month, for: startDate)!
        
        return dateRange.compactMap { day -> Date? in
            let date = calendar.date(byAdding: .day, value: day - 1, to: startDate)!
            return range.contains(date) ? date : nil
        }
    }
}
#Preview{
    TabControl()
}
