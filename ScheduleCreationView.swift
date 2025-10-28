import SwiftUI
import WidgetKit
import Foundation
//jvu was here

let defaults = UserDefaults(suiteName: "group..com.jackrvu.mavhub.dayViews")!

struct ScheduleCreationView: View {
    @Binding var scheduleIndex: Int
    @State private var tempSchedule: Schedule = Schedule(
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
    @State private var schedules: [Schedule] = []

    @State private var nameEmpty: Bool = false
    @AppStorage("schedules", store: defaults) private var schedulesData: Data = Data()
    @Environment(\.dismiss) var dismiss
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    
    @AppStorage("hasOpenedBefore") private var hasOpenedBefore: Bool = false
    // Alert states for user feedback
    @State private var showAlert: Bool = false
    @State private var alertTitle: String = ""
    @State private var alertMessage: String = ""
    
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

    init(scheduleIndex: Binding<Int>) {
        self._scheduleIndex = scheduleIndex
    }

    var body: some View {
        let color = loadColor() ?? .orange
        let textColor = color.isLight() ? Color.black : Color.white
        
        VStack(alignment: .leading) {
            // Header with Cancel and Save buttons
            HStack {
                // Cancel Button
                Button(action: {
                    dismiss()
                    scheduleIndex = -1
                }) {
                    Text("Cancel")
                        .frame(maxWidth: 100, minHeight: 44)
                        .foregroundColor(.white)
                        .background(Color.red)
                        .cornerRadius(10.0)
                }
                
                Spacer()
                
                // Title
                Text(scheduleIndex == -1 ? "Create Schedule" : "Edit Schedule")
                    .font(.headline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                // Save Button
                Button(action: {
                    if !tempSchedule.name.isEmpty {
                        saveSchedule()
                        dismiss()
                    } else {
                        nameEmpty = true
                    }
                    hasOpenedBefore = true
                }) {
                    Text("Save")
                        .frame(maxWidth: 100, minHeight: 44)
                        .foregroundColor(textColor)
                        .background(color)
                        .cornerRadius(10.0)
                }
            }
            .padding()

            // Scrollable Form
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Name Field
                    TextField("Name", text: $tempSchedule.name, onEditingChanged: { isEditing in
                        if nameEmpty {
                            nameEmpty = false
                        }
                    })
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // Validation Message for Name
                    if nameEmpty {
                        Text("* Required field")
                            .foregroundColor(.red)
                            .font(.footnote)
                            .padding(.top, -10)
                    }
                    
                    // Assignments Link Field with Clear Button
                    ZStack(alignment: .trailing) {
                        TextField("Assignments Link", text: $tempSchedule.assignmentsLink)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .autocorrectionDisabled(true)
                        
                        if !tempSchedule.assignmentsLink.isEmpty {
                            Button(action: {
                                tempSchedule.assignmentsLink = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                            }
                            .padding(.trailing, 8)
                        }
                    }
                    
                    // Grade Picker
                    Picker("Grade Selection", selection: $tempSchedule.grade) {
                        Text("High School").tag(0)
                        Text("Middle School").tag(1)
                        Text("Sixth Grade").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .foregroundColor(color)
                    
                    // Carrier Fields
                    Group {
                        TextField("A Carrier", text: $tempSchedule.aCarrier)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("B Carrier", text: $tempSchedule.bCarrier)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("C Carrier", text: $tempSchedule.cCarrier)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("D Carrier", text: $tempSchedule.dCarrier)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("E Carrier", text: $tempSchedule.eCarrier)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("F Carrier", text: $tempSchedule.fCarrier)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("G Carrier", text: $tempSchedule.gCarrier)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    // Day Fields
                    Group {
                        TextField("Day 1 Morning Ensembles", text: $tempSchedule.d1Morning)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Day 1 Da Vinci", text: $tempSchedule.d1Vinci)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Day 2 Morning Ensembles", text: $tempSchedule.d2Morning)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField(tempSchedule.grade != 0 ? "Day 4 Da Vinci" : "Day 3 Da Vinci", text: $tempSchedule.d3Vinci)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Day 4 Morning Ensembles", text: $tempSchedule.d4Morning)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Day 5 Morning Ensembles", text: $tempSchedule.d5Morning)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Day 6 Morning Ensembles", text: $tempSchedule.d6Morning)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Day 6 Da Vinci", text: $tempSchedule.d6Vinci)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        TextField("Day 7 Morning Ensembles", text: $tempSchedule.d7Morning)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding()
            }
            .padding(.bottom, 40)
        }
        .onAppear {
            loadSchedules()
            if scheduleIndex >= 0, scheduleIndex < schedules.count {
                tempSchedule = schedules[scheduleIndex]
            }
        }
    }

    // MARK: - Load Schedules from AppStorage
    private func loadSchedules() {
        if let decodedSchedules = try? JSONDecoder().decode([Schedule].self, from: schedulesData) {
            schedules = decodedSchedules
        }
    }

    // MARK: - Save Schedule to AppStorage
    private func saveSchedule() {
        if scheduleIndex >= 0 && scheduleIndex < schedules.count {
            schedules[scheduleIndex] = tempSchedule
        } else {
            schedules.append(tempSchedule)
            // Update scheduleIndex to the new schedule's index
            scheduleIndex = schedules.count - 1
        }

        // Encode and save to AppStorage
        if let encodedSchedules = try? JSONEncoder().encode(schedules) {
            schedulesData = encodedSchedules
            alertTitle = "Success"
            alertMessage = "Schedule has been saved successfully."
            showAlert = true
            // Reload widgets if necessary
            WidgetCenter.shared.reloadAllTimelines()
        } else {
            alertTitle = "Error"
            alertMessage = "Failed to save the schedule. Please try again."
            showAlert = true
        }
    }
}

struct Schedule: Codable, Identifiable {
    var id: UUID = UUID()

    var name: String
    var assignmentsLink: String
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
    var assignments: [Assignment]
}


#Preview {
    ScheduleCreationView(scheduleIndex: .constant(-1))
}
