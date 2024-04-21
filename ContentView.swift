//
//  ContentView.swift
//  Fitness App
//
//  Created by Chase Wolf on 2/15/24.
//

import SwiftUI

struct ContentView: View {
    @StateObject var goalData = GoalData()
    var body: some View {
        TabView {
            //Goals View
            Goals().environmentObject(goalData)
                .tabItem {
                    Image(systemName: "star.circle")
                        .foregroundColor(Color.purple)
                    Text("Goals")
                }
            //Nutrition View
            Nutrition().environmentObject(goalData).tabItem {
                Image(systemName: "fork.knife.circle")
                Text("Nutrition")
            }
            //Fitness View
            Fitness().environmentObject(goalData)
                .tabItem {
                    Image(systemName: "figure.run.circle")
                        .foregroundColor(Color.purple)
                    Text("Fitness")
                        .foregroundColor(Color.purple)
                }
        }
    }
}

#Preview {
    ContentView()
}
