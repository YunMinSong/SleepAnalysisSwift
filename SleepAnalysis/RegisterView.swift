//
//  RegisterView.swift
//  SleepAnalysis
//
//  Created by 장형준 on 2023/03/21.
//

import SwiftUI

struct RegisterView: View {
    
    @State var email: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("이메일을 알려주세요")
                .font(.title)
                .bold()
                .padding(.top, 100.0)
            Text("Calm이 수면 정보를 기억해둘게요")
                .foregroundColor(Color(red: 0.481, green: 0.511, blue: 0.57))
            EmailField(email: $email)
                .padding(.top, 50.0)
            Spacer()
            if isValidEmail(testStr: email) {
                Button(action: {}) {
                    Rectangle()
                        .foregroundColor(.blue)
                        .frame(width: 358, height: 56)
                        .cornerRadius(28)
                        .overlay(Text("다음").foregroundColor(.white))
                }
            } else {
                Rectangle()
                    .foregroundColor(Color(red: 0.602, green: 0.749, blue: 0.984))
                    .frame(width: 358, height: 56)
                    .cornerRadius(28)
                    .overlay(Text("다음").foregroundColor(.white))
            }
        }
    }
}

struct EmailField: View {
    
    @Binding var email: String
    
    var body: some View {
        Rectangle()
            .foregroundColor(Color(red: 0.956, green: 0.961, blue: 0.965))
            .frame(width: 358, height: 56)
            .cornerRadius(8)
            .overlay(inField(email: $email))
        }
    }


struct inField: View {
    
    @Binding var email: String
    
    var body: some View {
        HStack {
            Text("이메일")
                .bold()
                .foregroundColor(Color(red: 0.655, green: 0.675, blue: 0.713))
                .padding(.leading, 25.0)
            TextField("example@example.com", text: $email)
                .foregroundColor(.black)
                .autocorrectionDisabled(true)
                .textInputAutocapitalization(.never)
        }
    }
}

func isValidEmail(testStr:String) -> Bool {
       let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
       let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
       return emailTest.evaluate(with: testStr)
        }

struct RegisterView_Previews: PreviewProvider {
    static var previews: some View {
        RegisterView()
    }
}
