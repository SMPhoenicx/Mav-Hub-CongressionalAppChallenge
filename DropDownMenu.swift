import SwiftUI
import WidgetKit

struct DropDownMenu: View {
    
    @Binding var isMenuOpen:Bool
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    @AppStorage("usingSchedule", store: defaults) private var usingSchedule:Int = 0
    @Binding var scheduleArr: [Schedule]
    var body: some View {
        let color = loadColor() ?? Color.orange
        let isLight = color.isLight()
        let textColor:Color = darkMode ? .white:.black;
        ZStack {
            ForEach(scheduleArr, id: \.id){ schedule in
                if let index = scheduleArr.firstIndex(where: { $0.id == schedule.id }) {
                    Button(action:{
                        usingSchedule = index
                        WidgetCenter.shared.reloadAllTimelines()
                    })
                    {
                        ZStack {
                            if #available(iOS 17.0, *) {
                                Capsule()
                                    .fill(.regularMaterial)
                                    .stroke(darkMode == isLight ? color:textColor, lineWidth: 2)
                                    .frame(width: 110, height: 45)
                            } else {
                                Capsule()
                                    .fill(textColor)
                                    .frame(width: 110, height: 45)
                                    .overlay(
                                            Capsule()
                                                .stroke(Color.red, lineWidth: 4)
                                        )
                            }
                            HStack{
                                Text(schedule.name)
                                    .foregroundStyle(textColor)
                                    .font(.system(size: 14, weight: .bold, design: .rounded))
                                    .lineLimit(1)
                                    .truncationMode(.tail)
                                if usingSchedule == index{
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(textColor)
                                        .font(.system(size: 14, weight: .bold, design: .rounded))
                                }
                            }
                            .padding(.horizontal, 8)
                        }
                    }
                    .displayOnMenuOpen(isMenuOpen, offset: CGFloat((index+1)*50))
                    .zIndex(2) // Ensure menu items are above other content
                }
            }
            ZStack {
                Circle()
                    .frame(width: 35, height: 35)
                    .foregroundColor(color)
                
                Image(systemName:"list.bullet")
                    .foregroundColor(isLight ? .black:.white)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
            }
            .onTapGesture {
                withAnimation{
                    isMenuOpen.toggle()
                }
            }
            .zIndex(3)
        }
        .preferredColorScheme(darkMode ? .dark:.light)
    }
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
}
 
struct DisplayOnOpenMenuViewModifier: ViewModifier {
    
    let isOpened: Bool
    let offset: CGFloat
    
    func body(content: Content) -> some View {
        content
            .shadow(color: .black.opacity(isOpened ? 0.1 : 0.0), radius: 10, x: 0, y: 5)
            .offset(x: 0, y: isOpened ? offset : 0)
            .animation(.spring(response: 0.5, dampingFraction: 0.5, blendDuration: 0.5), value: isOpened)
            .opacity(isOpened ? 1.0 : 0.0)
    }
}
 
extension View {
    func displayOnMenuOpen(_ isOpened: Bool, offset: CGFloat) -> some View {
        modifier(DisplayOnOpenMenuViewModifier(isOpened: isOpened, offset: offset))
    }
}

#Preview{
    TabControl()
}
