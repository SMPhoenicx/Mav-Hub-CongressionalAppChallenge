//
//  CalendarInfoPage.swift
//  NewMavApp
//
//  Created by Suman Muppavarapu on 8/13/25.
//

import SwiftUI

struct CalendarInfoPage: View {
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    
    var body: some View {
        let color = loadColor() ?? Color.orange
        let textColor: Color = darkMode ? .white : .black
        
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Event Colors Card
                    VStack(alignment: .leading, spacing: 15) {
                        HStack {
                            Rectangle()
                                .fill(color)
                                .frame(width: 5, height: 30)
                            
                            Text("Event Color Guide")
                                .font(.system(size: 22, weight: .bold, design: .rounded))
                                .foregroundColor(textColor)
                                .padding(.leading, 8)
                            
                            Spacer()
                        }
                        
                        VStack(spacing: 12) {
                            EventColorRow(color: .red, title: "Important Dates", textColor: textColor)
                            EventColorRow(color: .green, title: "Events", textColor: textColor)
                            EventColorRow(color: .purple, title: "Athletics", textColor: textColor)
                            EventColorRow(color: .orange, title: "Fine Arts", textColor: textColor)
                        }
                        .padding(.horizontal, 10)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(darkMode ? Color.black.opacity(0.4) : Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(darkMode ? color.opacity(0.7) : color.opacity(0.3), lineWidth: 1)
                    )
                    
                    // Disclaimer Card
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Rectangle()
                                .fill(color)
                                .frame(width: 5, height: 25)
                            
                            Text("Important Notice")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(textColor)
                                .padding(.leading, 8)
                            
                            Spacer()
                        }
                        
                        Text("Timings are not always accurate, so ensure to check. Calendar updated every 24 hours, so recently rescheduled events might not be reflected.")
                            .font(.system(size: 14, weight: .regular, design: .rounded))
                            .foregroundColor(darkMode ? textColor.opacity(0.8) : .gray)
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                            .padding(.horizontal, 10)
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(darkMode ? Color.black.opacity(0.4) : Color.white)
                            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 15)
                            .stroke(darkMode ? color.opacity(0.7) : color.opacity(0.3), lineWidth: 1)
                    )
                    
                    Spacer(minLength: 20)
                }
                .padding(.horizontal)
                .padding(.top, 10)
            }
            .navigationTitle("Info")
            .navigationBarTitleDisplayMode(.large)
        }
    }
    
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
}

struct EventColorRow: View {
    let color: Color
    let title: String
    let textColor: Color
    
    var body: some View {
        HStack(spacing: 15) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(width: 30, height: 30)
            
            Text(title)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(textColor)
            
            Spacer()
        }
    }
}

// MARK: - Preview
#Preview {
    CalendarInfoPage()
}
