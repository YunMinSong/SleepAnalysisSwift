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
            Text("2SLEEP")
                .font(.title)
                .bold()
            Spacer()
            Button(action: {print("notif is pressed")}, label: {Image("bell")})
        }
    }
}

struct RecommendHeaderView: View{
    var body: some View {
        HStack{
            Text("추천 수면")
                .font(.title)
                .bold()
            Spacer()
            
        }
    }
}

struct ScheduleHeaderView: View{
    var body: some View {
        HStack{
            Text("수면 기록")
                .font(.title)
                .bold()
            Spacer()
            
        }
    }
}

struct SettingHeaderView: View{
    var body: some View {
        HStack{
            Text("설정")
                .font(.title)
                .bold()
            Spacer()
            
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

func date_to_string(date: Date) -> String{
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm"
    return formatter.string(from: date)
}

func time_to_string(seconds: Int) -> String{
    let hour = seconds/3600
    let minutes = (seconds%3600)/60
    var hour_string = "\(hour)"
    var minute_string = "\(minutes)"
    if hour < 10{
        hour_string = "0\(hour)"
    }
    if minutes < 10{
        minute_string = "0\(minutes)"
    }
    return (hour_string+":"+minute_string)
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
        
    //Put calculated one
    var body: some View {
        
        let from1 = date_to_string(date: mainSleepStart)
        let to1 = time_to_string(seconds: Int(mainSleepEnd.timeIntervalSince(mainSleepStart)))
        let from2 = date_to_string(date: napSleepStart)
        let to2 = time_to_string(seconds: Int(napSleepEnd.timeIntervalSince(napSleepStart)))

        VStack() {
            HStack{
                VStack{
                    HStack{
                        Text("\(userId)님")
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
            
            if sleep_onset == Date.now || work_onset == Date.now || work_offset == Date.now || !isRegistered {
                ZStack(alignment: .center) {
                    Rectangle()
                        .foregroundColor(.white)
                        .cornerRadius(16.0)
                        .frame(height: 300)
                    VStack(alignment: .leading) {
                        Text("\(userId)님에게 딱 맞는 수면 패턴을 추천해 드릴게요")
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
                RecommendedSleep(from1: from1, to1: to1, from2: from2, to2: to2)
            }
        }
    }
}

struct RecommendedSleep: View {
    
    var from1: String
    var to1: String
    var from2: String
    var to2: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color(red: 0.948, green: 0.953, blue: 0.962))
                .frame(width: 310, height: 180)
                .cornerRadius(16)
                .padding(.vertical, 10)
            VStack(alignment: .center, spacing: 10) {
                RecommendedCaption(from: from1, to: to1)
                if (to2 != "00:00"){
                    RecommendedCaption(from: from2, to: to2)
                }else{
                    NoNapCaption()
                }
            }
        }
    }
}

struct NoNapCaption: View {
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .frame(width: 278, height: 70)
                .cornerRadius(16)
            HStack(spacing: 15) {
                Image("moon3")
                Text("No Nap Needed")
                    .font(.headline)
            }.padding([.leading, .trailing],10)
        }
    }
}

struct RecommendedCaption: View {
    
    var from: String
    var to: String
    
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
    @AppStorage("UserId") private var userId: String = "-"
    var body: some View {
        VStack(alignment: .leading) {
            VStack{
                Text("잠시 바람 쐬는건 어때요?")
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.title2)
                Text("\(userId)님 각성도가 낮아요")
                    .padding([.bottom], 10)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            ZStack{
                Rectangle()
                    .foregroundColor(Color(red: 0.948, green: 0.953, blue: 0.962))
                    .frame(width: 330, height: 180)
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
                    PointMark(x: .value("x", AwarenessData[288].x), y: .value("y", AwarenessData[288].y))
                        .annotation(position: .trailing, alignment: .leading) {
                            Text("now")
                                .foregroundStyle(.gray)
                                .offset(x: 10, y: 0)
                        }
                    RuleMark(
                        xStart: .value("Start", AwarenessData[0].x),
                        xEnd: .value("End", AwarenessData[575].x),
                        y: .value("Value", 0.0)
                    ).opacity(0.3)
                        .foregroundStyle(.gray)
                        .annotation(position: .trailing, alignment: .leading) {
                            Text("0")
                                .foregroundStyle(.gray)
                        }
                }
                .chartYAxis(.hidden)
                .chartXAxis(.hidden)
                .frame(width: 290, height: 160)
            }
        }
    }
}

