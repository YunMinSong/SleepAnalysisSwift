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

struct WhenSleepView: View {
    
    @AppStorage("whenSleep") private var sleepTime: String = ""
    
    @State var isValid: Bool = true
    @State var userName: String = "홍길동"
    @State var whenSleepHour_1: String = ""
    @State var whenSleepHour_2: String = ""
    @State var whenSleepMinute_1: String = ""
    @State var whenSleepMinute_2: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("언제 주무시고 싶으신가요?")
                .font(.title)
                .bold()
                .alignmentGuide(.leading, computeValue: {d in -20.0})
            Text("\(userName)님이 희망하시는 취침시간을 알려주세요")
                .font(.custom("descript", size: 14))
                .padding(.vertical, 2)
                .alignmentGuide(.leading, computeValue: {d in -20.0})
            HStack(spacing: 10) {
                whenView(when: $whenSleepHour_1)
                whenView(when: $whenSleepHour_2)
                Text(":")
                    .font(.largeTitle)
                whenView(when: $whenSleepMinute_1)
                whenView(when: $whenSleepMinute_2)
            }
            .alignmentGuide(.leading, computeValue: {d in -20.0})
            .padding(.top, 80.0)
            
            NavigationLink(destination: WhenStartView(whenSleep: saveTime())) {
                Rectangle().foregroundColor(.blue).frame(width: 390, height: 56).cornerRadius(8)
                    .overlay(Text("다음").foregroundColor(.white))
            }.padding(.top, 100.0)
                .opacity(textIsAppropriate() && timeIsAppropriate() ? 1 : 0)
                .simultaneousGesture(TapGesture().onEnded({
                    self.sleepTime = saveTime()
                }))
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
    
    func saveTime() -> String {
        if textIsAppropriate() && timeIsAppropriate() {
            let whenSleep: String = whenSleepHour_1+whenSleepHour_2+":"+whenSleepMinute_1+whenSleepMinute_2
            return whenSleep
        }
        return ""
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

struct WhenSleepView_Previews: PreviewProvider {
    static var previews: some View {
        WhenSleepView()
    }
}
