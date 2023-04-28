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
            Text("my night")
                .font(.title)
                .bold()
            Spacer()
            Button(action: {print("notif is pressed")}, label: {Image("bell")})
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
                VStack{
                    HStack{
                        Text("\(userName)님")
                            .bold()
                            .font(.title2)
                        Spacer()
                    }
                    HStack{
                        Text("이때 주무시는건 어때요?")
                        Spacer()
                    }
                }
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
                ZStack {
                    Rectangle()
                        .foregroundColor(.white)
                        .cornerRadius(16.0)
                        .frame(height: 300)
                    VStack(alignment: .leading) {
                        Text("\(userName)님에게 딱 맞는 수면 패턴을 추천해 드릴게요")
                            .font(.custom("Small", size: 15))
                            .padding(.top, 5.0)
                        GifImage("notFound")
                            .padding(.horizontal, 20)
                        /*Image("sskoo")
                            .padding(.vertical, 50.0)
                            .alignmentGuide(.leading, computeValue: { d in -100.0})
                         */
                    }
                }.padding(.horizontal)
            } else {
                RecommendedSleep(from1: $from1, to1: $to1, from2: $from2, to2: $to2)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
}

struct RecommendedSleep: View {
    
    @Binding var from1: String
    @Binding var to1: String
    @Binding var from2: String
    @Binding var to2: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color(red: 0.948, green: 0.953, blue: 0.962))
                .frame(width: 310, height: 180)
                .cornerRadius(16)
                .padding(.vertical, 10)
            VStack(alignment: .center, spacing: 10) {
                RecommendedCaption(from: $from1, to: $to1)
                RecommendedCaption(from: $from2, to: $to2)
            }
        }
    }
}

struct RecommendedCaption: View {
    
    @Binding var from: String
    @Binding var to: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .frame(width: 278, height: 70)
                .cornerRadius(16)
            HStack(spacing: 15) {
                Image("moon3")
                HStack(alignment: .bottom, spacing: 3) {
                    Text(specificTime(original:from).0)
                        .font(.custom("Small", size: 15))
                    Text(from)
                        .font(.headline)
                    Text("부터")
                        .font(.custom("Small", size: 15))
                    Text(timeInterval(original:to))
                        .font(.headline)
                    Text("이상")
                        .font(.custom("Small", size: 15))
                }
            }.padding([.leading, .trailing],10)
        }
    }
}


struct GraphView: View {
    
    @Binding var AwarenessData: [LineData]
    @Binding var tabSelection : Int
    @State private var userName: String = "홍길동"
    var body: some View {
        VStack(alignment: .leading) {
            HStack{
                VStack{
                    Text("잠시 바람 쐬는건 어때요?")
                        .bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .font(.title2)
                        .padding([.bottom], 5)
                    Text("\(userName)님 각성도가 낮아요")
                        .font(.system(size: 12))
                        .padding([.bottom], 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                Spacer()
                Button(action: {self.tabSelection = 2}, label: {
                    Image(systemName: "chevron.right")
                })
            }
            ZStack{
                Rectangle()
                    .foregroundColor(Color(red: 0.948, green: 0.953, blue: 0.962))
                    .frame(width: 310, height: 180)
                    .cornerRadius(16)
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
                .chartYAxis(.hidden)
                .chartXAxis(.hidden)
                .frame(width: 290, height: 160)
            }
//            .background(Color(red: 0.948, green: 0.953, blue: 0.962))
//            .cornerRadius(16)
//            .offset(x:10, y:10)
        }
    }
}
