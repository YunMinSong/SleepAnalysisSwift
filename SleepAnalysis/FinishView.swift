//
//  FinishView.swift
//  SleepAnalysis
//
//  Created by 장형준 on 2023/03/21.
//

import SwiftUI

struct FinishView: View {
    
    let title = "준비가 완료되었어요"
    let description = "이제 Calm과 함께 잘 자요 :)"
    
    var body: some View {
        VStack(alignment: .center) {
            Image("Star3")
                .padding(.top, 200.0)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.title2)
                    .bold()
                    .padding(.top, 100.0)
                    
                Text(description)
                    .foregroundColor(Color(red: 0.481, green: 0.511, blue: 0.57))
                    .padding(.top, 3.0)
                Spacer()
                NavigationLink(destination: MainView()) {
                    Rectangle()
                        .foregroundColor(.blue)
                        .frame(width: 358, height: 56)
                        .cornerRadius(28)
                        .overlay(Text("시작하기").foregroundColor(.white))
                }
            }
        }
    }
}

struct FinishView_Previews: PreviewProvider {
    static var previews: some View {
        FinishView()
    }
}
