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
    @AppStorage("needUpdate") var needUpdate:Bool = false
    
    let now = Date.now
    let oneweekafter = Date.now.addingTimeInterval(60*60*24*7*1.0)
    let top_pad = 3.0, bottom_pad = 3.0, leading_pad = 10.0, trailing_pad = 10.0
    var body: some View {
        VStack {
            Text("Settings")
                .font(.title)
                .bold()
            Text("")
                .font(.title)
            HStack{
                Text("Sleep Onset : ")
                    .bold()
                Spacer()
            }.padding(EdgeInsets(top: top_pad, leading: leading_pad, bottom: bottom_pad, trailing: trailing_pad))
            HStack{
                DatePicker(
                    "",
                    selection: $sleep_onset,
                    in: now...oneweekafter,
                    displayedComponents: [.date, .hourAndMinute]
                ).onChange(of: sleep_onset, perform: { _ in
                    needUpdate = true
                })
                Spacer()
            }.padding(EdgeInsets(top: top_pad, leading: leading_pad, bottom: bottom_pad, trailing: trailing_pad))
            HStack{
                Text("Work Period : ")
                    .bold()
                Spacer()
            }.padding(EdgeInsets(top: top_pad, leading: leading_pad, bottom: bottom_pad, trailing: trailing_pad))
            HStack{
                Spacer(minLength: 65)
                Text("Start")
                Spacer()
                DatePicker(
                    "",
                    selection: $work_onset,
                    in: now...oneweekafter,
                    displayedComponents: [.date, .hourAndMinute]
                ).onChange(of: work_onset, perform: { _ in
                    needUpdate = true
                })
                Spacer()
            }.padding(EdgeInsets(top: top_pad, leading: leading_pad, bottom: bottom_pad, trailing: trailing_pad))
            HStack{
                Spacer(minLength: 70)
                Text("End")
                Spacer()
                DatePicker(
                    "",
                    selection: $work_offset,
                    in: now...oneweekafter,
                    displayedComponents: [.date, .hourAndMinute]
                ).onChange(of: work_offset, perform: { _ in
                    needUpdate = true
                })
                Spacer()
            }.padding(EdgeInsets(top: top_pad, leading: leading_pad, bottom: bottom_pad, trailing: trailing_pad))
            HStack{
                Text("Alarm Setting : ")
                    .bold()
                Spacer()
            }.padding(EdgeInsets(top: top_pad, leading: leading_pad, bottom: bottom_pad, trailing: trailing_pad))
            HStack{
                DatePicker(
                    "",
                    selection: $alarm,
                    in: now...Date.now.addingTimeInterval(60.0*60*24),
                    displayedComponents: [.hourAndMinute]
                )
                Spacer()
            }.padding(EdgeInsets(top: top_pad, leading: leading_pad, bottom: bottom_pad, trailing: trailing_pad))
        }
        .padding(EdgeInsets(top: top_pad, leading: leading_pad, bottom: bottom_pad, trailing: trailing_pad))
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
