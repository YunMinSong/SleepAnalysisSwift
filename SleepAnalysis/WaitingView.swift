//
//  WaitingView.swift
//  SleepAnalysis
//
//  Created by 장형준 on 2023/03/21.
//

import SwiftUI

struct WaitingView: View {
    
    @AppStorage("UserEmail") private var userEmail: String = ""
    @AppStorage("UserId") private var userId: String = "-"
    let email: String
    
    var body: some View {
        var count = 0
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
                for _ in 0...11 {
                    count += 1
                }
            }
    }
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
