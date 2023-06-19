//
//  RecommendView.swift
//  SleepAnalysis
//
//  Created by 장형준 on 2023/03/14.
//
/*
 To do
1. Add calculated recommend time
 */

import SwiftUI
import EventKit

struct RecommendView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @StateObject var data = AwarenessModel()
    @AppStorage("sleep_onset") var sleep_onset: Date = Date.now
    @AppStorage("work_onset") var work_onset: Date = Date.now
    @AppStorage("work_offset") var work_offset: Date = Date.now
    @AppStorage("Registered") var isRegistered: Bool = false
    @AppStorage("UserId") private var userId: String = "-"
    
    @State private var userName: String = "홍길동"
    @State var isLoading = false
    
    @AppStorage("lastUpdated") var lastUpdated:Date = Date.now.addingTimeInterval(-60.0*60.0*3)
    @AppStorage("lastSleep") var lastSleep:Date = Date.now.addingTimeInterval(-1*60.0*60.0*24.0*14.0)
    @AppStorage("needUpdate") var needUpdate:Bool = false
    
    @FetchRequest(sortDescriptors: []) var entries: FetchedResults<Entry>
    @FetchRequest(sortDescriptors: []) var V0_cores: FetchedResults<V0_main>
    
    @AppStorage("mainSleepStart") var mainSleepStart: Date = Date.now
    @AppStorage("mainSleepEnd") var mainSleepEnd: Date = Date.now
    @AppStorage("napSleepStart") var napSleepStart: Date = Date.now
    @AppStorage("napSleepEnd") var napSleepEnd: Date = Date.now
    
    @State private var from1: String = "19:40"
    @State private var to1: String = "04:20"
    @State private var from2: String = "10:15"
    @State private var to2: String = "02:50"
        
    var body: some View {
        
        NavigationView {
            if isLoading{
                LoadingView()
            }else{
                ZStack {
                    Rectangle()
                        .foregroundColor(Color(red: 0.948, green: 0.953, blue: 0.962))
                    if sleep_onset == Date.now || work_onset == Date.now || work_offset == Date.now || !isRegistered {
                        BeforeTimeGet(userName: userId)
                    } else {
                        AfterTimeGet(userName: userId, from1: $from1, to1: $to1, from2: $from2, to2: $to2, sleep_onset: sleep_onset, work_onset: work_onset, work_offset: work_offset)
                    }
                }.navigationTitle("추천 수면")
                .onAppear{
                    print(needUpdate)
                    if needUpdate || Date.now.timeIntervalSince(lastUpdated) > 60.0*60.0*2{
                        if sleep_onset < Date.now{
                            sleep_onset = sleep_onset.addingTimeInterval(60*60*24.0)
                        }
                        while work_onset < sleep_onset{
                            work_onset = work_onset.addingTimeInterval(60*60*24.0)
                        }
                        while work_offset < work_onset{
                            work_offset = work_offset.addingTimeInterval(60*60*24.0)
                        }
                        isLoading = true
                        readSleep(from: lastSleep, to: Date.now)
                        lastSleep = Date.now
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                            needUpdate = false
                            lastUpdated = Date.now
                            //PCR prediction initial data
                            let startDate = Date.now.addingTimeInterval(-1.0*60*60*24*1)
                            var V0 =  [-0.8590, -0.6837, 0.1140, 14.2133] //initial condition
                            
                            //find V0
                            for v in V0_cores{
                                if v.time! >= startDate{
                                    V0 = [v.y, v.x, v.n, v.h]
                                    break
                                }
                                managedObjectContext.delete(v)
                            }
                            let (y_data, suggestion_pattern, sleep_pattern) = processSleepData(V0: V0, entries: entries)
                            let yesterday = Date.now.addingTimeInterval(60.0*60.0*24.0)
                            for x in 0...575{
                                let V0_core = V0_main(context: managedObjectContext)
                                V0_core.time = yesterday.addingTimeInterval(Double(x)*5.0*60.0)
                                V0_core.y = y_data[x][0]
                                V0_core.x = y_data[x][1]
                                V0_core.n = y_data[x][2]
                                V0_core.h = y_data[x][3]
                                do {
                                    try managedObjectContext.save()
                                } catch {
                                    // handle the Core Data error
                                }
                            }
                            for x in 0...575{
                                data.SleepSuggestionData[x] = LineData(Category: suggestion_pattern[x].1, x: formatDate(offset: Double(x)*5.0*60.0), y: Double(suggestion_pattern[x].0))
                            }
                            for x in 0...575{
                                let C = 3.37*0.5*(1+coef_y*y_data[x][1] + coef_x * y_data[x][0])
                                let D_up = (2.46+10.2+C) //sleep thres
                                let awareness = D_up - y_data[x][3]
                                data.AwarenessData[x] = LineData(Category:"Alertness",x:formatDate(offset: Double(x)*5.0*60.0-1.0*60*60*24*1), y:Double(awareness))
                                data.SleepData[x] = LineData(Category:"Sleep",x:formatDate(offset: Double(x)*5.0*60.0-1.0*60*60*24*1), y:Double(sleep_pattern[x]))
                            }
                            isLoading=false
                            from1 = date_to_string(date: self.mainSleepStart)
                            to1 = time_to_string(seconds: Int(self.mainSleepEnd.timeIntervalSince(self.mainSleepStart)))
                            from2 = date_to_string(date: self.napSleepStart)
                            to2 = time_to_string(seconds: Int(self.napSleepEnd.timeIntervalSince(self.napSleepStart)))
                        }
                    }
                }
            }
        }.navigationBarBackButtonHidden()
    }
}

