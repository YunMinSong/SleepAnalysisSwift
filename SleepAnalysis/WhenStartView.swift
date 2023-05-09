//
//  WhenSleepView.swift
//  SleepAnalysis
//
//  Created by 장형준 on 2023/03/14.
//

/*
 Need to do more
 1. Load user name
 */

import SwiftUI
import Combine

struct WhenStartView: View {
    @Binding var AwarenessData: [LineData]
    @Binding var SleepData: [LineData]
    @Binding var SleepSuggestionData: [LineData]
    
    let sleep_onset: Date
    
    @AppStorage("work_onset") var work_onset: Date = Date.now
    @AppStorage("UserId") private var userId: String = "-"
    
    @State var isValid: Bool = true
    @State var userName: String = "홍길동"
    @State var whenStartHour_1: String = ""
    @State var whenStartHour_2: String = ""
    @State var whenStartMinute_1: String = ""
    @State var whenStartMinute_2: String = ""
    @State var whenStart: String = ""
    
    @FocusState private var focusField: StartField?
    
    enum StartField: Hashable {
        case hour1
        case hour2
        case minute1
        case minute2
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("언제 일을 시작하시나요?")
                .font(.title)
                .bold()
                .alignmentGuide(.leading, computeValue: {d in -20.0})
            Text("\(userId)님의 근무 시작 시간을 알려주세요")
                .font(.custom("descript", size: 14))
                .padding(.vertical, 2)
                .alignmentGuide(.leading, computeValue: {d in -20.0})
            Text("출근 시간과 수면 시간이 같으면 안됩니다!")
                .foregroundColor(.red)
                .bold()
                .font(.custom("descript", size: 14))
                .padding(.top, 2)
                .alignmentGuide(.leading, computeValue: {d in -20.0})
                .opacity(isSame() ? 0 : 1)
            HStack(spacing: 10) {
                whenView(when: $whenStartHour_1)
                    .focused($focusField, equals: .hour1)
                    .onChange(of: whenStartHour_1) { _ in
                        if whenStartHour_1.isEmpty {
                            focusField = .hour1
                        } else if whenStartHour_2.isEmpty {
                            focusField = .hour2
                        } else {
                            focusField = nil
                        }
                    }
                whenView(when: $whenStartHour_2)
                    .focused($focusField, equals: .hour2)
                    .onChange(of: whenStartHour_2) { _ in
                        if whenStartHour_2.isEmpty {
                            focusField = .hour2
                        } else if whenStartMinute_1.isEmpty {
                            focusField = .minute1
                        } else {
                            focusField = nil
                        }
                    }
                Text(":")
                    .font(.largeTitle)
                whenView(when: $whenStartMinute_1)
                    .focused($focusField, equals: .minute1)
                    .onChange(of: whenStartMinute_1) { _ in
                        if whenStartMinute_1.isEmpty {
                            focusField = .minute1
                        } else if whenStartMinute_2.isEmpty {
                            focusField = .minute2
                        } else {
                            focusField = nil
                        }
                    }
                whenView(when: $whenStartMinute_2)
                    .focused($focusField, equals: .minute2)
                    .onChange(of: whenStartMinute_2) { _ in
                        if !whenStartMinute_2.isEmpty {
                            focusField = nil
                        }
                    }
            }
            .alignmentGuide(.leading, computeValue: {d in -20.0})
            .padding(.top, 80.0)
            
            NavigationLink(destination: WhenFinishView(AwarenessData: $AwarenessData, SleepData: $SleepData, SleepSuggestionData: $SleepSuggestionData, sleep_onset: sleep_onset, work_onset: saveTime())) {
                Rectangle().foregroundColor(.blue).frame(width: 390, height: 56).cornerRadius(8)
                    .overlay(Text("다음").foregroundColor(.white))
            }.padding(.top, 100.0)
                .opacity(textIsAppropriate()&&timeIsAppropriate() ? 1 : 0)
                .simultaneousGesture(TapGesture().onEnded({
                    self.work_onset = saveTime()
                }))
        }.onTapGesture {
            self.endTextEditing()
        }
    }
    
    func textIsAppropriate() -> Bool {
        let whenStart: String = whenStartHour_1+whenStartHour_2+":"+whenStartMinute_1+whenStartMinute_2
            if whenStart.count < 5 {
                return false
            }
            return true
        }
    
    func isSame() -> Bool {
        let startHour = Int(whenStartHour_1+whenStartHour_2)
        let startMinute = Int(whenStartMinute_1+whenStartMinute_2)
        let dateComponents = DateComponents(timeZone: todayTimeZone, year: todayYear.year, month: todayMonth.month, day: todayDay.day, hour: startHour, minute: startMinute)
        let startDate = Calendar.current.date(from: dateComponents)
        if startDate == sleep_onset {
            return false
        }
        return true
    }
    
    func timeIsAppropriate() -> Bool {
        let startHour: Int = Int(whenStartHour_1+whenStartHour_2) ?? 0
        let startMinute: Int = Int(whenStartMinute_1+whenStartMinute_2) ?? 0
        if startHour <= 0 || startHour > 24 || startMinute > 59 || !isSame() {
            return false
        }
        return true
    }
    
    func isTimePassed() -> Bool {
        let currentTime = dateFormatter.string(from: Date())
        let currentHour1 = currentTime[currentTime.index(after: currentTime.firstIndex(of: " ")!)]
        let currentHour2 = currentTime[currentTime.index(currentTime.index(after: currentTime.firstIndex(of: " ")!), offsetBy: 1)]
        let currentMinute1 = currentTime[currentTime.index(after: currentTime.firstIndex(of: ":")!)]
        let currentMinute2 = currentTime[currentTime.index(currentTime.index(after: currentTime.firstIndex(of: ":")!), offsetBy: 1)]
        let currentHour = String(currentHour1) + String(currentHour2)
        let currentMinute = String(currentMinute1) + String(currentMinute2)
        let startHour = Int(whenStartHour_1+whenStartHour_2)!
        let startMinute = Int(whenStartMinute_1+whenStartMinute_2)!
        if Int(currentHour)! >= startHour && Int(currentMinute)! >= startMinute {
            return true
        }
        return false
    }
    
    func saveTime() -> Date {
        if textIsAppropriate() && timeIsAppropriate() {
            let startHour = Int(whenStartHour_1+whenStartHour_2)
            let startMinute = Int(whenStartMinute_1+whenStartMinute_2)
            if isTimePassed() {
                let dateComponents = DateComponents(timeZone: todayTimeZone, year: todayYear.year, month: todayMonth.month, day: todayDay.day!+1, hour: startHour, minute: startMinute)
                let work_onset = Calendar.current.date(from: dateComponents) ?? Date()
                return work_onset
            } else {
                let dateComponents = DateComponents(timeZone: todayTimeZone, year: todayYear.year, month: todayMonth.month, day: todayDay.day, hour: startHour, minute: startMinute)
                let work_onset = Calendar.current.date(from: dateComponents) ?? Date()
                return work_onset
            }
        }
        return Date()
    }
}

//struct WhenStartView_Previews: PreviewProvider {
//    static var previews: some View {
//        WhenStartView(sleep_onset: Date())
//    }
//}
