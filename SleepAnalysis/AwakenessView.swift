//
//  AwakenessView.swift
//  SleepAnalysis
//
//  Created by 장형준 on 2023/05/26.
//

import SwiftUI

struct AwakenessView: View {
    
    @State var isOtherChecked: Int = 0
    @State var repeated: Bool = false
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("오늘은 얼마나 가뿐하신가요?")
                    .font(.title)
                    .bold()
                    .padding(.top)
                Spacer().frame(height: 10)
                Text("지금의 각성도를 잘 메모해둘게요 :)")
                    .foregroundColor(Color(red: 0.481, green: 0.511, blue: 0.57))
                Spacer().frame(height: 50)
                AwakenessLibrary()
                    .alignmentGuide(.leading, computeValue: { d in -15.0 })
                NavigationLink(destination: MainView()) {
                    Rectangle()
                        .foregroundColor(.blue)
                        .frame(width: 358, height: 56)
                        .cornerRadius(28)
                        .overlay(Text("시작하기").foregroundColor(.white))
                        .padding(.vertical)
                }
            }
        }
    }
}

struct AwakenessLibrary: View {
    
    @State var isClicked1: Bool = false
    @State var isClicked2: Bool = false
    @State var isClicked3: Bool = false
    @State var isClicked4: Bool = false
    @State var isClicked5: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Button(action: {
                isClicked1.toggle()
                isClicked2 = false
                isClicked3 = false
                isClicked4 = false
                isClicked5 = false
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(self.isClicked1 ? Color.blue : Color(red: 0.956, green: 0.961, blue: 0.965))
                        .frame(width: 326, height: 82)
                    VStack(alignment: .leading) {
                        Text("5단계")
                            .bold()
                            .foregroundColor(.black)
                            .alignmentGuide(.leading, computeValue: { d in 280.0 })
                        Spacer()
                            .frame(height: 10)
                        Text("몸이 가벼워요 😎")
                            .foregroundColor(.black)
                            .alignmentGuide(.leading, computeValue: { d in 280.0 })
                    }
                }
                
            }
            Button(action: {
                isClicked2.toggle()
                isClicked3 = false
                isClicked4 = false
                isClicked5 = false
                isClicked1 = false
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(self.isClicked2 ? Color.blue : Color(red: 0.956, green: 0.961, blue: 0.965))
                        .frame(width: 326, height: 82)
                    VStack(alignment: .leading) {
                        Text("4단계")
                            .bold()
                            .foregroundColor(.black)
                            .alignmentGuide(.leading, computeValue: { d in 280.0 })
                        Spacer()
                            .frame(height: 10)
                        Text("조금 좋아요 😀")
                            .foregroundColor(.black)
                            .alignmentGuide(.leading, computeValue: { d in 280.0 })
                    }
                }
            }
            Button(action: {
                isClicked3.toggle()
                isClicked2 = false
                isClicked4 = false
                isClicked5 = false
                isClicked1 = false
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(self.isClicked3 ? Color.blue : Color(red: 0.956, green: 0.961, blue: 0.965))
                        .frame(width: 326, height: 82)
                    VStack(alignment: .leading) {
                        Text("3단계")
                            .bold()
                            .foregroundColor(.black)
                            .alignmentGuide(.leading, computeValue: { d in 280.0 })
                        Spacer()
                            .frame(height: 10)
                        Text("평소랑 비슷해요 😶")
                            .foregroundColor(.black)
                            .alignmentGuide(.leading, computeValue: { d in 280.0 })
                    }
                }
            }
            Button(action: {
                isClicked4.toggle()
                isClicked3 = false
                isClicked2 = false
                isClicked5 = false
                isClicked1 = false
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(self.isClicked4 ? Color.blue : Color(red: 0.956, green: 0.961, blue: 0.965))
                        .frame(width: 326, height: 82)
                    VStack(alignment: .leading) {
                        Text("2단계")
                            .bold()
                            .foregroundColor(.black)
                            .alignmentGuide(.leading, computeValue: { d in 280.0 })
                        Spacer()
                            .frame(height: 10)
                        Text("살짝 졸려요 🥲")
                            .foregroundColor(.black)
                            .alignmentGuide(.leading, computeValue: { d in 280.0 })
                    }
                }
            }
            Button(action: {
                isClicked5.toggle()
                isClicked3 = false
                isClicked4 = false
                isClicked1 = false
                isClicked2 = false
            }) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(self.isClicked5 ? Color.blue : Color(red: 0.956, green: 0.961, blue: 0.965))
                        .frame(width: 326, height: 82)
                    VStack(alignment: .leading) {
                        Text("1단계")
                            .bold()
                            .foregroundColor(.black)
                            .alignmentGuide(.leading, computeValue: { d in 280.0 })
                        Spacer()
                            .frame(height: 10)
                        Text("너무 피곤해요 😵‍💫")
                            .foregroundColor(.black)
                            .alignmentGuide(.leading, computeValue: { d in 280.0 })
                    }
                }
            }
        }
    }
}

struct AwakenessView_Previews: PreviewProvider {
    static var previews: some View {
        AwakenessView()
    }
}