struct BeforeTimeGet: View {
    //@Binding var userName: String
    let userName: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .cornerRadius(16.0)
                .frame(height: 400)
            VStack(alignment: .leading) {
                Text("수면 추천 받기")
                    .font(.title)
                    .bold()
                    .padding(.top)
                Text("\(userName)님에게 딱 맞는 수면 패턴을 추천해 드릴게요")
                    .font(.custom("Small", size: 15))
                    .padding(.top, 5.0)
                GifImage("notFound")
                    .frame(width: 200, height: 200)
                    .padding(.horizontal, 50)
                /*Image("sskoo")
                    .padding(.vertical, 50.0)
                    .alignmentGuide(.leading, computeValue: { d in -100.0})
                 */
                NavigationLink(destination: WhenSleepView()) {
                    Rectangle()
                        .foregroundColor(.blue)
                        .cornerRadius(28)
                        .frame(width: 310, height: 48)
                        .overlay(Text("시작하기")
                            .foregroundColor(.white))
                }            }
        }.padding(.horizontal)
            .padding(.bottom, 150.0)
    }
}

struct AfterTimeGet: View {
    
    //@Binding var userName: String
    let userName: String
    @Binding var from1: String
    @Binding var to1: String
    @Binding var from2: String
    @Binding var to2: String
    
    let sleep_onset: Date
    let work_onset: Date
    let work_offset: Date
    
    var body: some View {
        ScrollView() {
            VStack(spacing: 5) {
                //Upper one
                ZStack {
                    Rectangle()
                        .foregroundColor(.white)
                        .frame(height: 339)
                        .cornerRadius(16.0)
                    VStack(alignment: .leading) {
                        Text("\(userName)님을 위한 정보")
                            .font(.title2)
                            .bold()
                            .padding(.top)
                        Text("말씀하신 내용을 바탕으로 추천해드려요")
                            .font(.custom("Small", size: 15))
                        BoxWithTwoCaption(sleep_onset: sleep_onset, work_onset: work_onset, work_offset: work_offset)
                    }
                }.padding()
                //Lower one
                ZStack {
                    Rectangle()
                        .foregroundColor(.white)
                        .frame(height: 600)
                        .cornerRadius(16.0)
                    VStack(alignment: .leading) {
                        Text("\(userName)님을 위한 추천 수면")
                            .font(.title2)
                            .bold()
                            .padding(.top)
                            .alignmentGuide(.leading, computeValue: { d in -25.0})
                        //Clock
                        ZStack {
                            Circle()
                                .frame(width: 150, height: 150)
                                .foregroundColor(Color(red: 0.949, green: 0.949, blue: 0.949))
                                .alignmentGuide(.leading, computeValue: { d in -70.0})
                            Path { path in
                                path.move(to: CGPoint(x: 180, y: 78))
                                path.addArc(center: .init(x: 180, y: 78), radius: 75, startAngle: Angle(degrees: timeToAngle(time: from2)), endAngle: Angle(degrees: timeToAngle(time: addTimeInString(time1: from2, time2: to2))), clockwise: false)
                            }.fill(Color.yellow)
                            Path { path in
                                path.move(to: CGPoint(x: 180, y: 78))
                                path.addArc(center: .init(x: 180, y: 78), radius: 75, startAngle: Angle(degrees: timeToAngle(time: from1)), endAngle: Angle(degrees: timeToAngle(time: addTimeInString(time1: from1, time2: to1))), clockwise: false)
                            }.fill(Color.blue)
                        }
                        //
                        BoxWithRecommend(from1: $from1, to1: $to1, from2: $from2, to2: $to2)
                            .alignmentGuide(.leading, computeValue: { d in -25.0})
                        Button(action: {
                        }) {
                            Rectangle()
                                .foregroundColor(.blue)
                                .frame(width: 310, height: 48)
                                .cornerRadius(28)
                                .overlay(Text("알람 맞추기")
                                    .foregroundColor(.white))
                        }.padding(.bottom)
                            .alignmentGuide(.leading, computeValue: { d in -25.0})
                    }
                }.padding()
                Rectangle()
                    .foregroundColor(Color(red: 0.948, green: 0.953, blue: 0.962))
                    .frame(height: 60)
            }
        }
    }
}

