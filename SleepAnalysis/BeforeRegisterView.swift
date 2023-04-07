//
//  BeforeRegisterView.swift
//  SleepAnalysis
//
//  Created by 장형준 on 2023/03/21.
//

import SwiftUI
import HealthKit

struct BeforeRegisterView: View {
    
    //To load sleep data from HealthKit
    let title: String = """
자도자도 피곤하다면?
"""
    
    let description: String = """
한번 잘 때 푹 자는게 중요해요
가장 효율적인 수면을 제안해드릴게요
"""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center) {
                Image("Scribble5")
                    .padding(.top, 200.0)
                VStack(alignment: .leading) {
                    Text(title)
                        .font(.title2)
                        .bold()
                        .padding(.top, 60.0)
                    
                    Text(description)
                        .foregroundColor(Color(red: 0.481, green: 0.511, blue: 0.57))
                        .padding(.top, 3.0)
                    Spacer()
                    NavigationLink(destination: RegisterView()) {
                        Rectangle()
                            .foregroundColor(.blue)
                            .frame(width: 358, height: 56)
                            .cornerRadius(28)
                            .overlay(Text("시작하기").foregroundColor(.white))
                    }
                }
            }
        }.onAppear {
            requestSleepAuthorization()
        }
    }
    
    struct BeforeRegisterView_Previews: PreviewProvider {
        static var previews: some View {
            BeforeRegisterView()
        }
    }
}
