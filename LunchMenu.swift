//
//  LunchMenu.swift
//  NewMavApp
//
//  Created by Suman Muppavarapu on 12/31/24.
//
import SwiftUI

struct LunchMenu:View{
    @State private var selectedSection: MenuSection = .all
    @AppStorage("darkMode", store: defaults) private var darkMode: Bool = true
    @AppStorage("selectedColor", store: defaults) var selectedColorData: Data = Data()
    @Environment(\.presentationMode) var presentationMode
    var body:some View{
        let color = loadColor() ?? .orange
        let textColor:Color = darkMode ? .white:.black
        VStack(alignment: .trailing){
            Picker("Select Section", selection: $selectedSection) {
                            ForEach(MenuSection.allCases) { section in
                                Text(section.rawValue).tag(section)
                            }
                        }
            .tint(darkMode == color.isLight() ? color:.blue)
                        .padding()
            ScrollView{
                VStack(alignment: .trailing){
                    if selectedSection == .all || selectedSection == .mainMeal{
                        //MARK: Main Meal
                        MainMeal(darkMode: darkMode)
                    }
                    if selectedSection == .all || selectedSection == .sandwichBar{
                        //MARK: Sandwich Bar
                        SandwichBar(darkMode: darkMode)
                    }
                    if selectedSection == .all || selectedSection == .chefsTable{
                        //MARK: Chef's Table
                        ChefsTable(darkMode: darkMode)
                    }
                    if selectedSection == .all || selectedSection == .spudSoup{
                        //MARK: Spuds & Soup
                        SpudSoup(darkMode: darkMode)
                    }
                    if selectedSection == .all || selectedSection == .selfBar{
                        //MARK: Breakfast/Salad Bar
                        SelfBar(darkMode: darkMode)
                    }
                    if selectedSection == .all || selectedSection == .desserts{
                        //MARK: Desserts
                        //TODO: NEED TO EDIT THE PICTURE
                        Desserts(darkMode: darkMode)
                    }
                    
                    if selectedSection == .all || selectedSection == .beverages{
                        //MARK: Beverages
                        Beverages(darkMode: darkMode)
                    }
                    
                    if selectedSection == .all || selectedSection == .snacks{
                        //MARK: Snacks
                        Snacks(darkMode: darkMode)
                    }
                    
                    if selectedSection == .all || selectedSection == .fastFood{
                        //MARK: Fast Food
                        FastFood()
                    }
                    if selectedSection == .all || selectedSection == .breakfast{
                        //MARK: Breakfast
                        Breakfast()
                    }
                    
                    if selectedSection == .all || selectedSection == .extras{
                        //MARK: Extras
                        Extras(darkMode: darkMode)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .navigationTitle(Text("Lunch Menu"))
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
        .padding(.bottom, 55)
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

struct MainMeal:View{
    
    let darkMode: Bool
    var body: some View{
        HStack{
            VStack(alignment: .trailing){
                Text("Main Meal")
                    .font(.title2)
                    .fontDesign(.serif)
                    .fontWeight(.bold)
                Divider()
                    .frame(width: 200)
                    .background(.white)
                HStack{
                    Text("Entrée")
                        .multilineTextAlignment(.leading)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$4.50")
                        .fontDesign(.serif)
                }
                .padding(.leading)
                HStack{
                    Text("+1 Veggie")
                        .multilineTextAlignment(.leading)
                        .italic()
                        .fontDesign(.serif)
                    Text("$6.00")
                        .fontDesign(.serif)
                }
                .padding(.leading)
                .padding(.bottom, 6)
                VStack(alignment: .leading){
                    HStack{
                        Text("Plate Lunch")
                            .multilineTextAlignment(.leading)
                            .padding(.trailing)
                            .fontDesign(.serif)
                        Spacer()
                        Text("$8.00")
                            .fontDesign(.serif)
                    }
                    Text("Entrée + choice of two: veg, dessert, milk, or juice")
                        .font(.caption)
                        .fontDesign(.monospaced)
                        .padding(.trailing, 16)
                        .italic()
                        .foregroundColor(.secondary)
                }
                .padding(.leading)
                .padding(.bottom, 6)
                HStack{
                    Text("Vegetable")
                        .multilineTextAlignment(.leading)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$2.00")
                        .fontDesign(.serif)
                }
                .padding(.leading)
                .padding(.bottom, 6)
                HStack{
                    Text("Breads")
                        .multilineTextAlignment(.leading)
                        .padding(.trailing)
                        .fontDesign(.serif)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.leading)
                HStack{
                    Text("Wheat Slice")
                        .multilineTextAlignment(.leading)
                        .italic()
                        .padding(.leading, 30)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$0.25")
                        .fontDesign(.serif)
                }
                HStack{
                    Text("Garlic Bread")
                        .multilineTextAlignment(.leading)
                        .italic()
                        .padding(.leading, 30)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$1.00")
                        .fontDesign(.serif)
                }
                HStack{
                    Text("Dinner Roll")
                        .multilineTextAlignment(.leading)
                        .italic()
                        .padding(.leading, 30)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$1.00")
                        .fontDesign(.serif)
                }
                HStack{
                    Text("Corn Muffins")
                        .multilineTextAlignment(.leading)
                        .italic()
                        .padding(.leading, 30)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$1.25")
                        .fontDesign(.serif)
                }
            }
            .frame(width: 210)
            Spacer()
            Image(.plateFork)
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(darkMode ? .white:.black)
                .scaledToFit()
        }
    }
}
struct SandwichBar:View{
    let darkMode: Bool
    var body: some View{
        HStack{
            Image(.sandwich)
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(darkMode ? .white:.black)
                .scaledToFit()
            VStack(alignment: .leading){
                Text("Sandwich Bar")
                    .font(.title2)
                    .fontDesign(.serif)
                    .fontWeight(.bold)
                    .padding(.trailing, 10)
                Divider()
                    .frame(width: 200)
                    .background(.white)
                VStack(alignment: .leading){
                    HStack{
                        Text("Small")
                            .multilineTextAlignment(.leading)
                            .padding(.leading)
                            .fontDesign(.serif)
                        Spacer()
                        Text("$3.50")
                            .fontDesign(.serif)
                    }
                    Text("Sandwich with meats, cheeses, & regular breads")
                        .font(.caption)
                        .fontDesign(.monospaced)
                        .padding(.leading, 16)
                        .italic()
                        .foregroundColor(.secondary)
                }
                .padding(.trailing)
                .padding(.bottom, 6)
                VStack(alignment: .leading){
                    HStack{
                        Text("Medium")
                            .multilineTextAlignment(.leading)
                            .padding(.leading)
                            .fontDesign(.serif)
                        Spacer()
                        Text("$6.00")
                            .fontDesign(.serif)
                    }
                    Text("Small sandwich with condiments")
                        .font(.caption)
                        .fontDesign(.monospaced)
                        .padding(.leading, 16)
                        .italic()
                        .foregroundColor(.secondary)
                }
                .padding(.trailing)
                .padding(.bottom, 6)
                VStack(alignment: .leading){
                    HStack{
                        Text("Large")
                            .multilineTextAlignment(.leading)
                            .padding(.leading)
                            .fontDesign(.serif)
                        Spacer()
                        Text("$7.50")
                            .fontDesign(.serif)
                    }
                    Text("Medium sandwich with specialty bread")
                        .font(.caption)
                        .fontDesign(.monospaced)
                        .padding(.leading, 16)
                        .italic()
                        .foregroundColor(.secondary)
                }
                .padding(.trailing)
                .padding(.bottom, 6)
                HStack{
                    Text("PB&J")
                        .multilineTextAlignment(.leading)
                        .padding(.leading)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$2.75")
                        .fontDesign(.serif)
                }
                .padding(.trailing)
                .padding(.bottom, 6)
                HStack{
                    Text("Toasted Cheese")
                        .multilineTextAlignment(.leading)
                        .padding(.leading)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$2.75")
                        .fontDesign(.serif)
                }
                .padding(.trailing)
                .padding(.bottom, 6)
                HStack{
                    Text("1 Meat/2 Bacon")
                        .multilineTextAlignment(.leading)
                        .padding(.leading)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$1.50")
                        .fontDesign(.serif)
                }
                .padding(.trailing)
                .padding(.bottom, 6)
                HStack{
                    Text("Cheese")
                        .multilineTextAlignment(.leading)
                        .padding(.leading)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$1.25")
                        .fontDesign(.serif)
                }
                .padding(.trailing)
                .padding(.bottom, 6)
            }
            .frame(width: 210)
        }
    }
}
struct ChefsTable:View{
    let darkMode: Bool
    var body: some View{
        HStack{
            VStack(alignment: .trailing){
                Text("Chef's Table")
                    .font(.title2)
                    .fontDesign(.serif)
                    .fontWeight(.bold)
                Divider()
                    .frame(width: 200)
                    .background(.white)
                VStack(alignment: .leading){
                    HStack{
                        Text("Sandwiches")
                            .multilineTextAlignment(.leading)
                            .padding(.trailing)
                            .fontDesign(.serif)
                        Spacer()
                        Text("$5.00")
                            .fontDesign(.serif)
                    }
                    Text("Pre-made, choice of: PB&J, Tuna, Ham, and others")
                        .font(.caption)
                        .fontDesign(.monospaced)
                        .padding(.trailing, 16)
                        .italic()
                        .foregroundColor(.secondary)
                }
                .padding(.leading)
                .padding(.bottom, 6)
                VStack(alignment: .leading){
                    HStack{
                        Text("Specialty")
                            .multilineTextAlignment(.leading)
                            .padding(.trailing)
                            .fontDesign(.serif)
                        Spacer()
                        Text("$7.50")
                            .fontDesign(.serif)
                    }
                    Text("Wrap, Sandwich, or Box can be available")
                        .font(.caption)
                        .fontDesign(.monospaced)
                        .padding(.trailing, 16)
                        .italic()
                        .foregroundColor(.secondary)
                }
                .padding(.leading)
                .padding(.bottom, 6)
                HStack{
                    Text("Sushi/Spring Roll")
                        .multilineTextAlignment(.leading)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$7.00")
                        .fontDesign(.serif)
                }
                .padding(.leading)
            }
            .frame(width: 210)
            Image(.chef)
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(darkMode ? .white:.black)
                .scaledToFit()
        }
    }
}
struct SpudSoup:View{
    let darkMode: Bool
    var body: some View{
        HStack{
            Image(.pot)
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(darkMode ? .white:.black)
                .scaledToFit()
            VStack(alignment: .leading){
                Text("Spuds & Soups")
                    .font(.title2)
                    .fontDesign(.serif)
                    .fontWeight(.bold)
                    .padding(.trailing, 10)
                Divider()
                    .frame(width: 200)
                    .background(.white)
                VStack(alignment: .leading){
                    HStack{
                        Text("Baked Potato")
                            .multilineTextAlignment(.leading)
                            .padding(.leading)
                            .fontDesign(.serif)
                        Spacer()
                        Text("$4.50")
                            .fontDesign(.serif)
                    }
                    Text("Loaded. Toppings: margarine, cheese, bac-o-bits, sour cream etc.")
                        .font(.caption)
                        .fontDesign(.monospaced)
                        .padding(.leading, 16)
                        .italic()
                        .foregroundColor(.secondary)
                }
                .padding(.trailing)
                .padding(.bottom, 6)
                VStack(alignment: .leading){
                    HStack{
                        Text("Sweet Potato")
                            .multilineTextAlignment(.leading)
                            .padding(.leading)
                            .fontDesign(.serif)
                        Spacer()
                        Text("$6.00")
                            .fontDesign(.serif)
                    }
                    Text("Loaded. Toppings: margarine, brown sugar, cinnamon, nutmeg, pecans etc.")
                        .font(.caption)
                        .fontDesign(.monospaced)
                        .padding(.leading, 16)
                        .italic()
                        .foregroundColor(.secondary)
                }
                .padding(.trailing)
                .padding(.bottom, 6)
                HStack{
                    Text("Plain Potato")
                        .multilineTextAlignment(.leading)
                        .padding(.leading)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$3.00")
                        .fontDesign(.serif)
                }
                .padding(.trailing)
                .padding(.bottom, 6)
                HStack{
                    Text("Soup")
                        .multilineTextAlignment(.leading)
                        .padding(.leading)
                        .fontDesign(.serif)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.trailing)
                HStack{
                    Text("Small")
                        .multilineTextAlignment(.leading)
                        .italic()
                        .padding(.leading, 30)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$2.50")
                        .fontDesign(.serif)
                }
                .padding(.trailing)
                HStack{
                    Text("Large")
                        .multilineTextAlignment(.leading)
                        .italic()
                        .padding(.leading, 30)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$3.50")
                        .fontDesign(.serif)
                }
                .padding(.trailing)
            }
            .frame(width: 210)
        }
    }
}
struct Desserts:View{
    let darkMode: Bool
    var body: some View{
        HStack{
            Image(.pot)
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(darkMode ? .white:.black)
                .scaledToFit()
            VStack(alignment: .leading){
                Text("Desserts")
                    .font(.title2)
                    .fontDesign(.serif)
                    .fontWeight(.bold)
                    .padding(.trailing, 10)
                Divider()
                    .frame(width: 200)
                    .background(.white)
                HStack{
                    Text("""
Cookies, Puddings, 
& Jello
""")
                    .multilineTextAlignment(.leading)
                    .padding(.leading)
                    .fontDesign(.serif)
                    Spacer()
                    Text("$2.00")
                        .fontDesign(.serif)
                }
                .padding(.trailing)
                .padding(.bottom, 6)
                HStack{
                    Text("""
Specialty, Cakes, Pies
""")
                    .multilineTextAlignment(.leading)
                    .padding(.leading)
                    .fontDesign(.serif)
                    Spacer()
                    Text("$3.50")
                        .fontDesign(.serif)
                }
                .padding(.trailing)
                .padding(.bottom, 6)
                HStack{
                    Text("Jeni's Ice Cream")
                        .multilineTextAlignment(.leading)
                        .padding(.leading)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$5.00")
                        .fontDesign(.serif)
                }
                .padding(.trailing)
                .padding(.bottom, 6)
                HStack{
                    Text("Frozen Yogurt")
                        .multilineTextAlignment(.leading)
                        .padding(.leading)
                        .fontDesign(.serif)
                        .fontWeight(.bold)
                    Spacer()
                }
                .padding(.trailing)
                HStack{
                    Text("Small")
                        .multilineTextAlignment(.leading)
                        .italic()
                        .padding(.leading, 30)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$2.50")
                        .fontDesign(.serif)
                }
                .padding(.trailing)
                HStack{
                    Text("Medium")
                        .multilineTextAlignment(.leading)
                        .italic()
                        .padding(.leading, 30)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$4.50")
                        .fontDesign(.serif)
                }
                .padding(.trailing)
                HStack{
                    Text("Large")
                        .multilineTextAlignment(.leading)
                        .italic()
                        .padding(.leading, 30)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$5.50")
                        .fontDesign(.serif)
                }
                .padding(.trailing)
            }
            .frame(width: 210)
        }
    }
}
struct Beverages:View{
    let darkMode: Bool
    var body: some View{
        HStack{
            VStack(alignment: .trailing){
                Text("Beverages")
                    .font(.title2)
                    .fontDesign(.serif)
                    .fontWeight(.bold)
                Divider()
                    .frame(width: 200)
                    .background(.white)
                HStack{
                    Text("Juices, Water, Gatorade 12oz")
                        .multilineTextAlignment(.leading)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$1.50")
                        .fontDesign(.serif)
                }
                .padding(.leading)
                .padding(.bottom, 6)
                VStack(alignment: .leading){
                    HStack{
                        Text("Milk")
                            .multilineTextAlignment(.leading)
                            .padding(.trailing)
                            .fontDesign(.serif)
                        Spacer()
                        Text("$1.50")
                            .fontDesign(.serif)
                    }
                    Text("1%, Skim, or Chocolate")
                        .font(.caption)
                        .fontDesign(.monospaced)
                        .padding(.trailing, 16)
                        .italic()
                        .foregroundColor(.secondary)
                }
                .padding(.leading)
                .padding(.bottom, 6)
                HStack{
                    Text("Ice/Hot Tea")
                        .multilineTextAlignment(.leading)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$2.25")
                        .fontDesign(.serif)
                }
                .padding(.leading)
                .padding(.bottom, 6)
                HStack{
                    Text("Coffee")
                        .multilineTextAlignment(.leading)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$2.75")
                        .fontDesign(.serif)
                }
                .padding(.leading)
                .padding(.bottom, 6)
                HStack{
                    Text("Snapple, Gatorade 20oz")
                        .multilineTextAlignment(.leading)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$2.50")
                        .fontDesign(.serif)
                }
                .padding(.leading)
                .padding(.bottom, 6)
            }
            .frame(width: 210)
            Image(.juice)
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(darkMode ? .white:.black)
                .scaledToFit()
        }
    }
}
struct Snacks:View{
    let darkMode: Bool
    var body: some View{
        HStack{
            Image(.snackpage)
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(darkMode ? .white:.black)
                .scaledToFit()
            VStack(alignment: .leading){
                Text("Snacks")
                    .font(.title2)
                    .fontDesign(.serif)
                    .fontWeight(.bold)
                    .padding(.trailing, 10)
                Divider()
                    .frame(width: 200)
                    .background(.white)
                VStack(alignment: .leading){
                    Text("Includes Baked Chips, Pretzels, Fig Newtons, Peanuts, Scooby-Doo etc.")
                        .font(.caption)
                        .fontDesign(.monospaced)
                        .italic()
                        .foregroundColor(.secondary)
                }
                .padding(.leading)
                .padding(.bottom, 6)
                HStack{
                    Text("All")
                        .multilineTextAlignment(.leading)
                        .padding(.leading)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$1.50")
                        .fontDesign(.serif)
                }
                .padding(.trailing)
                .padding(.bottom, 6)
                HStack{
                    Text("Saltines")
                        .multilineTextAlignment(.leading)
                        .padding(.leading)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$0.25")
                        .fontDesign(.serif)
                }
                .padding(.trailing)
                .padding(.bottom, 6)
            }
            .frame(width: 210)
        }
    }
}
struct FastFood:View{
    var body:some View{
        HStack{
            Spacer()
            VStack(alignment:.trailing){
                Text("\"Fast Food\"")
                    .font(.title2)
                    .fontDesign(.serif)
                    .fontWeight(.bold)
                    .padding(.trailing, 10)
                Divider()
                    .frame(width: 200)
                    .background(.white)
                HStack(alignment: .top){
                    VStack(alignment:.trailing){
                        HStack{
                            Text("Egg Roll")
                                .multilineTextAlignment(.leading)
                                .padding(.leading)
                                .fontDesign(.serif)
                            Spacer()
                            Text("$1.75")
                                .fontDesign(.serif)
                        }
                        .padding(.trailing)
                        .padding(.bottom, 6)
                        HStack{
                            Text("Tamales")
                                .multilineTextAlignment(.leading)
                                .padding(.leading)
                                .fontDesign(.serif)
                            Spacer()
                            Text("$1.75")
                                .fontDesign(.serif)
                        }
                        .padding(.trailing)
                        .padding(.bottom, 6)
                        HStack{
                            Text("Sliders")
                                .multilineTextAlignment(.leading)
                                .padding(.leading)
                                .fontDesign(.serif)
                            Spacer()
                            Text("$1.75")
                                .fontDesign(.serif)
                        }
                        .padding(.trailing)
                        .padding(.bottom, 6)
                        HStack{
                            Text("Hot Pocket")
                                .multilineTextAlignment(.leading)
                                .padding(.leading)
                                .fontDesign(.serif)
                            Spacer()
                            Text("$1.75")
                                .fontDesign(.serif)
                        }
                        .padding(.trailing)
                        .padding(.bottom, 6)
                        VStack(alignment: .leading){
                            HStack{
                                Text("Popper")
                                    .multilineTextAlignment(.leading)
                                    .padding(.leading)
                                    .fontDesign(.serif)
                                Spacer()
                                Text("$3.50")
                                    .fontDesign(.serif)
                            }
                            Text("Chicken or Shrimp")
                                .font(.caption)
                                .fontDesign(.monospaced)
                                .padding(.leading, 16)
                                .italic()
                                .foregroundColor(.secondary)
                        }
                        .padding(.trailing)
                        .padding(.bottom, 6)
                        HStack{
                            Text("Pizza")
                                .multilineTextAlignment(.leading)
                                .padding(.leading)
                                .fontDesign(.serif)
                            Spacer()
                            Text("$3.50")
                                .fontDesign(.serif)
                        }
                        .padding(.trailing)
                        .padding(.bottom, 6)
                        HStack{
                            Text("BBQ on Bun")
                                .multilineTextAlignment(.leading)
                                .padding(.leading)
                                .fontDesign(.serif)
                            Spacer()
                            Text("$3.50")
                                .fontDesign(.serif)
                        }
                        .padding(.trailing)
                        .padding(.bottom, 6)
                    }
                    Spacer()
                    VStack(alignment:.trailing){
                        VStack(alignment: .leading){
                            HStack{
                                Text("Hoagie")
                                    .multilineTextAlignment(.leading)
                                    .fontDesign(.serif)
                                Spacer()
                                Text("$3.50")
                                    .fontDesign(.serif)
                            }
                            Text("Meatball")
                                .font(.caption)
                                .fontDesign(.monospaced)
                                .italic()
                                .foregroundColor(.secondary)
                        }
                        .padding(.bottom, 6)
                        VStack(alignment: .leading){
                            HStack{
                                Text("Sandwich")
                                    .multilineTextAlignment(.leading)
                                    .fontDesign(.serif)
                                Spacer()
                                Text("$3.50")
                                    .fontDesign(.serif)
                            }
                            Text("Fish and Chicken")
                                .font(.caption)
                                .fontDesign(.monospaced)
                                .italic()
                                .foregroundColor(.secondary)
                        }
                        .padding(.bottom, 6)
                        HStack{
                            Text("Sausage Stick")
                                .multilineTextAlignment(.leading)
                                .fontDesign(.serif)
                            Spacer()
                            Text("$3.50")
                                .fontDesign(.serif)
                        }
                        .padding(.bottom, 6)
                        HStack{
                            Text("Gyros")
                                .multilineTextAlignment(.leading)
                                .fontDesign(.serif)
                            Spacer()
                            Text("$3.50")
                                .fontDesign(.serif)
                        }
                        .padding(.bottom, 6)
                        HStack{
                            Text("Hot Dog")
                                .multilineTextAlignment(.leading)
                                .fontDesign(.serif)
                            Spacer()
                            Text("$3.50")
                                .fontDesign(.serif)
                        }
                        .padding(.bottom, 6)
                        HStack{
                            Text("Corn Dog")
                                .multilineTextAlignment(.leading)
                                .fontDesign(.serif)
                            Spacer()
                            Text("$3.00")
                                .fontDesign(.serif)
                        }
                        .padding(.bottom, 6)
                        HStack{
                            Text("French Fries")
                                .multilineTextAlignment(.leading)
                                .fontDesign(.serif)
                            Spacer()
                            Text("$2.00")
                                .fontDesign(.serif)
                        }
                        .padding(.bottom, 6)
                    }
                    .padding(.trailing)
                }
            }
        }
    }
}
struct Breakfast:View{
    var body: some View{
        HStack{
            Spacer()
            VStack(alignment:.leading){
                Text("Breakfast")
                    .font(.title2)
                    .fontDesign(.serif)
                    .fontWeight(.bold)
                    .padding(.trailing, 10)
                Divider()
                    .frame(width: 200)
                    .background(.white)
                HStack(alignment: .top){
                    VStack(alignment:.trailing){
                        HStack{
                            Text("Biscuit")
                                .multilineTextAlignment(.leading)
                                .padding(.leading)
                                .fontDesign(.serif)
                            Spacer()
                            Text("$1.25")
                                .fontDesign(.serif)
                        }
                        .padding(.trailing)
                        .padding(.bottom, 6)
                        HStack{
                            Text("Bagel")
                                .multilineTextAlignment(.leading)
                                .padding(.leading)
                                .fontDesign(.serif)
                            Spacer()
                            Text("$1.25")
                                .fontDesign(.serif)
                        }
                        .padding(.trailing)
                        .padding(.bottom, 6)
                        HStack{
                            Text("Muffins")
                                .multilineTextAlignment(.leading)
                                .padding(.leading)
                                .fontDesign(.serif)
                            Spacer()
                            Text("$1.75")
                                .fontDesign(.serif)
                        }
                        .padding(.trailing)
                        .padding(.bottom, 6)
                        HStack{
                            Text("Cereal, Small Oatmeal")
                                .multilineTextAlignment(.leading)
                                .padding(.leading)
                                .fontDesign(.serif)
                            Spacer()
                            Text("$1.50")
                                .fontDesign(.serif)
                        }
                        .padding(.trailing)
                        .padding(.bottom, 6)
                        HStack{
                            Text("Kashi Cereal, Large Oatmeal")
                                .multilineTextAlignment(.leading)
                                .padding(.leading)
                                .fontDesign(.serif)
                            Spacer()
                            Text("$2.50")
                                .fontDesign(.serif)
                        }
                        .padding(.trailing)
                        .padding(.bottom, 6)
                        HStack{
                            Text("Fresh Fruit")
                                .multilineTextAlignment(.leading)
                                .padding(.leading)
                                .fontDesign(.serif)
                            Spacer()
                            Text("$2.00")
                                .fontDesign(.serif)
                        }
                        .padding(.trailing)
                        .padding(.bottom, 6)
                        HStack{
                            Text("Lo-Fat Yogurt")
                                .multilineTextAlignment(.leading)
                                .padding(.leading)
                                .fontDesign(.serif)
                            Spacer()
                            Text("$1.50")
                                .fontDesign(.serif)
                        }
                        .padding(.trailing)
                        .padding(.bottom, 6)
                        HStack{
                            Text("Parfait")
                                .multilineTextAlignment(.leading)
                                .padding(.leading)
                                .fontDesign(.serif)
                            Spacer()
                            Text("$2.75")
                                .fontDesign(.serif)
                        }
                        .padding(.trailing)
                        .padding(.bottom, 6)
                    }
                    Spacer()
                    VStack(alignment:.trailing){
                        HStack{
                            Text("Croissant")
                                .multilineTextAlignment(.leading)
                                .fontDesign(.serif)
                            Spacer()
                            Text("$3.00")
                                .fontDesign(.serif)
                        }
                        .padding(.bottom, 6)
                        HStack{
                            Text("Kolache")
                                .multilineTextAlignment(.leading)
                                .fontDesign(.serif)
                            Spacer()
                            Text("$3.00")
                                .fontDesign(.serif)
                        }
                        .padding(.bottom, 6)
                        HStack{
                            Text("Breakfast Taco")
                                .multilineTextAlignment(.leading)
                                .fontDesign(.serif)
                            Spacer()
                            Text("$3.00")
                                .fontDesign(.serif)
                        }
                        .padding(.bottom, 6)
                        HStack{
                            Text("Sausage Biscuit")
                                .multilineTextAlignment(.leading)
                                .fontDesign(.serif)
                            Spacer()
                            Text("$3.00")
                                .fontDesign(.serif)
                        }
                        .padding(.bottom, 6)
                        HStack{
                            Text("2 Pancakes")
                                .multilineTextAlignment(.leading)
                                .fontDesign(.serif)
                            Spacer()
                            Text("$3.00")
                                .fontDesign(.serif)
                        }
                        .padding(.bottom, 6)
                        HStack{
                            Text("2 French Toast")
                                .multilineTextAlignment(.leading)
                                .fontDesign(.serif)
                            Spacer()
                            Text("$3.00")
                                .fontDesign(.serif)
                        }
                        .padding(.bottom, 6)
                        HStack{
                            Text("Plain waffle")
                                .multilineTextAlignment(.leading)
                                .fontDesign(.serif)
                            Spacer()
                            Text("$3.00")
                                .fontDesign(.serif)
                        }
                        .padding(.bottom, 6)
                        HStack{
                            Text("Topped waffle")
                                .multilineTextAlignment(.leading)
                                .fontDesign(.serif)
                            Spacer()
                            Text("$3.50")
                                .fontDesign(.serif)
                        }
                        .padding(.bottom, 6)
                    }
                    .padding(.trailing)
                }
            }
        }
    }
}
struct Extras:View{
    let darkMode: Bool
    var body: some View{
        HStack{
            VStack(alignment: .trailing){
                Text("Extras")
                    .font(.title2)
                    .fontDesign(.serif)
                    .fontWeight(.bold)
                Divider()
                    .frame(width: 200)
                    .background(.white)
                HStack{
                    Text("Cream Cheese")
                        .multilineTextAlignment(.leading)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$0.75")
                        .fontDesign(.serif)
                }
                .padding(.leading)
                .padding(.bottom, 6)
                HStack{
                    Text("PB/Nutella")
                        .multilineTextAlignment(.leading)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$0.75")
                        .fontDesign(.serif)
                }
                .padding(.leading)
                .padding(.bottom, 6)
                HStack{
                    Text("Sour Cream")
                        .multilineTextAlignment(.leading)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$0.75")
                        .fontDesign(.serif)
                }
                .padding(.leading)
                .padding(.bottom, 6)
                HStack{
                    Text("Honey/Jelly")
                        .multilineTextAlignment(.leading)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$0.50")
                        .fontDesign(.serif)
                }
                .padding(.leading)
                .padding(.bottom, 6)
                HStack{
                    Text("Margarine")
                        .multilineTextAlignment(.leading)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$0.25")
                        .fontDesign(.serif)
                }
                .padding(.leading)
                .padding(.bottom, 6)
                HStack{
                    Text("Lemon Wedge")
                        .multilineTextAlignment(.leading)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$0.25")
                        .fontDesign(.serif)
                }
                .padding(.leading)
                .padding(.bottom, 6)
            }
            .frame(width: 210)
            Spacer()
            Image(systemName: "fork.knife")
                .resizable()
                .frame(maxWidth: 120, maxHeight: 150)
                .foregroundStyle(darkMode ? .white: .black)
                .padding(.horizontal)
        }
    }
}
struct SelfBar:View{
    let darkMode: Bool
    var body: some View{
        HStack{
            VStack(alignment: .trailing){
                Text("Self-Service Bar")
                    .font(.title2)
                    .fontDesign(.serif)
                    .fontWeight(.bold)
                Divider()
                    .frame(width: 200)
                    .background(.white)
                VStack(alignment: .leading){
                    Text("Includes Specialty Breakfast, fruit, salad fixings, dressings etc.")
                        .font(.caption)
                        .fontDesign(.monospaced)
                        .italic()
                        .foregroundColor(.secondary)
                }
                .padding(.leading)
                .padding(.bottom, 6)
                HStack{
                    Text("Small")
                        .multilineTextAlignment(.leading)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$3.00")
                        .fontDesign(.serif)
                }
                .padding(.leading)
                .padding(.bottom, 6)
                HStack{
                    Text("Medium")
                        .multilineTextAlignment(.leading)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$4.25")
                        .fontDesign(.serif)
                }
                .padding(.leading)
                .padding(.bottom, 6)
                HStack{
                    Text("Large")
                        .multilineTextAlignment(.leading)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$6.00")
                        .fontDesign(.serif)
                }
                .padding(.leading)
                .padding(.bottom, 6)
                HStack{
                    Text("X-Large")
                        .multilineTextAlignment(.leading)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$8.00")
                        .fontDesign(.serif)
                }
                .padding(.leading)
                .padding(.bottom, 6)
                HStack{
                    Text("Hard Boiled Eggs")
                        .multilineTextAlignment(.leading)
                        .fontDesign(.serif)
                    Spacer()
                    Text("$1.50")
                        .fontDesign(.serif)
                }
                .padding(.leading)
                .padding(.bottom, 6)
            }
            .frame(width: 210)
            Image(.saladbowl)
                .resizable()
                .renderingMode(.template)
                .foregroundStyle(darkMode ? .white:.black)
                .scaledToFit()
        }
    }
}
enum MenuSection: String, CaseIterable, Identifiable {
    case all = "All"
    case mainMeal = "Main Meal"
    case sandwichBar = "Sandwich Bar"
    case chefsTable = "Chef's Table"
    case spudSoup = "Spuds & Soup"
    case selfBar = "Self-Service Bar"
    case desserts = "Desserts"
    case beverages = "Beverages"
    case snacks = "Snacks"
    case fastFood = "Fast Food"
    case breakfast = "Breakfast"
    case extras = "Extras"
    
    var id: String { self.rawValue }
}
                            

                                      #Preview{
                                     TabControl()
                                 }
