//
//  GradeClass.swift
//  NewMavApp
//
//  Created by Suman Muppavarapu on 8/7/25.
//


import SwiftUI

// MARK: - Data Models
struct GradeClass: Codable, Identifiable {
    let id = UUID()
    var className: String
    var calculationType: CalculationType
    var assignments: [GradeAssignment]
    var sections: [GradeSection]
    var semesterExam: SemesterExam?
    var enableSemesterExam: Bool
    
    init(className: String = "", calculationType: CalculationType = .percentage) {
        self.className = className
        self.calculationType = calculationType
        self.assignments = []
        self.sections = [GradeSection(name: "Assignments", weight: 100.0)]
        self.semesterExam = nil
        self.enableSemesterExam = false
    }
}

struct GradeAssignment: Codable, Identifiable {
    let id = UUID()
    var name: String
    var grade: Double?
    var units: Double? // For points-based system
    var sectionId: UUID? // For percentage-based system
    
    init(name: String = "", grade: Double? = nil, units: Double? = nil, sectionId: UUID? = nil) {
        self.name = name
        self.grade = grade
        self.units = units
        self.sectionId = sectionId
    }
}

struct GradeSection: Codable, Identifiable {
    let id = UUID()
    var name: String
    var weight: Double // Percentage weight
    
    init(name: String, weight: Double = 0.0) {
        self.name = name
        self.weight = weight
    }
}

struct SemesterExam: Codable {
    var grade: Double?
    var weight: Double // Percentage weight of exam
    
    init(grade: Double? = nil, weight: Double = 20.0) {
        self.grade = grade
        self.weight = weight
    }
}

enum CalculationType: String, CaseIterable, Codable {
    case percentage = "Percentage"
    case points = "Points"
}

// MARK: - Main View
struct GradeCalculatorView: View {
    @AppStorage("gradeClasses", store: UserDefaults.standard) private var gradeClassesData: Data = Data()
    @AppStorage("darkMode", store: UserDefaults.standard) private var darkMode: Bool = true
    @AppStorage("selectedColor", store: UserDefaults.standard) private var selectedColorData: Data = Data()
    
    @State private var gradeClasses: [GradeClass] = []
    @State private var selectedClassIndex: Int = 0
    @State private var showingAddClass = false
    @State private var newClassName = ""
    
    var currentClass: GradeClass? {
        guard !gradeClasses.isEmpty && selectedClassIndex < gradeClasses.count else { return nil }
        return gradeClasses[selectedClassIndex]
    }
    
    var body: some View {
        let color = loadColor() ?? Color.orange
        
        VStack(spacing: 0) {
            // Header
            headerView(color: color)
            
            if let currentClass = currentClass {
                // Main Content
                ScrollView {
                    VStack(spacing: 20) {
                        // Grade Display
                        gradeDisplayView(for: currentClass, color: color)
                        
                        // Calculator Type Picker
                        calculationTypePicker(color: color)
                        
                        // Semester Exam Toggle
                        semesterExamToggle(color: color)
                        
                        // Content based on calculation type
                        if currentClass.calculationType == .percentage {
                            percentageBasedView(color: color)
                        } else {
                            pointsBasedView(color: color)
                        }
                    }
                    .padding()
                }
            } else {
                // Empty state
                emptyStateView(color: color)
            }
        }
        .background(darkMode ? Color.black : Color.white)
        .onAppear {
            loadGradeClasses()
        }
        .sheet(isPresented: $showingAddClass) {
            addClassSheet
        }
    }
    
