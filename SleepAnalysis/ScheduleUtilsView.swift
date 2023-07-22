import SwiftUI
import Foundation
import Charts

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
    @Environment(\.managedObjectContext) var managedObjectContext
    @Environment(\.dismiss) private var dismiss
    
    @FetchRequest(sortDescriptors: []) var entries: FetchedResults<Entry>
    @FetchRequest(sortDescriptors: []) var V0_cores: FetchedResults<V0_main>
    @AppStorage("needUpdate") var needUpdate: Bool = false
    
    @ObservedObject var entry : Entry
    @State var sleepStart: Date = Date.now
    @State var sleepEnd: Date = Date.now
    @State private var entryStart: Date = Date.now
    @State private var editDone = false
    @State private var removeDone = false
    let calendar = Calendar.current
        
    public var body: some View{
        VStack{
            let startTime = calendar.startOfDay(for: Date.now)
            let endTime = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: Date.now)!
            HStack{
                Text("Start of Sleep : ")
                    .bold()
                Spacer()
            }.padding([.trailing, .leading], 10)
            HStack{
                DatePicker(
                    "",
                    selection: $sleepStart,
                    displayedComponents: [.hourAndMinute]
                )
                Spacer()
            }
            HStack{
                Text("End of Sleep : ")
                    .bold()
                Spacer()
            }.padding([.trailing, .leading], 10)
            HStack{
                DatePicker(
                    "",
                    selection: $sleepEnd,
                    displayedComponents: [.hourAndMinute]
                )
                Spacer()
            }
            HStack{
                Text("Duration of Sleep : \(getTimeDuration(original: entry.sleepEnd!.timeIntervalSince(entry.sleepStart!)))")
                    .bold()
                Spacer()
            }.padding([.trailing, .leading], 10)
            Text("")
            
            HStack{
                Button(action: {
                    editDone = true
                    entry.sleepStart = sleepStart
                    entry.sleepEnd = sleepEnd
                    entryStart = sleepStart
                    if managedObjectContext.hasChanges{
                        do {
                            try managedObjectContext.save()
                        } catch let nserror as NSError{
                            // handle the Core Data error
                            print("Unresolved error \(nserror), \(nserror.userInfo)")
                            
                        }
                    }
                    needUpdate = true
                    
                }, label: {Text("Edit Sleep")})
                .alert("Sleep time has been updated", isPresented: $editDone) {
                    Button("OK", role: .cancel) { }
                }
                Text("  ")
                Button(action: {
                    removeDone = true
                    managedObjectContext.delete(entry)
                    try! managedObjectContext.save()
                    entry.sleepStart = Date.now
                    entry.sleepEnd = Date.now
                    needUpdate = true
                    dismiss()
                    
                }, label: {Text("Remove Sleep")}
                ).alert("Sleep time has been deleted", isPresented: $removeDone) {
                    Button("OK", role: .cancel) { }
                }
                
            }
            
        }.navigationTitle("Sleep")
            .onAppear{
                sleepStart = entry.sleepStart!
                sleepEnd = entry.sleepEnd!
            }
            .onDisappear{
                entryStart = Date.now
            }
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
    var entry:EntryAwareness
    public var body: some View{
            VStack(alignment: .leading) {
                ZStack{
                    VStack{
                        HStack{
                            Text(entry.sleepStart.formatted(date: .omitted, time: .shortened))
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
