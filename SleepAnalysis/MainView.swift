//
//  MainView.swift
//  SleepAnalysis
//
//  Created by Reinatt Wijaya on 2022/11/06.
//

import SwiftUI
import CoreData

class AwarenessModel: ObservableObject{
    @Published var AwarenessData = [LineData](repeating: LineData(Category: "Awareness", x: formatDate(offset: 0.0), y: 0.0), count: 12*24*2)
    @Published var SleepData = [LineData](repeating: LineData(Category: "Sleep", x: formatDate(offset: 0.0), y: 0.0), count: 12*24*2)
    @Published var SleepSuggestionData = [LineData](repeating: LineData(Category: "Sleep Suggestion", x: formatDate(offset: 0.0), y: 0.0), count: 12*24*2)
}

struct MainView: View {
    @State private var tabSelection = 1
    @AppStorage("UserEmail") private var userEmail: String = ""
    @AppStorage("needUpdate") var needUpdate:Bool = false
    @AppStorage("sleep_onset") var sleep_onset: Date = Date.now
    @AppStorage("work_onset") var work_onset: Date = Date.now
    @AppStorage("work_offset") var work_offset: Date = Date.now
    
    let persistenceController = PersistenceController.shared
    
    init(){
        needUpdate = true
    }
    
    var body: some View {
        if self.userEmail == "" {
            BeforeRegisterView()
        } else {
            TabView(selection: $tabSelection) {
                ContentView(tabSelection: $tabSelection)
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
                RecommendView()
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
                .onAppear{
                    if sleep_onset < Date.now{
                        sleep_onset = sleep_onset.addingTimeInterval(60*60*24.0)
                    }
                    while work_onset < sleep_onset{
                        work_onset = work_onset.addingTimeInterval(60*60*24.0)
                    }
                    while work_offset < work_onset{
                        work_offset = work_offset.addingTimeInterval(60*60*24.0)
                    }
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