    // MARK: - Header View
    private func headerView(color: Color) -> some View {
        HStack {
            Text("Grade Calculator")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(darkMode ? .white : .black)
            
            Spacer()
            
            // Class selector and add button
            HStack {
                if !gradeClasses.isEmpty {
                    Picker("Select Class", selection: $selectedClassIndex) {
                        ForEach(0..<gradeClasses.count, id: \.self) { index in
                            Text(gradeClasses[index].className.isEmpty ? "Class \(index + 1)" : gradeClasses[index].className)
                                .tag(index)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    .foregroundColor(color)
                }
                
                Button(action: {
                    showingAddClass = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(color)
                }
            }
        }
        .padding()
        .background(darkMode ? Color.gray.opacity(0.1) : Color.gray.opacity(0.05))
    }
    
    // MARK: - Grade Display
    private func gradeDisplayView(for gradeClass: GradeClass, color: Color) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(gradeClass.className.isEmpty ? "Unnamed Class" : gradeClass.className)
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(darkMode ? .white : .black)
                
                Text("\(gradeClass.calculationType.rawValue) Based")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 5) {
                Text(String(format: "%.2f%%", calculateOverallGrade(for: gradeClass)))
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(color)
                
                Text("Overall Grade")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(darkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
        )
    }
    
    // MARK: - Calculation Type Picker
    private func calculationTypePicker(color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Calculation Method")
                .font(.headline)
                .foregroundColor(darkMode ? .white : .black)
            
            Picker("Calculation Type", selection: Binding(
                get: { currentClass?.calculationType ?? .percentage },
                set: { newType in
                    if let index = gradeClasses.firstIndex(where: { $0.id == currentClass?.id }) {
                        gradeClasses[index].calculationType = newType
                        saveGradeClasses()
                    }
                }
            )) {
                ForEach(CalculationType.allCases, id: \.self) { type in
                    Text(type.rawValue).tag(type)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }
    
    // MARK: - Semester Exam Toggle
    private func semesterExamToggle(color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Semester Exam")
                    .font(.headline)
                    .foregroundColor(darkMode ? .white : .black)
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { currentClass?.enableSemesterExam ?? false },
                    set: { enabled in
                        if let index = gradeClasses.firstIndex(where: { $0.id == currentClass?.id }) {
                            gradeClasses[index].enableSemesterExam = enabled
                            if enabled && gradeClasses[index].semesterExam == nil {
                                gradeClasses[index].semesterExam = SemesterExam()
                            }
                            saveGradeClasses()
                        }
                    }
                ))
                .toggleStyle(SwitchToggleStyle(tint: color))
            }
            
            if currentClass?.enableSemesterExam == true {
                semesterExamFields(color: color)
            }
        }
    }
    
