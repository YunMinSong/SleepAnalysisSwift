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

struct RecommendView: View {
    @AppStorage("whenSleep") private var sleepTime: String = ""
    @AppStorage("whenStart") private var startTime: String = ""
    @AppStorage("whenFinish") private var finishTime: String = ""
    @AppStorage("UserId") private var userId: String = "-"
    
    @State private var userName: String = "홍길동"
    //Put calculated one
    @State private var from1: String = "19:40"
    @State private var to1: String = "04:20"
    @State private var from2: String = "10:15"
    @State private var to2: String = "02:50"
    
    var body: some View {
        NavigationView {
            ZStack {
                Rectangle()
                    .foregroundColor(Color(red: 0.948, green: 0.953, blue: 0.962))
                if sleepTime == "" || startTime == "" || finishTime == "" {
                    BeforeTimeGet(userName: userId)
                } else {
                    AfterTimeGet(userName: userId, from1: $from1, to1: $to1, from2: $from2, to2: $to2, whenSleep: sleepTime, whenStart: startTime, whenFinish: finishTime)
                }
            }.navigationTitle("추천 수면")
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
    
    let whenSleep: String
    let whenStart: String
    let whenFinish: String
    
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
                        BoxWithTwoCaption(whenSleep: whenSleep, whenStart: whenStart, whenFinish: whenFinish)
                    }
                }.padding()
                //Lower one
                ZStack {
                    Rectangle()
                        .foregroundColor(.white)
                        .frame(height: 424)
                        .cornerRadius(16.0)
                    VStack(alignment: .leading) {
                        Text("\(userName)님을 위한 추천 수면")
                            .font(.title2)
                            .bold()
                            .padding(.top)
                        BoxWithRecommend(from1: $from1, to1: $to1, from2: $from2, to2: $to2)
                        Button(action: {}) {
                            Rectangle()
                                .foregroundColor(.blue)
                                .frame(width: 310, height: 48)
                                .cornerRadius(28)
                                .overlay(Text("알람 맞추기")
                                    .foregroundColor(.white))
                        }.padding(.bottom)
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
    
    let whenSleep: String
    let whenStart: String
    let whenFinish: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(Color(red: 0.948, green: 0.953, blue: 0.962))
                .frame(width: 310, height: 230)
                .cornerRadius(16)
                .padding(.vertical, 15)
            VStack(alignment: .center) {
                SmallCaptionWithSleep(whenSleep: whenSleep)
                SmallCaptionWithWork(whenStart: whenStart, whenFinish: whenFinish)
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
    
    let whenSleep: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .frame(width: 278, height: 95)
                .cornerRadius(8)
            HopeSleepContent(whenSleep: whenSleep)
        }
    }
}

struct SmallCaptionWithWork: View {
    
    let whenStart: String
    let whenFinish: String
    
    var body: some View {
        ZStack {
            Rectangle()
                .foregroundColor(.white)
                .frame(width: 278, height: 95)
                .cornerRadius(8)
            WorkContent(whenStart: whenStart, whenFinish: whenFinish)
        }
    }
}

struct HopeSleepContent: View {
    
    let whenSleep: String
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 30) {
            HStack(spacing: 150) {
                Text("희망 취침 시간")
                    .font(.headline)
                Image("Subtract")
            }
            HStack(alignment: .bottom) {
                Text(specificTime(original: whenSleep).former)
                    .font(.custom("Small", size: 15))
                Text(specificTime(original:whenSleep).backward)
                    .font(.headline)
            }
        }
    }
}

struct WorkContent: View {
    
    let whenStart: String
    let whenFinish: String
    
    var body: some View {
        VStack(alignment: .trailing, spacing: 30) {
            HStack(spacing: 180) {
                Text("근무 시간")
                    .font(.headline)
                Image("id-card")
            }
            HStack(spacing: 40) {
                HStack(alignment: .bottom) {
                    Text(specificTime(original: whenStart).former)
                        .font(.custom("Small", size: 15))
                    Text(specificTime(original: whenStart).backward)
                        .font(.headline)
                }
                HStack(alignment: .bottom) {
                    Text(specificTime(original: whenFinish).former)
                        .font(.custom("Small", size: 15))
                    Text(specificTime(original:whenFinish).backward)
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
    if intHour < 11 {
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

struct RecommendView_Previews: PreviewProvider {
    static var previews: some View {
        RecommendView()
    }
}
