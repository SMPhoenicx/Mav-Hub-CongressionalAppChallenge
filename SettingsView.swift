import SwiftUI
import WidgetKit
import UIKit
struct SettingsView: View {
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    @AppStorage("scheduleView") private var scheduleView: Bool = false
    @AppStorage("sportsView") var sportsView: Bool = true
    @AppStorage("schedules", store: defaults) private var schedulesData: Data = Data()
    @AppStorage("assignmentSharing") var assignmentSharing: Bool = false
    @State private var selectedColor: Color = .orange // Default color
    @State private var showColorPicker = false // State to control the sheet
    @State private var tempColor: Color = .orange
    @State private var scheduleCreate: Int = -1
    @State private var showScheduleCreate: Bool = false
    @State private var showDeleteAlert = false
    @State private var scheduleToDelete: Schedule? = nil
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
    @AppStorage("usingSchedule", store: defaults) private var usingSchedule:Int = 0
    @Environment(\.presentationMode) var presentationMode
    
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
    
    func generateScheduleLink(schedule: Schedule) -> URL? {
        let encoder = JSONEncoder()
        do {
            // Create a copy of the schedule with an empty assignments array
            var modifiedSchedule = schedule
            modifiedSchedule.assignments = [] // Set assignments to an empty array
            if !assignmentSharing{
                modifiedSchedule.assignmentsLink = ""
            }
            // Convert the modified schedule to JSON
            let jsonData = try encoder.encode(modifiedSchedule)
            
            // Base64 encode the JSON data
            let base64Data = jsonData.base64EncodedString()
            
            // Percent-encode the Base64 string
            if let encodedBase64 = base64Data.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                // Construct the custom URL
                return URL(string: "mavhub://schedule?data=\(encodedBase64)")
            } else {
                print("Failed to percent-encode Base64 string.")
                return nil
            }
        } catch {
            print("Failed to encode schedule: \(error)")
            return nil
        }
    }

    
    var body: some View {
        var color = loadColor() ?? Color.orange
        let textColor: Color = color.isLight() ? .black:.white
        var scheduleArr = loadSchedules()
        VStack {
            HStack {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                Spacer()
            }
            .padding()
            
            Form{
                Section(header: Text("Schedules")){
                    List{
                        ForEach(scheduleArr, id: \.id) { schedule in
                            let isSelected = usingSchedule == scheduleArr.firstIndex(where: { $0.id == schedule.id })

                            Button(action: {
                                if let index = scheduleArr.firstIndex(where: { $0.id == schedule.id }) {
                                    usingSchedule = index
                                    WidgetCenter.shared.reloadAllTimelines()
                                }
                            }) {
                                HStack {
                                    // Schedule Name
                                    Text(schedule.name)
                                        .foregroundColor(isSelected ? textColor : (darkMode ? .white : .black))
                                        .font(.system(size: 16, weight: .medium))
                                        .padding(.leading, 8)

                                    Spacer()

                                    // Edit Icon
                                    Button(action: {
                                        if let index = scheduleArr.firstIndex(where: { $0.id == schedule.id }) {
                                            scheduleCreate = index
                                            showScheduleCreate.toggle()
                                        }
                                    }){
                                        Image(systemName: "square.and.pencil")
                                            .foregroundColor(isSelected ? textColor : color.isLight() == darkMode ? color: Color.blue)
                                            .padding(.trailing, 8)
                                    }
                                    
                                    // Share Button
                                    Button(action: {
                                        if let scheduleLink = generateScheduleLink(schedule: schedule) {
                                            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                                               let rootViewController = windowScene.windows.first?.rootViewController {
                                                let activityViewController = UIActivityViewController(
                                                    activityItems: [scheduleLink],
                                                    applicationActivities: nil
                                                )
                                                rootViewController.present(activityViewController, animated: true, completion: nil)
                                            }
                                        }
                                    }) {
                                        Image(systemName: "square.and.arrow.up")
                                            .foregroundColor(isSelected ? textColor : color.isLight() == darkMode ? color: Color.blue)
                                            .padding(.trailing, 8)
                                    }
                                    .padding(.trailing, 8)

                                    // Trash Icon
                                    Button(action: {
                                        scheduleToDelete = schedule
                                        showDeleteAlert = true
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(scheduleArr.count < 2 ? .gray:.red)
                                    }
                                    .disabled(scheduleArr.count < 2)
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(isSelected ? selectedColor : (Color.clear))
                                .cornerRadius(10)
                                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                            }
                        }


                        .deleteDisabled(scheduleArr.count == 1)
                        Button(action:{
                            scheduleCreate = -1
                            showScheduleCreate.toggle()
                        }){
                            HStack {
                                Spacer()
                                HStack(spacing: 8) {
                                    Text("Create New Schedule").foregroundStyle(darkMode == selectedColor.isLight() ? selectedColor:.blue)
                                    Image(systemName: "plus.app").foregroundStyle(darkMode == selectedColor.isLight() ? selectedColor:.blue)
                                }
                                Spacer()
                            }
                            .padding(.horizontal)
                        }
                        .fullScreenCover(isPresented: $showScheduleCreate){
                            ScheduleCreationView(scheduleIndex: $scheduleCreate)
                        }
                    }
                    .alert(isPresented: $showDeleteAlert) {
                        let scheduleName = scheduleToDelete?.name ?? "this schedule"
                        return Alert(
                            title: Text("Delete Schedule?"),
                            message: Text("Are you sure you'd like to delete \(scheduleName)'s schedule?"),
                            primaryButton: .destructive(Text("Delete")) {
                                deleteScheduleConfirm()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                }
                Section(header: Text("App Theme")){
                    // Button to show the color picker sheet
                    Button(action: {
                        showColorPicker.toggle()
                    }) {
                        HStack {
                            Text("Select Color")
                                .foregroundStyle(darkMode ? .white:.black)
                            Spacer()
                            Rectangle()
                                .fill(selectedColor)
                                .frame(width: 30, height: 30)
                                .cornerRadius(5)
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 10).stroke(darkMode ? .white:.black))
                    }
                    .padding(.bottom, 5.0)
                    CarrierViewWithCircle(carrierTitle: "A Carrier", time: "8:30-9:30", carrier: "A")
                    Toggle(isOn: $darkMode) {
                        Text("Dark Mode")
                            .fontWeight(.medium)
                    }
                    .padding(.horizontal)
                }
                Section(header: Text("Customize Views"))
                {
                    Toggle(isOn: $scheduleView) {
                        Text("Scrolling Schedule")
                            .fontWeight(.medium)
                        Text("Enables number bar scrolling on Schedules")
                    }
                    .padding(.horizontal)
                    Toggle(isOn: $assignmentSharing) {
                        Text("Share Assignments with Schedule")
                            .fontWeight(.medium)
                        Text("Shares your assignments link when sharing a schedule")
                    }
                    .padding(.horizontal)
                    Toggle(isOn: $sportsView) {
                        Text("Sporting Events")
                            .fontWeight(.medium)
                        Text("Shows a button for sports on your calendar or home page")
                    }
                    .padding(.horizontal)
                }
                VStack{
                    Text("Created by Suman Muppavarapu ('26) & Jack Vu ('25)")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Text(
    """

    With help from: Ayaan Dhuka ('25), Enbao Cao ('25), Caiman Moreno-Earle ('25), Landon Doughty ('25)
"""
                    )
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Text("Art by Violet Vu ('28)")
                        .font(.caption)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Link("Suggest a Feature or Report a Bug", destination: URL(string: "https://docs.google.com/forms/d/e/1FAIpQLSchrbNGw5yb32LO5UWXmS6F7E_M-PYUq3fAfJIHvDMsoR4GdQ/viewform")!)
                        .font(.caption)
                        .padding(.horizontal)
                        .foregroundColor(.blue)
                        .underline()
                }
            }
            Spacer()
        }
        .padding(.top, 10.0)
        .padding(.bottom, 60.0)
        .sheet(isPresented: $showColorPicker) {
            CustomColorPicker(selectedColor: $selectedColor, isPresented: $showColorPicker)
                .onChange(of: selectedColor) { newColor in
                    saveColor(newColor)
                }
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding()
                .presentationDetents([.medium])
        }
        .navigationBarBackButtonHidden(true) // Hide default back button
            .toolbar {//custom back button cuz color
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack{
                            Image(systemName: "chevron.left")
                                .foregroundStyle(darkMode == color.isLight() ? color:textColor)
                                .font(.title3)
                            Text("Back")
                                .foregroundStyle(darkMode == color.isLight() ? color:textColor)
                                .font(.title3)
                        }
                    }
                }
            }
        .onAppear {
            if let storedColor = loadColor() {
                selectedColor = storedColor
            }
            scheduleArr = loadSchedules()
            if usingSchedule >= scheduleArr.count {
                usingSchedule = 0
            }
            if !scheduleArr.isEmpty {
                curSchedule = scheduleArr[usingSchedule]
            }
        }
    }
    
    private func deleteScheduleConfirm() {
            guard let scheduleToRemove = scheduleToDelete else { return }
            
            var scheduleArr = loadSchedules()
            if let index = scheduleArr.firstIndex(where: { $0.id == scheduleToRemove.id }) {
                scheduleArr.remove(at: index)
                if let encodedSchedules = try? JSONEncoder().encode(scheduleArr) {
                    schedulesData = encodedSchedules
                }
                WidgetCenter.shared.reloadAllTimelines()
            }
            
            // Clear the reference
            scheduleToDelete = nil
        }
    private func deleteSchedule(at offsets: IndexSet) {
        var scheduleArr = loadSchedules()
        // Remove schedules at the specified offsets
        scheduleArr.remove(atOffsets: offsets)

        // Save the updated array back to AppStorage
        if let encodedSchedules = try? JSONEncoder().encode(scheduleArr) {
            schedulesData = encodedSchedules
        }
        WidgetCenter.shared.reloadAllTimelines()
    }

    // Save the color in UserDefaults as Data
    private func saveColor(_ color: Color) {
        let uiColor = UIColor(color)
        if let data = try? NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false) {
            selectedColorData = data
        }
    }
    
    // Load the color from UserDefaults
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

    func exportScheduleAsJSON(schedule: Schedule, fileName: String = "schedule.json", presentingViewController: UIViewController) {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted

        do {
            // Encode the Schedule to JSON data
            let jsonData = try encoder.encode(schedule)

            // Get the document directory path
            if let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
                let fileURL = documentDirectory.appendingPathComponent(fileName)
                try jsonData.write(to: fileURL)

                // Create an activity view controller for sharing
                let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)

                // Present the activity view controller
                DispatchQueue.main.async {
                    presentingViewController.present(activityViewController, animated: true, completion: nil)
                }
            } else {
                print("Failed to retrieve the document directory.")
            }
        } catch {
            print("Failed to encode or write schedule: \(error)")
        }
    }


}

#Preview {
    TabControl()
}
