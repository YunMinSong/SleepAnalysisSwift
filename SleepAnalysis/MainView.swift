//
//  MainView.swift
//  SleepAnalysis
//
//  Created by Reinatt Wijaya on 2022/11/06.
//

import SwiftUI

struct MainView: View {
    
    @AppStorage("UserEmail") private var userEmail: String = ""
    
    let persistenceController = PersistenceController.shared
    
    var body: some View {
        if self.userEmail == "" {
            BeforeRegisterView()
        } else {
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
            }.navigationBarBackButtonHidden()
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
