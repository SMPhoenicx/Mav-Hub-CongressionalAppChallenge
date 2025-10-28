import SwiftUI

// jvu was here

// MARK: - Assignment Model
struct Assignment: Codable, Identifiable, Equatable {
    let id: UUID
    let summary: String
    let dtstart: String
    let dtend: String
    let description: String
    let selfAdded: Bool
    // Parsed date objects (optional)
    var startDate: Date?
    var endDate: Date?
    
    // NEW: Track whether an assignment is complete
    var isComplete: Bool
    
    init(id: UUID = UUID(),
         summary: String,
         dtstart: String,
         dtend: String,
         description: String,
         selfAdded: Bool,
         startDate: Date? = nil,
         endDate: Date? = nil,
         isComplete: Bool)
    {
        self.id = id
        self.summary = summary
        self.dtstart = dtstart
        self.dtend = dtend
        self.description = description
        self.startDate = startDate
        self.endDate = endDate
        self.isComplete = isComplete
        self.selfAdded = selfAdded
        self.isComplete = isComplete
    }
    
    static func == (lhs: Assignment, rhs: Assignment) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - AssignmentsView
struct AssignmentsView: View {
    // MARK: - AppStorage
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    @AppStorage("usingSchedule", store: defaults) private var usingSchedule: Int = 0
    @AppStorage("schedules", store: defaults) private var schedulesData: Data = Data()
    
    // MARK: - State
    @State var renderCheck: Bool = false
    @State private var showAddTaskModal: Bool = false
    @State private var schedules: [Schedule] = []
    @State private var currentDate = Date()
    @State private var scheduleArr: [Schedule] = []
    @State private var selectedDate: Date
    
    // Add initializer to accept an initial date
    init(initialDate: Date = Date()) {
        self._selectedDate = State(initialValue: initialDate)
    }
    
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
    
    /// The raw assignments from the iCal feed.
    @State private var temp_assignments: [Assignment] = []
    
    /// Grouped assignments by day (startOfDay).
    @State private var groupedAssignments: [Date: [Assignment]] = [:]
    
    /// A sorted list of all days between earliest & latest event.
    @State private var sortedDays: [Date] = []
    
    /// -- Week-based date selection
    @State private var earliestWeekStart: Date = Date()
    @State private var latestWeekStart: Date = Date()
    @State private var currentWeekStart: Date = Date()
    
    // MARK: - Alert State
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
    // MARK: - Link Validation State
    @State private var isLinkValid: Bool = true
    @State var updateValidation: Bool = false
    
    @AppStorage("viewType") private var viewType: String = "Calendar"
    
    @Environment(\.dismiss) var dismiss
    // MARK: - Body
    var body: some View {
        let color = loadColor() ?? .orange
        let textColor = color.isLight() ? Color.black : Color.white
        let text2Color:Color = darkMode ? .white:.black
        HStack{
            Button(action:{
                dismiss()
            }){
                Image(systemName: "xmark")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            }
            .padding()
            Spacer()
            Picker("View Style", selection: $viewType) {
                Image(systemName: "calendar")
                    .tag("Calendar")
                Image(systemName: "list.bullet")
                    .tag("List")
            }
            .pickerStyle(.segmented)
            .frame(maxWidth: 130)
            .padding()
        }
        VStack(spacing: 0) {
            if isLinkValid {
                if validateICalLink(curSchedule.assignmentsLink) {
                    if viewType == "Calendar" {
                        HeaderView(
                            currentWeekStart: $currentWeekStart,
                            selectedDate: $selectedDate,
                            isAtFirstWeek: isAtFirstWeek,
                            isAtLastWeek: isAtLastWeek,
                            goToPreviousWeek: goToPreviousWeek,
                            goToNextWeek: goToNextWeek,
                            textColor: textColor,
                            color: color
                        )
                        
                        CalendarAssignView(
                            assignments: curSchedule.assignments,
                            groupedAssignments: groupedAssignments,
                            selectedDate: $selectedDate,
                            currentWeekStart: $currentWeekStart,
                            deleteAssignment: deleteAssignment,
                            toggleCompletion: toggleCompletion,
                            curSchedule: curSchedule
                        )
                        .task{
                            await fetchAssignments()
                        }
                    }
                    else{
                        ListAssignView(
                                assignments: curSchedule.assignments,
                                deleteAssignment: deleteAssignment,
                                toggleCompletion: toggleCompletion,
                                curSchedule: curSchedule,
                                darkMode: darkMode,
                                color: color,
                                textColor: text2Color
                            )
                        .task{
                            await fetchAssignments()
                        }
                    }
                    // Add Button
                    Spacer()
                    Button(action: {
                        showAddTaskModal = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(textColor)
                            .frame(width: 56, height: 56)
                            .background(color)
                            .clipShape(Circle())
                            .shadow(radius: 4)
                    }
                    .padding(.bottom, 100) // Adjusted padding for better layout
                    .sheet(isPresented: $showAddTaskModal) {
                        AddTaskView(
                            curSchedule: $curSchedule,
                            tempAssignments: $temp_assignments,
                            selectedDate: selectedDate
                        )
                    }
                } else {
                    NoLinkView(
                        color: color,
                        textColor: textColor,
                        assignmentsLink: $curSchedule.assignmentsLink,
                        saveSchedule: saveSchedule
                    )
                }
                
            } else {
                NoLinkView(
                    color: color,
                    textColor: textColor,
                    assignmentsLink: $curSchedule.assignmentsLink,
                    saveSchedule: saveSchedule
                )
            }
        }
        .background(Color(UIColor.systemGroupedBackground))
        // MARK: - Modifiers
        .onAppear {
            loadInitialSchedules()
            currentWeekStart = startOfWeek(for: selectedDate)
            print(selectedDate)
        }
        .onChange(of: curSchedule.assignments) { _ in
            // Update scheduleArr and persist changes
            if usingSchedule < scheduleArr.count {
                scheduleArr[usingSchedule].assignments = curSchedule.assignments
                saveSchedules(schedules: scheduleArr)
            }
            groupAssignmentsByDay()
            setupWeekBoundaries()
        }
        .alert(alertTitle, isPresented: $showAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(alertMessage)
        }
        .background(Color(UIColor.systemGroupedBackground))
        .gesture(
            DragGesture()
                .onEnded { value in
                    handleSwipeGesture(value: value)
                    currentWeekStart = startOfWeek(for: selectedDate)
                }
        )
    }
    
    // MARK: - Helpers
    private func handleSwipeGesture(value: DragGesture.Value) {
        let dragThreshold: CGFloat = 50
        if value.translation.width > dragThreshold {
            // Swiped right -> go to previous date
            selectedDate = previousDate()
        } else if value.translation.width < -dragThreshold {
            // Swiped left -> go to next date
            selectedDate = nextDate()
        }
    }
    
    private func nextDate() -> Date {
        guard let next = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) else {
            return selectedDate
        }
        return next
    }
    
