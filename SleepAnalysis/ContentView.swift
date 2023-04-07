//
//  ContentView.swift
//  SleepAnalysis
//
//  Created by Reinatt Wijaya on 2022/11/02.
//

import SwiftUI
import Charts

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
//    let dateFormatter = DateFormatter()
//    let stringVal = dateFormatter.string(from: date)
    return date
}

struct ContentView: View {
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @State var AwarenessData = [LineData](repeating: LineData(Category: "Awareness", x: formatDate(offset: 0.0), y: 0.0), count: 12*24*2)
    @State var SleepData = [LineData](repeating: LineData(Category: "Sleep", x: formatDate(offset: 0.0), y: 0.0), count: 12*24*2)
    @State var SleepSuggestionData = [LineData](repeating: LineData(Category: "Sleep Suggestion", x: formatDate(offset: 0.0), y: 0.0), count: 12*24*2)
    @State var isLoading = false
    @State var lastUpdated = Date.now.addingTimeInterval(-60.0*60.0*3)
    
    @AppStorage("sleep_onset") var sleep_onset: Date = Date.now
    @AppStorage("work_onset") var work_onset: Date = Date.now
    @AppStorage("work_offset") var work_offset: Date = Date.now
    @AppStorage("lastSleep") var lastSleep:Date = Date.now.addingTimeInterval(-1*60.0*60.0*24.0*14.0)
    @AppStorage("needUpdate") var needUpdate:Bool = false

    
    @AppStorage("V0_x") var V0_x: Double = -0.8283
    @AppStorage("V0_y") var V0_y: Double = 0.8413
    @AppStorage("V0_n") var V0_n: Double = 0.6758
    @AppStorage("V0_H") var V0_H: Double = 13.3336
    
    @FetchRequest(sortDescriptors: []) var entries: FetchedResults<Entry>
    @FetchRequest(sortDescriptors: []) var V0_cores: FetchedResults<V0_main>
    
    @State var suggestion_pattern = [(Double, String)](repeating: (0.0, "Main Sleep"), count: 12*24*2+10)
    @State var sleep_pattern = [Double](repeating: 0.0, count: 12*24*2+10)
    @State var y_data = [[Double]](repeating: [0.0], count: 12*24*2+10)
    @State var mainSleepStart = Date.now
    @State var mainSleepEnd = Date.now
    @State var napSleepStart = Date.now
    @State var napSleepEnd = Date.now
    
