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
    
    let whenSleep: String
    
    @AppStorage("whenStart") private var startTime: String = ""
    @AppStorage("UserId") private var userId: String = "-"
    
    @State var isValid: Bool = true
    @State var userName: String = "홍길동"
    @State var whenStartHour_1: String = ""
    @State var whenStartHour_2: String = ""
    @State var whenStartMinute_1: String = ""
    @State var whenStartMinute_2: String = ""
    @State var whenStart: String = ""
    
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
                whenView(when: $whenStartHour_2)
                Text(":")
                    .font(.largeTitle)
                whenView(when: $whenStartMinute_1)
                whenView(when: $whenStartMinute_2)
            }
            .alignmentGuide(.leading, computeValue: {d in -20.0})
            .padding(.top, 80.0)
            
            NavigationLink(destination: WhenFinishView(whenSleep: whenSleep, whenStart: saveTime())) {
                Rectangle().foregroundColor(.blue).frame(width: 390, height: 56).cornerRadius(8)
                    .overlay(Text("다음").foregroundColor(.white))
            }.padding(.top, 100.0)
                .opacity(textIsAppropriate()&&timeIsAppropriate() ? 1 : 0)
                .simultaneousGesture(TapGesture().onEnded({
                    self.startTime = saveTime()
                }))
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
        let whenStart: String = whenStartHour_1+whenStartHour_2+":"+whenStartMinute_1+whenStartMinute_2
        if whenStart == whenSleep {
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
    
    func saveTime() -> String {
        if textIsAppropriate() && timeIsAppropriate() {
            let whenStart: String = whenStartHour_1+whenStartHour_2+":"+whenStartMinute_1+whenStartMinute_2
            return whenStart
        }
        return ""
    }
}

struct WhenStartView_Previews: PreviewProvider {
    static var previews: some View {
        WhenStartView(whenSleep: "")
    }
}
