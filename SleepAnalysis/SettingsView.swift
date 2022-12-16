//
//  SettingsView.swift
//  SleepAnalysis
//
//  Created by Reinatt Wijaya on 2022/11/06.
//

import SwiftUI

struct SettingsView: View {
    
//    @AppStorage("V0_x") var V0_x: Double = -0.8283
//    @AppStorage("V0_y") var V0_y: Double = 0.8413
//    @AppStorage("V0_n") var V0_n: Double = 0.6758
//    @AppStorage("V0_H") var V0_H: Double = 13.3336
    @AppStorage("sleep_onset") var sleep_onset: Date = Date.now
    @AppStorage("work_onset") var work_onset: Date = Date.now
    @AppStorage("work_offset") var work_offset: Date = Date.now
    @AppStorage("alarm") var alarm: Date = Date.now
    
    let now = Date.now
    let oneweekafter = Date.now.addingTimeInterval(60*60*24*7*1.0)
    
    var body: some View {
        VStack {
            Text("Settings")
            HStack{
                Text("Sleep Onset : ")
                Spacer()
            }
            HStack{
                DatePicker(
                    "",
                    selection: $sleep_onset,
                    in: now...oneweekafter,
                    displayedComponents: [.date, .hourAndMinute]
                )
                Spacer()
            }
            HStack{
                Text("Work Onset : ")
                Spacer()
            }
            HStack{
                DatePicker(
                    "",
                    selection: $work_onset,
                    in: now...oneweekafter,
                    displayedComponents: [.date, .hourAndMinute]
                )
                DatePicker(
                    "",
                    selection: $work_offset,
                    in: now...oneweekafter,
                    displayedComponents: [.date, .hourAndMinute]
                )
            }.padding(EdgeInsets(top: 0.0, leading: 0.0, bottom: 10.0, trailing: 0.0))
            HStack{
                Text("Alarm Setting : ")
                Spacer()
            }
            HStack{
                DatePicker(
                    "",
                    selection: $alarm,
                    in: now...Date.now.addingTimeInterval(60.0*60*24),
                    displayedComponents: [.hourAndMinute]
                )
                Spacer()
            }
        }
        .padding()
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