    var body: some View {
        GeometryReader{ geometry in
            if isLoading{
                LoadingView()
            }else{
                VStack{
                    VStack{
                        HeaderView()
                            .padding()
                    }.background(.white)
                    VStack {
                        AlertView()
                            .padding()
                            .background(.white)
                            .previewLayout(.fixed(width: 400, height: 60))
                            .cornerRadius(15)
                            .onTapGesture{print("you clicked alertView")}
                        SleepTimeView(mainSleepStart: $mainSleepStart, mainSleepEnd: $mainSleepEnd, napSleepStart: $napSleepStart, napSleepEnd: $napSleepEnd)
                            .padding()
                            .background(.white)
                            .previewLayout(.fixed(width: 400, height: 60))
                            .cornerRadius(15)
                            .onTapGesture{print("you clicked sleeptimeView")}
                        GraphView(AwarenessData: $AwarenessData)
                            .padding()
                            .background(.white)
                            .previewLayout(.fixed(width: 400, height: 60))
                            .cornerRadius(15)
                            .frame(height: geometry.size.height/3)
                            .onTapGesture{print("you clicked graphView")}
                        Spacer()
                        //                List{
                        //                Chart {
                        //                    ForEach(SleepData){
                        //                        LineMark(
                        //                            x: .value("x1", $0.x),
                        //                            y: .value("y1", $0.y),
                        //                            series: .value("sleep", "s")
                        //                        ).foregroundStyle(by: .value("Category", $0.Category))
                        //                        AreaMark(
                        //                            x: .value("x1", $0.x),
                        //                            y: .value("y1", $0.y)
                        //                        ).foregroundStyle(.blue)
                        //                    }
                        //                    ForEach(AwarenessData){
                        //                        LineMark(
                        //                            x: .value("x", $0.x),
                        //                            y: .value("y", $0.y),
                        //                            series: .value("awareness", "a")
                        //                        ).interpolationMethod(.catmullRom)
                        //                            .foregroundStyle(by: .value("Category", $0.Category))
                        //                    }
                        //
                        //                }.frame(height: geometry.size.height/3)
                        //                //                }.refreshable {
                        //                //                    print("something")
                        //                //                }
                        //                Chart(SleepSuggestionData) {
                        //                    LineMark(
                        //                        x: .value("x", $0.x),
                        //                        y: .value("y", $0.y)
                        //                    ).foregroundStyle(by: .value("Category", $0.Category))
                        //                    AreaMark(
                        //                        x: .value("x", $0.x),
                        //                        y: .value("y", $0.y)
                        //                    ).foregroundStyle(by: .value("Category", $0.Category))
                        //                }.frame(height: geometry.size.height/3)
                    }.padding()
                    
                }
                    .onAppear(){
                        if needUpdate || Date.now.timeIntervalSince(lastUpdated) > 60.0*60.0*2{
                            isLoading = true
                            readSleep(from: lastSleep, to: Date.now)
                            lastSleep = Date.now
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
                                needUpdate = false
                                lastUpdated = Date.now
                                print("BRUH")
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
                                
                                //Sleep Suggestion
                                let step = 1/12.0
                                let V0_suggest = [V0_x, V0_y, V0_n, V0_H]
                                let suggest = Sleep_pattern_suggestion(V0: V0_suggest, sleep_onset: Int(sleep_onset.timeIntervalSince(Date.now)/60/5), work_onset: Int(work_onset.timeIntervalSince(Date.now)/60/5), work_offset: Int(work_offset.timeIntervalSince(Date.now)/60/5), step: step)
                                let MainSleep = suggest.CSS
                                let NapSleep = suggest.Nap
                                
                                //debug
                                mainSleepStart = Date.now.addingTimeInterval(Double(MainSleep[0])*5.0*60.0)
                                mainSleepEnd = Date.now.addingTimeInterval(Double(MainSleep[1])*5.0*60.0)
                                napSleepStart = Date.now.addingTimeInterval(Double(NapSleep[0])*5.0*60.0)
                                napSleepEnd = Date.now.addingTimeInterval(Double(NapSleep[1])*5.0*60.0)
                                //                    print("Main sleep: ", mainSleepStart)
                                //                    print("Main sleep: ", mainSleepEnd)
                                //                    print("Nap sleep: ", napSleepStart)
                                //                    print("Nap sleep: ", napSleepEnd)
                                
                                
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
                                        //                        print(entry.sleepStart!)
                                        continue
                                    }else{
                                        //distance from startDate:
                                        let startToSleep = entry.sleepStart?.timeIntervalSince(startDate)
                                        let sleepToSleep = entry.sleepEnd!.timeIntervalSince(entry.sleepStart!)
                                        
                                        //                        print(String(startToSleep!), String(sleepToSleep))
                                        //fill out the array
                                        let idx = Int(startToSleep!/60/5)
                                        let offset = Int(sleepToSleep/60/5)
                                        
                                        //                        print(idx, offset)
                                        
                                        for i in 0..<offset{
                                            sleep_pattern[idx+i] = 1.0
                                        }
                                    }
                                }
                                y_data = pcr_simulation(V0: V0, sleep_pattern: sleep_pattern, step: 5/60.0)
                                //                let start = DispatchTime.now()
                                let yesterday = Date.now.addingTimeInterval(60.0*60.0*24.0)
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
                                    SleepSuggestionData[x] = LineData(Category: suggestion_pattern[x].1, x: formatDate(offset: Double(x)*5.0*60.0), y: Double(suggestion_pattern[x].0))
                                }
                                for x in 0...575{
                                    let C = 3.37*0.5*(1+coef_y*y_data[x][1] + coef_x * y_data[x][0])
                                    let D_up = (2.46+10.2+C) //sleep thres
                                    let awareness = D_up - y_data[x][3]
                                    AwarenessData[x] = LineData(Category:"Alertness",x:formatDate(offset: Double(x)*5.0*60.0-1.0*60*60*24*1), y:Double(awareness))
                                    SleepData[x] = LineData(Category:"Sleep",x:formatDate(offset: Double(x)*5.0*60.0-1.0*60*60*24*1), y:Double(sleep_pattern[x]))
                                }
                                isLoading=false
                            }
                        }
                    }.background(Color.gray.brightness(0.35))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
