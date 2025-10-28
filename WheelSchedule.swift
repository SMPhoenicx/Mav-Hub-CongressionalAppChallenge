
// jvu was here
import SwiftUI

struct WheelSchedule: View {
    @State private var selectedIndex: Int = 0
    @State private var buttonPositions: [CGFloat] = []
    @State private var indexSelect: String = "1"
    
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
    
    let buttonTitles = ["1", "2", "3", "4", "5", "6", "7"]
    
    var body: some View {
        let color = loadColor() ?? Color.orange
        let isLight = color.isLight()
        let boxColor: Color = darkMode ? .white:.black
        GeometryReader { geometry in
            NavigationStack{
                VStack {
                    Text("Schedule")
                        .foregroundStyle(isLight == darkMode ? color:boxColor)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .font(.headline)
                        .padding(.horizontal, 10.0)
                    Spacer()
                    ScrollView{
                        DayViewsNoEvent(dayValue: $indexSelect, showAdds: false)
                            .frame(alignment:.center)
                    }.padding(.top, 50)
                    
                    ScrollViewReader { scrollViewProxy in
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(0..<buttonTitles.count, id: \.self) { index in
                                    Button(action: {
                                        withAnimation {
                                            selectedIndex = index
                                            indexSelect = "\(index + 1)"
                                            scrollViewProxy.scrollTo(index, anchor: .center) // Scroll to the center
                                        }
                                    }) {
                                        Image(systemName: "\(buttonTitles[index]).square")
                                            .font(.system(size: 40)) // Adjust icon size
                                            .foregroundStyle( selectedIndex != index ? boxColor:color)
                                            .frame(width: 40, height: 40) // Adjust button size
                                            .scaleEffect(selectedIndex == index ? 1.3 : 1.0)
                                            .animation(.spring(response: 0.3, dampingFraction: 0.6, blendDuration: 0.5), value: selectedIndex)
                                    }
                                    .padding(.vertical, 10)
                                    .background(GeometryReader { geo in
                                        Color.clear
                                            .preference(key: ButtonPositionPreferenceKey.self, value: [geo.frame(in: .global).midX])
                                    })
                                    .id(index) // Assign an ID to each button
                                }
                            }
                            .padding(.horizontal, (geometry.size.width - 60) / 2) // Center the buttons horizontally
                        }
                        .frame(height: 54) // Adjust height as needed
                        .onPreferenceChange(ButtonPositionPreferenceKey.self) { positions in
                            guard !positions.isEmpty, positions.count == buttonTitles.count else { return }
                            let centerX = geometry.size.width / 2
                            let closestIndex = buttonTitles.indices.min(by: { abs(positions[$0] - centerX) < abs(positions[$1] - centerX) }) ?? 0
                            selectedIndex = closestIndex
                            indexSelect = "\(closestIndex + 1)"
                        }
                    }
                    Color.clear.frame(height: 50)
                }
            }
        }
    }
}

// Define a PreferenceKey to store button positions
struct ButtonPositionPreferenceKey: PreferenceKey {
    static var defaultValue: [CGFloat] = []
    
    static func reduce(value: inout [CGFloat], nextValue: () -> [CGFloat]) {
        value.append(contentsOf: nextValue())
    }
}

#Preview {
   TabControl()
}