struct BoxWithTwoCaption: View {
    
    let sleep_onset: Date
    let work_onset: Date
    let work_offset: Date
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color(red: 0.948, green: 0.953, blue: 0.962))
                .frame(width: 310, height: 230)
                .cornerRadius(16)
                .padding(.vertical, 15)
            VStack(alignment: .center) {
                SmallCaptionWithSleep(sleep_onset: sleep_onset)
                SmallCaptionWithWork(work_onset: work_onset, work_offset: work_offset)
            }
        }
    }
}

struct BoxWithRecommend: View {
    
    @Binding var from1: String
    @Binding var to1: String
    @Binding var from2: String
    @Binding var to2: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color(red: 0.948, green: 0.953, blue: 0.962))
                .frame(width: 310, height: 272)
                .cornerRadius(16)
                .padding(.vertical, 15)
            VStack(alignment: .center, spacing: 15) {
                SmallCaptionWithRecommend(from: $from1, to: $to1)
                SmallCaptionWithRecommend(from: $from2, to: $to2)
            }
        }
    }
}

struct SmallCaptionWithRecommend: View {
    
    @Binding var from: String
    @Binding var to: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .frame(width: 278, height: 112)
                .cornerRadius(16)
            RecommendContent(from: $from, to: $to)
        }
    }
}

struct RecommendContent: View {
    
    @Binding var from: String
    @Binding var to: String
    
    var body: some View {
        VStack(alignment: .center, spacing: 30) {
            HStack(spacing: 15) {
                Image("moon")
                HStack(alignment: .bottom, spacing: 3) {
                    Text(specificTime(original:from).0)
                        .font(.custom("Small", size: 15))
                    Text(specificTime(original:from).1)
                        .font(.headline)
                    Text("부터")
                        .font(.custom("Small", size: 15))
                }
            }.padding(.trailing, 100.0)
            HStack(spacing: 15) {
                Image("clock")
                HStack(alignment: .bottom, spacing: 3) {
                    Text(timeInterval(original:to))
                        .font(.headline)
                    Text("이상")
                        .font(.custom("Small", size: 15))
                }
            }.padding(.leading, 100.0)
        }
    }
}

struct SmallCaptionWithSleep: View {
    
    let sleep_onset: Date
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .frame(width: 278, height: 95)
                .cornerRadius(8)
            HopeSleepContent(sleep_onset: sleep_onset)
        }
    }
}

struct SmallCaptionWithWork: View {
    
    let work_onset: Date
    let work_offset: Date
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .frame(width: 278, height: 95)
                .cornerRadius(8)
            WorkContent(work_onset: work_onset, work_offset: work_offset)
        }
    }
}

struct HopeSleepContent: View {
    
    let sleep_onset: Date
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 30) {
            HStack(spacing: 150) {
                Text("희망 취침 시간")
                    .font(.headline)
                Image("Subtract")
            }
            HStack(alignment: .bottom) {
                Text(specificTime(original: induceHourMinute(original: sleep_onset)).former)
                    .font(.custom("Small", size: 15))
                Text(specificTime(original: induceHourMinute(original: sleep_onset)).backward)
                    .font(.headline)
            }
        }
    }
}

