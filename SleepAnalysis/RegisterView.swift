//
//  RegisterView.swift
//  SleepAnalysis
//
//  Created by 장형준 on 2023/03/21.
//

import SwiftUI
import UIKit
import HealthKit

struct RegisterView: View {
    
    @State var email: String = ""
    let healthStore: HKHealthStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("이메일을 알려주세요")
                .font(.title)
                .bold()
                .padding(.top, 100.0)
            Text("2Sleep이 수면 정보를 기억해둘게요")
                .foregroundColor(Color(red: 0.481, green: 0.511, blue: 0.57))
            CustomField(text: $email, title: "이메일", example: "example@example.com")
                .padding(.top, 50.0)
            Spacer()
            if isValidEmail(testStr: email) {
                NavigationLink(destination: CheckView(healthStore: healthStore, email: email)) {
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

class CustomTextField: UITextField {

    private func getKeyboardLanguage() -> String? {
        return "ko-KR"
    }

    override var textInputMode: UITextInputMode? {
        if let language = getKeyboardLanguage() {
            for inputMode in UITextInputMode.activeInputModes {
                if inputMode.primaryLanguage! == language {
                    return inputMode
                }
            }
        }
        return super.textInputMode
    }

}

struct CustomField: View {
    
    @Binding var text: String
    let title: String
    let example: String
    
    var body: some View {
        Rectangle()
            .foregroundColor(Color(red: 0.956, green: 0.961, blue: 0.965))
            .frame(width: 358, height: 56)
            .cornerRadius(8)
            .overlay(inField(text: $text, title: title, example: example))
        }
    }

struct inField: View {
    
    @Binding var text: String
    
    let title: String
    let example: String
    
    var body: some View {
        HStack {
            Text(title)
                .bold()
                .foregroundColor(Color(red: 0.655, green: 0.675, blue: 0.713))
                .padding(.leading, 25.0)
            TextField(example, text: $text)
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
        RegisterView(healthStore: HKHealthStore())
    }
}
