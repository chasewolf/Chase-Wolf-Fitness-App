//
//  Goals.swift
//  Fitness App
//
//  Created by Chase Wolf on 2/27/24.
//

import SwiftUI

class DateFormats: ObservableObject { //date formatter used to display Date() variables
    static let shared = DateFormats()
    
    private init() {}
    
}

class GoalData: ObservableObject {
    // User Information used across other views
    @Published var goalDate = Date()
    @Published var startDate = Date()
    @Published var userWeight = 0.1
    @Published var goalWeight = 0.1
    @Published var userHeight = 0.1
    @Published var userGender = ""
    @Published var userAge = 0
    @Published var BMI = 0.1
    @Published var goalCal = 0.1
    @Published var userCal = 0.1
    @Published var goalWater = 0.1
    @Published var userWater = 0.1
    @Published var goalCarbs = 0.1
    @Published var userCarbs = 0.1
    @Published var goalProtein = 0.1
    @Published var userProtein = 0.1
    @Published var goalFat = 0.1
    @Published var userFat = 0.1
    @Published var goalSugar = 0.1
    @Published var userSugar = 0.1
    @Published var userChol = 0.1
    @Published var userVitA = 0.1
    @Published var userVitC = 0.1
    @Published var userCalcium = 0.1
    @Published var userSodium = 0.1
    @Published var userPotassium = 0.1
    @Published var userIron = 0.1
    @Published var calLost = 0.1
    @Published var difficulty = 0
    @Published var workouts: [Workout] = []
    @Published var daysPassed = 0.1
    @Published var daysOnTrack = 0.0
    @Published var increaseDiff = 0
    private var dailyResetTimer: Timer?
    
    //Code to reset daily nutrients and cal lost
    init() {
        startDailyResetTimer()
    }
    
    deinit {
        stopDailyResetTimer()
    }
    
    func startDailyResetTimer() {
        let now = Date()
        let calendar = Calendar.current
        let tomorrowMidnight = calendar.startOfDay(for: now) + 24 * 60 * 60
        
        let timeInterval = tomorrowMidnight.timeIntervalSince(now)
        
        dailyResetTimer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false) { [weak self] _ in
            self?.resetDailyValues()
            self?.startDailyResetTimer() // Schedule next reset
        }
    }
    
    func stopDailyResetTimer() {
        dailyResetTimer?.invalidate()
        dailyResetTimer = nil
    }
    
    private func resetDailyValues() {
        if userCal / goalCal > 0.8 && userCal / goalCal < 1.2 {
            daysOnTrack += 1
        }
        userCal = 0.1
        userWater = 0.1
        userCarbs = 0.1
        userProtein = 0.1
        userFat = 0.1
        userVitA = 0.1
        userVitC = 0.1
        userCalcium = 0.1
        userSodium = 0.1
        userPotassium = 0.1
        userIron = 0.1
        calLost = 0.1
        daysPassed += 1
        
    }
}
struct Goals: View {//main goals view
    @State private var selectedDate = Date()
    @State private var isDatePickerVisible = false
    @State private var weightCurText = ""
    @State private var weightGoalText = ""
    @State private var feetText = ""
    @State private var inText = ""
    @State private var ageText = ""
    @State private var weightField = false
    @State private var weightUpdateField = false
    @State private var startWeight = 0.1
    @State private var heightField = false
    @State private var ageField = false
    @State private var maleTab = Color.purple
    @State private var femaleTab = Color.purple
    @State private var offTrackField = false
    @State private var onTrackField = false
    //private variables used and modified in the Goals view
    
    @EnvironmentObject var dateFormats: DateFormats
    @EnvironmentObject var userData: GoalData
    //environment objects allow them to be observed and modified
    private var userBMI: Double {//bmi calculation
        let BMI = userData.userWeight / (userData.userHeight * userData.userHeight) * 703
        userData.BMI = BMI
        return BMI
    }
    