    /// Move to the previous date (yesterday).
    private func previousDate() -> Date {
        guard let prev = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) else {
            return selectedDate
        }
        return prev
    }
    
    // MARK: - Toggle Complete
    /// Toggle the `isComplete` state for a specific assignment (by ID).
    func toggleCompletion(_ assignment: Assignment) -> Void {
        // Find the current index of the assignment
        if let currentIndex = curSchedule.assignments.firstIndex(where: { $0.id == assignment.id }) {
            
            // Create a new assignment with the updated completion state
            var newAssignment = Assignment(
                summary: assignment.summary,
                dtstart: assignment.dtstart,
                dtend: assignment.dtend,
                description: assignment.description,
                selfAdded: assignment.selfAdded,
                isComplete: !assignment.isComplete
            )
            
            // If it's an ICS-based task, we parse ICS dates.
            // Otherwise, keep the existing start/end date for selfAdded tasks.
            if assignment.selfAdded {
                newAssignment.startDate = assignment.startDate
                newAssignment.endDate = assignment.endDate
            } else {
                newAssignment.startDate = parseICSDateString(assignment.dtstart)
                newAssignment.endDate   = parseICSDateString(assignment.dtend)
            }
            
            print(newAssignment.summary,
                  newAssignment.description,
                  newAssignment.dtstart,
                  newAssignment.dtend,
                  newAssignment.isComplete)
            
            // Remove the old assignment and insert the new one at the same position
            curSchedule.assignments.remove(at: currentIndex)
            curSchedule.assignments.insert(newAssignment, at: currentIndex)
            
            // Trigger re-render
            updateValidation.toggle()
        } else {
            print("Assignment not found for toggling completion.")
        }
    }
    func deleteAssignment(_ assignment: Assignment) {
        curSchedule.assignments.removeAll { $0.id == assignment.id }
        updateValidation = !updateValidation
        print("delete registered")
    }
    // MARK: - Update from iCal
    private func updateAssignments() {
        // Calculate the cutoff date based on school year logic
        let currentDate = Date()
        let currentYear = Calendar.current.component(.year, from: currentDate)
        let currentMonth = Calendar.current.component(.month, from: currentDate)
        
        let schoolYearStartYear = (currentMonth >= 7) ? currentYear : currentYear - 1
        
        let cutoffDate = Calendar.current.date(from: DateComponents(year: schoolYearStartYear, month: 7, day: 1)) ?? currentDate

        for newAssignment in temp_assignments {
            // Find existing assignment with same summary (title)
            if let existingIndex = curSchedule.assignments.firstIndex(where: { existing in
                existing.summary.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() ==
                newAssignment.summary.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() &&
                !existing.selfAdded             }) {
                var updatedAssignment = newAssignment
                updatedAssignment.isComplete = curSchedule.assignments[existingIndex].isComplete
                
                curSchedule.assignments[existingIndex] = updatedAssignment
            } else {
                curSchedule.assignments.append(newAssignment)
            }
        }

        for index in curSchedule.assignments.indices {
            let assignment = curSchedule.assignments[index]
            
            if !assignment.isComplete,
               let endDate = assignment.endDate,
               endDate < cutoffDate {
                curSchedule.assignments[index].isComplete = true
            }
        }

        // Optional: Remove assignments that are no longer in the ICS feed
        if temp_assignments.count > 5 {
                let newSummaries = Set(temp_assignments.map { $0.summary.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() })
                curSchedule.assignments.removeAll { assignment in
                    !assignment.selfAdded &&
                    !newSummaries.contains(assignment.summary.trimmingCharacters(in: .whitespacesAndNewlines).lowercased())
                }
            }
    }


}

struct ListAssignView: View {
    @State private var showDetail = false
    @State private var selectedAssignment: Assignment? = nil
    let assignments: [Assignment]
    let deleteAssignment: (Assignment) -> Void
    let toggleCompletion: (Assignment) -> Void
    let curSchedule: Schedule
    let darkMode: Bool
    let color: Color
    let textColor: Color
    
    @AppStorage("sorting") private var sorting: String = "Date"

