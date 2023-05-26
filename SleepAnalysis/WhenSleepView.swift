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

let maxLength: Int = 1
let todayYear = Calendar.current.dateComponents([.year], from: Date())
let todayMonth = Calendar.current.dateComponents([.month], from: Date())
let todayDay = Calendar.current.dateComponents([.day], from: Date())
let todayTimeZone = TimeZone(identifier: TimeZone.current.identifier)!
var dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "YYYY-MM-dd HH:mm"
    
    return dateFormatter
}()

struct WhenSleepView: View {
    
    @AppStorage("sleep_onset") var sleep_onset: Date = Date.now
    @AppStorage("UserId") var userId: String = "-"
    @AppStorage("needUpdate") var needUpdate:Bool = false
    
    @State var isValid: Bool = true
    @State var userName: String = "홍길동"
    @State var whenSleepHour_1: String = ""
    @State var whenSleepHour_2: String = ""
    @State var whenSleepMinute_1: String = ""
    @State var whenSleepMinute_2: String = ""
    
    @FocusState private var focusField: SleepField?
    
    enum SleepField: Hashable {
        case hour1
        case hour2
        case minute1
        case minute2
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("언제 주무시고 싶으신가요?")
                .font(.title)
                .bold()
                .alignmentGuide(.leading, computeValue: {d in -20.0})
            Text("\(userId)님이 희망하시는 취침시간을 알려주세요")
                .font(.custom("descript", size: 14))
                .padding(.vertical, 2)
                .alignmentGuide(.leading, computeValue: {d in -20.0})
            HStack(spacing: 10) {
                whenView(when: $whenSleepHour_1)
                    .focused($focusField, equals: .hour1)
                    .onChange(of: whenSleepHour_1) { _ in
                        if whenSleepHour_1.isEmpty {
                            focusField = .hour1
                        } else if whenSleepHour_2.isEmpty {
                            focusField = .hour2
                        } else {
                            focusField = nil
                        }
                    }
                whenView(when: $whenSleepHour_2)
                    .focused($focusField, equals: .hour2)
                    .onChange(of: whenSleepHour_2) { _ in
                        if whenSleepHour_2.isEmpty {
                            focusField = .hour2
                        } else if whenSleepMinute_1.isEmpty {
                            focusField = .minute1
                        } else {
                            focusField = nil
                        }
                    }
                Text(":")
                    .font(.largeTitle)
                whenView(when: $whenSleepMinute_1)
                    .focused($focusField, equals: .minute1)
                    .onChange(of: whenSleepMinute_1) { _ in
                        if whenSleepMinute_1.isEmpty {
                            focusField = .minute1
                        } else if whenSleepMinute_2.isEmpty {
                            focusField = .minute2
                        } else {
                            focusField = nil
                        }
                    }
                whenView(when: $whenSleepMinute_2)
                    .focused($focusField, equals: .minute2)
                    .onChange(of: whenSleepMinute_2) { _ in
                        if !whenSleepMinute_2.isEmpty {
                            focusField = nil
                        }
                    }
            }
            .alignmentGuide(.leading, computeValue: {d in -20.0})
            .padding(.top, 80.0)
            
            NavigationLink(destination: WhenStartView(sleep_onset: saveTime())) {
                Rectangle().foregroundColor(.blue).frame(width: 390, height: 56).cornerRadius(8)
                    .overlay(Text("다음").foregroundColor(.white))
            }.padding(.top, 100.0)
                .opacity(textIsAppropriate() && timeIsAppropriate() ? 1 : 0)
                .simultaneousGesture(TapGesture().onEnded({
                    self.sleep_onset = saveTime()
                }))
        }.onTapGesture {
            self.endTextEditing()
        }
        .onAppear{
            needUpdate = true
        }
    }
    
    func textIsAppropriate() -> Bool {
        let whenSleep: String = whenSleepHour_1+whenSleepHour_2+":"+whenSleepMinute_1+whenSleepMinute_2
            if whenSleep.count < 5 {
                return false
            }
            return true
        }
    
    func timeIsAppropriate() -> Bool {
        let sleepHour: Int = Int(whenSleepHour_1+whenSleepHour_2) ?? 0
        let sleepMinute: Int = Int(whenSleepMinute_1+whenSleepMinute_2) ?? 0
        if sleepHour <= 0 || sleepHour > 24 || sleepMinute > 59 {
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
        let sleepHour = Int(whenSleepHour_1+whenSleepHour_2)!
        let sleepMinute = Int(whenSleepMinute_1+whenSleepMinute_2)!
        if Int(currentHour)! >= sleepHour && Int(currentMinute)! >= sleepMinute {
            return true
        }
        return false
    }
    
    func saveTime() -> Date {
        if textIsAppropriate() && timeIsAppropriate() {
            let sleepHour = Int(whenSleepHour_1+whenSleepHour_2)
            let sleepMinute = Int(whenSleepMinute_1+whenSleepMinute_2)
            if isTimePassed() {
                let dateComponents = DateComponents(timeZone: todayTimeZone, year: todayYear.year, month: todayMonth.month, day: todayDay.day!+1, hour: sleepHour, minute: sleepMinute)
                sleep_onset = Calendar.current.date(from: dateComponents) ?? Date()
                return sleep_onset
            } else {
                let dateComponents = DateComponents(timeZone: todayTimeZone, year: todayYear.year, month: todayMonth.month, day: todayDay.day, hour: sleepHour, minute: sleepMinute)
                sleep_onset = Calendar.current.date(from: dateComponents) ?? Date()
                return sleep_onset
            }
        }
        return Date()
    }
}

//Keyboard input rectangle
struct whenView: View {
    
    @Binding var when: String
    
    var body: some View {
        Rectangle()
            .foregroundColor(Color(red: 0.948, green: 0.953, blue: 0.962))
            .frame(width: 73.5, height: 80)
            .cornerRadius(16)
            .overlay(TextField("", text: $when)
                .keyboardType(.numberPad)
                .onReceive(Just(when), perform: { _ in
                    if maxLength < when.count {
                        when = String(when.prefix(maxLength))
                    }
                })
                .autocorrectionDisabled(true)
                .font(.largeTitle)
                .bold()
                .padding(25))
    }
}

//hideKeyboard
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

//Make keyboard down by touching empty view
extension View {
    func endTextEditing() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

//struct WhenSleepView_Previews: PreviewProvider {
//    static var previews: some View {
//        WhenSleepView()
//    }
//}
