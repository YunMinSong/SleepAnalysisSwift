//
//  ContentView.swift
//  SleepAnalysis
//
//  Created by Reinatt Wijaya on 2022/11/02.
//

import SwiftUI
import Charts
import CoreData

struct LineData: Encodable, Identifiable{
    let id = UUID()
    var Category: String
    var x: Date
    var y: Double
    
    init(Category:String, x: Date, y: Double){
        self.Category = Category
        self.x = x
        self.y = y
    }
}

public func formatDate(offset: Double)->Date{
    let date = Date.now.addingTimeInterval(offset)
    return date
}

struct entry{
    let sleepStart: Date?
    let sleepEnd: Date?
}

func processSleepData(V0: [Double], entries: FetchedResults<Entry>) -> ([[Double]], [(Double, String)], [Double]){
    
    @AppStorage("sleep_onset") var sleep_onset: Date = Date.now
    @AppStorage("work_onset") var work_onset: Date = Date.now
    @AppStorage("work_offset") var work_offset: Date = Date.now
    
    @AppStorage("V0_x") var V0_x: Double = -0.8283
    @AppStorage("V0_y") var V0_y: Double = 0.8413
    @AppStorage("V0_n") var V0_n: Double = 0.6758
    @AppStorage("V0_H") var V0_H: Double = 13.3336
    
    var suggestion_pattern = [(Double, String)](repeating: (0.0, "Main Sleep"), count: 12*24*2+10)
    var sleep_pattern = [Double](repeating: 0.0, count: 12*24*2+10)
    var y_data = [[Double]](repeating: [0.0], count: 12*24*2+10)
    
    @AppStorage("mainSleepStart") var mainSleepStart: Date = Date.now
    @AppStorage("mainSleepEnd") var mainSleepEnd: Date = Date.now
    @AppStorage("napSleepStart") var napSleepStart: Date = Date.now
    @AppStorage("napSleepEnd") var napSleepEnd: Date = Date.now
    
    //PCR prediction initial data
    let startDate = Date.now.addingTimeInterval(-1.0*60*60*24*1)
    //Sleep Suggestion
    let step = 1/12.0
    let V0_suggest = [V0_x, V0_y, V0_n, V0_H]

    let suggest = Sleep_pattern_suggestion(V0: V0_suggest, sleep_onset: Int(sleep_onset.timeIntervalSince(Date.now)/60/5), work_onset: Int(work_onset.timeIntervalSince(Date.now)/60/5), work_offset: Int(work_offset.timeIntervalSince(Date.now)/60/5), step: step)
    let MainSleep = suggest.CSS
    let NapSleep = suggest.Nap
    
    mainSleepStart = Date.now.addingTimeInterval(Double(MainSleep[0])*5.0*60.0)
    mainSleepEnd = Date.now.addingTimeInterval(Double(MainSleep[1])*5.0*60.0)
    napSleepStart = Date.now.addingTimeInterval(Double(NapSleep[0])*5.0*60.0)
    napSleepEnd = Date.now.addingTimeInterval(Double(NapSleep[1])*5.0*60.0)
//    print("Main sleep: ", mainSleepStart)
//    print("Main sleep: ", mainSleepEnd)
//    print("Nap sleep: ", napSleepStart)
//    print("Nap sleep: ", napSleepEnd)
    
    
    var idx = Int(MainSleep[0])
    var offset = Int(MainSleep[1])
    for i in 0..<offset{
        suggestion_pattern[288+idx+i] = (1.0, "Main Sleep")
        sleep_pattern[288+idx+i] = 1.0
    }
    
    idx = Int(NapSleep[0])
    offset = Int(NapSleep[1])
    for i in 0..<offset{
        suggestion_pattern[288+idx+i] = (1.0, "Nap")
        sleep_pattern[288+idx+i] = 1.0
    }
    
    
    for entry in entries{
        if entry.sleepStart == nil{
            continue
        }
        if entry.sleepStart! < startDate{
            continue
        }else{
            let startToSleep = entry.sleepStart?.timeIntervalSince(startDate)
            let sleepToSleep = entry.sleepEnd!.timeIntervalSince(entry.sleepStart!)
            
            //fill out the array
            let idx = Int(startToSleep!/60/5)
            let offset = Int(sleepToSleep/60/5)
                        
            for i in 0..<offset{
                sleep_pattern[idx+i] = 1.0
            }
        }
    }
    y_data = pcr_simulation(V0: V0, sleep_pattern: sleep_pattern, step: 5/60.0)
    
    return (y_data, suggestion_pattern, sleep_pattern)
}

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    @Binding var tabSelection: Int
//    @Binding var AwarenessData: [LineData]
//    @Binding var SleepData: [LineData]
//    @Binding var SleepSuggestionData: [LineData]
    @StateObject var data = AwarenessModel()
    @State var isLoading = false
    
    @AppStorage("lastUpdated") var lastUpdated:Date = Date.now.addingTimeInterval(-60.0*60.0*3)
    @AppStorage("lastSleep") var lastSleep:Date = Date.now.addingTimeInterval(-1*60.0*60.0*24.0*14.0)
    @AppStorage("needUpdate") var needUpdate:Bool = false
    
    @FetchRequest(sortDescriptors: []) var entries: FetchedResults<Entry>
    @FetchRequest(sortDescriptors: []) var V0_cores: FetchedResults<V0_main>
    
    @AppStorage("mainSleepStart") var mainSleepStart: Date = Date.now
    @AppStorage("mainSleepEnd") var mainSleepEnd: Date = Date.now
    @AppStorage("napSleepStart") var napSleepStart: Date = Date.now
    @AppStorage("napSleepEnd") var napSleepEnd: Date = Date.now
    
    var body: some View {
        
            GeometryReader{ geometry in
                if isLoading{
                    LoadingView()
                }else{
                    ScrollView(){
                    VStack{
                        HeaderView()
                            .padding()
                            .background(.white)
                            
                        VStack (spacing: 40){
                            SleepTimeView(tabSelection: $tabSelection, mainSleepStart: $mainSleepStart, mainSleepEnd: $mainSleepEnd, napSleepStart: $napSleepStart, napSleepEnd: $napSleepEnd)
                                .padding()
                                .background(.white)
                                .previewLayout(.fixed(width: 400, height: 120))
                                .cornerRadius(15)
                                .onTapGesture{print("you clicked sleeptimeView")}
                            
                            GraphView(AwarenessData: $data.AwarenessData,tabSelection: $tabSelection)
                                .padding()
                                .background(.white)
                                .previewLayout(.fixed(width: 400, height: 60))
                                .cornerRadius(15)
                                .frame(height: geometry.size.height/3)
                                .onTapGesture{print("you clicked graphView")}
                        }.padding()
                    }
                    .onAppear(){
                        if needUpdate || Date.now.timeIntervalSince(lastUpdated) > 60.0*60.0*2{
                            isLoading = true
                            readSleep(from: lastSleep, to: Date.now)
                            lastSleep = Date.now
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2){
                                needUpdate = false
                                lastUpdated = Date.now
                                
                                //PCR prediction initial data
                                let startDate = Date.now.addingTimeInterval(-1.0*60*60*24*1)
                                var V0 =  [-0.8590, -0.6837, 0.1140, 14.2133] //initial condition
                                
                                //find V0
                                for v in V0_cores{
                                    if v.time! >= startDate{
                                        V0 = [v.y, v.x, v.n, v.h]
                                        break
                                    }
                                    managedObjectContext.delete(v)
                                }
                                let (y_data, suggestion_pattern, sleep_pattern) = processSleepData(V0: V0, entries: entries)
                                let yesterday = Date.now.addingTimeInterval(-1*60.0*60.0*24.0)
                                for x in 0...575{
                                    let V0_core = V0_main(context: managedObjectContext)
                                    V0_core.time = yesterday.addingTimeInterval(Double(x)*5.0*60.0)
                                    V0_core.y = y_data[x][0]
                                    V0_core.x = y_data[x][1]
                                    V0_core.n = y_data[x][2]
                                    V0_core.h = y_data[x][3]
                                    do {
                                        try managedObjectContext.save()
                                    } catch {
                                        // handle the Core Data error
                                    }
                                }
                                for x in 0...575{
                                    data.SleepSuggestionData[x] = LineData(Category: suggestion_pattern[x].1, x: formatDate(offset: Double(x)*5.0*60.0), y: Double(suggestion_pattern[x].0))
                                }
                                for x in 0...575{
                                    let C = 3.37*0.5*(1+coef_y*y_data[x][1] + coef_x * y_data[x][0])
                                    let D_up = (2.46+10.2+C) //sleep thres
                                    let awareness = D_up - y_data[x][3]
                                    data.AwarenessData[x] = LineData(Category:"Alertness",x:formatDate(offset: Double(x)*5.0*60.0-1.0*60*60*24*1), y:Double(awareness))
                                    data.SleepData[x] = LineData(Category:"Sleep",x:formatDate(offset: Double(x)*5.0*60.0-1.0*60*60*24*1), y:Double(sleep_pattern[x]))
                                }
                                isLoading=false
                            }
                        }
                    }
                }.background(Color.gray.brightness(0.35))
            }
        }
    }
}

//struct ContentView_Previews: PreviewProvider {
//    static var previews: some View {
//        ContentView()
//    }
//}
