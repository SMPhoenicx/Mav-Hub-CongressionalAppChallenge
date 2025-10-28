// jvu was here, katie wasn't      :O!

import SwiftUI

enum Screen {
    case screen1, screen2, screen3, screen4, screen5, screen6, screen7
}

struct ScheduleHomeView: View {
    @Binding var tabSelection: TabBarItem
    @State var screen = Screen.screen1
    @State var dayOne = "1"
    @State var dayTwo = "2"
    @State var dayThree = "3"
    @State var dayFour = "4"
    @State var dayFive = "5"
    @State var daySix = "6"
    @State var daySeven = "7"
    @State private var buttonScale: CGFloat = 1.0
    @State var index = "1"
    
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
    let slideTransition = AnyTransition.opacity
    
    var body: some View {
        let color = loadColor() ?? Color.orange
        let isLight = color.isLight()
        let text2Color: Color = isLight ? .black:.white
        let textColor: Color = darkMode ? .white:.black
        NavigationStack{
            VStack {
                Text("Schedule")
                    .foregroundStyle(isLight == darkMode ? color:textColor)
                    .fontWeight(.semibold)
                    .fontDesign(.rounded)
                    .font(.headline)
                    .padding(.horizontal, 10.0)
                ScrollView{
                    switch screen {
                    case .screen1:
                        DayViewsNoEvent(dayValue: $dayOne, showAdds: false)
                            .transition(slideTransition)
                    case .screen2:
                        DayViewsNoEvent(dayValue: $dayTwo, showAdds: false)
                            .transition(slideTransition)
                    case .screen3:
                        DayViewsNoEvent(dayValue: $dayThree, showAdds: false)
                            .transition(slideTransition)
                    case .screen4:
                        DayViewsNoEvent(dayValue: $dayFour, showAdds: false)
                            .transition(slideTransition)
                    case .screen5:
                        DayViewsNoEvent(dayValue: $dayFive, showAdds: false)
                            .transition(slideTransition)
                    case .screen6:
                        DayViewsNoEvent(dayValue: $daySix, showAdds: false)
                            .transition(slideTransition)
                    case .screen7:
                        DayViewsNoEvent(dayValue: $daySeven, showAdds: false)
                            .transition(slideTransition)
                            .transition(slideTransition)
                    }
                }.padding(.top, 30)
                .frame(alignment:.center)
                Spacer()
                // Bottom button bar with animation
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            screen = .screen1
                            index = "1"
                        }
                    }) {
                        if screen == .screen1{
                            Image(systemName: "1.square.fill")
                                .resizable()
                                .frame(width: 40.0, height: 40.0)
                                .scaleEffect(1.3)
                                .padding(.leading, 10.0)
                                .padding(.trailing, 2.0)
                                .foregroundStyle(isLight == darkMode ? text2Color:textColor, color)
                        }
                        else{
                            Image(systemName: "1.square")
                                .resizable()
                                .frame(width: 40.0, height: 40.0)
                                .scaleEffect(buttonScale)
                                .padding(.leading, 10.0)
                                .padding(.trailing, 2.0)
                                .foregroundStyle(isLight == darkMode ? color:textColor)
                        }
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            screen = .screen2
                            index = "2"
                        }
                    }) {
                        if screen == .screen2{
                            Image(systemName: "2.square.fill")
                                .resizable()
                                .frame(width: 40.0, height: 40.0)
                                .scaleEffect(1.3)
                                .padding(.horizontal, 2.0)
                                .foregroundStyle(isLight == darkMode ? text2Color:textColor, color)
                        }
                        else{
                            Image(systemName: "2.square")
                                .resizable()
                                .frame(width: 40.0, height: 40.0)
                                .scaleEffect(buttonScale)
                                .padding(.horizontal, 2.0)
                                .foregroundStyle(isLight == darkMode ? color:textColor)
                        }
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            screen = .screen3
                            index = "3"
                        }
                    }) {
                        if screen == .screen3{
                            Image(systemName: "3.square.fill")
                                .resizable()
                                .frame(width: 40.0, height: 40.0)
                                .scaleEffect(1.3)
                                .padding(.horizontal, 2.0)
                                .foregroundStyle(isLight == darkMode ? text2Color:textColor, color)
                        }
                        else{
                            Image(systemName: "3.square")
                                .resizable()
                                .frame(width: 40.0, height: 40.0)
                                .scaleEffect(buttonScale)
                                .padding(.horizontal, 2.0)
                                .foregroundStyle(isLight == darkMode ? color:textColor)
                        }
                    }
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            screen = .screen4
                            index = "4"
                        }
                    }) {
                        if screen == .screen4{
                            Image(systemName: "4.square.fill")
                                .resizable()
                                .frame(width: 40.0, height: 40.0)
                                .scaleEffect(1.3)
                                .padding(.horizontal, 2.0)
                                .foregroundStyle(isLight == darkMode ? text2Color:textColor, color)
                        }
                        else{
                            Image(systemName: "4.square")
                                .resizable()
                                .frame(width: 40.0, height: 40.0)
                                .scaleEffect(buttonScale)
                                .padding(.horizontal, 2.0)
                                .foregroundStyle(isLight == darkMode ? color:textColor)
                        }
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            screen = .screen5
                            index = "5"
                        }
                    }) {
                        if screen == .screen5{
                            Image(systemName: "5.square.fill")
                                .resizable()
                                .frame(width: 40.0, height: 40.0)
                                .scaleEffect(1.3)
                                .padding(.horizontal, 2.0)
                                .foregroundStyle(isLight == darkMode ? text2Color:textColor, color)
                        }
                        else{
                            Image(systemName: "5.square")
                                .resizable()
                                .frame(width: 40.0, height: 40.0)
                                .scaleEffect(buttonScale)
                                .padding(.horizontal, 2.0)
                                .foregroundStyle(isLight == darkMode ? color:textColor)
                        }
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            screen = .screen6
                            index = "6"
                        }
                    }) {
                        if screen == .screen6{
                            Image(systemName: "6.square.fill")
                                .resizable()
                                .frame(width: 40.0, height: 40.0)
                                .scaleEffect(1.3)
                                .padding(.horizontal, 2.0)
                                .foregroundStyle(isLight == darkMode ? text2Color:textColor, color)
                        }
                        else{
                            Image(systemName: "6.square")
                                .resizable()
                                .frame(width: 40.0, height: 40.0)
                                .scaleEffect(buttonScale)
                                .padding(.horizontal, 2.0)
                                .foregroundStyle(isLight == darkMode ? color:textColor)
                        }
                    }
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            screen = .screen7
                            index = "7"
                        }
                    }) {
                        if screen == .screen7{
                            Image(systemName: "7.square.fill")
                                .resizable()
                                .frame(width: 40.0, height: 40.0)
                                .scaleEffect(1.3)
                                .padding(.trailing, 10.0)
                                .padding(.leading, 2.0)
                                .foregroundStyle(isLight == darkMode ? text2Color:textColor, color)
                        }
                        else{
                            Image(systemName: "7.square")
                                .resizable()
                                .frame(width: 40.0, height: 40.0)
                                .scaleEffect(buttonScale)
                                .padding(.trailing, 10.0)
                                .padding(.leading, 2.0)
                                .foregroundStyle(isLight == darkMode ? color:textColor)
                        }
                    }
                    Spacer()
                }
                .padding(.bottom, 50)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 10)
            }
            .onChange(of: tabSelection) { newTab in
                if newTab != .schedule {
                    DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                        screen = .screen1
                        index = "1"
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onDisappear {
            screen = .screen1
        }
    }
}

#Preview {
    TabControl()
}
