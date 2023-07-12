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
                HStack{
                    Text("수면 추천")
                        .bold()
                        .font(.title2)
                    Spacer()
                }
                Spacer()
                Button(action: {self.tabSelection = 3}, label: {
                    Image(systemName: "chevron.right")
                })
                .foregroundColor(.black)
            }
            
            if sleep_onset == Date.now || work_onset == Date.now || work_offset == Date.now || !isRegistered {
                ZStack(alignment: .center) {
                    Rectangle()
                        .foregroundColor(.white)
                        .cornerRadius(16.0)
                        .frame(height: sleep_onset == Date.now || work_onset == Date.now || work_offset == Date.now || !isRegistered ? 331 : 472)
                    VStack(alignment: .leading) {
                        Text("\(userId)님의 수면 데이터가 없어요")
                            .font(.custom("Small", size: 15))
                            .padding(.top, 5.0)
                        GifImage("notFound")
                            .padding(.horizontal, 20)
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
    @State var isSliding: Bool = false
    
    var body: some View {
        VStack(alignment: .center) {
            ZStack {
                VStack(alignment: .center, spacing: 20) {
                    //Clock
                    ZStack {
                        Circle()
                            .frame(width: 280, height: 280)
                            .foregroundColor(Color(red: 0.949, green: 0.949, blue: 0.949))
                            .alignmentGuide(.leading, computeValue: { d in -70.0})
                        Path { path in
                            path.move(to: CGPoint(x: 165, y: 140))
                            path.addArc(center: .init(x: 165, y: 140), radius: 140, startAngle: Angle(degrees: timeToAngle(time: from2)), endAngle: Angle(degrees: timeToAngle(time: addTimeInString(time1: from2, time2: to2))), clockwise: false)
                        }.fill(isSliding ? Color.blue : Color(red: 0.769, green: 0.85, blue: 0.942))
                        Path { path in
                            path.move(to: CGPoint(x: 165, y: 140))
                            path.addArc(center: .init(x: 165, y: 140), radius: 140, startAngle: Angle(degrees: timeToAngle(time: from1)), endAngle: Angle(degrees: timeToAngle(time: addTimeInString(time1: from1, time2: to1))), clockwise: false)
                        }.fill(isSliding ? Color(red: 0.769, green: 0.85, blue: 0.942) : Color.blue)
                        Circle()
                            .frame(width: 200, height: 200)
                            .foregroundColor(.white)
                            .alignmentGuide(.leading, computeValue: { d in -70.0})
                        //Picker
                        Picker(centerX: 165, centerY: 140)
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundColor(isSliding ? Color(red: 0.769, green: 0.85, blue: 0.942) : Color.blue)
                            .offset(x:120*cos(timeToAngle(time: from1)*Double.pi/180), y: 120*sin(timeToAngle(time: from1)*Double.pi/180))
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundColor(isSliding ? Color(red: 0.769, green: 0.85, blue: 0.942) : Color.blue)
                            .offset(x:120*cos(timeToAngle(time: addTimeInString(time1: from1, time2: to1))*Double.pi/180), y: 120*sin(timeToAngle(time: addTimeInString(time1: from1, time2: to1))*Double.pi/180))
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundColor(isSliding ? Color.blue : Color(red: 0.769, green: 0.85, blue: 0.942))
                            .offset(x:120*cos(timeToAngle(time: from2)*Double.pi/180), y: 120*sin(timeToAngle(time: from2)*Double.pi/180))
                        Circle()
                            .frame(width: 40, height: 40)
                            .foregroundColor(isSliding ? Color.blue : Color(red: 0.769, green: 0.85, blue: 0.942))
                            .offset(x:120*cos(timeToAngle(time: addTimeInString(time1: from2, time2: to2))*Double.pi/180), y: 120*sin(timeToAngle(time: addTimeInString(time1: from2, time2: to2))*Double.pi/180))
                        
                    }
                }
            }
            //TimeList
            ZStack {
                Rectangle()
                    .frame(width: 310, height: 94)
                    .cornerRadius(8)
                    .foregroundColor(Color(red: 0.969, green: 0.969, blue: 0.969))
                HStack {
                    if !isSliding {
                        RecommendedCaption(from: isSliding ? from2 : from1, to: isSliding ? to2 : to1)
                            .padding(.leading)
                        Spacer().frame(width: 10)
                        Button(action: {isSliding.toggle()}, label: {
                            Image(systemName: "chevron.right")
                        })
                        .foregroundColor(.black)
                    } else {
                        Button(action: {isSliding.toggle()}, label: {
                            Image(systemName: "chevron.left")
                        })
                        .foregroundColor(.black)
                        Spacer().frame(width: 10)
                        RecommendedCaption(from: isSliding ? from2 : from1, to: isSliding ? to2 : to1)
                            .padding(.trailing)
                    }
                }
            }
        }
    }
}

struct Picker: View {
    
    var centerX: CGFloat
    var centerY: CGFloat
    
    var body: some View {
        ZStack {
            smallPicker(centerX: centerX, centerY: centerY, IsLower: true)
            smallPicker(centerX: centerX, centerY: centerY, IsLower: false)
            Circle()
                .frame(width: 175, height: 175)
                .foregroundColor(.white)
                .alignmentGuide(.leading, computeValue: { d in -70.0})
            largePicker(centerX: centerX, centerY: centerY)
        }
    }
}

struct largePicker: View {
    
    var centerX: CGFloat;
    var centerY: CGFloat;
    
    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: centerX, y: centerY))
                path.addArc(center: .init(x: centerX, y: centerY), radius: 98, startAngle: Angle(degrees: -1.3), endAngle: Angle(degrees: 1.3), clockwise: false)
            }.fill(Color(red: 0.798, green: 0.833, blue: 0.879))
            Path { path in
                path.move(to: CGPoint(x: centerX, y: centerY))
                path.addArc(center: .init(x: centerX, y: centerY), radius: 98, startAngle: Angle(degrees: 88.7), endAngle: Angle(degrees: 91.3), clockwise: false)
            }.fill(Color(red: 0.798, green: 0.833, blue: 0.879))
            Path { path in
                path.move(to: CGPoint(x: centerX, y: centerY))
                path.addArc(center: .init(x: centerX, y: centerY), radius: 98, startAngle: Angle(degrees: 178.7), endAngle: Angle(degrees: 181.3), clockwise: false)
            }.fill(Color(red: 0.798, green: 0.833, blue: 0.879))
            Path { path in
                path.move(to: CGPoint(x: centerX, y: centerY))
                path.addArc(center: .init(x: centerX, y: centerY), radius: 98, startAngle: Angle(degrees: 268.7), endAngle: Angle(degrees: 271.3), clockwise: false)
            }.fill(Color(red: 0.798, green: 0.833, blue: 0.879))
            Circle()
                .frame(width: 160, height: 160)
                .foregroundColor(.white)
                .alignmentGuide(.leading, computeValue: { d in -70.0})
            Text("24").foregroundColor(Color(red:0.786, green: 0.821, blue: 0.863)).bold()
                .offset(x: 0, y: -63)
            Text("06")
                .foregroundColor(Color(red:0.786, green: 0.821, blue: 0.863)).bold()
                .offset(x: 63, y: 0)
            Text("12").foregroundColor(Color(red:0.786, green: 0.821, blue: 0.863)).bold()
                .offset(x: 0, y: 63)
            Text("18").foregroundColor(Color(red:0.786, green: 0.821, blue: 0.863)).bold()
                .offset(x: -63, y: 0)
        }
    }
}

