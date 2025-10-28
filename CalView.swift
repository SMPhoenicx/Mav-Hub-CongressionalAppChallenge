//
//  CalView.swift
//  NewMavApp
//
//  Created by Suman Muppavarapu on 9/1/24.
//
// jvu was here
import SwiftUI
struct CalView: View{
    @Binding var tabSelection: TabBarItem
    @State var curDate: Date = Date()
    @State var index: String = "1"
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    @Binding var navigationPath: NavigationPath
    
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
        let textColor: Color = darkMode ? .white:.black
        NavigationStack(path: $navigationPath){
            HStack{
                Text("Calendar")
                    .foregroundStyle(color.isLight() == darkMode ? color:textColor)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .font(.headline)
                    .padding(.horizontal, 10.0)
            }
            ScrollView(.vertical, showsIndicators: false){
                HStack{
                    Spacer()
                    NavigationLink(destination: CalendarInfoPage()) {
                        ZStack{
                            Circle()
                                .fill(color)
                                .frame(width: 35, height: 35)
                            Image(systemName: "questionmark")
                                .resizable()
                                .frame(width: 10, height: 15)
                                .foregroundStyle(color.isLight() ? .black : .white)
                        }.frame(width: 64)
                            .padding(.leading)
                    }
                    
                }
                    CustomDatePicker(currentDate: $curDate, tabSelection: $tabSelection)
            }
        }
    }
}

#Preview{
    TabControl()
}
