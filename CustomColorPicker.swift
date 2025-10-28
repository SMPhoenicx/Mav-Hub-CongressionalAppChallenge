//
//  CustomColorPicker.swift
//  NewMavApp
//
//  Created by Suman Muppavarapu on 9/2/24.
//

import SwiftUI
import WidgetKit

struct CustomColorPicker: View {
    @Binding var selectedColor: Color
    @Binding var isPresented: Bool // New binding to control sheet dismissal
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    private func saveColor(color: Color) {
            let uiColor = UIColor(color) // Convert Color to UIColor
            do {
                let data = try NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false)
                let defaults = UserDefaults(suiteName: "group..com.jackrvu.mavhub.dayViews")!
                defaults.set(data, forKey: "selectedColor")
            } catch {
                print("Failed to archive color: \(error)")
            }
        }
    let ourColors: [Color] = [.red, .blue, .green,
                              Color(red: 173/255, green: 173/255, blue: 173/255),
                              Color(red: 71/255, green: 71/255, blue: 71/255),
                              Color(red: 30/255, green: 76/255, blue: 99/255),
                              Color(red: 71/255, green: 159/255, blue: 211/255),
                              Color(red: 120/255, green: 211/255, blue: 248/255),
                              Color(red: 165/255, green: 225/255, blue: 250/255),
                              Color(red: 215/255, green: 250/255, blue: 248/255),
                              Color(red: 16/255, green: 46/255, blue: 118/255),
                              Color(red: 35/255, green: 85/255, blue: 206/255),
                              Color(red: 79/255, green: 133/255, blue: 246/255),
                              Color(red: 127/255, green: 165/255, blue: 248/255),
                              Color(red: 51/255, green: 27/255, blue: 142/255),
                              Color(red: 71/255, green: 36/255, blue: 171/255),
                              Color(red: 126/255, green: 82/255, blue: 245/255),
                              Color(red: 171/255, green: 141/255, blue: 247/255),
                              Color(red: 89/255, green: 30/255, blue: 120/255),
                              Color(red: 140/255, green: 51/255, blue: 182/255),
                              Color(red: 196/255, green: 95/255, blue: 246/255),
                              Color(red: 233/255, green: 203/255, blue: 251/255),
                              Color(red: 111/255, green: 34/255, blue: 61/255),
                              Color(red: 141/255, green: 46/255, blue: 79/255),
                              Color(red: 170/255, green: 57/255, blue: 93/255),
                              Color(red: 222/255, green: 120/255, blue: 157/255),
                              Color(red: 232/255, green: 167/255, blue: 191/255),
                              Color(red: 120/255, green: 34/255, blue: 14/255),
                              Color(red: 166/255, green: 44/255, blue: 23/255),
                              Color(red: 237/255, green: 108/255, blue: 89/255),
                              Color(red: 240/255, green: 146/255, blue: 134/255),
                              Color(red: 237/255, green: 115/255, blue: 46/255),
                              Color(red: 239/255, green: 140/255, blue: 86/255),
                              Color(red: 242/255, green: 169/255, blue: 132/255),
                              Color(red: 243/255, green: 175/255, blue: 61/255),
                              Color(red: 246/255, green: 202/255, blue: 131/255),
                              Color(red: 249/255, green: 218/255, blue: 174/255),
                              Color(red: 245/255, green: 201/255, blue: 68/255),
                              Color(red: 248/255, green: 218/255, blue: 133/255),
                              Color(red: 250/255, green: 229/255, blue: 175/255),
                              Color(red: 243/255, green: 236/255, blue: 78/255),
                              Color(red: 254/255, green: 247/255, blue: 129/255),
                              Color(red: 254/255, green: 251/255, blue: 192/255),
                              Color(red: 198/255, green: 209/255, blue: 71/255),
                              Color(red: 221/255, green: 235/255, blue: 92/255),
                              Color(red: 235/255, green: 242/255, blue: 155/255),
                              Color(red: 43/255, green: 61/255, blue: 22/255),
                              Color(red: 88/255, green: 121/255, blue: 52/255),
                              Color(red: 134/255, green: 185/255, blue: 83/255),
                              Color(red: 163/255, green: 209/255, blue: 110/255),
                              Color(red: 186/255, green: 220/255, blue: 148/255)]
    
    let gridItemLayout = [GridItem(.adaptive(minimum: 21))]
    
    var body: some View {
        let lightColors = ourColors.filter{!$0.isLight()}
        let darkColors = ourColors.filter{$0.isLight()}
        VStack {
            HStack {
                Spacer()
                Button(action: {
                    isPresented = false // Dismiss the picker
                }) {
                    Image(systemName: "xmark")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                }
            }
            Text("Recommended for dark mode:")
                .foregroundStyle(Color.black)
                .padding(.bottom, -10)
            LazyVGrid(columns: gridItemLayout, spacing: 3) {
                ForEach(darkColors, id: \.self) { color in
                    ColorSquare(color: color)
                        .onTapGesture {
                            selectedColor = color
                            saveColor(color: color)
                            WidgetCenter.shared.reloadAllTimelines()
                        }
                }
            }
            .padding()
            Text("Recommended for light mode:")
                .foregroundStyle(Color.black)
                .padding(.bottom, -10)
            LazyVGrid(columns: gridItemLayout, spacing: 3) {
                ForEach(lightColors, id: \.self) { color in
                    ColorSquare(color: color)
                        .onTapGesture {
                            selectedColor = color
                            saveColor(color: color)
                        }
                }
            }
            .padding()
        }
    }
}

struct ColorSquare: View {
    let color: Color

    var body: some View {
        color
            .frame(width: 25, height: 25)
            .cornerRadius(3)
            .overlay(
                RoundedRectangle(cornerRadius: 3)
                    .stroke(Color.black.opacity(0.2), lineWidth: 1)
            )
    }
}

extension Color {
    func luminance() -> Double {
        let components = UIColor(self).cgColor.components!
        let red = components[0]
        let green = components[1]
        let blue = components[2]

        func channel(_ value: CGFloat) -> CGFloat {
            return value < 0.03928 ? value / 12.92 : pow((value + 0.055) / 1.055, 2.4)
        }

        return 0.2126 * channel(red) + 0.7152 * channel(green) + 0.0722 * channel(blue)
    }
    
    func isLight() -> Bool {
        return self.luminance() > 0.21
    }
    /*func contrastRatio(with color: Color) -> Double {
            let luminance1 = self.luminance() + 0.05
            let luminance2 = color.luminance() + 0.05
            return max(luminance1, luminance2) / min(luminance1, luminance2)
        }
        
    // Determine if the text color is visible on a given background color
    func isVisibleOn(background color: Color) -> Bool {
        let contrastRatio = self.contrastRatio(with: color)
        return contrastRatio < 4.5
    }
    func isModerateOn(background color: Color) -> Bool {
        let contrastRatio = self.contrastRatio(with: color)
        return contrastRatio < 4.5 && contrastRatio > 2.3
    }*/
}

#Preview{
    TabControl()
}
