import SwiftUI
import Foundation
import Charts

//struct ScheduleGraphView: View {
//    
//    @Binding var AwarenessData: [LineData]
//    
//    var body: some View {
//        VStack(alignment: .leading) {
//            HStack{
//                VStack{
//                    Text("민수님")
//                    Text("이때 주무시는건 어때요?")
//                }
//                Spacer()
//                Text("logo")
//            }
//            Chart {
//                ForEach(AwarenessData){
//                    LineMark(
//                        x: .value("x", $0.x),
//                        y: .value("y", $0.y),
//                        series: .value("awareness", "a")
//                    ).interpolationMethod(.catmullRom)
//                        .foregroundStyle(by: .value("Category", $0.Category))
//                }
//            }
//        }
//    }
//}