    var body: some View {
        let now = Date()
        let calendar = Calendar.current
        let startOfToday = calendar.startOfDay(for: now)
        let startOfTomorrow = calendar.date(byAdding: .day, value: 1, to: startOfToday) ?? now
        let startOfWeekAfterNext = calendar.date(byAdding: .weekOfYear, value: 2, to: startOfToday) ?? now

        // Categorize assignments
        let dueToday = assignments.filter { calendar.isDate($0.endDate ?? now, inSameDayAs: now) }
        let dueTomorrow = assignments.filter { calendar.isDate($0.endDate ?? now, inSameDayAs: startOfTomorrow) }
        // Get the Monday–Sunday of the current week
        let thisWeekInterval = calendar.dateInterval(of: .weekOfYear, for: now) ?? DateInterval(start: now, duration: 0)
        let startOfWeek = thisWeekInterval.start
        let endOfWeek = calendar.date(byAdding: .day, value: 6, to: startOfWeek) ?? thisWeekInterval.end

        // Assignments between now and end of this week (excluding today/tomorrow)
        let dueThisWeek = assignments.filter {
            guard let dueDate = $0.endDate else { return false }
            return dueDate > startOfTomorrow && dueDate <= endOfWeek
        }
        let startOfThisWeek = thisWeekInterval.start

        // Start and end of next week
        let startOfNextWeek = calendar.date(byAdding: .weekOfYear, value: 1, to: startOfThisWeek) ?? now
        let endOfNextWeek = calendar.date(byAdding: .day, value: 6, to: startOfNextWeek) ?? now

        let dueNextWeek = assignments.filter {
            guard let dueDate = $0.endDate else { return false }
            return dueDate >= startOfNextWeek && dueDate <= endOfNextWeek
        }

        let dueLater = assignments.filter { ($0.endDate ?? now) >= startOfWeekAfterNext }
        //for list, temporary fix
        let filtered = assignments.filter { ($0.endDate ?? now) >= calendar.date(from: DateComponents(year: 2024, month: 12, day: 23)) ?? now}
        HStack{
            Spacer()
            HStack{
                Text("Sort By:")
                    .foregroundStyle(darkMode == color.isLight() ? color:textColor)
                Picker("Sort By", selection: $sorting) {
                    Text("Date").tag("Date")
                    Text("Class").tag("Class")
                    Text("Incomplete").tag("Incomplete")
                }
                .tint(darkMode == color.isLight() ? color:textColor)
            }
            .padding(.trailing)
        }

        Group {
            if assignments.isEmpty {
                Text("No assignments available.")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                List {
                    if sorting == "Date" {
                        // Sort by Date
                        if !dueToday.isEmpty {
                            Section(header: Text("Due Today").foregroundColor(darkMode == color.isLight() ? color:textColor)) {
                                groupedAssignmentSection(assignments: dueToday)
                            }
                        }
                        if !dueTomorrow.isEmpty {
                            Section(header: Text("Due Tomorrow").foregroundColor(darkMode == color.isLight() ? color:textColor)) {
                                groupedAssignmentSection(assignments: dueTomorrow)
                            }
                        }
                        if !dueThisWeek.isEmpty {
                            Section(header: Text("Due This Week").foregroundColor(darkMode == color.isLight() ? color:textColor)) {
                                groupedAssignmentSection(assignments: dueThisWeek)
                            }
                        }
                        if !dueNextWeek.isEmpty {
                            Section(header: Text("Due Next Week").foregroundColor(darkMode == color.isLight() ? color:textColor)) {
                                groupedAssignmentSection(assignments: dueNextWeek)
                            }
                        }
                        if !dueLater.isEmpty {
                            Section(header: Text("Due Later").foregroundColor(darkMode == color.isLight() ? color:textColor)) {
                                groupedAssignmentSection(assignments: dueLater)
                            }
                        }
                    } else if sorting == "Class" {
                        // Sort by Class
                        groupedAssignmentSection(assignments: filtered)
                    } else if sorting == "Incomplete" {
                        // Sort by Incomplete - show only incomplete assignments
                        let incompleteAssignments = assignments.filter { !$0.isComplete }
                        if !incompleteAssignments.isEmpty {
                            Section(header: Text("Incomplete Assignments").foregroundColor(darkMode == color.isLight() ? color:textColor)) {
                                groupedAssignmentSection(assignments: incompleteAssignments)
                            }
                        } else {
                            Text("No incomplete assignments!")
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    }
                }
                .listStyle(InsetGroupedListStyle())
            }
        }
        .fullScreenCover(isPresented: $showDetail) {
            if let selectedAssignment = selectedAssignment {
                AssignmentDetailView(assignment: selectedAssignment)
            }
        }
    }

    /// Groups assignments by class and creates sections
    private func groupedAssignmentSection(assignments: [Assignment]) -> some View {
        let assignmentsByClass = Dictionary(grouping: assignments) { assignment in
            parseClassName(from: assignment)
        }

        return ForEach(assignmentsByClass.keys.sorted(), id: \.self) { className in
            Section(header: ClassHeaderView(className: className)) {
                ForEach(assignmentsByClass[className] ?? []) { assignment in
                    AssignmentRowView(
                        assignment: assignment,
                        deleteAction: {
                            deleteAssignment(assignment)
                        },
                        toggleCompletion: {
                            toggleCompletion(assignment)
                        },
                        showDetail: {
                            selectedAssignment = assignment
                            showDetail = true
                        }
                    )
                }
            }
        }
    }

    private func parseClassName(from assignment: Assignment) -> String {
        if let range = assignment.summary.range(of: "- ") {
            return String(assignment.summary[..<range.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return assignment.summary.isEmpty ? "Other" : assignment.summary.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
}


// MARK: - AddTaskView
struct AddTaskView: View {
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    @Binding var curSchedule: Schedule
    @Binding var tempAssignments: [Assignment]
    @Environment(\.dismiss) private var dismiss
    
    @State private var summary: String = ""
    @State private var event: String = ""
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    
    // Initialize with selectedDate
    init(curSchedule: Binding<Schedule>,
         tempAssignments: Binding<[Assignment]>,
         selectedDate: Date)
    {
        self._curSchedule = curSchedule
        self._tempAssignments = tempAssignments
        // Initialize startTime and endTime with selectedDate
        self._startTime = State(initialValue: selectedDate)
        self._endTime   = State(initialValue:
            Calendar.current.date(byAdding: .hour, value: 1, to: selectedDate)
            ?? selectedDate.addingTimeInterval(3600)
        )
    }
    
    var body: some View {
        let color = loadColor() ?? .orange
        let textColorBox: Color = darkMode ? .white : .black
        let textColor = color.isLight() ? Color.black : Color.white
        
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    Text("Add New Task")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(color)
                        .padding(.top, 20)
                        .padding(.horizontal)
                    
                    // Form Fields
                    VStack(alignment: .leading, spacing: 20) {
                        // Title Field
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Title")
                                .font(.headline)
                                .foregroundColor(.primary)
                            TextField("Enter task title", text: $summary)
                                .padding()
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(8)
                                .foregroundColor(textColorBox)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(color.opacity(0.5), lineWidth: 1)
                                )
                        }
                        
                        // Description Field
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Description")
                                .font(.headline)
                                .foregroundColor(.primary)
                            TextEditor(text: $event)
                                .frame(height: 100)
                                .padding(4)
                                .background(Color(UIColor.systemBackground))
                                .foregroundColor(textColorBox)
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(color.opacity(0.5), lineWidth: 1)
                                )
                        }
                        
                        // Start Time Picker
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Start Time")
                                .font(.headline)
                                .foregroundColor(.primary)
                            DatePicker("Select start time", selection: $startTime,
                                       displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                                .padding()
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(color.opacity(0.5), lineWidth: 1)
                                )
                        }
                        
                        // End Time Picker
                        VStack(alignment: .leading, spacing: 5) {
                            Text("End Time")
                                .font(.headline)
                                .foregroundColor(.primary)
                            DatePicker("Select end time", selection: $endTime,
                                       displayedComponents: [.date, .hourAndMinute])
                                .datePickerStyle(CompactDatePickerStyle())
                                .labelsHidden()
                                .padding()
                                .background(Color(UIColor.systemBackground))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(color.opacity(0.5), lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(UIColor.systemGroupedBackground),
                        Color(UIColor.systemBackground)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .edgesIgnoringSafeArea(.all)
            )
            .navigationTitle("Add Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel Button
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .foregroundColor(color)
                            .fontWeight(.semibold)
                    }
                }
                
                // Save Button
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        saveTask()
                        dismiss()
                    }) {
                        Text("Save")
                            .foregroundColor(textColor)
                            .fontWeight(.semibold)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(summary.isEmpty ? color.opacity(0.5) : color)
                            .cornerRadius(8)
                    }
                    .disabled(summary.isEmpty)
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Error"),
                      message: Text(alertMessage),
                      dismissButton: .default(Text("OK")))
            }
        }
    }
    
    private func loadColor() -> Color? {
        do {
            if let uiColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self,
                                                                    from: selectedColorData) {
                return Color(uiColor)
            }
        } catch {
            print("Failed to unarchive color: \(error)")
        }
        return nil
    }
    
    private func saveTask() {
        let newTask = Assignment(
            summary: summary,
            dtstart: ISO8601DateFormatter().string(from: startTime),
            dtend: ISO8601DateFormatter().string(from: endTime),
            description: event,
            selfAdded: true,
            startDate: startTime,
            endDate: endTime,
            isComplete: false
        )
        curSchedule.assignments.append(newTask)
        tempAssignments.append(newTask) // Add to tempAssignments for immediate update if needed
    }
}

