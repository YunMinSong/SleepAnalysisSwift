//
//  CheckView.swift
//  SleepAnalysis
//
//  Created by 장형준 on 2023/03/21.
//

import SwiftUI

struct CheckView: View {
    let email: String
    
    var body: some View {
        VStack(alignment: .center) {
            Image("tangle")
                .padding(.top, 200.0)
            //Classification should be added
            if true {
                FirstUser(email: email)
            } else {
                RegisteredUser(email: email)
            }
        }
    }
}
// If there is no sleep data already registered
struct FirstUser: View {
    
    let title: String = """
Calm을
처음 사용하시나요?
"""
    let description: String = """
사용자를 위한 맞춤 수면을 위해서
일주일간의 수면 기록을 수집할게요
"""
    let email: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .bold()
                .padding(.top, 60.0)
                
            Text(description)
                .foregroundColor(Color(red: 0.481, green: 0.511, blue: 0.57))
                .padding(.top, 3.0)
            Spacer()
            NavigationLink(destination: WaitingView(email: email)) {
                Rectangle()
                    .foregroundColor(.blue)
                    .frame(width: 358, height: 56)
                    .cornerRadius(28)
                    .overlay(Text("다음").foregroundColor(.white))
            }.navigationBarBackButtonHidden()
        }
    }
}

// If there is sleep data already registered
struct RegisteredUser: View {
    
    let email: String
    
    let description: String = """
사용자를 위한 맞춤 수면을 위해서
지난 기간 동안의 수면 기록을 수집할게요
"""
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("""
\(extractId(email:email))님
그동안 잘 주무셨나요?
""")
                .font(.title2)
                .bold()
                .padding(.top, 60.0)
                
            Text(description)
                .foregroundColor(Color(red: 0.481, green: 0.511, blue: 0.57))
                .padding(.top, 3.0)
            Spacer()
            NavigationLink(destination: WaitingView(email: email)) {
                Rectangle()
                    .foregroundColor(.blue)
                    .frame(width: 358, height: 56)
                    .cornerRadius(28)
                    .overlay(Text("다음").foregroundColor(.white))
            }.navigationBarBackButtonHidden()
        }
    }
    
}

struct CheckView_Previews: PreviewProvider {
    static var previews: some View {
        CheckView(email: "")
    }
}
