//
//  MainView.swift
//  SleepAnalysis
//
//  Created by Reinatt Wijaya on 2022/11/06.
//

import SwiftUI

struct MainView: View {
    
    let persistenceController = PersistenceController.shared
    
    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }.environment(\.managedObjectContext, persistenceController.container.viewContext)
            
            ScheduleView(calendar: Calendar(identifier: .gregorian))
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .tabItem {
                    Label("Schedule", systemImage: "calendar.badge.clock")
                }
            RecommendView()
                .tabItem {
                    Label("Recommend", systemImage: "moon.fill")
                        .environment(\.managedObjectContext, persistenceController.container.viewContext)
                }
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
                }
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