struct smallPicker: View {
    
    var centerX: CGFloat;
    var centerY: CGFloat;
    var IsLower: Bool
    
    var body: some View {
        ZStack {
            Path { path in
                path.move(to: CGPoint(x: centerX, y: centerY))
                path.addArc(center: .init(x: centerX, y: centerY), radius: 98, startAngle: Angle(degrees: IsLower ? 13.7 : 193.7), endAngle: Angle(degrees: IsLower ? 16.3 : 196.3), clockwise: false)
            }.fill(Color(red: 0.898, green: 0.918, blue: 0.935))
            Path { path in
                path.move(to: CGPoint(x: centerX, y: centerY))
                path.addArc(center: .init(x: centerX, y: centerY), radius: 98, startAngle: Angle(degrees: IsLower ? 28.7 : 208.7), endAngle: Angle(degrees: IsLower ? 31.3 : 211.3), clockwise: false)
            }.fill(Color(red: 0.898, green: 0.918, blue: 0.935))
            Path { path in
                path.move(to: CGPoint(x: centerX, y: centerY))
                path.addArc(center: .init(x: centerX, y: centerY), radius: 98, startAngle: Angle(degrees: IsLower ? 43.7 : 223.7), endAngle: Angle(degrees: IsLower ? 46.3 : 226.3), clockwise: false)
            }.fill(Color(red: 0.898, green: 0.918, blue: 0.935))
            Path { path in
                path.move(to: CGPoint(x: centerX, y: centerY))
                path.addArc(center: .init(x: centerX, y: centerY), radius: 98, startAngle: Angle(degrees: IsLower ? 58.7 : 237.7), endAngle: Angle(degrees: IsLower ? 61.3 : 241.3), clockwise: false)
            }.fill(Color(red: 0.898, green: 0.918, blue: 0.935))
            Path { path in
                path.move(to: CGPoint(x: centerX, y: centerY))
                path.addArc(center: .init(x: centerX, y: centerY), radius: 98, startAngle: Angle(degrees: IsLower ? 73.7 : 253.7), endAngle: Angle(degrees: IsLower ? 76.3 : 256.3), clockwise: false)
            }.fill(Color(red: 0.898, green: 0.918, blue: +150.935))
            Path { path in
                path.move(to: CGPoint(x: centerX, y: centerY))
                path.addArc(center: .init(x: centerX, y: centerY), radius: 98, startAngle: Angle(degrees: IsLower ? 88.7 : 268.7), endAngle: Angle(degrees: IsLower ? 91.3 : 271.3), clockwise: false)
            }.fill(Color(red: 0.898, green: 0.918, blue: 0.935))
            Path { path in
                path.move(to: CGPoint(x: centerX, y: centerY))
                path.addArc(center: .init(x: centerX, y: centerY), radius: 98, startAngle: Angle(degrees: IsLower ? 103.7 : 283.7), endAngle: Angle(degrees: IsLower ? 106.3 : 286.3), clockwise: false)
            }.fill(Color(red: 0.898, green: 0.918, blue: 0.935))
            Path { path in
                path.move(to: CGPoint(x: centerX, y: centerY))
                path.addArc(center: .init(x: centerX, y: centerY), radius: 98, startAngle: Angle(degrees: IsLower ? 118.7 : 298.7), endAngle: Angle(degrees: IsLower ? 121.3 : 301.3), clockwise: false)
            }.fill(Color(red: 0.898, green: 0.918, blue: 0.935))
            Path { path in
                path.move(to: CGPoint(x: centerX, y: centerY))
                path.addArc(center: .init(x: centerX, y: centerY), radius: 98, startAngle: Angle(degrees: IsLower ? 133.7 : 313.7), endAngle: Angle(degrees: IsLower ? 136.3 : 316.3), clockwise: false)
            }.fill(Color(red: 0.898, green: 0.918, blue: 0.935))
            ZStack {
                Path { path in
                    path.move(to: CGPoint(x: centerX, y: centerY))
                    path.addArc(center: .init(x: centerX, y: centerY), radius: 98, startAngle: Angle(degrees: IsLower ? 148.7 : 328.7), endAngle: Angle(degrees: IsLower ? 151.3 : 331.3), clockwise: false)
                }.fill(Color(red: 0.898, green: 0.918, blue: 0.935))
                Path { path in
                    path.move(to: CGPoint(x: centerX, y: centerY))
                    path.addArc(center: .init(x: centerX, y: centerY), radius: 98, startAngle: Angle(degrees: IsLower ? 163.7 : 343.7), endAngle: Angle(degrees: IsLower ? 166.3 : 346.3), clockwise: false)
                }.fill(Color(red: 0.898, green: 0.918, blue: 0.935))
            }
        }
    }
}

