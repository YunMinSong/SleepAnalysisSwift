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
    let now = Date.now
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd. HH:mm"
        return formatter
    }()
    @AppStorage("lastLoad") var lastLoadTime: String = ""
    
    
    var body: some View {
            NavigationView{
                ZStack{
                    Rectangle()
                        .foregroundColor(Color(red: 0.948, green: 0.953, blue: 0.962))
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
                        }.padding()
                        
                        NavigationLink(destination: Text("Terms of Service")){
                            VStack(spacing: 5){
                                HStack{
                                    Text("약관 및 개인정보 처리방침 동의")
                                        .bold()
                                    Spacer()
                                }
                            }
                        }.padding()
                        NavigationLink(destination: RecSettingView()){
                            VStack(spacing: 5){
                                HStack{
                                    Text("추천 수면 세팅")
                                        .bold()
                                    Spacer()
                                }
                            }
                        }.padding()
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
                        }.padding()
                    }.listStyle(.inset)
                }.navigationTitle("설정")
            }.navigationBarBackButtonHidden()
    }
}

struct RecSettingView: View {
    @AppStorage("sleep_onset") var sleep_onset: Date = Date.now
    @AppStorage("work_onset") var work_onset: Date = Date.now
    @AppStorage("work_offset") var work_offset: Date = Date.now
    @AppStorage("alarm") var alarm: Date = Date.now
    @AppStorage("needUpdate") var needUpdate:Bool = false
    let now = Date.now
    let oneweekafter = Date.now.addingTimeInterval(60*60*24*7*1.0)
    
    var body: some View {
        ZStack{
            Rectangle()
                .foregroundColor(.white)
                .frame(height: 350)
                .cornerRadius(16.0)
            VStack{
                Text("추천 수면 세팅")
                    .font(.title)
                    .bold()
                
                Text("")
                HStack{
                    Text("Sleep Onset : ")
                        .bold()
                    Spacer()
                }
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
                }
                HStack{
                    Text("Work Period : ")
                        .bold()
                    Spacer()
                }
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
                }
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
                }
                HStack{
                    Text("Alarm Setting : ")
                        .bold()
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