// MARK: - HeaderView
struct HeaderView: View {
    @Binding var currentWeekStart: Date
    @Binding var selectedDate: Date
    var isAtFirstWeek: Bool
    var isAtLastWeek: Bool
    var goToPreviousWeek: () -> Void
    var goToNextWeek: () -> Void
    var textColor: Color
    var color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            
            // One-week row (arrows + month/year text)
            HStack {
                // Left arrow (go to previous week)
                Button(action: {
                    goToPreviousWeek()
                }) {
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .padding(4)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(8)
                        .foregroundColor(Color.blue)
                }
                Spacer()
                Text(monthRange(for: currentWeekStart))
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundStyle(.gray)
                Spacer()
                Button(action: {
                    goToNextWeek()
                }) {
                    Image(systemName: "chevron.right")
                        .font(.title3)
                        .padding(4)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(8)
                        .foregroundColor(Color.blue)
                }
            }
            .padding(.horizontal)
            
            // 7-day boxes
            HStack(spacing: 8) {
                ForEach(weekDates(for: currentWeekStart), id: \.self) { day in
                    DayBox(
                        day: day,
                        isSelected: Calendar.current.isDate(day, inSameDayAs: selectedDate),
                        color: color,
                        textColor: textColor,
                        action: {
                            selectedDate = day
                        }
                    )
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .padding(.top, 10)
        .background(Color(UIColor.systemGroupedBackground))
    }
    
    /// Generates the 7 dates for the week starting at `weekStart`.
    private func weekDates(for weekStart: Date) -> [Date] {
        let cal = Calendar.current
        var days: [Date] = []
        for i in 0..<7 {
            if let day = cal.date(byAdding: .day, value: i, to: weekStart) {
                days.append(day)
            }
        }
        return days
    }
    
    /// Determines the month range text based on the weekStart date.
    private func monthRange(for weekStart: Date) -> String {
        let calendar = Calendar.current
        let weekDates = weekDates(for: weekStart)
        
        guard let firstDay = weekDates.first,
              let lastDay = weekDates.last else {
            return weekStart.formatted(.dateTime.month(.wide).year()) // Fallback
        }
        
        let firstMonth = calendar.component(.month, from: firstDay)
        let lastMonth = calendar.component(.month, from: lastDay)
        let firstYear = calendar.component(.year, from: firstDay)
        let lastYear = calendar.component(.year, from: lastDay)
        
        if firstMonth == lastMonth && firstYear == lastYear {
            // Same month and year
            return firstDay.formatted(.dateTime.month(.wide).year())
        } else {
            // Different months and/or years
            let firstMonthString = firstDay.formatted(.dateTime.month(.wide))
            let lastMonthString  = lastDay.formatted(.dateTime.month(.wide).year())
            return "\(firstMonthString) - \(lastMonthString)"
        }
    }
}

// MARK: - DayBox
struct DayBox: View {
    let day: Date
    let isSelected: Bool
    let color: Color
    let textColor: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack {
                Text(day, format: .dateTime.weekday(.abbreviated))
                    .font(.caption2)
                    .foregroundColor(isSelected ? textColor : .secondary)
                
                Text(day, format: .dateTime.day())
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .frame(width: 46, height: 46)
            .background(isSelected ? color : Color.clear)
            .foregroundColor(isSelected ? textColor : .primary)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.4), lineWidth: 1)
            )
            .cornerRadius(8)
        }
    }
}

