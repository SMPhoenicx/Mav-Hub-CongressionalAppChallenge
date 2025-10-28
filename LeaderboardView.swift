//
//  LeaderboardView.swift
//  NewMavApp
//
//  Created by Suman Muppavarapu on 8/23/24.
//
// jvu was here

import SwiftUI

struct LeaderboardView: View {
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    @StateObject private var network = Network()
    @State private var colors = [
        "Chidsey": Color(red: 138 / 255, green: 1 / 255, blue: 1 / 255), //always first for a reason
        "Hoodwink": Color(red: 0 / 255, green: 54 / 255, blue: 181 / 255),
        "Claremont": Color(red: 60 / 255, green: 1 / 255, blue: 138 / 255),
        "Mulligan": Color(red: 9 / 255, green: 69 / 255, blue: 1 / 255),
        "Winston": Color(red: 214 / 255, green: 175 / 255, blue: 2 / 255),
        "Taub": Color(red: 2 / 255, green: 154 / 255, blue: 168 / 255)
    ]
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        let color = loadColor() ?? Color.orange
        let isLight = color.isLight()
        let textColor:Color = darkMode ? .white:.black
        VStack{
            Text("House Games Leaderboard")
                .foregroundStyle(darkMode == isLight ? color:textColor)
                .fontWeight(.semibold)
                .fontDesign(.rounded)
                .font(.headline)
                .padding(.horizontal, 10.0)
            Rectangle()
                .frame(height: 1)
                .foregroundStyle(Color(red: 50 / 255, green: 50 / 255, blue: 50 / 255))
                .padding(.horizontal, 2.0)
            
            VStack {
                HStack{
                    VStack{
                        if network.rankings.indices.contains(1) {
                            Text(network.rankings[1].name)
                                .font(.title2)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                            ZStack{
                                RoundedRectangle(cornerRadius:20)
                                    .fill(colors[network.rankings[1].name]!.gradient)
                                    .frame(width: 100, height: 130)
                                VStack{
                                    Text("2nd")
                                        .font(.largeTitle)
                                        .fontWeight(.semibold)
                                        .foregroundStyle(Color(.white))
                                        .fontDesign(.rounded)
                                    
                                    .padding(.bottom, 5.0)
                                    if #available(iOS 17.0, *) {
                                        Text("\(network.rankings[1].points)")
                                            .foregroundStyle(Color(.black))
                                            .font(.headline)
                                            .background(Capsule()
                                                .stroke(.black, lineWidth: 5.0)
                                                .fill(Color(red: 192 / 255, green: 192 / 255, blue: 192 / 255))
                                                .frame(width: 40.0, height: 30.0)
                                            )
                                    } else {
                                        Text("\(network.rankings[1].points)")
                                            .foregroundStyle(Color(.black))
                                            .font(.headline)
                                            .background(Capsule()
                                                .fill(Color(red: 192 / 255, green: 192 / 255, blue: 192 / 255))
                                                .frame(width: 40.0, height: 30.0)
                                            )
                                    }
                                }
                            }
                        }
                    }
                    .offset(y: 15)
                    VStack{
                        if network.rankings.indices.contains(0) {
                            Text(network.rankings[0].name)
                                .font(.title2)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                            ZStack{
                                RoundedRectangle(cornerRadius:20)
                                    .fill(colors[network.rankings[0].name]!.gradient)
                                    .frame(width: 100, height: 160)
                                VStack{
                                    Text("1st")
                                        .font(.largeTitle)
                                        .fontWeight(.semibold)
                                        .fontDesign(.rounded)
                                        .foregroundStyle(Color(.white))
                                        .padding(.bottom, 5.0)
                                    if #available(iOS 17.0, *) {
                                        Text("\(network.rankings[0].points)")
                                            .foregroundStyle(Color(.black))
                                            .font(.headline)
                                            .background(Capsule()
                                                .stroke(.black, lineWidth: 5.0)
                                                .fill(Color(red: 255 / 255, green: 215 / 255, blue: 0 / 255))
                                                .frame(width: 40.0, height: 30.0)
                                            )
                                    } else {
                                        Text("\(network.rankings[0].points)")
                                            .foregroundStyle(Color(.black))
                                            .font(.headline)
                                            .background(Capsule()
                                                .fill(Color(red: 255 / 255, green: 215 / 255, blue: 0 / 255))
                                                .frame(width: 40.0, height: 30.0)
                                            )
                                    }
                                }
                            }
                        }
                    }
                    VStack{
                        if network.rankings.indices.contains(2) {
                            Text(network.rankings[2].name)
                                .font(.title2)
                                .fontWeight(.medium)
                                .fontDesign(.rounded)
                            ZStack{
                                RoundedRectangle(cornerRadius:20)
                                    .fill(colors[network.rankings[2].name]!.gradient)
                                    .frame(width: 100, height: 110)
                                VStack{
                                    Text("3rd")
                                        .font(.largeTitle)
                                        .fontWeight(.semibold)
                                        .fontDesign(.rounded)
                                        .foregroundStyle(Color(.white))
                                        .padding(.bottom, 5.0)
                                    if #available(iOS 17.0, *) {
                                        Text("\(network.rankings[2].points)")
                                            .foregroundStyle(Color(.black))
                                            .font(.headline)
                                            .background(Capsule()
                                                .stroke(.black, lineWidth: 5.0)
                                                .fill(Color(red: 172 / 255, green: 128 / 255, blue: 66 / 255))
                                                .frame(width: 40.0, height: 30.0)
                                            )
                                    } else {
                                        Text("\(network.rankings[2].points)")
                                            .foregroundStyle(Color(.black))
                                            .font(.headline)
                                            .background(Capsule()
                                                .fill(Color(red: 172 / 255, green: 128 / 255, blue: 66 / 255))
                                                .frame(width: 40.0, height: 30.0)
                                            )
                                    }
                                    
                                }
                            }
                        }
                    }
                    .offset(y: 25)
                    
                }
                .padding(.top, 20.0)
                VStack{
                    if network.rankings.indices.contains(3) {
                        HStack(alignment: .center, spacing: 16) {
                            ZStack {
                                if #available(iOS 17.0, *) {
                                    Circle()
                                        .stroke(.white, lineWidth: 5.0)
                                        .fill(colors[network.rankings[3].name]!)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Text("4")
                                                .font(.title3)
                                                .fontDesign(.rounded)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(Color(.white))
                                        )
                                } else {
                                    Circle()
                                        .fill(colors[network.rankings[3].name]!)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Text("4")
                                                .font(.title3)
                                                .fontDesign(.rounded)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(Color(.white))
                                        )
                                }
                            }
                            .padding(.leading, 10)
                            Text(network.rankings[3].name)
                                .font(.title3)
                                .foregroundStyle(Color(.white))
                                .fontDesign(.rounded)
                                .fontWeight(.semibold)
                            Spacer()
                            Text("\(network.rankings[3].points)")
                                .font(.title3)
                                .foregroundStyle(Color(.white))
                                .fontDesign(.rounded)
                                .fontWeight(.semibold)
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 8) // Reduced vertical padding
                        .background(colors[network.rankings[3].name]!)
                        .cornerRadius(28)
                        .padding(.horizontal) // Keep the horizontal padding as it is
                    }
                    if network.rankings.indices.contains(4) {
                        HStack(alignment: .center, spacing: 16) {
                            ZStack {
                                if #available(iOS 17.0, *) {
                                    Circle()
                                        .stroke(.white, lineWidth: 5.0)
                                        .fill(colors[network.rankings[4].name]!)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Text("5")
                                                .font(.title3)
                                                .fontDesign(.rounded)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(Color(.white))
                                        )
                                } else {
                                    Circle()
                                        .fill(colors[network.rankings[4].name]!)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Text("5")
                                                .font(.title3)
                                                .fontDesign(.rounded)
                                                .fontWeight(.semibold)
                                            .foregroundStyle(Color(.white))
                                        )
                                }
                            }
                            .padding(.leading, 10)
                            Text(network.rankings[4].name)
                                .font(.title3)
                                .fontDesign(.rounded)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(.white))
                            Spacer()
                            Text("\(network.rankings[4].points)")
                                .font(.title3)
                                .fontDesign(.rounded)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(.white))
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 8) // Reduced vertical padding
                        .background(colors[network.rankings[4].name]!)
                        .cornerRadius(28)
                        .padding(.horizontal) // Keep the horizontal padding as it is
                    }
                    if network.rankings.indices.contains(5) {
                        HStack(alignment: .center, spacing: 16) {
                            ZStack {
                                if #available(iOS 17.0, *) {
                                    Circle()
                                        .stroke(.white, lineWidth: 5.0)
                                        .fill(colors[network.rankings[5].name]!)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Text("6")
                                                .font(.title3)
                                                .fontDesign(.rounded)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(Color(.white)       )
                                        )
                                } else {
                                    Circle()
                                        .fill(colors[network.rankings[5].name]!.gradient)
                                        .frame(width: 40, height: 40)
                                        .overlay(
                                            Text("6")
                                                .font(.title3)
                                                .fontDesign(.rounded)
                                                .fontWeight(.semibold)
                                                .foregroundStyle(Color(.white))
                                        )
                                }
                            }
                            .padding(.leading, 10)
                            Text(network.rankings[5].name)
                                .font(.title3)
                                .fontDesign(.rounded)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(.white))
                            Spacer()
                            Text("\(network.rankings[5].points)")
                                .font(.title3)
                                .fontDesign(.rounded)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color(.white))
                                .padding(.horizontal)
                        }
                        .padding(.vertical, 8) // Reduced vertical padding
                        .background(colors[network.rankings[5].name]!)
                        .cornerRadius(28)
                        .padding(.horizontal) // Keep the horizontal padding as it is
                    }
                }
                Spacer()
            }
            .onAppear {
                network.getRankings()
            }
        }
        .navigationBarBackButtonHidden(true) // Hide default back button
            .toolbar {//custom back button cuz color
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        HStack{
                            Image(systemName: "chevron.left")
                                .foregroundStyle(darkMode == isLight ? color:textColor)
                                .font(.title3)
                            Text("Back")
                                .foregroundStyle(darkMode == isLight ? color:textColor)
                                .font(.title3)
                        }
                    }
                }
            }
    }
    func grayDivider() -> some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(.gray)
            .padding(.top, 3)
            .padding(.bottom, 5)
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
#Preview {
    LeaderboardView()
}
