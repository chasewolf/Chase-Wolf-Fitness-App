import SwiftUI

struct Nutrition: View {
    //variables and functions
    
    @EnvironmentObject var dateFormats: DateFormats
    @EnvironmentObject var userData: GoalData
    
    @State private var itemInfo: ItemInfo?
    
    //where the api key is implemented
    func requestFood() {
        guard let url = URL(string: "https://trackapi.nutritionix.com/v2/natural/nutrients") else {
            print("Invalid URL")
            return
        }
        
        let body: [String: String] = ["query": "\(foodText)"]
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("7b416548", forHTTPHeaderField: "x-app-id") // Replace YOUR_APP_ID with your actual app ID
        request.setValue("b05a8eb6a83d20671a04db04701ca3b1", forHTTPHeaderField: "x-app-key") // Replace YOUR_APP_KEY with your actual app key
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                print("No data in response: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            if let decodedResponse = try? JSONDecoder().decode(Response.self, from: data) {
                DispatchQueue.main.async {
                    // Assign the decoded response to the @State property
                    self.nutrients = decodedResponse
                }
                return
            }
            
            print("Failed to decode response")
            
        }.resume()
        
    }
    
    struct Response: Codable {
        // Define the structure of the response object
        // You might need to create this struct based on the JSON response from the server
        let foods: [Food]
    }
    struct Food: Codable {
        let food_name: String
        let nf_calories: Double
        let nf_total_fat: Double
        let nf_saturated_fat: Double
        let nf_cholesterol: Double
        let nf_sodium: Double
        let nf_total_carbohydrate: Double
        let nf_dietary_fiber: Double
        let nf_sugars: Double
        let nf_protein: Double
        let nf_potassium: Double
        // Add more properties if needed
    }
    
    //color of nutrition meters
    func getCol(user: Double, goal: Double, lose: Bool, max: Double, min: Double) -> Color {
        let progress = user/goal
        if lose {
            if user < min {
                return Color.red
            }
            else if progress < 1 {
                return Color.green
            }
            else {
                return Color.red
            }
        }
        else {
            if user > max {
                return Color.red
            }
            else if progress > 1 {
                return Color.green
            }
            else {
                return Color.red
            }
        }
    }
    //var for if the user is attempting to gain weight
    private var weightGain: Bool {
        if userData.userWeight < userData.goalWeight {
            return true
        }
        else {
            return false
        }
    }
    private var userBMI: Double {//bmi calculation
        let BMI = userData.userWeight / (userData.userHeight * userData.userHeight) * 703
        userData.BMI = BMI
        return BMI
    }
    private var goalBMI: Double {
        let BMI = userData.goalWeight / (userData.userHeight * userData.userHeight) * 703
        userData.BMI = BMI
        return BMI
    }
    private var difficulty: Int {//difficulty calculation
        var totalDays = 0
        totalDays = Calendar.current.dateComponents([.day], from: userData.startDate, to: userData.goalDate).day ?? 0
        let months = totalDays / 31
        var diff = userData.difficulty
        let bmiDiff = abs(goalBMI - userBMI)
        if months < 3 {
            if bmiDiff < 0.5 {
                diff = 1
            } else if bmiDiff < 1 {
                diff = 2
            } else if bmiDiff < 1.7 {
                diff = 3
            } else {
                diff = 4
            }
        } else if months < 7 {
            if bmiDiff < 0.6 {
                diff = 1
            } else if bmiDiff < 1.2 {
                diff = 2
            } else if bmiDiff < 1.9 {
                diff = 3
            } else {
                diff = 4
            }
        } else if months < 13 {
            if bmiDiff < 0.8 {
                diff = 1
            } else if bmiDiff < 1.5 {
                diff = 2
            } else if bmiDiff < 2.4 {
                diff = 3
            } else {
                diff = 4
            }
        } else {
            diff = 2
        }
        diff += userData.increaseDiff
        userData.difficulty = diff
        return diff
    }
    private var calGoal: Double {//calorie calculation
        var cal = 0.0
        if userData.userGender == "Male" {
            cal = (10 * userData.userWeight / 2.2)
            cal += (6.25 * userData.userHeight * 2.54)
            cal -= (5.0 * Double(userData.userAge)) + 5
        }
        else {
            cal = (10 * userData.userWeight / 2.2)
            cal += (6.25 * userData.userHeight * 2.54)
            cal -= (5 * Double(userData.userAge)) - 161
        }
        if userData.goalWeight >= userData.userWeight {
            if difficulty == 1 {
                cal *= 1.2
            } else if difficulty == 2 {
                cal *= 1.35
            } else if difficulty == 3 {
                cal *= 1.55
            } else if difficulty == 4 {
                cal *= 1.8
            }
        } else {
            if difficulty == 1 {
                cal *= 0.9
            } else if difficulty == 2 {
                cal *= 0.85
            } else if difficulty == 3 {
                cal *= 0.75
            } else if difficulty == 4 {
                cal *= 0.6
            }
        }
        return cal
    }
    private var waterGoal: Double {//water calculation
        var oz = 0.0
        if difficulty == 1 {
            oz = 90.0
        } else if difficulty == 2 {
            oz = 110.0
        } else if difficulty == 3 {
            oz = 135.0
        } else if difficulty == 4 {
            oz = 160.0
        }
        return oz
    }
    private var sugarGoal: Double {//sugar calculation
        var g = 0.0
        if userData.userGender == "Male" {
            g = 36.0
        }
        else {
            g = 25.0
        }
        return g
    }
    private var carbGoal: Double {//carb calculation
        let carbs = calGoal * 0.55 * 0.129598
        return carbs
    }
    private var proteinGoal: Double {//protein calculation
        var protein = 0.0
        if weightGain {
            protein = calGoal * 0.35 * 0.129598
        }
        else {
            protein = calGoal * 0.15 * 0.129598
        }
        return protein
    }
    private var fatGoal: Double {//fat calculation
        let fat = calGoal * 0.35 * 0.129598
        return fat
    }
    
    //different variables used in body
    @State private var foodText = ""
    @State private var nutrients: Response?
    @State private var vitAGoal = 800.0
    @State private var vitCGoal = 85.0
    @State private var CaGoal = 1000.0
    @State private var NaGoal = 1500.0
    @State private var KGoal = 4100.0
    @State private var FeGoal = 13.0
    @State private var cholGoal = 300.0
    @State private var waterField = false
    @State private var waterText = ""
    @State private var nutField = false
    @State private var calInfo = false
    @State private var waterInfo = false
    @State private var carbInfo = false
    @State private var protInfo = false
    @State private var fatInfo = false
    @State private var sugarInfo = false
    @State private var cholInfo = false
    @State private var NaInfo = false
    
    //functions to add nutrients
    func addCal(cal: String) {
        userData.userCal += Double(cal) ?? 0.0
    }
    func addCarbs(cal: String) {
        userData.userCarbs += Double(cal) ?? 0.0
    }
    func addChol(cal: String) {
        userData.userChol += Double(cal) ?? 0.0
    }
    func addNa(cal: String) {
        userData.userSodium += Double(cal) ?? 0.0
    }
    func addK(cal: String) {
        userData.userPotassium += Double(cal) ?? 0.0
    }
    func addSugar(cal: String) {
        userData.userSugar += Double(cal) ?? 0.0
    }
    func addFat(cal: String) {
        userData.userFat += Double(cal) ?? 0.0
    }
    func addProt(cal: String) {
        userData.userProtein += Double(cal) ?? 0.0
    }
    //nutrition display
    var body: some View {
        //getting colors
        let calCol = getCol(user: userData.userCal, goal: userData.goalCal, lose: !weightGain, max: userData.goalCal * 1.2, min: userData.goalCal * 0.5)
        let waterCol = getCol(user: userData.userWater, goal: userData.goalWater, lose: !weightGain, max: userData.goalCal * 3.0, min: userData.goalCal * 1.0)
        let protCol = getCol(user: userData.userWater, goal: userData.goalWater, lose: !weightGain, max: userData.goalCal * 1.5, min: userData.goalCal * 1.0)
        TabView {
            VStack {
                VStack {
                    //header
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .frame(width: 180.0, height: 50.0)
                            .foregroundColor(.white)
                            .shadow(radius: 5)
                        Text("Nutrition")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundColor(Color.purple)
                    }
                    ZStack {
                        if !nutField {
                            RoundedRectangle(cornerRadius: 20)
                                .padding(.bottom, 10.0)
                                .frame(width: 350.0, height: 600.0)
                                .foregroundColor(.white)
                                .shadow(radius: 5)
                        }
                        VStack {
                            //search tool
                            if !nutField {
                                TextField("Enter Foods(Ex: 2 bananas, 3 grapes)", text: $foodText).frame(width: 300)
                                    .padding()
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Button("Find Food") {
                                    requestFood()
                                    nutField.toggle()
                                }
                            }
                            if nutField {
                                
                                Button(action: {
                                    
                                    nutField.toggle()
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 20)
                                            .frame(width: 100.0, height: 30.0)
                                            .foregroundColor(.white)
                                            .shadow(color: .blue, radius: 5)
                                        Text("Add Foods")
                                    }
                                }
                                //search tool
                                if let response = nutrients {
                                    List {
                                        ForEach(response.foods, id: \.food_name) { food in
                                            VStack(alignment: .leading) {
                                                Text("Food Name: \(food.food_name)")
                                                Text("Calories: \(food.nf_calories)").onAppear { addCal(cal: "\(food.nf_calories)") }
                                                
                                                Text("Total Fat: \(food.nf_total_fat)").onAppear { addFat(cal: "\(food.nf_total_fat)") }
                                                Text("Cholesterol: \(food.nf_cholesterol)").onAppear { addChol(cal: "\(food.nf_cholesterol)") }
                                                Text("Sodium: \(food.nf_sodium)").onAppear { addNa(cal: "\(food.nf_sodium)") }
                                                Text("Total Carbohydrate: \(food.nf_total_carbohydrate)").onAppear { addCarbs(cal: "\(food.nf_total_carbohydrate)") }
                                                Text("Sugars: \(food.nf_sugars)").onAppear { addSugar(cal: "\(food.nf_sugars)") }
                                                Text("Protein: \(food.nf_protein)").onAppear { addProt(cal: "\(food.nf_protein)") }
                                                Text("Potassium: \(food.nf_potassium)").onAppear { addK(cal: "\(food.nf_potassium)") }
                                            }
                                        }
                                    }
                                    
                                } else {
                                    Text("")
                                }
                            }
                            VStack {
                                //add water button and text field
                                Button(action: {
                                    waterField.toggle()
                                }){
                                    VStack {
                                        Text("Water")
                                            .font(.title)
                                            .foregroundColor(Color.black)
                                        Image(systemName: "plus.app").font(.system(size: 20))
                                        
                                    }.padding()
                                }
                                if waterField {
                                    VStack {
                                        TextField("add _ oz of water", text: $waterText)
                                            .frame(width: 200.0)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                        Button(action: {
                                            waterField.toggle()
                                            userData.userWater += Double(waterText) ?? 0.0
                                            
                                        }){
                                            Text("submit")
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }.padding() .tabItem {
                Image(systemName: "takeoutbag.and.cup.and.straw.fill")
                    .foregroundColor(Color.purple)
                Text("Meals")
                    .foregroundColor(Color.purple)
            }
            VStack(spacing: 5) {
                ZStack {//header
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 180.0, height: 50.0)
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                    Text("Nutrition")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(Color.purple)
                }
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .padding(.bottom, 10.0)
                        .frame(width: 350.0, height: 600.0)
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                    //different nutrient information. Same information provided in Nutrition and Exercise research
                    if calInfo {
                        Text("Calories are units of measurement used to quantify the energy content of food and beverages.Average daily calorie intake: Mifflin-St Jeor Equation(equation created to determine recommended calorie intake)Men: (10 × weight in kg) + (6.25 × height in cm) - (5 × age in years) + 5. Women: (10 × weight in kg) + (6.25 × height in cm) - (5 × age in years) - 161.")
                            .frame(width: 300.0)
                        Button(action: {
                            calInfo.toggle()
                        }){
                            Image(systemName: "info.circle")
                                .foregroundColor(Color.purple).padding(.top, 530.0)
                        }
                        
                    }
                    if waterInfo {
                        Text("As a general guideline, it's recommended that adults aim to drink about 8 glasses (64 ounces) of water per day, but this can vary. Staying mindful of one's thirst and adjusting water intake accordingly is also crucial for maintaining proper hydration. This should increase with more physical activity. Users with a more difficult goal will be suggested to drink more water. For light difficulty = 90oz, moderate = 110 oz, hard = 135 oz, extreme = 160 oz").frame(width: 300.0)
                        Button(action: {
                            waterInfo.toggle()
                        }){
                            Image(systemName: "info.circle")
                                .foregroundColor(Color.purple).padding(.top, 530.0)
                        }
                    }
                    if carbInfo {
                        Text("Carbohydrates are the body's primary source of energy. When consumed, they are broken down into glucose, which is then used by cells for various metabolic processes. Glucose is particularly important for fueling the brain and supporting physical activity. The Dietary Guidelines for Americans recommend 45-65% of calories in our diet come from carbohydrates.").frame(width: 300.0)
                        Button(action: {
                            carbInfo.toggle()
                        }){
                            Image(systemName: "info.circle")
                                .foregroundColor(Color.purple).padding(.top, 530.0)
                        }
                    }
                    if protInfo {
                        Text("https://www.calculator.net/protein-calculator.html Proteins play a crucial role in the growth and maintenance of muscle tissue. Muscle growth, also known as hypertrophy, is a complex process that involves the synthesis of new proteins within muscle cells.Most adults need around 0.75g of protein per kilo of body weight per day (for the average woman, this is 45g, or 55g for men).CDC recommends 10-35% of caloric intake").frame(width: 300.0)
                        Button(action: {
                            protInfo.toggle()
                        }){
                            Image(systemName: "info.circle")
                                .foregroundColor(Color.purple).padding(.top, 530.0)
                        }
                    }
                    if fatInfo {
                        Text("https://nutrition.ucdavis.edu/outreach/nutr-health-info-sheets/pro-fat#:~:text=How%20much%20fat%20should%20be,calories%20(1%2C2). It's important to note that while fat is essential for health, an imbalance in fat storage, such as excess body fat, can contribute to various health issues, including obesity and related conditions. A healthy balance of fat, along with a well-rounded diet and regular physical activity, is crucial for overall well-being. The 2015-2020 Dietary Guidelines for Americans recommends limiting total fat to 20 to 35 percent of total daily calories and saturated fat to no more than 10 percent of total daily calories").frame(width: 300.0)
                        Button(action: {
                            fatInfo.toggle()
                        }){
                            Image(systemName: "info.circle")
                                .foregroundColor(Color.purple).padding(.top, 530.0)
                        }
                    }
                    if sugarInfo {
                        Text("Men should consume no more than 9 teaspoons (36 grams or 150 calories) of added sugar per day. For women, the number is lower: 6 teaspoons (25 grams or 100 calories) per day.").frame(width: 300.0)
                        Button(action: {
                            sugarInfo.toggle()
                        }){
                            Image(systemName: "info.circle")
                                .foregroundColor(Color.purple).padding(.top, 530.0)
                        }
                    }
                    if cholInfo {
                        Text("If you have risk factors for heart disease, you should not consume more than 200 milligrams of cholesterol a day. If you do not have risk factors for heart disease, you should limit your cholesterol intake to no more than 300 milligrams a day").frame(width: 300.0)
                        Button(action: {
                            cholInfo.toggle()
                        }){
                            Image(systemName: "info.circle")
                                .foregroundColor(Color.purple).padding(.top, 530.0)
                        }
                    }
                    if NaInfo {
                        Text("https://www.webmd.com/vitamins-and-supplements/vitamins-minerals-how-much-should-you-take Sodium: Function: Regulates fluid balance, nerve function, and muscle contractions. It is a component of table salt (sodium chloride).  1500 mg/day").frame(width: 300.0)
                        Button(action: {
                            NaInfo.toggle()
                        }){
                            Image(systemName: "info.circle")
                                .foregroundColor(Color.purple).padding(.top, 530.0)
                        }
                    }
                    if !calInfo && !waterInfo && !sugarInfo && !carbInfo && !cholInfo && !NaInfo && !fatInfo && !protInfo {
                        VStack {
                            
                            HStack {
                                ZStack {
                                    //calories
                                    RoundedRectangle(cornerRadius: 20)
                                        .padding(.bottom, 10.0)
                                        .frame(width: 90, height: 150)
                                        .foregroundColor(.white)
                                        .shadow(radius: 5)
                                    if !calInfo {
                                        VStack {
                                            Text("Calories").padding(.top, -35.0)
                                            
                                            Text("\(Int(userData.userCal))/\(Int(userData.goalCal))")
                                                .font(.subheadline).onAppear() {
                                                    userData.goalCal = calGoal
                                                }
                                            Text("(cal)")
                                                .font(.footnote)
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .frame(width: 40, height: 10)
                                                    .foregroundColor(Color.gray.opacity(0.3))
                                                
                                                RoundedRectangle(cornerRadius: 5)
                                                    .frame(width: min(38, 38 * CGFloat(userData.userCal / userData.goalCal)), height: 5)
                                                    .foregroundColor(calCol)
                                                    
                                            }.padding(.bottom)
                                            
                                        }
                                    }
                                    
                                    Button(action: {
                                        calInfo.toggle()
                                    }){
                                        Image(systemName: "info.circle")
                                            .foregroundColor(Color.purple).padding(.top, 70.0)
                                    }
                                }
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .padding(.bottom, 10.0)
                                        .frame(width: 90, height: 150)
                                        .foregroundColor(.white)
                                        .shadow(radius: 5)
                                    if !waterInfo {
                                        VStack {
                                            //water
                                            Text("Water").padding(.top, -35.0)
                                            Text("\(Int(userData.userWater))/\( Int(userData.goalWater)) ") .font(.subheadline).onAppear() {
                                                userData.goalWater = waterGoal
                                            }
                                            Text("(oz)")
                                                .font(.footnote)
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .frame(width: 40, height: 10)
                                                    .foregroundColor(Color.gray.opacity(0.3))
                                                
                                                RoundedRectangle(cornerRadius: 5)
                                                    .frame(width: min(38, 38 * CGFloat(userData.userWater / userData.goalWater)), height: 5)
                                                    .foregroundColor(waterCol)}.padding(.bottom)
                                        }
                                        
                                        Button(action: {
                                            waterInfo.toggle()
                                        }){
                                            Image(systemName: "info.circle")
                                                .foregroundColor(Color.purple).padding(.top, 70.0)
                                        }
                                    }
                                }
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .padding(.bottom, 10.0)
                                        .frame(width: 90, height: 150)
                                        .foregroundColor(.white)
                                        .shadow(radius: 5)
                                    if !carbInfo {
                                        VStack {
                                            //carbs
                                            Text("Carbs").padding(.top, -35.0)
                                            Text("\(Int(userData.userCarbs))/\( Int(userData.goalCarbs)) ").onAppear() {
                                                userData.goalCarbs = carbGoal
                                            }   .font(.subheadline).onAppear() {
                                                userData.goalCarbs = carbGoal
                                            }
                                            Text("(g)")
                                                .font(.footnote)
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .frame(width: 40, height: 10)
                                                    .foregroundColor(Color.gray.opacity(0.3))
                                                
                                                RoundedRectangle(cornerRadius: 5)
                                                    .frame(width: min(38, 38 * CGFloat(userData.userCarbs / userData.goalCarbs)), height: 5)
                                                    .foregroundColor(calCol)
                                            }.padding(.bottom)
                                        }
                                        
                                        Button(action: {
                                            carbInfo.toggle()
                                        }){
                                            Image(systemName: "info.circle")
                                                .foregroundColor(Color.purple).padding(.top, 70.0)
                                        }
                                    }
                                }
                                
                            }
                            
                            HStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .padding(.bottom, 10.0)
                                        .frame(width: 90, height: 150)
                                        .foregroundColor(.white)
                                        .shadow(radius: 5)
                                    if !fatInfo {
                                        VStack {
                                            //fat
                                            Text("Fat").padding(.top, -35.0)
                                            Text("\(Int(userData.userFat))/\( Int(userData.goalFat)) ").onAppear() {
                                                userData.goalFat = fatGoal
                                            }   .font(.subheadline)
                                            Text("(g)")
                                                .font(.footnote)
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .frame(width: 40, height: 10)
                                                    .foregroundColor(Color.gray.opacity(0.3))
                                                
                                                RoundedRectangle(cornerRadius: 5)
                                                    .frame(width: min(38, 38 * CGFloat(userData.userFat / userData.goalFat)), height: 5)
                                                    .foregroundColor(calCol)
                                            }.padding(.bottom)
                                        }
                                        
                                        Button(action: {
                                            fatInfo.toggle()
                                        }){
                                            Image(systemName: "info.circle")
                                                .foregroundColor(Color.purple).padding(.top, 70.0)
                                        }
                                    }
                                }
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .padding(.bottom, 10.0)
                                        .frame(width: 90, height: 150)
                                        .foregroundColor(.white)
                                        .shadow(radius: 5)
                                    if !sugarInfo {
                                        VStack {
                                            //sugar
                                            Text("Sugar").padding(.top, -35.0)
                                            Text("\(Int(userData.userSugar))/\( Int(sugarGoal))").onAppear() {
                                                userData.goalSugar = sugarGoal
                                            }
                                            .font(.subheadline)
                                            Text("(g)")
                                                .font(.footnote)
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .frame(width: 40, height: 10)
                                                    .foregroundColor(Color.gray.opacity(0.3))
                                                
                                                RoundedRectangle(cornerRadius: 5)
                                                    .frame(width: min(38, 38 * CGFloat(userData.userSugar / sugarGoal)), height: 5)
                                                    .foregroundColor(calCol)
                                            }.padding(.bottom)
                                        }
                                        
                                        Button(action: {
                                            sugarInfo.toggle()
                                        }){
                                            Image(systemName: "info.circle")
                                                .foregroundColor(Color.purple).padding(.top, 70.0)
                                        }
                                    }
                                }
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .padding(.bottom, 10.0)
                                        .frame(width: 90, height: 150)
                                        .foregroundColor(.white)
                                        .shadow(radius: 5)
                                    if !cholInfo {
                                        VStack {
                                            //cholesterol
                                            Text("Cholesterol").padding(.top, -35.0)
                                            Text("\(Int(userData.userChol))/\( Int(cholGoal)) ") .font(.subheadline)
                                            Text("(mg)")
                                                .font(.footnote)
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .frame(width: 40, height: 10)
                                                    .foregroundColor(Color.gray.opacity(0.3))
                                                
                                                RoundedRectangle(cornerRadius: 5)
                                                    .frame(width: min(38, 38 * CGFloat(userData.userChol / cholGoal)), height: 5)
                                                    .foregroundColor(calCol)
                                            }.padding(.bottom)
                                        }
                                        
                                        Button(action: {
                                            cholInfo.toggle()
                                        }){
                                            Image(systemName: "info.circle")
                                                .foregroundColor(Color.purple).padding(.top, 70.0)
                                        }
                                    }
                                }
                                
                            }
                            HStack {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .padding(.bottom, 10.0)
                                        .frame(width: 90, height: 150)
                                        .foregroundColor(.white)
                                        .shadow(radius: 5)
                                    if !protInfo {
                                        VStack {
                                            //protein
                                            Text("Protein").padding(.top, -35.0)
                                            Text("\(Int(userData.userProtein))/\( Int(userData.goalProtein)) ").onAppear() {
                                                userData.goalProtein = proteinGoal
                                            }     .font(.subheadline).onAppear() {
                                                userData.goalProtein = proteinGoal
                                            }
                                            Text("(g)")
                                                .font(.footnote)
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .frame(width: 40, height: 10)
                                                    .foregroundColor(Color.gray.opacity(0.3))
                                                
                                                RoundedRectangle(cornerRadius: 5)
                                                    .frame(width: min(38, 38 * CGFloat(userData.userProtein / userData.goalProtein)), height: 5)
                                                    .foregroundColor(protCol)
                                            }.padding(.bottom)
                                        }
                                        
                                        Button(action: {
                                            protInfo.toggle()
                                        }){
                                            Image(systemName: "info.circle")
                                                .foregroundColor(Color.purple).padding(.top, 70.0)
                                        }
                                    }
                                }
                                ZStack {
                                    RoundedRectangle(cornerRadius: 20)
                                        .padding(.bottom, 10.0)
                                        .frame(width: 90, height: 150)
                                        .foregroundColor(.white)
                                        .shadow(radius: 5)
                                    if !NaInfo {
                                        VStack {
                                            //sodium
                                            Text("Sodium").padding(.top, -35.0)
                                            Text("\(Int(userData.userSodium))/\( Int(NaGoal)) ") .font(.subheadline)
                                            Text("(mg)")
                                                .font(.footnote)
                                            ZStack {
                                                RoundedRectangle(cornerRadius: 5)
                                                    .frame(width: 40, height: 10)
                                                    .foregroundColor(Color.gray.opacity(0.3))
                                                
                                                RoundedRectangle(cornerRadius: 5)
                                                    .frame(width: min(38, 38 * CGFloat(userData.userSodium / NaGoal)), height: 5)
                                                    .foregroundColor(calCol)
                                            }.padding(.bottom)
                                        }
                                        
                                        Button(action: {
                                            NaInfo.toggle()
                                        }){
                                            Image(systemName: "info.circle")
                                                .foregroundColor(Color.purple).padding(.top, 70.0)
                                        }
                                    }
                                }
                            }
                            HStack(spacing: 50){
                                if !waterField {
                                    
                                }
                                
                            }.padding(.bottom, 300.0)
                            
                        }
                        .padding(.bottom, -200.0)
                    }
                }
            }.padding().tabItem {
                Image(systemName: "info.circle.fill").foregroundColor(Color.purple)
                Text("Nutrition")
                    .foregroundColor(Color.purple)
            }
        }
        
    }
}
struct ItemInfo: Codable {
    let id: String
    let name: String
    let brand: Brand
    // Add other properties as needed
}

// Define a struct to represent the Brand object within the ItemInfo
struct Brand: Codable {
    let id: String
    let name: String
    // Add other properties as needed
}
struct Nutrition_Previews: PreviewProvider {
    static var previews: some View {
        Nutrition().environmentObject(GoalData())
    }
}
