//
//  Fitness.swift
//  Fitness App
//
//  Created by Chase Wolf on 2/27/24.
//

import SwiftUI

//to filter results
enum SearchOption: String, CaseIterable {
    case name = "Exercise Name"
    case value = "Exercise Value"
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

//find total exercise time
struct ExerciseProperties {
    var sets: String
    var reps: String
    var time: String
    
    var finTime: Double {
        var t = 0.0
        if time == "" {
            t += (Double(reps) ?? 0.0) * 0.02
            t = t * (Double(sets) ?? 0.0)
            t += (Double(sets) ?? 0.0) * 2.2
        } else {
            t += (Double(time) ?? 0.0)
        }
        return t
    }
}

//workout class
class Workout: Hashable {
    //all 140+ exercies
    let exerciseList: [[String: Int]] = [
        // Chest Exercises
        ["Bar Dip": 20],
        ["Bench Press": 16],
        ["Cable Chest Press": 14],
        ["Close-Grip Bench Press": 16],
        ["Close-Grip Feet-Up Bench Press": 16],
        ["Decline Bench Press": 16],
        ["Dumbbell Chest Fly": 14],
        ["Dumbbell Chest Press": 14],
        ["Dumbbell Decline Chest Press": 14],
        ["Dumbbell Floor Press": 14],
        ["Dumbbell Pullover": 14],
        ["Feet-Up Bench Press": 16],
        ["Floor Press": 12],
        ["Incline Bench Press": 16],
        ["Incline Dumbbell Press": 14],
        ["Incline Push-Up": 12],
        ["Kneeling Incline Push-Up": 10],
        ["Kneeling Push-Up": 10],
        ["Machine Chest Fly": 14],
        ["Machine Chest Press": 14],
        ["Pec Deck": 14],
        ["Push-Up": 12],
        ["Push-Up Against Wall": 10],
        ["Push-Ups With Feet in Rings": 14],
        ["Resistance Band Chest Fly": 10],
        ["Smith Machine Bench Press": 14],
        ["Smith Machine Incline Bench Press": 14],
        ["Standing Cable Chest Fly": 12],
        ["Standing Resistance Band Chest Fly": 12],
        
        // Shoulder Exercises
        ["Band External Shoulder Rotation": 12],
        ["Band Internal Shoulder Rotation": 12],
        ["Band Pull-Apart": 8],
        ["Barbell Front Raise": 14],
        ["Barbell Rear Delt Row": 14],
        ["Barbell Upright Row": 14],
        ["Behind the Neck Press": 14],
        ["Cable Lateral Raise": 14],
        ["Cable Rear Delt Row": 14],
        ["Dumbbell Front Raise": 14],
        ["Dumbbell Horizontal Internal Shoulder Rotation": 14],
        ["Dumbbell Horizontal External Shoulder Rotation": 14],
        ["Dumbbell Lateral Raise": 14],
        ["Dumbbell Rear Delt Row": 14],
        ["Dumbbell Shoulder Press": 14],
        ["Face Pull": 12],
        ["Front Hold": 16],
        ["Lying Dumbbell External Shoulder Rotation": 10],
        ["Lying Dumbbell Internal Shoulder Rotation": 10],
        ["Machine Lateral Raise": 12],
        ["Machine Shoulder Press": 14],
        ["Monkey Row": 14],
        ["Overhead Press": 16],
        ["Plate Front Raise": 12],
        ["Power Jerk": 14],
        ["Push Press": 14],
        ["Reverse Cable Flyes": 14],
        ["Reverse Dumbbell Flyes": 14],
        ["Reverse Machine Fly": 14],
        ["Seated Dumbbell Shoulder Press": 14],
        ["Seated Barbell Overhead Press": 14],
        ["Seated Smith Machine Shoulder Press": 14],
        ["Snatch Grip Behind the Neck Press": 14],
        ["Squat Jerk": 20],
        ["Split Jerk": 20],
        
        // Bicep Exercises
        ["Barbell Curl": 12],
        ["Barbell Preacher Curl": 12],
        ["Bodyweight Curl": 10],
        ["Cable Curl With Bar": 12],
        ["Cable Curl With Rope": 12],
        ["Concentration Curl": 12],
        ["Dumbbell Curl": 12],
        ["Dumbbell Preacher Curl": 12],
        ["Hammer Curl": 12],
        ["Incline Dumbbell Curl": 10],
        ["Machine Bicep Curl": 12],
        ["Spider Curl": 12],
        
        // Triceps Exercises
        ["Barbell Standing Triceps Extension": 12],
        ["Barbell Lying Triceps Extension": 10],
        ["Bench Dip": 14],
        ["Close-Grip Push-Up": 16],
        ["Dumbbell Lying Triceps Extension": 12],
        ["Dumbbell Standing Triceps Extension": 12],
        ["Overhead Cable Triceps Extension": 12],
        ["Tricep Bodyweight Extension": 10],
        ["Tricep Pushdown With Bar": 12],
        ["Tricep Pushdown With Rope": 12],
        
        // Leg Exercises
        ["Air Squat": 10],
        ["Barbell Hack Squat": 12],
        ["Barbell Lunge": 20],
        ["Barbell Walking Lunge": 20],
        ["Belt Squat": 16],
        ["Body Weight Lunge": 14],
        ["Box Squat": 14],
        ["Bulgarian Split Squat": 20],
        ["Chair Squat": 16],
        ["Dumbbell Lunge": 20],
        ["Dumbbell Squat": 20],
        ["Front Squat": 20],
        ["Goblet Squat": 20],
        ["Hack Squat Machine": 20],
        ["Half Air Squat": 12],
        ["Hip Adduction Machine": 12],
        ["Landmine Hack Squat": 12],
        ["Landmine Squat": 18],
        ["Leg Extension": 16],
        ["Leg Press": 18],
        ["Lying Leg Curl": 16],
        ["Pause Squat": 22],
        ["Romanian Deadlift": 22],
        ["Safety Bar Squat": 18],
        ["Seated Leg Curl": 16],
        ["Shallow Body Weight Lunge": 14],
        ["Side Lunges (Bodyweight)": 14],
        ["Smith Machine Squat": 18],
        ["Squat": 20],
        ["Step Up": 20],
        
        // Back Exercises
        ["Back Extension": 16],
        ["Barbell Row": 14],
        ["Barbell Shrug": 16],
        ["Block Snatch": 14],
        ["Cable Close Grip Seated Row": 14],
        ["Cable Wide Grip Seated Row": 14],
        ["Chin-Up": 20],
        ["Clean": 28],
        ["Clean and Jerk": 36],
        ["Deadlift": 20],
        ["Deficit Deadlift": 18],
        ["Dumbbell Deadlift": 18],
        ["Dumbbell Row": 18],
        ["Dumbbell Shrug": 14],
        ["Floor Back Extension": 14],
        ["Good Morning": 12],
        ["Hang Clean": 28],
        ["Hang Power Clean": 28],
        ["Hang Power Snatch": 36],
        ["Hang Snatch": 36],
        ["Inverted Row": 16],
        ["Inverted Row with Underhand Grip": 16],
        ["Jefferson Curl": 14],
        ["Kettlebell Swing": 12],
        ["Lat Pulldown With Pronated Grip": 14],
        ["Lat Pulldown With Supinated Grip": 14],
        ["One-Handed Cable Row": 14],
        ["One-Handed Lat Pulldown": 14],
        ["Pause Deadlift": 24],
        ["Pendlay Row": 16],
        ["Power Clean": 28],
        ["Power Snatch": 36],
        ["Pull-Up": 24],
        ["Rack Pull": 20],
        ["Seal Row": 24],
        ["Seated Machine Row": 24],
        ["Snatch": 36],
        ["Snatch Grip Deadlift": 20],
        ["Stiff-Legged Deadlift": 20],
        ["Straight Arm Lat Pulldown": 14],
        ["Sumo Deadlift": 20],
        ["T-Bar Row": 16],
        ["Trap Bar Deadlift With High Handles": 18],
        ["Trap Bar Deadlift With Low Handles": 20],
        
        // Glute Exercises
        ["Banded Side Kicks": 12],
        ["Cable Pull Through": 12],
        ["Clamshells": 12],
        ["Dumbbell Romanian Deadlift": 16],
        ["Dumbbell Frog Pumps": 12],
        ["Fire Hydrants": 12],
        ["Frog Pumps": 12],
        ["Glute Bridge": 12],
        ["Hip Abduction Against Band": 12],
        ["Hip Abduction Machine": 12],
        ["Hip Thrust": 16],
        ["Hip Thrust Machine": 16],
        ["Hip Thrust With Band Around Knees": 20],
        ["Lateral Walk With Band": 20],
        ["Machine Glute Kickbacks": 18],
        ["One-Legged Glute Bridge": 18],
        ["One-Legged Hip Thrust": 20],
        ["Romanian Deadlift": 20],
        ["Single Leg Romanian Deadlift": 24],
        ["Standing Glute Kickback in Machine": 18],
        ["Step Up": 20],
        
        //Ab Exercises
        ["Cable Crunch": 16],
        ["Crunch": 16],
        ["Dead Bug": 16],
        ["Hanging Leg Raise": 12],
        ["Hanging Knee Raise": 12],
        ["Hanging Sit-Up": 16],
        ["High to Low Wood Chop with Band": 16],
        ["Horizontal Wood Chop with Band": 16],
        ["Kneeling Ab Wheel Roll-Out": 20],
        ["Kneeling Plank": 12],
        ["Kneeling Side Plank": 14],
        ["Lying Leg Raise": 32],
        ["Lying Windshield Wiper": 32],
        ["Lying Windshield Wiper with Bent Knees": 32],
        ["Machine Crunch": 16],
        ["Mountain Climbers": 36],
        ["Oblique Crunch": 32],
        ["Oblique Sit-Up": 32],
        ["Plank": 32],
        ["Side Plank": 36],
        ["Sit-Up": 20],
        
        // Calves Exercises
        ["Eccentric Heel Drop": 12],
        ["Heel Raise": 12],
        ["Seated Calf Raise": 12],
        ["Standing Calf Raise": 12],
        
        // Forearm Flexors & Grip Exercises
        ["Barbell Wrist Curl": 14],
        ["Barbell Wrist Curl Behind the Back": 14],
        ["Bar Hang": 10],
        ["Dumbbell Wrist Curl": 12],
        ["Farmers Walk": 16],
        ["Fat Bar Deadlift": 16],
        ["Gripper": 16],
        ["One-Handed Bar Hang": 16],
        ["Plate Pinch": 16],
        ["Plate Wrist Curl": 16],
        ["Towel Pull-Up": 16],
        
        // Forearm Extensor Exercises
        ["Barbell Wrist Extension": 14],
        ["Dumbbell Wrist Extension": 14],
        
        //Cardio
        ["Walk": 20],
        ["Light Run/Jog": 40],
        ["Hard Run/Sprint": 60],
        ["Bear Crawl": 80],
        ["Walk with Incline": 30],
        ["Light Run/Jog with Incline": 56],
        ["Hard Run/Sprint with Incline": 80]
    ]
    
