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
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                Text("수면 데이터 업데이트하기")
                Spacer()
            }
            HStack {
                Text("더 정확한 추천을 해드릴게요")
                Spacer()
            }
        }
    }
}

struct SleepTimeView: View {
    
    @Binding var mainSleepStart : Date
    @Binding var mainSleepEnd   : Date
    @Binding var napSleepStart  : Date
    @Binding var napSleepEnd    : Date
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                VStack{
                    Text("민수님")
                    Text("이때 주무시는건 어때요?")
                }
                Spacer()
                Text("logo")
            }
            VStack{
                HStack {
                    Spacer()
                    Text(mainSleepStart.formatted(date: .numeric, time: .shortened))
                    Text(mainSleepEnd.formatted(date: .numeric, time: .shortened))
                    Spacer()
                    Text("Duration: \(mainSleepEnd.timeIntervalSince(mainSleepStart)/3600, specifier: "%.0f") hours")
                }
                HStack {
                    Spacer()
                    Text(napSleepStart.formatted(date: .numeric, time: .shortened))
                    Text(napSleepEnd.formatted(date: .numeric, time: .shortened))
                    Spacer()
                    Text("Duration: \(napSleepEnd.timeIntervalSince(napSleepStart)/3600, specifier: "%.0f") hours")
                }
            }.padding(15)
                .background(Color.gray.brightness(0.35))
                .cornerRadius(20)
        }
    }
}

struct GraphView: View {
    
    @Binding var AwarenessData: [LineData]
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                VStack{
                    Text("민수님")
                    Text("이때 주무시는건 어때요?")
                }
                Spacer()
                Text("logo")
            }
            Chart {
                ForEach(AwarenessData){
                    LineMark(
                        x: .value("x", $0.x),
                        y: .value("y", $0.y),
                        series: .value("awareness", "a")
                    ).interpolationMethod(.catmullRom)
                        .foregroundStyle(by: .value("Category", $0.Category))
                }
            }
        }
    }
}