struct WorkContent: View {
    
    let work_onset: Date
    let work_offset: Date
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 30) {
            HStack(spacing: 180) {
                Text("근무 시간")
                    .font(.headline)
                Image("id-card")
            }
            HStack(spacing: 40) {
                HStack(alignment: .bottom) {
                    Text(specificTime(original: induceHourMinute(original: work_onset)).former)
                        .font(.custom("Small", size: 15))
                    Text(specificTime(original: induceHourMinute(original: work_onset)).backward)
                        .font(.headline)
                }
                HStack(alignment: .bottom) {
                    Text(specificTime(original: induceHourMinute(original: work_offset)).former)
                        .font(.custom("Small", size: 15))
                    Text(specificTime(original: induceHourMinute(original: work_offset)).backward)
                        .font(.headline)
                }
            }
        }
    }
}

extension String {
    subscript(_ index: Int) -> Character {
        return self[self.index(self.startIndex, offsetBy: index)]
    }
}

func specificTime(original: String) -> (former: String, backward: String) {
    var intHour = Int(String(original[0]) + String(original[1])) ?? 0
    let minute = String(original[3]) + String(original[4])
    var former: String
    var backward: String
    if intHour <= 11 {
        former = "오전"
    } else {
        former = "오후"
        if intHour != 12 {
            intHour -= 12
        }
    }
    backward = "\(intHour)" + "시 " + minute + "분"
    return (former, backward)
}

func timeInterval(original: String) -> String {
    let intHour = Int(String(original[0]) + String(original[1])) ?? 0
    let minute = String(original[3]) + String(original[4])

    let result = "\(intHour)" + "시간 " + minute + "분"
    return result
}

func induceHourMinute(original: Date?) -> String {
    let time = dateFormatter.string(from: original!)
    let hour1 = time[time.index(after: time.firstIndex(of: " ")!)]
    let hour2 = time[time.index(time.index(after: time.firstIndex(of: " ")!), offsetBy: 1)]
    let minute1 = time[time.index(after: time.firstIndex(of: ":")!)]
    let minute2 = time[time.index(time.index(after: time.firstIndex(of: ":")!), offsetBy: 1)]
    return String(hour1) + String(hour2) + ":" + String(minute1) + String(minute2)
}

func getHourMinute(time: String) -> (Double, Double) {
    if !time.contains(":") || time.count != 5 {
        return (0.0, 0.0)
    } else {
        let hour1 = time[time.startIndex]
        let hour2 = time[time.index(after: time.startIndex)]
        let minute1 = time[time.index(time.startIndex, offsetBy: 3)]
        let minute2 = time[time.index(time.startIndex, offsetBy: 4)]
        let hour = Double(String(hour1) + String(hour2))
        let minute = Double(String(minute1)+String(minute2))
        return (hour ?? 0.0, minute ?? 0.0)
    }
}

func timeToAngle(time: String) -> Double {
    let Dtime = getHourMinute(time: time)
    if Dtime.0 > 24.0 || Dtime.1 > 60.0 {
        return -90.0
    } else {
        return 15*Dtime.0 + 0.25*Dtime.1 - 90.0
    }
}

func addTimeInString(time1: String, time2: String) -> String {
    let hour1 = getHourMinute(time: time1).0
    let minute1 = getHourMinute(time: time1).1
    let hour2 = getHourMinute(time: time2).0
    let minute2 = getHourMinute(time: time2).1
    var hour = Int(hour1 + hour2)
    var minute = Int(minute1 + minute2)
    let hourR: String
    let minuteR: String
    if hour >= 24 {
        hour-=24
    }
    if minute >= 60 {
        hour+=1
        minute-=60
    }
    if hour < 10 {
        hourR = "0"+String(hour)
    } else {
        hourR = String(hour)
    }
    if minute < 10 {
        minuteR = "0"+String(minute)
    } else {
        minuteR = String(minute)
    }
    return hourR+":"+minuteR
}

/*struct RecommendView_Previews: PreviewProvider {
    static var previews: some View {
        RecommendView()
    }
}*/