    //workout items
    var exercises: [String: ExerciseProperties] = [:]
    let userData: GoalData
    var workout: [String: Int] = [:]
    var time = 0.0
    var name: String = ""
    var exerciseProperties: [String: ExerciseProperties] = [:]
    
    init(userData: GoalData) {
        self.userData = userData
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(workout)
        hasher.combine(time)
    }
    
    static func == (lhs: Workout, rhs: Workout) -> Bool {
        return lhs.workout == rhs.workout && lhs.time == rhs.time
    }
    
    //add exercise to workouts list and add to toal time
    func addExercise(exerciseName: String, properties: ExerciseProperties) {
        exercises[exerciseName] = properties
        let exerciseTime = properties.finTime
        time += exerciseTime // Accumulate the time of each exercise
    }
    
    //calorie calculation
    var cals: Double {
        var totalCal = 0.0
        for (exerciseName, exerciseProps) in exercises {
            var met = 0 // Default MET value
            if let exerciseMet = exerciseList.first(where: { $0.keys.contains(exerciseName) })?[exerciseName] {
                met = exerciseMet
            }
            let exerciseCalories = exerciseProps.finTime * userData.userWeight * Double(met) / 2.2 / 200
            totalCal += exerciseCalories
        }
        return totalCal
    }
}

//To sort items in display. I don't think I used this.
func chunked<T>(array: [T], size: Int) -> [[T]] {
    return stride(from: 0, to: array.count, by: size).map {
        Array(array[$0 ..< Swift.min($0 + size, array.count)])
    }
}

struct Fitness: View {
    @EnvironmentObject var dateFormats: DateFormats
    @EnvironmentObject var userData: GoalData
    
