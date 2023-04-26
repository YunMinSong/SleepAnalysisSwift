//
//  ContentUtilsView.swift
//  SleepAnalysis
//
//  Created by Reinatt Wijaya on 2023/03/06.
//

import SwiftUI
import Foundation
import Charts

struct HeaderView: View{
    var body: some View {
        HStack{
            Text("my sleep")
            Spacer()
            Button(action: {print("notif is pressed")}, label: {Text("notif")})
        }
    }
}

struct AlertView: View {
    @Binding var tabSelection : Int
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                Text("내 수면")
                    .bold()
                Spacer()
                Button(action: {self.tabSelection = 2}, label: {
                    Image(systemName: "chevron.right")
                })
            }
        }
    }
}

struct SleepTimeView: View {
    @Binding var tabSelection : Int
    @Binding var mainSleepStart : Date
    @Binding var mainSleepEnd   : Date
    @Binding var napSleepStart  : Date
    @Binding var napSleepEnd    : Date
    
    @AppStorage("sleep_onset") var sleep_onset: Date = Date.now
    @AppStorage("work_onset") var work_onset: Date = Date.now
    @AppStorage("work_offset") var work_offset: Date = Date.now
    @AppStorage("Registered") var isRegistered: Bool = false
    @AppStorage("UserId") private var userId: String = "-"
    
    @State private var userName: String = "홍길동"
    //Put calculated one
    @State private var from1: String = "19:40"
    @State private var to1: String = "04:20"
    @State private var from2: String = "10:15"
    @State private var to2: String = "02:50"
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                Text("수면 추천")
                    .bold()
                Spacer()
                Button(action: {self.tabSelection = 3}, label: {
                    Image(systemName: "chevron.right")
                })
            }
            //            VStack{
            //                HStack {
            //                    Spacer()
            //                    Text(mainSleepStart.formatted(date: .numeric, time: .shortened))
            //                    Text(mainSleepEnd.formatted(date: .numeric, time: .shortened))
            //                    Spacer()
            //                    Text("Duration: \(mainSleepEnd.timeIntervalSince(mainSleepStart)/3600, specifier: "%.0f") hours")
            //                }
            //                HStack {
            //                    Spacer()
            //                    Text(napSleepStart.formatted(date: .numeric, time: .shortened))
            //                    Text(napSleepEnd.formatted(date: .numeric, time: .shortened))
            //                    Spacer()
            //                    Text("Duration: \(napSleepEnd.timeIntervalSince(napSleepStart)/3600, specifier: "%.0f") hours")
            //                }
            //            }.padding(15)
            //                .background(Color.gray.brightness(0.35))
            //                .cornerRadius(20)
            
            if sleep_onset == Date.now || work_onset == Date.now || work_offset == Date.now || !isRegistered {
                BeforeTimeGet(userName: userId)
            } else {
                BoxWithRecommend(from1: $from1, to1: $to1, from2: $from2, to2: $to2)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}

struct GraphView: View {
    
    @Binding var AwarenessData: [LineData]
    @Binding var tabSelection : Int
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                VStack{
                    Text("잠시 바람 쐬는건 어때요?")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    Text("각성도가 낮아요")
                        .font(.system(size: 12))
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
                Button(action: {self.tabSelection = 2}, label: {
                    Image(systemName: "chevron.right")
                })
            }
            Chart {
                ForEach(AwarenessData){
                    LineMark(
                        x: .value("x", $0.x),
                        y: .value("y", $0.y),
                        series: .value("Alertness", "a")
                    ).interpolationMethod(.catmullRom)
                        .foregroundStyle(by: .value("Category", $0.Category))
                }
            }
        }
    }
}