    private var goalDiffCur: Double {//calculate weight lost/gained
        let diff = abs(userData.goalWeight - userData.userWeight)
        return diff
    }
    private var goalDiffStart: Double {//calculate weight loss/gain goal
        let diff = 0.0001 + abs(userData.goalWeight - startWeight) //needed to add a value to prevent divide by zero
        return diff
    }
    private var progress: Double { //percentage of progress
        let prog = (goalDiffStart - goalDiffCur)/goalDiffStart
        return prog
    }
    private var dayPercent: Double {//the percent of days until goal date since it was selected
        let totalDays = Calendar.current.dateComponents([.day], from: userData.startDate, to: userData.goalDate).day ?? 0
        let daysLeft = Calendar.current.dateComponents([.day], from: Date(), to: userData.goalDate).day ?? 0
        return Double(totalDays - daysLeft) / Double(totalDays)
    }
    let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM"
        return formatter
    }()
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM-dd-yyyy"
        return formatter
    }()
    
    //the app's display of the goal view
    var body: some View {
        
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 150.0, height: 50.0)
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                Text("Goals")
                    .font(.largeTitle)
                    .fontWeight(.heavy)
                    .foregroundColor(Color.purple)
            }
            ZStack {
                
                RoundedRectangle(cornerRadius: 20)
                    .padding(.bottom, 50.0)
                    .frame(width: 350.0, height: 600.0)
                    .foregroundColor(.white)
                    .shadow(radius: 5)
                
                VStack(spacing: 20) {
                    
                    VStack(spacing: 10) {
                        
                        //On/Off track button
                        HStack{
                            if !ageField &&  !heightField && !weightField && !isDatePickerVisible{
                                VStack {
                                    if offTrackField {
                                        if userData.daysOnTrack / userData.daysPassed < 0.75 || userData.increaseDiff >= 3{
                                            Text("Keep Working")
                                                .font(.largeTitle)
                                            Button(action: {
                                                offTrackField.toggle()
                                            }){
                                                Text("ok").font(.title2).padding(.bottom, 200.0)
                                                
                                            }
                                        }
                                        else {
                                            Text("Would you like to increase the intensity of your nutrition goals?")
                                            HStack {
                                                Button(action: {
                                                    offTrackField.toggle()
                                                    userData.increaseDiff += 1
                                                }){
                                                    Text("Yes").font(.title2).foregroundColor(Color.green).padding(.bottom, 200.0)
                                                }
                                                Button(action: {
                                                    offTrackField.toggle()
                                                    
                                                }){
                                                    Text("No").font(.title2).foregroundColor(Color.red).padding(.bottom, 200.0)
                                                }
                                            }
                                        }
                                    }
                                    if onTrackField {
                                        if userData.daysOnTrack / userData.daysPassed < 0.75 || userData.increaseDiff >= 3{
                                            Text("Keep Working")
                                                .font(.largeTitle)
                                            Button(action: {
                                                onTrackField.toggle()
                                            }){
                                                Text("ok").font(.title2).padding(.bottom, 200.0)
                                                
                                            }
                                        }
                                        else {
                                            Text("Would you like to increase the intensity of your nutrition goals?")
                                            HStack {
                                                Button(action: {
                                                    onTrackField.toggle()
                                                    userData.increaseDiff += 1
                                                }){
                                                    Text("Yes").font(.title2).foregroundColor(Color.green).padding(.bottom, 200.0)
                                                }
                                                Button(action: {
                                                    offTrackField.toggle()
                                                    
                                                }){
                                                    Text("No").font(.title2).foregroundColor(Color.red).padding(.bottom, 200.0)
                                                }
                                            }
                                        }
                                    }
                                    //progress display
                                    Text("Progress: \(Int(userData.userWeight))/\(Int(userData.goalWeight))lbs")
                                        .padding(.top, -30.0)
                                    
                                    HStack{
                                        ZStack {
                                            
                                            Circle()
                                                .stroke(Color.gray.opacity(0.3), style: StrokeStyle(lineWidth: 10))
                                                .frame(width: 55.0, height: 55.0)
                                            
                                            Circle()
                                                .trim(from: 0.0, to: progress)
                                                .stroke(Color.purple, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                                                .frame(width: 55.0, height: 55.0)
                                                .rotationEffect(.degrees(-90))
                                            
                                            Text("\(Int(progress * 100))%")
                                                .font(.body)
                                                .bold()
                                        }
                                        .padding(4.0)
                                        
                                        
                                        if progress > Double(dayPercent) - 0.05 { Button(action: {
                                            onTrackField.toggle()
                                        }) {
                                            Text("on track")
                                                .foregroundColor(Color.green)
                                        }
                                        }
                                        else { Button(action: {
                                            offTrackField.toggle()
                                            
                                        }) {
                                            Text("off track")
                                                .foregroundColor(Color.red)
                                        }
                                        }
                                    }
                                }
                            }
                        }
                        
                        //header
                        if !ageField &&  !heightField && !weightField && !offTrackField && !onTrackField{
                            Text("My Goal")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Color.purple)
                        }
                        
                        //Goal Date selection
                        if !ageField &&  !heightField && !weightField && !offTrackField && !onTrackField{
                            Button(action: {
                                isDatePickerVisible.toggle()
                            }) {
                                HStack {
                                    Text("Select Goal Date")
                                    Image(systemName: "calendar.badge.plus")
                                }
                            }
                            .padding()
                            .foregroundColor(Color.purple)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.purple, lineWidth: 2)
                            )
                        }
                        if isDatePickerVisible {
                            Text("Reach Goal by:")
                            DatePicker("", selection: $selectedDate, in: Date()..., displayedComponents: .date)
                                .datePickerStyle(WheelDatePickerStyle())
                                .padding()
                            Text("Start Date:")
                            Text(dateFormatter.string(from:userData.startDate))
                            Button(action: {
                                userData.goalDate = selectedDate
                                userData.startDate = Date()
                                isDatePickerVisible.toggle()
                            }) {
                                Text("Select Date")
                                    .font(.headline)
                                    .padding()
                            }
                        }
                    }
                    if !isDatePickerVisible {
                        if !weightUpdateField {
                            
                            if weightField {
                                VStack(spacing: 10) {
                                    TextField("Current Weight (lbs)", text: $weightCurText)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    TextField("Goal Weight (lbs)", text: $weightGoalText)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                    
                                    Button(action: {
                                        userData.userWeight = Double(weightCurText) ?? 0.0
                                        startWeight = Double(weightCurText) ?? 0.0
                                        userData.goalWeight = Double(weightGoalText) ?? 0.0
                                        weightField.toggle()
                                        weightUpdateField.toggle()
                                        
                                    }) {
                                        Text("Submit")
                                        
                                    }
                                }
                            }
                        }
                        //User and Goal weight
                        else {
                            if !ageField &&  !heightField &&  !offTrackField && !onTrackField {
                                if weightField {
                                    VStack(spacing: 10) {
                                        TextField("Current Weight (lbs)", text: $weightCurText)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                        
                                        
                                        Button(action: {
                                            userData.userWeight = Double(weightCurText) ?? 0.0
                                            weightField.toggle()
                                        }) {
                                            Text("Submit")
                                            
                                        }
                                        Button(action: {
                                            weightUpdateField.toggle()
                                        }) {
                                            Text("Reset Goal Weight")
                                            
                                        }
                                    }
                                }
                            }
                        }
                        if !ageField &&  !heightField &&  !offTrackField && !onTrackField {
                            Button(action: {
                                weightField.toggle()
                            }) {
                                Text("Weight")
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.purple)
                                    .cornerRadius(10)
                            }
                        }
                        //User height
                        if heightField {
                            VStack(spacing: 10) {
                                TextField("Feet", text: $feetText)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                TextField("Inches", text: $inText)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Button(action: {
                                    let feet = Double(feetText) ?? 0.0
                                    let inches = Double(inText) ?? 0.0
                                    userData.userHeight = feet * 12 + inches
                                    heightField.toggle()
                                }) {
                                    Text("Submit")
                                }
                            }
                        }
                        if !ageField &&  !weightField && !offTrackField && !onTrackField {
                            Button(action: {
                                heightField.toggle()
                            }) {
                                Text("Height")
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.purple)
                                    .cornerRadius(10)
                            }
                        }
                        //user gender
                        if !ageField &&  !heightField && !weightField && !offTrackField && !onTrackField{
                            HStack {
                                Button(action: {
                                    userData.userGender = "Male"
                                    maleTab = Color.gray
                                    femaleTab = Color.purple
                                }) {
                                    Text("Male")
                                        .padding(8)
                                        .foregroundColor(.white)
                                        .background(maleTab)
                                        .cornerRadius(10)
                                }
                                
                                Text("/")
                                
                                Button(action: {
                                    userData.userGender = "Female"
                                    femaleTab = Color.gray
                                    maleTab = Color.purple
                                }) {
                                    Text("Female")
                                        .padding(8)
                                        .foregroundColor(.white)
                                        .background(femaleTab)
                                        .cornerRadius(10)
                                }
                            }
                        }
                        //user age
                        if !heightField && !weightField && !offTrackField && !onTrackField {
                            Button(action:{
                                ageField.toggle()
                            }) {
                                Text("Age")
                                    .padding()
                                    .foregroundColor(.white)
                                    .background(Color.purple)
                                    .cornerRadius(10)
                            }
                            
                            if ageField {
                                TextField("___ years old", text: $ageText)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                
                                Button(action: {
                                    userData.userAge = Int(ageText) ?? 0
                                    ageField.toggle()
                                }) {
                                    Text("Submit")
                                    
                                }
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .padding()
    }
}

struct Goals_Previews: PreviewProvider {
    static var previews: some View {
        Goals().environmentObject(GoalData()) // Provide GoalData environment object
    }
}
