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

func secondsToHoursMinutesSeconds(_ seconds: Int) -> (Int, Int, Int) {
    return (seconds / 3600, (seconds % 3600) / 60, (seconds % 3600) % 60)
}

func getTimeDuration(original: Double) -> String {
    let (h,m,_) = secondsToHoursMinutesSeconds(Int(original))

    let result = "\(h)" + "시간 " + "\(m)" + "분"
    return result
}

struct EntryAwareness{
    var sleepStart: Date
    var sleepEnd: Date
}

public struct CalendarDetailView: View{
    var entry : Entry
    public var body: some View{
        VStack{
            Text("Start of sleep: \(entry.sleepStart!.formatted(date: .omitted ,time: .shortened))")
            Text("End of sleep: \(entry.sleepEnd!.formatted(date: .omitted, time: .shortened))")
            Text("Duration of sleep: \(getTimeDuration(original: entry.sleepEnd!.timeIntervalSince(entry.sleepStart!)))")
        }.navigationTitle("sleep")
    }
}

public struct CalendarCardAwarenessView: View{
    var entry:EntryAwareness
    @State private var from:String = "19:40"
    @State private var to: String = "20:40"
    @State private var duration: String = "04:20"
    public var body: some View{
            VStack(alignment: .leading) {
                ZStack{
                    VStack{
                        ZStack{
                            Rectangle()
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            HStack{
                                Image("sun")
                                VStack{
                                    HStack{
                                        Text("활동").font(.system(size: 13))
                                        Spacer()
                                    }
                                    HStack{
                                        Text(getTimeDuration(original:entry.sleepEnd.timeIntervalSince(entry.sleepStart)))
                                            .bold()
                                            .font(.title3)
                                        Spacer()
                                    }
                                }
                                Spacer()
                            }.padding(10)
                        }
                        Spacer()
                        HStack{
                            Text(entry.sleepEnd.formatted(date: .omitted, time: .shortened))
                                .font(.system(size: 10))
                                .frame(maxWidth:50, alignment: .bottomLeading)
                            VStack { Divider().background(.gray) }
                        }.background(Color(red: 0.948, green: 0.953, blue: 0.962))
                    }
                }
                Spacer()
                /*Image("sskoo")
                 .padding(.vertical, 50.0)
                 .alignmentGuide(.leading, computeValue: { d in -100.0})
                 */
            //        Text("Start of sleep: \(entry.sleepStart!.formatted(date: .omitted ,time: .shortened))")
            //        Text("End of sleep: \(entry.sleepEnd!.formatted(date: .omitted, time: .shortened))")
            //        Text("Duration of sleep: \(entry.sleepEnd!.timeIntervalSince(entry.sleepStart!)/60.0/60.0) hours")
        }
    }
}

public struct CalendarCardView: View{
    var entry: EntryAwareness
    @State private var from:String = "19:40"
    @State private var to: String = "20:40"
    @State private var duration: String = "04:20"
    public var body: some View{
            VStack(alignment: .leading) {
                ZStack{
                    VStack{
                        ZStack{
                            Rectangle()
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            HStack{
                                Image("moon2")
                                VStack{
                                    HStack{
                                        Text("낮잠").font(.system(size: 13))
                                        Spacer()
                                    }
                                    HStack{
                                        Text(getTimeDuration(original:entry.sleepEnd.timeIntervalSince(entry.sleepStart)))
                                            .bold()
                                            .font(.title3)
                                        Spacer()
                                    }
                                }
                                Spacer()
                            }.padding(10)
                        }
                        Spacer()
                        HStack{
                            Text(entry.sleepEnd.formatted(date: .omitted, time: .shortened))
                                .font(.system(size: 10))
                                .frame(maxWidth:50, alignment: .bottomLeading)
                            VStack { Divider().background(.gray) }
                        }.background(Color(red: 0.948, green: 0.953, blue: 0.962))
                    }
                }
                Spacer()
                /*Image("sskoo")
                 .padding(.vertical, 50.0)
                 .alignmentGuide(.leading, computeValue: { d in -100.0})
                 */
            //        Text("Start of sleep: \(entry.sleepStart!.formatted(date: .omitted ,time: .shortened))")
            //        Text("End of sleep: \(entry.sleepEnd!.formatted(date: .omitted, time: .shortened))")
            //        Text("Duration of sleep: \(entry.sleepEnd!.timeIntervalSince(entry.sleepStart!)/60.0/60.0) hours")
        }
    }
}

public struct CalendarCardViewFirst: View{
    var entry: Entry
    public var body: some View{
            VStack(alignment: .leading) {
                ZStack{
                    VStack{
                        HStack{
                            Text(entry.sleepStart!.formatted(date: .omitted, time: .shortened))
                                .font(.system(size: 10))
                                .frame(maxWidth:50, alignment: .bottomLeading)
                            VStack { Divider().background(.gray) }
                        }.background(Color(red: 0.948, green: 0.953, blue: 0.962))
                            .padding([.leading], 5)
                        ZStack{
                            Rectangle()
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            HStack{
                                Image("moon2")
                                VStack{
                                    HStack{
                                        Text("낮잠").font(.system(size: 13))
                                        Spacer()
                                    }
                                    HStack{
                                        Text(getTimeDuration(original:entry.sleepEnd!.timeIntervalSince(entry.sleepStart!)))
                                            .bold()
                                            .font(.title3)
                                        Spacer()
                                    }
                                }
                                Spacer()
                            }.padding(10)
                        }
                        Spacer()
                        HStack{
                            Text(entry.sleepEnd!.formatted(date: .omitted, time: .shortened))
                                .font(.system(size: 10))
                                .frame(maxWidth:50, alignment: .bottomLeading)
                            VStack { Divider().background(.gray) }
                        }.background(Color(red: 0.948, green: 0.953, blue: 0.962))
                    }
                }
                Spacer()
                /*Image("sskoo")
                 .padding(.vertical, 50.0)
                 .alignmentGuide(.leading, computeValue: { d in -100.0})
                 */
            //        Text("Start of sleep: \(entry.sleepStart!.formatted(date: .omitted ,time: .shortened))")
            //        Text("End of sleep: \(entry.sleepEnd!.formatted(date: .omitted, time: .shortened))")
            //        Text("Duration of sleep: \(entry.sleepEnd!.timeIntervalSince(entry.sleepStart!)/60.0/60.0) hours")
        }
    }
}
