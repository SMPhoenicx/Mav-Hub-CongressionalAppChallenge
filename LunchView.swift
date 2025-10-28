import SwiftUI

struct LunchView: View {
    
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    @StateObject private var lunchdata = LunchData()
    @State private var selectedDay = ""
    var dateValue: Date
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        let color = loadColor() ?? Color.orange
        let isLight = color.isLight()
        let textColor:Color = darkMode ? .white:.black
        let text2Color: Color = color.isLight() ? .black : .white
        ScrollView{
            VStack {
                if let error = lunchdata.error {
                    Text(error)
                        .foregroundStyle(darkMode == isLight ? color:textColor)
                        .padding()
                } else if let lunchDetails = lunchdata.lunchItems[selectedDay] {
                    Text("Lunch for \(selectedDay)")
                        .foregroundStyle(darkMode == isLight ? color:textColor)
                        .fontWeight(.semibold)
                        .fontDesign(.rounded)
                        .font(.headline)
                        .padding(.horizontal, 10.0)
                        .font(.title)
                        .fontWeight(.bold)
                        .padding(.bottom, 10)
                    
                    VStack(alignment: .leading, spacing: 15) {
                        if let actionStation = lunchDetails.actionStation,
                           !actionStation.isEmpty {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Action Station")
                                    .foregroundStyle(darkMode == isLight ? color:textColor)
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                    .font(.headline)
                                HStack{
                                    Text(actionStation)
                                        .font(.body)
                                        .padding(.horizontal, 10.0)
                                    Spacer()
                                    
                                }
                            }
                            Divider()
                        }
                        
                        if let entreeOfTheDay = lunchDetails.entreeOfTheDay,
                           !entreeOfTheDay.isEmpty {
                            VStack(alignment: .leading){
                                HStack{
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Entree of the Day")
                                            .foregroundStyle(darkMode == isLight ? color:textColor)
                                            .fontWeight(.semibold)
                                            .fontDesign(.rounded)
                                            .font(.headline)
                                        Text(entreeOfTheDay)
                                            .font(.body)
                                            .padding(.horizontal, 10.0)
                                    }
                                    Spacer()
                                    VStack(alignment:.trailing){
                                        Spacer()
                                        Text("Plate Lunch*: $8.00")
                                        Text("Entrée + 1 Side: $6.00")
                                        Text("Entrée: $4.50")
                                    }
                                    .font(.system(size: 14))
                                }
                                Spacer()
                                Text("*Plate lunch is Entrée + 2 of: veg, desssert, milk/juice")
                                    .font(.caption2)
                            }
                            Divider()
                        }
                        
                        if let featureOfTheDay =  lunchDetails.featureOfTheDay,
                           !featureOfTheDay.isEmpty {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Feature of the Day")
                                    .foregroundStyle(darkMode == isLight ? color:textColor)
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                    .font(.headline)
                                HStack{
                                    Text(featureOfTheDay)
                                        .font(.body)
                                        .padding(.horizontal, 10.0)
                                    Spacer()
                                    if (featureOfTheDay.contains("Egg Rolls") || featureOfTheDay.contains("Tamale") || featureOfTheDay.contains("Pocket") || featureOfTheDay.contains("Slider")){
                                        Text(" $1.75")
                                    }
                                    else if (featureOfTheDay.contains("Chicken") || featureOfTheDay.contains("Shrimp") || featureOfTheDay.contains("Pizza") || featureOfTheDay.contains("BBQ") || featureOfTheDay.contains("Meatball") || featureOfTheDay.contains("Sausage") ||
                                             featureOfTheDay.contains("Gyro") || featureOfTheDay.contains("Hot Dog")){
                                        Text(" $3.50")
                                    }
                                    else if featureOfTheDay.contains("Corn Dog"){
                                        Text("$3.00")
                                    }
                                    else if featureOfTheDay.contains("French Fries"){
                                        Text("$3.00")
                                    }
                                    else if featureOfTheDay.contains("Potato"){
                                        VStack{
                                            Text("Loaded: $4.50")
                                            Text("Plain: $3.00")
                                        }
                                    }
                                    
                                    else{
                                        Text("Unknown")
                                    }
                                }
                            }
                            Divider()
                        }
                        
                        if let soupOfTheDay = lunchDetails.soupOfTheDay,
                           !soupOfTheDay.isEmpty {
                            HStack{
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Soup of the Day")
                                        .foregroundStyle(darkMode == isLight ? color:textColor)
                                        .fontWeight(.semibold)
                                        .fontDesign(.rounded)
                                        .font(.headline)
                                    Text(soupOfTheDay)
                                        .font(.body)
                                        .padding(.horizontal, 10.0)
                                }
                                Spacer()
                                VStack(alignment:.trailing){
                                    Spacer()
                                    Text("Large: $3.50")
                                    Text("Small: $2.50")
                                }
                            }
                            Divider()
                        }
                        
                        if let todaysSides = lunchDetails.todaysSides,
                           !todaysSides.isEmpty {
                            HStack(alignment: .top){
                                VStack(alignment: .leading, spacing: 5) {
                                    Text("Today's Sides")
                                        .foregroundStyle(darkMode == isLight ? color:textColor)
                                        .fontWeight(.semibold)
                                        .fontDesign(.rounded)
                                        .font(.headline)
                                    ForEach(todaysSides.indices){ index in
                                        Text(todaysSides[index])
                                            .font(.body)
                                            .padding(.horizontal, 10.0)
                                    }
                                    
                                }
                                Spacer()
                                Text("$2.00")
                            }
                            Divider()
                        }
                        
                        if let todaysVegetarianEntree = lunchDetails.todaysVegetarianEntree, !todaysVegetarianEntree.isEmpty {
                            VStack(alignment: .leading, spacing: 5) {
                                Text("Vegetarian Entree")
                                    .foregroundStyle(darkMode == isLight ? color:textColor)
                                    .fontWeight(.semibold)
                                    .fontDesign(.rounded)
                                    .font(.headline)
                                Text(todaysVegetarianEntree)
                                    .font(.body)
                                    .padding(.horizontal, 10.0)
                            }
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .shadow(radius: 5)
                    .padding(.horizontal)
                } else {
                    Text("Loading...")
                        .padding()
                }
            }
            .padding(.top)
            .onAppear {
                lunchdata.fetchData(from: "https://j05c9mz9da.execute-api.us-east-2.amazonaws.com/dev")
                selectedDay = getDayOfWeek(from: dateValue)
            }
        }
        .preferredColorScheme(.dark)
        .padding(.bottom, 55)
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
            ToolbarItem(placement: .topBarTrailing){
                NavigationLink(destination: LunchMenu()) {
                    HStack(alignment: .center, spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(text2Color)
                                .frame(width: 25, height: 25)
                            
                            Image(systemName: "menucard.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 13, height: 13)
                                .foregroundStyle(color)
                        }
                        .padding(.leading, 4)
                        Text("Menu")
                            .font(.system(size: 14))
                            .foregroundStyle(text2Color)
                            .padding(.trailing)
                    }
                    .padding(.vertical, 4) // Reduced vertical padding
                    .background(color)
                    .cornerRadius(16)
                }
            }
        }
    }
    
    func getDayOfWeek(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE"
        return dateFormatter.string(from: date)
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
    TabControl()
}
