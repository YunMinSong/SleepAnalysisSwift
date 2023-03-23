//
//  WhenSleepView.swift
//  SleepAnalysis
//
//  Created by 장형준 on 2023/03/14.
//

/*
 Need to do more
 1. Load user name
 2. Send time data to next page
 */

import SwiftUI
import Combine

struct WhenFinishView: View {
    
    let whenSleep: String
    let whenStart: String
    
    @AppStorage("whenFinish") private var finishTime: String = ""
    @AppStorage("UserId") private var userId: String = "-"
    
    @State var userName: String = "홍길동"
    @State var whenFinishHour_1: String = ""
    @State var whenFinishHour_2: String = ""
    @State var whenFinishMinute_1: String = ""
    @State var whenFinishMinute_2: String = ""
    @State var whenFinish: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("언제 퇴근하시나요?")
                .font(.title)
                .bold()
                .alignmentGuide(.leading, computeValue: {d in -20.0})
            Text("\(userId)님의 퇴근 시각을 알려주세요")
                .font(.custom("descript", size: 14))
                .padding(.vertical, 2)
                .alignmentGuide(.leading, computeValue: {d in -20.0})
            Text("퇴근 시간과 출근 시간이 같으면 안됩니다!")
                .foregroundColor(.red)
                .bold()
                .font(.custom("descript", size: 14))
                .padding(.top, 2)
                .alignmentGuide(.leading, computeValue: {d in -20.0})
                .opacity(isSame() ? 0 : 1)
            HStack(spacing: 10) {
                whenView(when: $whenFinishHour_1)
                whenView(when: $whenFinishHour_2)
                Text(":")
                    .font(.largeTitle)
                whenView(when: $whenFinishMinute_1)
                whenView(when: $whenFinishMinute_2)
            }
            .alignmentGuide(.leading, computeValue: {d in -20.0})
            .padding(.top, 80.0)
            
            NavigationLink(destination: RecommendView()) {
                Rectangle().foregroundColor(.blue).frame(width: 390, height: 56).cornerRadius(8)
                    .overlay(Text("다음").foregroundColor(.white))
            }.padding(.top, 100.0)
                .opacity(textIsAppropriate() ? 1 : 0)
                .simultaneousGesture(TapGesture().onEnded({
                    self.finishTime = saveTime()
                }))
        }
    }
    
    func textIsAppropriate() -> Bool {
        let whenFinish: String = whenFinishHour_1+whenFinishHour_2+":"+whenFinishMinute_1+whenFinishMinute_2
            if whenFinish.count < 5 {
                return false
            }
            return true
        }
    func isSame() -> Bool {
        
        let whenFinish: String = whenFinishHour_1+whenFinishHour_2+":"+whenFinishMinute_1+whenFinishMinute_2
        if whenFinish == whenStart {
            return false
        }
        return true
    }
    
    func timeIsAppropriate() -> Bool {
        let finishHour: Int = Int(whenFinishHour_1+whenFinishHour_2) ?? 0
        let finishMinute: Int = Int(whenFinishMinute_1+whenFinishMinute_2) ?? 0
        if finishHour <= 0 || finishHour > 24 || finishMinute > 59 || !isSame() {
            return false
        }
        return true
    }
    
    func saveTime() -> String {
        if textIsAppropriate() && timeIsAppropriate() {
            let whenFinish: String = whenFinishHour_1+whenFinishHour_2+":"+whenFinishMinute_1+whenFinishMinute_2
            return whenFinish
        }
        return ""
    }
}

struct WhenFinishView_Previews: PreviewProvider {
    static var previews: some View {
        WhenFinishView(whenSleep: "", whenStart: "")
    }
}