    //fitness variables
    @State private var searchText: String = ""
    @State private var searchResults: [String] = []
    @State private var showSearchTool = false
    @State private var selectedExercises: [String] = []
    @State private var workouts: [Workout] = []
    @State private var exerciseProperties: [String: ExerciseProperties] = [:]
    @State private var workoutName: String = ""
    //140+ exercises again. I know I did not need to include it twice, but I didn't feel like fixing it.
    let exercises: [[String: Int]] = [
        // Chest Exercises
        ["Bar Dip": 20],
        ["Bench Press": 16],
        ["Cable Chest Press": 14],
        ["Close-Grip Bench Press": 16],
        ["Close-Grip Feet-Up Bench Press": 16],
        ["Decline Bench Press": 16],
        ["Dumbbell Chest Fly": 14],
        ["Dumbbell Chest Press": 14],
        ["Dumbbell Decline Chest Press": 14],
        ["Dumbbell Floor Press": 14],
        ["Dumbbell Pullover": 14],
        ["Feet-Up Bench Press": 16],
        ["Floor Press": 12],
        ["Incline Bench Press": 16],
        ["Incline Dumbbell Press": 14],
        ["Incline Push-Up": 12],
        ["Kneeling Incline Push-Up": 10],
        ["Kneeling Push-Up": 10],
        ["Machine Chest Fly": 14],
        ["Machine Chest Press": 14],
        ["Pec Deck": 14],
        ["Push-Up": 12],
        ["Push-Up Against Wall": 10],
        ["Push-Ups With Feet in Rings": 14],
        ["Resistance Band Chest Fly": 10],
        ["Smith Machine Bench Press": 14],
        ["Smith Machine Incline Bench Press": 14],
        ["Standing Cable Chest Fly": 12],
        ["Standing Resistance Band Chest Fly": 12],
        
        // Shoulder Exercises
        ["Band External Shoulder Rotation": 12],
        ["Band Internal Shoulder Rotation": 12],
        ["Band Pull-Apart": 8],
        ["Barbell Front Raise": 14],
        ["Barbell Rear Delt Row": 14],
        ["Barbell Upright Row": 14],
        ["Behind the Neck Press": 14],
        ["Cable Lateral Raise": 14],
        ["Cable Rear Delt Row": 14],
        ["Dumbbell Front Raise": 14],
        ["Dumbbell Horizontal Internal Shoulder Rotation": 14],
        ["Dumbbell Horizontal External Shoulder Rotation": 14],
        ["Dumbbell Lateral Raise": 14],
        ["Dumbbell Rear Delt Row": 14],
        ["Dumbbell Shoulder Press": 14],
        ["Face Pull": 12],
        ["Front Hold": 16],
        ["Lying Dumbbell External Shoulder Rotation": 10],
        ["Lying Dumbbell Internal Shoulder Rotation": 10],
        ["Machine Lateral Raise": 12],
        ["Machine Shoulder Press": 14],
        ["Monkey Row": 14],
        ["Overhead Press": 16],
        ["Plate Front Raise": 12],
        ["Power Jerk": 14],
        ["Push Press": 14],
        ["Reverse Cable Flyes": 14],
        ["Reverse Dumbbell Flyes": 14],
        ["Reverse Machine Fly": 14],
        ["Seated Dumbbell Shoulder Press": 14],
        ["Seated Barbell Overhead Press": 14],
        ["Seated Smith Machine Shoulder Press": 14],
        ["Snatch Grip Behind the Neck Press": 14],
        ["Squat Jerk": 20],
        ["Split Jerk": 20],
        
        // Bicep Exercises
        ["Barbell Curl": 12],
        ["Barbell Preacher Curl": 12],
        ["Bodyweight Curl": 10],
        ["Cable Curl With Bar": 12],
        ["Cable Curl With Rope": 12],
        ["Concentration Curl": 12],
        ["Dumbbell Curl": 12],
        ["Dumbbell Preacher Curl": 12],
        ["Hammer Curl": 12],
        ["Incline Dumbbell Curl": 10],
        ["Machine Bicep Curl": 12],
        ["Spider Curl": 12],
        
        // Triceps Exercises
        ["Barbell Standing Triceps Extension": 12],
        ["Barbell Lying Triceps Extension": 10],
        ["Bench Dip": 14],
        ["Close-Grip Push-Up": 16],
        ["Dumbbell Lying Triceps Extension": 12],
        ["Dumbbell Standing Triceps Extension": 12],
        ["Overhead Cable Triceps Extension": 12],
        ["Tricep Bodyweight Extension": 10],
        ["Tricep Pushdown With Bar": 12],
        ["Tricep Pushdown With Rope": 12],
        
        // Leg Exercises
        ["Air Squat": 10],
        ["Barbell Hack Squat": 12],
        ["Barbell Lunge": 20],
        ["Barbell Walking Lunge": 20],
        ["Belt Squat": 16],
        ["Body Weight Lunge": 14],
        ["Box Squat": 14],
        ["Bulgarian Split Squat": 20],
        ["Chair Squat": 16],
        ["Dumbbell Lunge": 20],
        ["Dumbbell Squat": 20],
        ["Front Squat": 20],
        ["Goblet Squat": 20],
        ["Hack Squat Machine": 20],
        ["Half Air Squat": 12],
        ["Hip Adduction Machine": 12],
        ["Landmine Hack Squat": 12],
        ["Landmine Squat": 18],
        ["Leg Extension": 16],
        ["Leg Press": 18],
        ["Lying Leg Curl": 16],
        ["Pause Squat": 22],
        ["Romanian Deadlift": 22],
        ["Safety Bar Squat": 18],
        ["Seated Leg Curl": 16],
        ["Shallow Body Weight Lunge": 14],
        ["Side Lunges (Bodyweight)": 14],
        ["Smith Machine Squat": 18],
        ["Squat": 20],
        ["Step Up": 20],
        
        // Back Exercises
        ["Back Extension": 16],
        ["Barbell Row": 14],
        ["Barbell Shrug": 16],
        ["Block Snatch": 14],
        ["Cable Close Grip Seated Row": 14],
        ["Cable Wide Grip Seated Row": 14],
        ["Chin-Up": 20],
        ["Clean": 28],
        ["Clean and Jerk": 36],
        ["Deadlift": 20],
        ["Deficit Deadlift": 18],
        ["Dumbbell Deadlift": 18],
        ["Dumbbell Row": 18],
        ["Dumbbell Shrug": 14],
        ["Floor Back Extension": 14],
        ["Good Morning": 12],
        ["Hang Clean": 28],
        ["Hang Power Clean": 28],
        ["Hang Power Snatch": 36],
        ["Hang Snatch": 36],
        ["Inverted Row": 16],
        ["Inverted Row with Underhand Grip": 16],
        ["Jefferson Curl": 14],
        ["Kettlebell Swing": 12],
        ["Lat Pulldown With Pronated Grip": 14],
        ["Lat Pulldown With Supinated Grip": 14],
        ["One-Handed Cable Row": 14],
        ["One-Handed Lat Pulldown": 14],
        ["Pause Deadlift": 24],
        ["Pendlay Row": 16],
        ["Power Clean": 28],
        ["Power Snatch": 36],
        ["Pull-Up": 24],
        ["Rack Pull": 20],
        ["Seal Row": 24],
        ["Seated Machine Row": 24],
        ["Snatch": 36],
        ["Snatch Grip Deadlift": 20],
        ["Stiff-Legged Deadlift": 20],
        ["Straight Arm Lat Pulldown": 14],
        ["Sumo Deadlift": 20],
        ["T-Bar Row": 16],
        ["Trap Bar Deadlift With High Handles": 18],
        ["Trap Bar Deadlift With Low Handles": 20],
        
        // Glute Exercises
        ["Banded Side Kicks": 12],
        ["Cable Pull Through": 12],
        ["Clamshells": 12],
        ["Dumbbell Romanian Deadlift": 16],
        ["Dumbbell Frog Pumps": 12],
        ["Fire Hydrants": 12],
        ["Frog Pumps": 12],
        ["Glute Bridge": 12],
        ["Hip Abduction Against Band": 12],
        ["Hip Abduction Machine": 12],
        ["Hip Thrust": 16],
        ["Hip Thrust Machine": 16],
        ["Hip Thrust With Band Around Knees": 20],
        ["Lateral Walk With Band": 20],
        ["Machine Glute Kickbacks": 18],
        ["One-Legged Glute Bridge": 18],
        ["One-Legged Hip Thrust": 20],
        ["Romanian Deadlift": 20],
        ["Single Leg Romanian Deadlift": 24],
        ["Standing Glute Kickback in Machine": 18],
        ["Step Up": 20],
        
        //Ab Exercises
        ["Cable Crunch": 16],
        ["Crunch": 16],
        ["Dead Bug": 16],
        ["Hanging Leg Raise": 12],
        ["Hanging Knee Raise": 12],
        ["Hanging Sit-Up": 16],
        ["High to Low Wood Chop with Band": 16],
        ["Horizontal Wood Chop with Band": 16],
        ["Kneeling Ab Wheel Roll-Out": 20],
        ["Kneeling Plank": 12],
        ["Kneeling Side Plank": 14],
        ["Lying Leg Raise": 32],
        ["Lying Windshield Wiper": 32],
        ["Lying Windshield Wiper with Bent Knees": 32],
        ["Machine Crunch": 16],
        ["Mountain Climbers": 36],
        ["Oblique Crunch": 32],
        ["Oblique Sit-Up": 32],
        ["Plank": 32],
        ["Side Plank": 36],
        ["Sit-Up": 20],
        
        // Calves Exercises
        ["Eccentric Heel Drop": 12],
        ["Heel Raise": 12],
        ["Seated Calf Raise": 12],
        ["Standing Calf Raise": 12],
        
        // Forearm Flexors & Grip Exercises
        ["Barbell Wrist Curl": 14],
        ["Barbell Wrist Curl Behind the Back": 14],
        ["Bar Hang": 10],
        ["Dumbbell Wrist Curl": 12],
        ["Farmers Walk": 16],
        ["Fat Bar Deadlift": 16],
        ["Gripper": 16],
        ["One-Handed Bar Hang": 16],
        ["Plate Pinch": 16],
        ["Plate Wrist Curl": 16],
        ["Towel Pull-Up": 16],
        
        // Forearm Extensor Exercises
        ["Barbell Wrist Extension": 14],
        ["Dumbbell Wrist Extension": 14],
        
        //Cardio
        ["Walk": 20],
        ["Light Run/Jog": 40],
        ["Hard Run/Sprint": 60],
        ["Bear Crawl": 80],
        ["Walk with Incline": 30],
        ["Light Run/Jog with Incline": 56],
        ["Hard Run/Sprint with Incline": 80]
    ]

