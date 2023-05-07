//
//  MainView.swift
//  SleepAnalysis
//
//  Created by Reinatt Wijaya on 2022/11/06.
//

import SwiftUI
import CoreData

struct MainView: View {
    @State private var tabSelection = 1
    @AppStorage("UserEmail") private var userEmail: String = ""
    @State var AwarenessData = [LineData](repeating: LineData(Category: "Awareness", x: formatDate(offset: 0.0), y: 0.0), count: 12*24*2)
    @State var SleepData = [LineData](repeating: LineData(Category: "Sleep", x: formatDate(offset: 0.0), y: 0.0), count: 12*24*2)
    @State var SleepSuggestionData = [LineData](repeating: LineData(Category: "Sleep Suggestion", x: formatDate(offset: 0.0), y: 0.0), count: 12*24*2)
    
    let persistenceController = PersistenceController.shared
    
    var body: some View {
        if self.userEmail == "" {
            BeforeRegisterView()
        } else {
            TabView(selection: $tabSelection) {
                ContentView(tabSelection: $tabSelection, AwarenessData: $AwarenessData, SleepData: $SleepData, SleepSuggestionData: $SleepSuggestionData)
                    .tabItem {
                        Label("Home", systemImage: "house.fill")
                    }.environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .tag(1)
                ScheduleView(calendar: Calendar(identifier: .gregorian))
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .tabItem {
                        Label("Schedule", systemImage: "calendar.badge.clock")
                    }
                    .tag(2)
                RecommendView(AwarenessData: $AwarenessData, SleepData: $SleepData, SleepSuggestionData: $SleepSuggestionData)
                    .tabItem {
                        Label("Recommend", systemImage: "moon.fill")
                    }
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    .tag(3)
                SettingsView()
                    .tabItem {
                        Label("Settings", systemImage: "gearshape.fill")
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                    }
                    .tag(4)
            }.navigationBarBackButtonHidden()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