struct NoNapCaption: View {
    
    var body: some View {
        HStack(spacing: 15) {
            Image("moon3")
            Text("No Nap Needed")
                .font(.headline)
        }.padding([.leading, .trailing],10)
    }
}

struct RecommendedCaption: View {
    
    var from: String
    var to: String
    
    var body: some View {
        HStack(spacing: 100) {
            VStack(alignment: .center, spacing: 5) {
                Text(from).font(.title3).fontWeight(.bold)
                Text("7/1").font(.custom("tooSmall", size: 12))
                Text("취침").font(.custom("tooSmall", size: 12)).fontWeight(.bold)
            }
            VStack(alignment: .center, spacing: 5) {
                Text(addTimeInString(time1:from, time2:to)).font(.title3).fontWeight(.bold)
                Text("7/2").font(.custom("tooSmall", size: 12))
                Text("기상").font(.custom("tooSmall", size: 12)).fontWeight(.bold)
            }
        }
    }
}


struct GraphView: View {
    
    @Binding var AwarenessData: [LineData]
    @Binding var tabSelection : Int
    var body: some View {
        VStack(alignment: .leading) {
            VStack{
                Text("잠시 바람 쐬는건 어때요?")
                    .bold()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .font(.title2)
                Text("각성도가 낮아요")
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