// MARK: - CalendarAssignView
struct CalendarAssignView: View {
    @State private var showDetail = false
    @State private var selectedAssignment: Assignment? = nil
    let assignments: [Assignment]
    let groupedAssignments: [Date: [Assignment]]
    @Binding var selectedDate: Date
    @Binding var currentWeekStart: Date
    let deleteAssignment: (Assignment) -> Void
    let toggleCompletion: (Assignment) -> Void // NEW: Callback to toggle isComplete
    @State var curSchedule: Schedule
    var body: some View {
        let color = loadColor() ?? .orange
        Group {
            if assignments.isEmpty {
                // No assignments at all
                Text("Loading tasks...")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                // Show assignments for selected date
                if let assignmentsForDay = groupedAssignments[Calendar.current.startOfDay(for: selectedDate)],
                   !assignmentsForDay.isEmpty {
                    
                    // Group by class name
                    let assignmentsByClass = Dictionary(grouping: assignmentsForDay) { assignment in
                        parseClassName(from: assignment)
                    }
                    
                    List {
                        ForEach(assignmentsByClass.keys.sorted(), id: \.self) { className in
                            Section(header: ClassHeaderView(className: className)) {
                                ForEach(assignmentsByClass[className] ?? []) { assignment in
                                    AssignmentRowView(
                                        assignment: assignment,
                                        deleteAction: {
                                            deleteAssignment(assignment)
                                        },
                                        toggleCompletion: {
                                            toggleCompletion(assignment)
                                        },
                                        showDetail: {
                                            selectedAssignment = assignment
                                            showDetail = true
                                        }
                                    )
                                    .fullScreenCover(isPresented: $showDetail) {
                                        if let selectedAssignment = selectedAssignment {
                                            AssignmentDetailView(assignment: selectedAssignment)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(InsetGroupedListStyle())
                } else {
                    ScrollView{
                        // No assignments for this date
                        Text("No tasks for this date.")
                            .foregroundColor(.secondary)
                            .padding(.top, 20)
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    func toggleCompletion(_ assignment: Assignment) -> Void {
        // Find the current index of the assignment
        if let currentIndex = curSchedule.assignments.firstIndex(where: { $0.id == assignment.id }) {
            
            // Create a new assignment with the updated completion state
            var newAssignment = Assignment(
                summary: assignment.summary,
                dtstart: assignment.dtstart,
                dtend: assignment.dtend,
                description: assignment.description,
                selfAdded: assignment.selfAdded,
                isComplete: !assignment.isComplete
            )
            
            // If it's an ICS-based task, we parse ICS dates.
            // Otherwise, keep the existing start/end date for selfAdded tasks.
            if assignment.selfAdded {
                newAssignment.startDate = assignment.startDate
                newAssignment.endDate = assignment.endDate
            } else {
                newAssignment.startDate = parseICSDateString(assignment.dtstart)
                newAssignment.endDate   = parseICSDateString(assignment.dtend)
            }
            
            print(newAssignment.summary,
                  newAssignment.description,
                  newAssignment.dtstart,
                  newAssignment.dtend,
                  newAssignment.isComplete)
            
            // Remove the old assignment and insert the new one at the same position
            curSchedule.assignments.remove(at: currentIndex)
            curSchedule.assignments.insert(newAssignment, at: currentIndex)
            
            // Trigger re-render
            //updateValidation.toggle()
        } else {
            print("Assignment not found for toggling completion.")
        }
    }
    private func parseICSDateString(_ icsDate: String) -> Date? {
        let format: String
        switch icsDate.count {
        case 8:  // "YYYYMMDD"
            format = "yyyyMMdd"
        case 15: // "YYYYMMDD'T'HHmmss"
            format = "yyyyMMdd'T'HHmmss"
        case 16: // "YYYYMMDD'T'HHmmssZ"
            format = "yyyyMMdd'T'HHmmssZ"
        default:
            print("Unsupported date format for string: \(icsDate)")
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone   = TimeZone(abbreviation: "UTC")
        return formatter.date(from: icsDate)
    }
    func deleteAssignment(_ assignment: Assignment) {
           curSchedule.assignments.removeAll { $0.id == assignment.id }
           // No need to manually save, onChange will handle it
    }
    // MARK: - Helper Functions
    
    func startOfWeek(for date: Date) -> Date {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: date) // Sunday=1, Monday=2, etc.
        let distance = (weekday == 1) ? 6 : weekday - 2
        return cal.date(byAdding: .day, value: -distance, to: cal.startOfDay(for: date)) ?? date
    }
    
    private func parseDetailFromSummary(_ summary: String) -> String? {
        if let range = summary.range(of: ": ") {
            return String(summary[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return nil
    }
    
    private func parseClassName(from assignment: Assignment) -> String {
        if let range = assignment.summary.range(of: "- ") {
            return String(assignment.summary[..<range.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return assignment.summary.isEmpty ? "Other" : assignment.summary.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    private func loadColor() -> Color? {
        // Load the user-selected color for checkboxes
        do {
            if let data = UserDefaults.standard.data(forKey: "selectedColor"),
               let uiColor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: data) {
                return Color(uiColor)
            }
        }
        return nil
    }
}

struct AssignmentRowView: View {
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    let assignment: Assignment
    let deleteAction: () -> Void
    let toggleCompletion: () -> Void
    let showDetail: () -> Void
    @State private var isDetailPresented = false
    var body: some View {
        var color = loadColor() ?? .orange
        HStack(alignment: .center, spacing: 8) {
            // The main assignment text
            VStack(alignment: .leading, spacing: 2) {
                let detail = parseDetailFromSummary(assignment.summary)
                if !assignment.selfAdded {
                    Text(detail ?? "No Description")
                        .font(.body)
                        .foregroundColor(assignment.isComplete ? .gray : .secondary)
                        .strikethrough(assignment.isComplete, color: .gray)
                } else {
                    // If no “: ”
                    Text(assignment.description.isEmpty
                         ? "No Description"
                         : assignment.description)
                    .font(.body)
                    .foregroundColor(assignment.isComplete ? .gray : .secondary)
                    .strikethrough(assignment.isComplete, color: .gray)
                }
                
                // Show times
                if let startDate = assignment.startDate,
                   let endDate = assignment.endDate {
                    Text("\(startDate.formatted(date: .numeric, time: .omitted)) - \(endDate.formatted(date: .numeric, time: .omitted))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
            // Checkbox to toggle completion
            Button(action: {
                let feedback = UINotificationFeedbackGenerator()
                feedback.prepare()
                feedback.notificationOccurred(.success)
                toggleCompletion()
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(color, lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if assignment.isComplete {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(color)
                            .frame(width: 24, height: 24)
                    }
                }
            }
            .buttonStyle(BorderlessButtonStyle())
            if assignment.selfAdded{
                // Trash button on the right
                Button(action: {
                    deleteAction()
                }) {
                    Image(systemName: "trash.fill")
                        .foregroundColor(.red)
                }
                .buttonStyle(BorderlessButtonStyle())
            }
        }
        .padding(.vertical, 4)
        // .contentShape(Rectangle()) // Makes the entire row tappable
    }
    private func loadColor() -> Color? {
        do {
            if let uiColor = try NSKeyedUnarchiver.unarchivedObject(
                ofClass: UIColor.self,
                from: selectedColorData
            ) {
                return Color(uiColor)
            }
        } catch {
            print("Failed to unarchive color: \(error)")
        }
        return nil
    }
    // MARK: - Helper Functions
    
    private func parseDetailFromSummary(_ summary: String) -> String? {
        if let range = summary.range(of: ": ") {
            return String(summary[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return nil
    }
}
// MARK: - ClassHeaderView
struct ClassHeaderView: View {
    let className: String
    
    var body: some View {
        HStack {
            // Class color indicator (small circle or rectangle)
            RoundedRectangle(cornerRadius: 4)
                .fill(colorForClass(className))
                .frame(width: 12, height: 12)
            
            Text(className)
                .font(.headline)
                .foregroundColor(.primary)
        }
    }
    
    /// Assign a color based on class name
    private func colorForClass(_ className: String) -> Color {
        let redKeywords    = ["math", "algebra", "geometry", "calculus", "differential", "linear", "equations"]
        let yellowKeywords = ["english", "literature", "composition", "writing"]
        let greenKeywords  = ["science", "biology", "chemistry", "environmental"]
        let blueKeywords   = ["physics"]
        let brownKeywords  = ["history", "global", "world", "modern", "black", "economics", "gov"]
        
        switch className.lowercased() {
        case _ where containsAny(className, keywords: redKeywords):
            return .red
        case _ where containsAny(className, keywords: yellowKeywords):
            return .yellow
        case _ where containsAny(className, keywords: greenKeywords):
            return .green
        case _ where containsAny(className, keywords: blueKeywords):
            return .blue
        case _ where containsAny(className, keywords: brownKeywords):
            return .brown
        default:
            return .orange
        }
    }
    
    private func containsAny(_ className: String, keywords: [String]) -> Bool {
        let lowercasedName = className.lowercased()
        return keywords.contains { lowercasedName.contains($0) }
    }
}

// MARK: - AssignmentDetailView

struct AssignmentDetailView: View {
    let assignment: Assignment
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    @Environment(\.dismiss) private var dismiss
    
    // Load the user's chosen color or default to .orange
    var body: some View {
        let color = loadColor() ?? .orange
        let detail = parseDetailFromSummary(assignment.summary)
        let title = parseClassName(from: assignment)
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    // Title Section
                    VStack(alignment: .leading, spacing: 8) {
                        Text(title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(color)
                            .cornerRadius(12)
                        
                        // Description below the title
                        if !assignment.selfAdded {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.5)) // Light gray background
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(detail ?? "No Description")
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                    .padding(12) // Padding inside the gray box
                            }
                            .padding() // Padding outside the box for layout
                        } else {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color.gray.opacity(0.5)) // Light gray background
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                
                                Text(assignment.description.isEmpty
                                     ? "No Description"
                                     : assignment.description)
                                    .font(.body)
                                    .foregroundColor(.primary)
                                    .multilineTextAlignment(.leading)
                                    .padding(12) // Padding inside the gray box
                            }
                            .padding() // Padding outside the box for layout
                        }
                        
                        Divider()
                        
                        // Start Date
                        if let start = assignment.startDate {
                            Label {
                                Text("Starts: \(start, formatter: dateFormatter)")
                                    .foregroundColor(.secondary)
                            } icon: {
                                Image(systemName: "calendar")
                                    .foregroundColor(color)
                            }
                        }
                        
                        // End Date
                        if let end = assignment.endDate {
                            Label {
                                Text("Due: \(end, formatter: dateFormatter)")
                                    .foregroundColor(.secondary)
                            } icon: {
                                Image(systemName: "clock.fill")
                                    .foregroundColor(color)
                            }
                        }
                        
                        Spacer(minLength: 20)
                        
                        // Action Buttons
                        HStack(spacing: 16) {
                            Button {
                                dismiss()
                            } label: {
                                Text("Close")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(.red)
                                    .cornerRadius(8)
                            }
                            
                            Button {
                                // Add "save" or other functionality here
                            } label: {
                                Text("Save")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.vertical, 12)
                                    .frame(maxWidth: .infinity)
                                    .background(color)
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Assignment Details")
                .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
    private func parseClassName(from assignment: Assignment) -> String {
        if let range = assignment.summary.range(of: "- ") {
            return String(assignment.summary[..<range.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            return assignment.summary.isEmpty ? "Other" : assignment.summary.trimmingCharacters(in: .whitespacesAndNewlines)
        }
    }
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }
    
    private func loadColor() -> Color? {
        do {
            if let uiColor = try NSKeyedUnarchiver.unarchivedObject(
                ofClass: UIColor.self,
                from: selectedColorData
            ) {
                return Color(uiColor)
            }
        } catch {
            print("Failed to unarchive color: \(error)")
        }
        return nil
    }
    private func parseDetailFromSummary(_ summary: String) -> String? {
        if let range = summary.range(of: ": ") {
            return String(summary[range.upperBound...]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return nil
    }
}


// MARK: - NoLinkView
struct NoLinkView: View {
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    let color: Color
    let textColor: Color
    @Binding var assignmentsLink: String
    let saveSchedule: () -> Void
    @State private var tempLink: String = ""
    
    var body: some View {
        let isLight = color.isLight()
        let text2Color: Color = darkMode ? .white:.black
        VStack(spacing: 24) {
            // Title Text
            Text("No valid link inserted")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(darkMode == isLight ? color:text2Color)
                .multilineTextAlignment(.center)
            
            Text("Please enter a valid Feed URL.")
                .font(.body)
                .foregroundColor(darkMode == isLight ? color.opacity(0.8):text2Color)
                .multilineTextAlignment(.center)
            
            // Text Field with Clear Button
            HStack {
                TextField("Assignments Link", text: $tempLink)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .autocorrectionDisabled(true)
                
                if !tempLink.isEmpty {
                    Button(action: {
                        tempLink = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .padding(.horizontal)
            
            // Save Button
            Button(action: {
                assignmentsLink = tempLink
                saveSchedule()
            }) {
                Text("Save")
                    .font(.headline)
                    .foregroundColor(textColor)
                    .frame(maxWidth: .infinity, minHeight: 50)
                    .background(color)
                    .cornerRadius(10)
            }
            .padding(.horizontal)
            .disabled(tempLink.isEmpty)
            .opacity(tempLink.isEmpty ? 0.6 : 1.0)
        }
        .padding(30)
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(15)
        .shadow(radius: 10)
        .onAppear {
            tempLink = assignmentsLink
        }
        Image(.guideFirst)
            .resizable()
            .frame(maxWidth: 350, maxHeight: 175)
        Image(.guideSecond)
            .resizable()
            .frame(maxWidth: 350, maxHeight: 175)
    }
}
#Preview{
    TabControl()
}
// MARK: - Extension: AssignmentsView Logic
extension AssignmentsView {
    
    private func startOfWeek(for date: Date) -> Date {
        let cal = Calendar.current
        let weekday = cal.component(.weekday, from: date) // Sunday=1, Monday=2, etc.
        let distance = (weekday == 1) ? 6 : weekday - 2
        return cal.date(byAdding: .day, value: -distance, to: cal.startOfDay(for: date)) ?? date
    }
    
    private func weekDates(for weekStart: Date) -> [Date] {
        let cal = Calendar.current
        var days: [Date] = []
        for i in 0..<7 {
            if let day = cal.date(byAdding: .day, value: i, to: weekStart) {
                days.append(day)
            }
        }
        return days
    }
    
    // Navigation without bounding check, so you can go to weeks with no assignments
    private func goToPreviousWeek() {
        let cal = Calendar.current
        if let newStart = cal.date(byAdding: .day, value: -7, to: currentWeekStart) {
            currentWeekStart = newStart
        }
    }
    
    private func goToNextWeek() {
        let cal = Calendar.current
        if let newStart = cal.date(byAdding: .day, value: 7, to: currentWeekStart) {
            currentWeekStart = newStart
        }
    }
    
    private var isAtFirstWeek: Bool {
        currentWeekStart <= earliestWeekStart
    }
    
    private var isAtLastWeek: Bool {
        currentWeekStart >= latestWeekStart
    }
    
    // MARK: - ICS + Assignments
    func fetchAssignments() async {
        guard validateICalLink(curSchedule.assignmentsLink),
              let url = URL(string: curSchedule.assignmentsLink) else {
            print("Invalid link. Cannot fetch assignments.")
            return
        }

        var request = URLRequest(url: url)
        request.setValue(
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3",
            forHTTPHeaderField: "User-Agent"
        )

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            
            await MainActor.run {
                // Clear temp assignments before parsing new ones
                self.temp_assignments.removeAll()
            }
            
            let parsedAssignments = parseICS(data: data)

            await MainActor.run {
                self.temp_assignments = parsedAssignments
                self.updateAssignments()
                self.groupAssignmentsByDay()
                self.setupWeekBoundaries()

                if self.usingSchedule < self.scheduleArr.count {
                    self.saveSchedules(schedules: self.scheduleArr)
                }
            }

        } catch {
            print("Error fetching assignments:", error)
        }
    }

    
    private func decodeHTMLEntities(_ string: String) -> String {
        guard let data = string.data(using: .utf8) else { return string }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        if let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) {
            return attributedString.string
        }
        return string
    }
    
    func groupAssignmentsByDay() {
        let calendar = Calendar.current
        
        // Group by endDate
        let dictionary = Dictionary(grouping: curSchedule.assignments) { assignment -> Date in
            guard let endDate = assignment.endDate else {
                return calendar.startOfDay(for: Date()) // fallback
            }
            return calendar.startOfDay(for: endDate)
        }
        
        groupedAssignments = dictionary
        
        // Find earliest & latest day
        let allDays = dictionary.keys
        guard let earliest = allDays.min(), let latest = allDays.max() else {
            sortedDays = []
            return
        }
        
        // Build a day-by-day array
        var days: [Date] = []
        var currentDay = earliest
        while currentDay <= latest {
            days.append(currentDay)
            guard let next = calendar.date(byAdding: .day, value: 1, to: currentDay) else { break }
            currentDay = next
        }
        
        sortedDays = days.sorted()
    }
    
    private func setupWeekBoundaries() {
        guard let earliestDay = sortedDays.first,
              let latestDay = sortedDays.last else {
            earliestWeekStart = startOfWeek(for: Date())
            latestWeekStart   = earliestWeekStart
            return
        }
        
        earliestWeekStart = startOfWeek(for: earliestDay)
        latestWeekStart   = startOfWeek(for: latestDay)
    }
    
    // MARK: - ICS Parsing
    func parseICS(data: Data) -> [Assignment] {
        guard let content = String(data: data, encoding: .utf8) else {
            print("Error converting data to text.")
            return []
        }
        
        // "Unfold" lines per RFC 5545:
        let unfoldedContent = content.components(separatedBy: .newlines).reduce(into: [String]()) { result, line in
            if let last = result.last,
               !line.contains(":") && !line.hasPrefix("BEGIN") && !line.hasPrefix("END") {
                result[result.count - 1] = last + line.trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                result.append(line)
            }
        }

        let lines = unfoldedContent
        var parsedAssignments: [Assignment] = []
        
        var summary = ""
        var dtstart = ""
        var dtend   = ""
        var description = ""
        
        for line in lines {
            if line.hasPrefix("SUMMARY:") {
                let rawSummary = line.replacingOccurrences(of: "SUMMARY:", with: "")
                summary = decodeHTMLEntities(rawSummary)
            } else if line.uppercased().starts(with: "DTSTART") {
                dtstart = parseICSDateLine(line)
            } else if line.uppercased().starts(with: "DTEND") {
                dtend = parseICSDateLine(line)
            } else if line.hasPrefix("DESCRIPTION:") || line.hasPrefix("DESCRIPTION;") {
                let rawDescription = line
                    .replacingOccurrences(of: "DESCRIPTION:", with: "")
                    .replacingOccurrences(of: "DESCRIPTION;", with: "")
                description = decodeHTMLEntities(rawDescription)
            } else if line.hasPrefix("END:VEVENT") {
                // Create the assignment
                var newAssignment = Assignment(
                    summary: summary,
                    dtstart: dtstart,
                    dtend: dtend,
                    description: description,
                    selfAdded: false,
                    isComplete: false
                )
                // Parse to Date objects
                newAssignment.startDate = parseICSDateString(dtstart)
                newAssignment.endDate   = parseICSDateString(dtend)
                
                parsedAssignments.append(newAssignment)
                
                // Reset for next event
                summary = ""
                dtstart = ""
                dtend = ""
                description = ""
            }
        }
        
        return parsedAssignments
    }
    
    private func parseICSDateLine(_ line: String) -> String {
        guard let idx = line.lastIndex(of: ":") else { return "" }
        return String(line[line.index(after: idx)...])
    }
    
    private func parseICSDateString(_ icsDate: String) -> Date? {
        let format: String
        switch icsDate.count {
        case 8:  // "YYYYMMDD"
            format = "yyyyMMdd"
        case 15: // "YYYYMMDD'T'HHmmss"
            format = "yyyyMMdd'T'HHmmss"
        case 16: // "YYYYMMDD'T'HHmmssZ"
            format = "yyyyMMdd'T'HHmmssZ"
        default:
            print("Unsupported date format for string: \(icsDate)")
            return nil
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone   = TimeZone(abbreviation: "UTC")
        return formatter.date(from: icsDate)
    }
    
    // MARK: - Persistence
    func saveSchedule() {
        if validateICalLink(curSchedule.assignmentsLink) {
            if usingSchedule < scheduleArr.count {
                scheduleArr[usingSchedule].assignmentsLink = curSchedule.assignmentsLink
                scheduleArr[usingSchedule].name = curSchedule.name
            } else {
                scheduleArr.append(curSchedule)
                usingSchedule = scheduleArr.count - 1
            }
            saveSchedules(schedules: scheduleArr)
            
            alertTitle = "Success"
            alertMessage = "Assignment link has been saved successfully."
            showAlert = true
        } else {
            curSchedule.assignmentsLink = ""
            alertTitle = "Invalid Link"
            alertMessage = "The provided assignment link is invalid. Please enter a valid feed URL."
            showAlert = true
        }
    }
    
    func loadInitialSchedules() {
        scheduleArr = loadSchedules()
        if usingSchedule >= scheduleArr.count {
            usingSchedule = 0
        }
        if !scheduleArr.isEmpty {
            curSchedule = scheduleArr[usingSchedule]
        }
    }
    
    func reloadSchedules() {
        scheduleArr = loadSchedules()
        if usingSchedule >= scheduleArr.count {
            usingSchedule = 0
        }
        if !scheduleArr.isEmpty {
            curSchedule = scheduleArr[usingSchedule]
        }
    }
    
    func loadSchedules() -> [Schedule] {
        if let decoded = try? JSONDecoder().decode([Schedule].self, from: schedulesData) {
            return decoded
        }
        return []
    }
    
    func saveSchedules(schedules: [Schedule]) {
        if let encoded = try? JSONEncoder().encode(schedules) {
            schedulesData = encoded
        } else {
            print("Failed to encode schedules.")
        }
    }
    
    // MARK: - Validation
    func validateICalLink(_ link: String) -> Bool {
        let validPrefix = "https://sjs.myschoolapp.com/podium/feed/iCal"
        guard link.hasPrefix(validPrefix) else {
            print("Invalid link prefix.")
            return false
        }
        guard let url = URL(string: link), url.scheme == "https" else {
            print("Invalid or non-https URL.")
            return false
        }
        return true
    }
    
    private func validateLink() {
        guard validateICalLink(curSchedule.assignmentsLink),
              let url = URL(string: curSchedule.assignmentsLink) else {
            DispatchQueue.main.async {
                isLinkValid = false
            }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "HEAD"
        request.setValue(
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/58.0.3029.110 Safari/537.3",
            forHTTPHeaderField: "User-Agent"
        )
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let _ = error {
                DispatchQueue.main.async {
                    isLinkValid = false
                }
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse,
               (200...299).contains(httpResponse.statusCode) {
                DispatchQueue.main.async {
                    isLinkValid = true
                }
            } else {
                DispatchQueue.main.async {
                    isLinkValid = false
                }
            }
        }
        .resume()
    }
    
    // MARK: - Load Color
    private func loadColor() -> Color? {
        do {
            if let uiColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self,
                                                                    from: selectedColorData) {
                return Color(uiColor)
            }
        } catch {
            print("Failed to unarchive color: \(error)")
        }
        return nil
    }
}