    private func semesterExamFields(color: Color) -> some View {
        HStack(spacing: 15) {
            VStack(alignment: .leading, spacing: 5) {
                Text("Exam Grade")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                TextField("Grade", value: Binding(
                    get: { currentClass?.semesterExam?.grade },
                    set: { grade in
                        if let index = gradeClasses.firstIndex(where: { $0.id == currentClass?.id }) {
                            if gradeClasses[index].semesterExam == nil {
                                gradeClasses[index].semesterExam = SemesterExam()
                            }
                            gradeClasses[index].semesterExam?.grade = grade
                            saveGradeClasses()
                        }
                    }
                ), format: .number)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
            }
            
            VStack(alignment: .leading, spacing: 5) {
                Text("Exam Weight (%)")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                TextField("Weight", value: Binding(
                    get: { currentClass?.semesterExam?.weight },
                    set: { weight in
                        if let index = gradeClasses.firstIndex(where: { $0.id == currentClass?.id }) {
                            if gradeClasses[index].semesterExam == nil {
                                gradeClasses[index].semesterExam = SemesterExam()
                            }
                            gradeClasses[index].semesterExam?.weight = weight ?? 20.0
                            saveGradeClasses()
                        }
                    }
                ), format: .number)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .keyboardType(.decimalPad)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(darkMode ? Color.gray.opacity(0.15) : Color.gray.opacity(0.08))
        )
    }
    
    // MARK: - Percentage Based View
    private func percentageBasedView(color: Color) -> some View {
        VStack(spacing: 15) {
            // Sections
            ForEach(currentClass?.sections ?? [], id: \.id) { section in
                percentageSectionView(section: section, color: color)
            }
            
            // Add Section Button
            Button(action: addSection) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Section")
                }
                .foregroundColor(color)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color, lineWidth: 1)
                )
            }
        }
    }
    
    private func percentageSectionView(section: GradeSection, color: Color) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            // Section Header
            HStack {
                TextField("Section Name", text: Binding(
                    get: { section.name },
                    set: { newName in
                        updateSectionName(sectionId: section.id, name: newName)
                    }
                ))
                .font(.headline)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Text("Weight:")
                    .foregroundColor(darkMode ? .white : .black)
                
                TextField("Weight", value: Binding(
                    get: { section.weight },
                    set: { weight in
                        updateSectionWeight(sectionId: section.id, weight: weight ?? 0.0)
                    }
                ), format: .number)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 70)
                .keyboardType(.decimalPad)
                
                Text("%")
                    .foregroundColor(darkMode ? .white : .black)
                
                Button(action: {
                    deleteSection(sectionId: section.id)
                }) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
            
            // Section Average
            let sectionAverage = calculateSectionAverage(sectionId: section.id)
            Text("Section Average: \(String(format: "%.2f%%", sectionAverage))")
                .font(.subheadline)
                .foregroundColor(color)
                .padding(.horizontal)
            
            // Assignments in this section
            let sectionAssignments = (currentClass?.assignments ?? []).filter { $0.sectionId == section.id }
            
            ForEach(sectionAssignments, id: \.id) { assignment in
                percentageAssignmentRow(assignment: assignment, color: color)
            }
            
            // Add Assignment Button
            Button(action: {
                addAssignment(to: section.id)
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("Add Assignment")
                }
                .foregroundColor(color.opacity(0.8))
                .padding(.horizontal)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(darkMode ? Color.gray.opacity(0.2) : Color.gray.opacity(0.1))
        )
    }
    
    private func percentageAssignmentRow(assignment: GradeAssignment, color: Color) -> some View {
        HStack(spacing: 10) {
            TextField("Assignment Name", text: Binding(
                get: { assignment.name },
                set: { newName in
                    updateAssignmentName(assignmentId: assignment.id, name: newName)
                }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Grade", value: Binding(
                get: { assignment.grade },
                set: { grade in
                    updateAssignmentGrade(assignmentId: assignment.id, grade: grade)
                }
            ), format: .number)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(width: 80)
            .keyboardType(.decimalPad)
            
            Text("%")
                .foregroundColor(darkMode ? .white : .black)
            
            Button(action: {
                deleteAssignment(assignmentId: assignment.id)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Points Based View
    private func pointsBasedView(color: Color) -> some View {
        VStack(spacing: 15) {
            Text("Assignments")
                .font(.headline)
                .foregroundColor(darkMode ? .white : .black)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Header
            HStack {
                Text("Assignment")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(darkMode ? .white : .black)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text("Units")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(darkMode ? .white : .black)
                    .frame(width: 60)
                
                Text("Grade")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(darkMode ? .white : .black)
                    .frame(width: 80)
                
                Spacer()
                    .frame(width: 30)
            }
            .padding(.horizontal)
            
            // Assignments
            ForEach(currentClass?.assignments ?? [], id: \.id) { assignment in
                pointsAssignmentRow(assignment: assignment, color: color)
            }
            
            // Add Assignment Button
            Button(action: {
                addPointsAssignment()
            }) {
                HStack {
                    Image(systemName: "plus")
                    Text("Add Assignment")
                }
                .foregroundColor(color)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(color, lineWidth: 1)
                )
            }
        }
    }
    
    private func pointsAssignmentRow(assignment: GradeAssignment, color: Color) -> some View {
        HStack(spacing: 10) {
            TextField("Assignment Name", text: Binding(
                get: { assignment.name },
                set: { newName in
                    updateAssignmentName(assignmentId: assignment.id, name: newName)
                }
            ))
            .textFieldStyle(RoundedBorderTextFieldStyle())
            
            TextField("Units", value: Binding(
                get: { assignment.units },
                set: { units in
                    updateAssignmentUnits(assignmentId: assignment.id, units: units)
                }
            ), format: .number)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(width: 60)
            .keyboardType(.decimalPad)
            
            TextField("Grade", value: Binding(
                get: { assignment.grade },
                set: { grade in
                    updateAssignmentGrade(assignmentId: assignment.id, grade: grade)
                }
            ), format: .number)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .frame(width: 80)
            .keyboardType(.decimalPad)
            
            Button(action: {
                deleteAssignment(assignmentId: assignment.id)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Empty State
    private func emptyStateView(color: Color) -> some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "graduationcap")
                .font(.system(size: 60))
                .foregroundColor(color.opacity(0.5))
            
            Text("No Classes Added")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(darkMode ? .white : .black)
            
            Text("Tap the + button to add your first class")
                .font(.body)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    // MARK: - Add Class Sheet
    private var addClassSheet: some View {
        NavigationView {
            VStack(spacing: 20) {
                TextField("Class Name", text: $newClassName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Spacer()
            }
            .navigationTitle("Add Class")
            .navigationBarItems(
                leading: Button("Cancel") {
                    showingAddClass = false
                    newClassName = ""
                },
                trailing: Button("Add") {
                    addClass()
                }
                .disabled(newClassName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )
        }
    }
    
    // MARK: - Helper Functions
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
    
    private func loadGradeClasses() {
        if let decoded = try? JSONDecoder().decode([GradeClass].self, from: gradeClassesData) {
            gradeClasses = decoded
        }
    }
    
    private func saveGradeClasses() {
        if let encoded = try? JSONEncoder().encode(gradeClasses) {
            gradeClassesData = encoded
        }
    }
    
    private func addClass() {
        let newClass = GradeClass(className: newClassName.trimmingCharacters(in: .whitespacesAndNewlines))
        gradeClasses.append(newClass)
        selectedClassIndex = gradeClasses.count - 1
        saveGradeClasses()
        showingAddClass = false
        newClassName = ""
    }
    
    private func addSection() {
        guard let index = gradeClasses.firstIndex(where: { $0.id == currentClass?.id }) else { return }
        let newSection = GradeSection(name: "New Section", weight: 0.0)
        gradeClasses[index].sections.append(newSection)
        saveGradeClasses()
    }
    
    private func deleteSection(sectionId: UUID) {
        guard let classIndex = gradeClasses.firstIndex(where: { $0.id == currentClass?.id }) else { return }
        gradeClasses[classIndex].sections.removeAll { $0.id == sectionId }
        gradeClasses[classIndex].assignments.removeAll { $0.sectionId == sectionId }
        saveGradeClasses()
    }
    
    private func addAssignment(to sectionId: UUID) {
        guard let index = gradeClasses.firstIndex(where: { $0.id == currentClass?.id }) else { return }
        let newAssignment = GradeAssignment(name: "", grade: nil, sectionId: sectionId)
        gradeClasses[index].assignments.append(newAssignment)
        saveGradeClasses()
    }
    
    private func addPointsAssignment() {
        guard let index = gradeClasses.firstIndex(where: { $0.id == currentClass?.id }) else { return }
        let newAssignment = GradeAssignment(name: "", grade: nil, units: nil)
        gradeClasses[index].assignments.append(newAssignment)
        saveGradeClasses()
    }
    
    private func deleteAssignment(assignmentId: UUID) {
        guard let classIndex = gradeClasses.firstIndex(where: { $0.id == currentClass?.id }) else { return }
        gradeClasses[classIndex].assignments.removeAll { $0.id == assignmentId }
        saveGradeClasses()
    }
    
    private func updateSectionName(sectionId: UUID, name: String) {
        guard let classIndex = gradeClasses.firstIndex(where: { $0.id == currentClass?.id }),
              let sectionIndex = gradeClasses[classIndex].sections.firstIndex(where: { $0.id == sectionId }) else { return }
        gradeClasses[classIndex].sections[sectionIndex].name = name
        saveGradeClasses()
    }
    
    private func updateSectionWeight(sectionId: UUID, weight: Double) {
        guard let classIndex = gradeClasses.firstIndex(where: { $0.id == currentClass?.id }),
              let sectionIndex = gradeClasses[classIndex].sections.firstIndex(where: { $0.id == sectionId }) else { return }
        gradeClasses[classIndex].sections[sectionIndex].weight = weight
        saveGradeClasses()
    }
    
    private func updateAssignmentName(assignmentId: UUID, name: String) {
        guard let classIndex = gradeClasses.firstIndex(where: { $0.id == currentClass?.id }),
              let assignmentIndex = gradeClasses[classIndex].assignments.firstIndex(where: { $0.id == assignmentId }) else { return }
        gradeClasses[classIndex].assignments[assignmentIndex].name = name
        saveGradeClasses()
    }
    
    private func updateAssignmentGrade(assignmentId: UUID, grade: Double?) {
        guard let classIndex = gradeClasses.firstIndex(where: { $0.id == currentClass?.id }),
              let assignmentIndex = gradeClasses[classIndex].assignments.firstIndex(where: { $0.id == assignmentId }) else { return }
        gradeClasses[classIndex].assignments[assignmentIndex].grade = grade
        saveGradeClasses()
    }
    
    private func updateAssignmentUnits(assignmentId: UUID, units: Double?) {
        guard let classIndex = gradeClasses.firstIndex(where: { $0.id == currentClass?.id }),
              let assignmentIndex = gradeClasses[classIndex].assignments.firstIndex(where: { $0.id == assignmentId }) else { return }
        gradeClasses[classIndex].assignments[assignmentIndex].units = units
        saveGradeClasses()
    }
    
    // MARK: - Grade Calculations
    private func calculateSectionAverage(sectionId: UUID) -> Double {
        let sectionAssignments = (currentClass?.assignments ?? []).filter { 
            $0.sectionId == sectionId && $0.grade != nil 
        }
        
        guard !sectionAssignments.isEmpty else { return 0.0 }
        
        let totalGrades = sectionAssignments.compactMap { $0.grade }.reduce(0, +)
        return totalGrades / Double(sectionAssignments.count)
    }
    
    private func calculateOverallGrade(for gradeClass: GradeClass) -> Double {
        var classAverage: Double = 0.0
        
        if gradeClass.calculationType == .percentage {
            // Percentage-based calculation
            let totalWeight = gradeClass.sections.map { $0.weight }.reduce(0, +)
            guard totalWeight > 0 else { return 0.0 }
            
            var weightedSum: Double = 0.0
            for section in gradeClass.sections {
                let sectionAverage = calculateSectionAverage(sectionId: section.id)
                weightedSum += sectionAverage * (section.weight / 100.0)
            }
            
            classAverage = weightedSum / (totalWeight / 100.0)
        } else {
            // Points-based calculation
            let validAssignments = gradeClass.assignments.filter { 
                $0.grade != nil && $0.units != nil && $0.grade! >= 0 && $0.units! > 0 
            }
            
            guard !validAssignments.isEmpty else { return 0.0 }
            
            let totalWorth = validAssignments.map { ($0.grade! * $0.units!) }.reduce(0, +)
            let totalUnits = validAssignments.compactMap { $0.units }.reduce(0, +)
            
            guard totalUnits > 0 else { return 0.0 }
            classAverage = totalWorth / totalUnits
        }
        
        // Apply semester exam if enabled
        if gradeClass.enableSemesterExam,
           let exam = gradeClass.semesterExam,
           let examGrade = exam.grade {
            
            let examWeight = exam.weight / 100.0
            let classWeight = 1.0 - examWeight
            
            classAverage = (classAverage * classWeight) + (examGrade * examWeight)
        }
        
        return max(0.0, min(100.0, classAverage)) // Clamp between 0 and 100
    }
}

#Preview {
    GradeCalculatorView()
}
