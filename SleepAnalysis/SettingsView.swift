//
//  SettingsView.swift
//  SleepAnalysis
//
//  Created by Reinatt Wijaya on 2022/11/06.
//

import SwiftUI

struct SettingsView: View {
    
    let now = Date.now
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd. HH:mm"
        return formatter
    }()
    @AppStorage("lastLoad") var lastLoadTime: String = ""
    
    
    var body: some View {
            NavigationView{
                VStack() {
                    SettingHeaderView()
                        .padding()
                        .background(.white)
                    List{
                        NavigationLink(destination:
                                        Button(action: {
                            //Need to Give action for loading sleep data
                            lastLoadTime = formatter.string(from: now)
                        }) {
                            Rectangle()
                                .foregroundColor(.blue)
                                .frame(width: 310, height: 48)
                                .cornerRadius(28)
                                .overlay(
                                    Text("수면 데이터 불러오기").foregroundColor(.white))
                        }){
                            VStack(spacing: 5){
                                HStack{
                                    Text("내 수면 데이터 불러오기")
                                        .bold()
                                    Spacer()
                                }
                                HStack{
                                    Text("마지막 데이터 업데이트 " + lastLoadTime)
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
                                    Spacer()
                                }
                            }
                        }.padding(.vertical)
                        
                        NavigationLink(destination: Text("Terms of Service")){
                            VStack(spacing: 5){
                                HStack{
                                    Text("약관 및 개인정보 처리방침 동의")
                                        .bold()
                                    Spacer()
                                }
                            }
                        }.padding(.vertical)
                        NavigationLink(destination: RecSettingView()){
                            VStack(spacing: 5){
                                HStack{
                                    Text("추천 수면 설정")
                                        .bold()
                                    Spacer()
                                }
                            }
                        }.padding(.vertical)
                        NavigationLink(destination: VStack(alignment: .leading) {
                            Text("앱 상세 버전").font(.headline)
                                .padding(.bottom)
                            Text("버전: " + loadVersion()[0])
                            Text("빌드 버전: " + loadVersion()[1])
                        }){
                            VStack(spacing: 5){
                                HStack{
                                    Text("앱 버전")
                                        .bold()
                                    Spacer()
                                }
                                HStack{
                                    Text("최신 버전")
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(red: 0.7, green: 0.7, blue: 0.7))
                                    Spacer()
                                }
                            }
                        }.padding(.vertical)
                    }.listStyle(.inset)
                }
            }.navigationBarBackButtonHidden()
    }
}

struct AddSleepView: View{
    @State var startDate = Date.now
    @State var endDate = Date.now
    @State var addDone = false
    @State var overlapError = false
    
    @AppStorage("needUpdate") var needUpdate: Bool = false
    @FetchRequest(sortDescriptors: [NSSortDescriptor(key: "sleepStart", ascending: true)]) var entries: FetchedResults<Entry>
    
    let twoweeksbefore = Date.now.addingTimeInterval(-1.0*60*60*24*14)
//    let oneweekafter = Date.now.addingTimeInterval(60*60*24*7*1.0)
    
    var body: some View{
        ZStack{
            Rectangle()
                .foregroundColor(.white)
                .frame(height: 350)
                .cornerRadius(16.0)
            VStack{
                Text("수면 기록 추가")
                    .font(.title)
                    .bold()
                
                Text("")
                HStack{
                    Text("수면 시간 : ")
                        .bold()
                    Spacer()
                }
                HStack{
                    Spacer(minLength: 70)
                    Text("시작")
                    Spacer()
                    DatePicker(
                        "",
                        selection: $startDate,
                        in: twoweeksbefore...Date.now,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    Spacer()
                }
                HStack{
                    Spacer(minLength: 70)
                    Text("종료")
                    Spacer()
                    DatePicker(
                        "",
                        selection: $endDate,
                        in: startDate...Date.now,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    Spacer()
                }
                Text("")
                Text("")
                Button(action: {
                    var isSafe = true
                    for entry in entries{
                        let sleepStart = entry.sleepStart!
                        let sleepEnd = entry.sleepEnd!
                        if startDate >= sleepStart && startDate <= sleepEnd{
                            isSafe = false
                            break
                        }
                        if endDate >= sleepStart && endDate <= sleepEnd{
                            isSafe = false
                            break
                        }
                    }
                    if isSafe{
                        writeSleep(.asleepCore, startDate: startDate, endDate: endDate)
                        addDone = true
                        needUpdate = true
                    }else{
                        overlapError = true
                    }
                    
                }, label: {Rectangle()
                        .foregroundColor(.blue)
                        .frame(width: 310, height: 48)
                        .cornerRadius(28)
                        .overlay(
                            Text("수면 기록 추가하기").foregroundColor(.white))})
                .padding(.vertical, 10.0)
                .alert("Sleep time has been added", isPresented: $addDone) {
                    Button("OK", role: .cancel) { }
                }
                .alert("Sleep time is overlapping", isPresented: $overlapError) {
                    Button("OK", role: .cancel) { }
                }
            }.padding()
        }.padding()
    }
}

struct RecSettingView: View {
    @AppStorage("sleep_onset") var sleep_onset: Date = Date.now
    @AppStorage("work_onset") var work_onset: Date = Date.now
    @AppStorage("work_offset") var work_offset: Date = Date.now
    @AppStorage("alarm") var alarm: Date = Date.now
    @AppStorage("needUpdate") var needUpdate:Bool = false
    let now = Date.now
    let dayAfterTomorrow = Date.now.addingTimeInterval(60*60*24*2*1.0)
    
    var body: some View {
        ZStack{
            Rectangle()
                .foregroundColor(.white)
                .frame(height: 350)
                .cornerRadius(16.0)
            VStack{
                Text("추천 수면 설정")
                    .font(.title)
                    .bold()
                
                Text("")
                HStack{
                    Text("수면 시작 : ")
                        .bold()
                    Spacer()
                }
                HStack{
                    DatePicker(
                        "",
                        selection: $sleep_onset,
                        in: now...dayAfterTomorrow,
                        displayedComponents: [.date, .hourAndMinute]
                    ).onChange(of: sleep_onset, perform: { _ in
                        needUpdate = true
                    })
                    Spacer()
                }
                HStack{
                    Text("근무 시간 : ")
                        .bold()
                    Spacer()
                }
                HStack{
                    Spacer(minLength: 70)
                    Text("시작")
                    Spacer()
                    DatePicker(
                        "",
                        selection: $work_onset,
                        in: now...dayAfterTomorrow,
                        displayedComponents: [.date, .hourAndMinute]
                    ).onChange(of: work_onset, perform: { _ in
                        needUpdate = true
                    })
                    Spacer()
                }
                HStack{
                    Spacer(minLength: 70)
                    Text("종료")
                    Spacer()
                    DatePicker(
                        "",
                        selection: $work_offset,
//                        in: now...oneweekafter,
                        displayedComponents: [.date, .hourAndMinute]
                    ).onChange(of: work_offset, perform: { _ in
                        needUpdate = true
                    })
                    Spacer()
                }
            }.padding()
        }.padding()
    }
}

//Load version and build version
func loadVersion() -> [String] {
    guard let dictionary = Bundle.main.infoDictionary,
          let version = dictionary["CFBundleShortVersionString"] as? String,
          let build = dictionary["CFBundleVersion"] as? String else {return ["", ""]}
    return [version, build]
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
