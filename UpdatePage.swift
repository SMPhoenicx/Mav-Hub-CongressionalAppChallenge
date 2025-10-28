//
//  UpdatePage.swift
//  NewMavApp
//
//  Created by Suman Muppavarapu on 9/2/24.
//

import SwiftUI

struct UpdatePage: View{
    @AppStorage("updatePage") private var updatePage: Bool = true
    @EnvironmentObject private var calendarModel: CalendarViewModel
    enum NavigationTarget {
        case home
    }
    @State private var navigationPath = NavigationPath()
    var body: some View{
        VStack{
            Text("Update Info")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()
            List{
                Section(header: Text("What's New?")){
                    Text("""
- Updated for the new school year!
- Added Fine Arts and other important dates to calendar. Calendar is also more up-to-date now.
- Made Wordle fit better
- Have fun waking up and coming back to school!
""")
                        .multilineTextAlignment(.leading)
                }
                Section(header: Text("Future")){
                    Text("""
Bug fixes, open to new ideas.
""")
                }
            }
            Button(action: {
                updatePage = false
                navigationPath.append(NavigationTarget.home)
            }) {
                Text("OK")
                    .frame(maxWidth: 120, minHeight: 44)
                    .foregroundStyle(Color(.black))
                    .background(.white) // Apply background color directly to the button
                    .cornerRadius(6.0) // Optional: Rounded corners
                    .padding(.horizontal, 8) // Optional: Padding around the button
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview{
    UpdatePage()
}