    //fitness display
    var body: some View {
        VStack {
            if !showSearchTool {
                //header
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .frame(width: 165.0, height: 50.0)
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                    Text("Fitness")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(Color.purple)
                }
                
                ZStack {
                    //display daily calories lost
                    RoundedRectangle(cornerRadius: 20)
                        .padding(.bottom, 50.0)
                        .frame(width: 350.0, height: 600.0)
                        .foregroundColor(.white)
                        .shadow(radius: 5)
                    VStack {
                        Text("Calories Lost Today: \(Int(userData.calLost))")
                            .font(.title)
                            .fontWeight(.bold)
                        ScrollView(.horizontal) {
                            HStack {
                                //show each workout as well as buttons to add or remove from daily calories
                                ForEach(workouts, id: \.self) { workout in
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 20)
                                            .padding(.bottom, 5.0)
                                            .frame(width: 130.0, height: 350.0)
                                            .foregroundColor(.white)
                                            .overlay(
                                                           RoundedRectangle(cornerRadius: 20)
                                                               .stroke(Color.purple, lineWidth: 2)
                                                       )
                                        VStack {
                                            Text("'\(workout.name)':")
                                            ForEach(workout.exercises.keys.sorted(), id: \.self) { exerciseName in
                                                Text(" \(exerciseName)")
                                                    .font(.caption)
                                                    .frame(width: 100.0)
                                            }
                                            Image(systemName: "dumbbell").foregroundColor(Color.purple).padding(.bottom, 5.0).font(.system(size: 50))
                                            Text(" \(Int(workout.time)) min")
                                            Text("- \(Int(workout.cals)) calories")
                                            HStack {
                                                Button(action: {
                                                    userData.calLost += workout.cals
                                                }){
                                                    Image(systemName: "plus.app.fill").padding(.top, 4.0).font(.system(size: 40))
                                                }
                                                Button(action: {
                                                    userData.calLost -= workout.cals
                                                }){
                                                    Image(systemName: "minus").padding(.top, 4.0).font(.system(size: 20))
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        .frame(width: 300.0)
                        
                        Button(action: {
                            showSearchTool.toggle()
                        }) {
                            HStack {
                                Text("Add New Workout")
                            }
                            Image(systemName: "plus.app")
                        }
                    }
                }
            } else {
                // Search Tool
                Text("My Workout:")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.purple)
                    .padding(.bottom, 50.0)
                
                VStack {
                    TextField("Workout Name:", text: $workoutName)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    ScrollView(.horizontal) {
                        ForEach(chunked(array: selectedExercises, size: 100), id: \.self) { chunk in
                            HStack(spacing: 0) {
                                ForEach(chunk, id: \.self) { exercise in
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 20)
                                            .padding(.bottom, 5.0)
                                            .frame(width: 130.0, height: 200.0)
                                            .foregroundColor(.white)
                                            .shadow(radius: 5)
                                        VStack {
                                            Text(exercise)
                                                .frame(width: 110.0)
                                            HStack {//amount of sets
                                                TextField("Sets", text: Binding(
                                                    get: { self.exerciseProperties[exercise]?.sets ?? "" },
                                                    set: { newValue in
                                                        if var props = self.exerciseProperties[exercise] {
                                                            props.sets = newValue
                                                            self.exerciseProperties[exercise] = props
                                                        } else {
                                                            self.exerciseProperties[exercise] = ExerciseProperties(sets: newValue, reps: "", time: "")
                                                        }
                                                    }
                                                ))
                                                .frame(width: 55.0)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                                //amount of reps
                                                TextField("Reps", text: Binding(
                                                    get: { self.exerciseProperties[exercise]?.reps ?? "" },
                                                    set: { newValue in
                                                        if var props = self.exerciseProperties[exercise] {
                                                            props.reps = newValue
                                                            self.exerciseProperties[exercise] = props
                                                        } else {
                                                            self.exerciseProperties[exercise] = ExerciseProperties(sets: "", reps: newValue, time: "")
                                                        }
                                                    }
                                                ))
                                                .frame(width: 55.0)
                                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                            }//or time spent doing exercise
                                            Text("or")
                                                .foregroundColor(Color.gray)
                                            TextField("Time(min)", text: Binding(
                                                get: { self.exerciseProperties[exercise]?.time ?? "" },
                                                set: { newValue in
                                                    if var props = self.exerciseProperties[exercise] {
                                                        props.time = newValue
                                                        self.exerciseProperties[exercise] = props
                                                    } else {
                                                        self.exerciseProperties[exercise] = ExerciseProperties(sets: "", reps: "", time: newValue)
                                                    }
                                                }
                                            ))
                                            .frame(width: 110.0)
                                            .textFieldStyle(RoundedBorderTextFieldStyle())
                                        }
                                    }.padding()
                                }
                            }
                        }
                    }
                    .frame(width: 300.0, height: 250.0)
                    //seach tool
                    TextField("Search for an exercise", text: $searchText)
                        .padding()
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    List(searchResults, id: \.self) { exercise in
                        Button(action: {
                            if selectedExercises.contains(exercise) {
                                selectedExercises.removeAll { $0 == exercise }
                            } else {
                                selectedExercises.append(exercise)
                            }
                        }) {
                            HStack {
                                Text(exercise)
                                Spacer()
                                if selectedExercises.contains(exercise) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    .frame(height: 150)
                    .padding(.horizontal)
                }
                
                // Button to add selected exercises to the workout
                Button(action: {
                    showSearchTool.toggle()
                    let newWorkout = Workout(userData: userData)
                    
                    var maxTime: Double = 0.0
                    
                    for selectedExercise in selectedExercises {
                        newWorkout.addExercise(exerciseName: selectedExercise, properties: exerciseProperties[selectedExercise] ?? ExerciseProperties(sets: "", reps: "", time: ""))
                        let exerciseProps = exerciseProperties[selectedExercise]
                        if let totTime = exerciseProps?.finTime {
                                maxTime += totTime
                        }
                    }
                    
                    newWorkout.time = maxTime
                    newWorkout.name = workoutName
                    workouts.append(newWorkout)
                    workoutName = ""
                    selectedExercises = []
                }) {
                    Text("Create Workout")
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.purple)
                        .cornerRadius(10)
                }
                .padding()
            }
        }
        .onAppear {
            updateSearchResults()
        }
        .onChange(of: searchText) { _ in//idk how to get rid of this warning properly, but it works just fine so I left it
            updateSearchResults()
        }
    }
    
    func updateSearchResults() {
        if searchText.isEmpty {
            searchResults = []
        } else {
            searchResults = exercises.compactMap { exerciseDict in
                exerciseDict.keys.first(where: { $0.localizedCaseInsensitiveContains(searchText) })
            }
        }
    }
}

struct Fitness_Previews: PreviewProvider {
    static var previews: some View {
        Fitness().environmentObject(GoalData()) // Provide GoalData environment object
    }
}
