//
//  WaitingView.swift
//  SleepAnalysis
//
//  Created by 장형준 on 2023/03/21.
//

import SwiftUI
import HealthKit

struct WaitingView: View {
    
    @AppStorage("UserEmail") private var userEmail: String = ""
    @AppStorage("UserId") private var userId: String = "-"
    let currentDate = Date()
    let email: String
    @State var sleepForWeek: [HKCategorySample] = []
    
    var body: some View {
        VStack(alignment: .center) {
            Image("Circle1")
                .padding(.top, 300.0)
            Spacer()
            Text("""
\(extractId(email:email))님의
수면 기록을 바탕으로
2Sleep을 구성중이에요
""")
            .font(.title2)
            .bold()
            .padding(.bottom, 150.0)
            //Put calculating in here
            NavigationLink(destination: FinishView()) {
                Text("다음")
                    .foregroundColor(.blue)
            }
        }.navigationBarBackButtonHidden()
            .onAppear {
                self.userEmail = email
                self.userId = extractId(email: email)
                //Collect sleep data during last 7 days
                readSleep(from: Date(timeInterval: -604800, since: currentDate), to: currentDate)
            }
    }
}

//Get sleep data for a week

//String -> Date
func makeStringToDate(str:String) -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.timeZone = TimeZone(abbreviation: "KST")

        return dateFormatter.date(from: str)!
}

//Date -> String
func dateToString(date:Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

       return dateFormatter.string(from: date)
}


func extractId(email: String) -> String {
    let firstSpace = email.firstIndex(of: "@") ?? email.endIndex
    let id = email[..<firstSpace]
    return String(id)
}

struct WaitingView_Previews: PreviewProvider {
    static var previews: some View {
        WaitingView(email: "")
    }
}
