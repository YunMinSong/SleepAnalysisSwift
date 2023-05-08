//
//  ScheduleView.swift
//  SleepAnalysis
//
//  Created by Reinatt Wijaya on 2022/11/06.
//

import SwiftUI
import CoreData
import HealthKit

extension Date: RawRepresentable {
    private static let formatter = ISO8601DateFormatter()
    
    public var rawValue: String {
        Date.formatter.string(from: self)
    }
    
    public init?(rawValue: String) {
        self = Date.formatter.date(from: rawValue) ?? Date()
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

struct ScheduleView: View {
    
    private let calendar: Calendar
    private let monthFormatter: DateFormatter
    private let dayFormatter: DateFormatter
    private let weekDayFormatter: DateFormatter
    private let fullFormatter: DateFormatter
    
    @State private var selectedDate = Self.now
    private static var now = Date()
        
    @FetchRequest(sortDescriptors: []) var entries: FetchedResults<Entry>
    
    init(calendar: Calendar) {
        self.calendar = calendar
        self.monthFormatter = DateFormatter(dateFormat: "MMMM YYYY", calendar: calendar)
        self.dayFormatter = DateFormatter(dateFormat: "d", calendar: calendar)
        self.weekDayFormatter = DateFormatter(dateFormat: "EEEEE", calendar: calendar)
        self.fullFormatter = DateFormatter(dateFormat: "dd MMMM yyyy", calendar: calendar)
        
        requestSleepAuthorization()
    }
    
    var body: some View {
        VStack {
            CalendarViewComponent(
                calendar: calendar,
                date: $selectedDate,
                content: { date in
                    ZStack {
                        Button(action: { selectedDate = date }) {
                            Text(dayFormatter.string(from: date))
                                .padding(6)
                                // Added to make selection sizes equal on all numbers.
                                .frame(width: 33, height: 33)
                                .foregroundColor(calendar.isDateInToday(date) ? Color.white : .primary)
                                .background(
                                    calendar.isDateInToday(date) ? Color.red
                                    : calendar.isDate(date, inSameDayAs: selectedDate) ? .blue
                                    : .clear
                                )
                                .cornerRadius(7)
                        }
                        
                        if (numberOfEventsInDate(date: date) >= 2) {
                            Circle()
                                .size(CGSize(width: 5, height: 5))
                                .foregroundColor(Color.green)
                                .offset(x: CGFloat(17),
                                        y: CGFloat(33))
                        }
                        
                        if (numberOfEventsInDate(date: date) >= 1) {
                            Circle()
                                .size(CGSize(width: 5, height: 5))
                                .foregroundColor(Color.green)
                                .offset(x: CGFloat(24),
                                        y: CGFloat(33))
                        }
                        
                        if (numberOfEventsInDate(date: date) >= 3) {
                            Circle()
                                .size(CGSize(width: 5, height: 5))
                                .foregroundColor(Color.green)
                                .offset(x: CGFloat(31),
                                        y: CGFloat(33))
                        }
                    }
                },
                trailing: { date in
                    Text(dayFormatter.string(from: date))
                        .foregroundColor(.secondary)
                },
                header: { date in
                    Text(weekDayFormatter.string(from: date)).fontWeight(.bold)
                },
                title: { date in
                    HStack {
                        
                        Button {
                            guard let newDate = calendar.date(
                                byAdding: .month,
                                value: -1,
                                to: selectedDate
                            ) else {
                                return
                            }
                            
                            selectedDate = newDate
                            
                        } label: {
                            Label(
                                title: { Text("Previous") },
                                icon: {
                                    Image(systemName: "chevron.left")
                                        .font(.title2)
                                    
                                }
                            )
                            .labelStyle(IconOnlyLabelStyle())
                            .padding(.horizontal)
                        }
                        
                        Spacer()
                        
                        Button {
                            selectedDate = Date.now
                        } label: {
                            Text(monthFormatter.string(from: date))
                                .foregroundColor(.blue)
                                .font(.title2)
                                .padding(2)
                        }
                        
                        Spacer()
                        
                        Button {
                            guard let newDate = calendar.date(
                                byAdding: .month,
                                value: 1,
                                to: selectedDate
                            ) else {
                                return
                            }
                            
                            selectedDate = newDate
                            
                        } label: {
                            Label(
                                title: { Text("Next") },
                                icon: {
                                    Image(systemName: "chevron.right")
                                        .font(.title2)
                                    
                                }
                            )
                            .labelStyle(IconOnlyLabelStyle())
                            .padding(.horizontal)
                        }
                    }
                }
            )
            .equatable()
            .background(Color.white)
            .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
            
        }.background(Color.gray.brightness(0.35))
    }
    
    func dateHasEvents(date: Date) -> Bool {
        
        for entry in entries {
            if calendar.isDate(date, inSameDayAs: entry.sleepStart ?? Date()) {
                return true
            }
        }
        
        return false
    }
    
    func numberOfEventsInDate(date: Date) -> Int {
        var count: Int = 0
        for entry in entries {
            if calendar.isDate(date, inSameDayAs: entry.sleepStart ?? Date()) {
                count += 1
            }
        }
        return count
    }
}

// MARK: - Component

public struct CalendarViewComponent<Day: View, Header: View, Title: View, Trailing: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @AppStorage("lastSleep") var lastSleep: Date = Date.now.addingTimeInterval(-1*60.0*60.0*24.0*14.0)
    @State var goodDuration: Int = 0
    @State var badDuration: Int = 0
    
    // Injected dependencies
    private var calendar: Calendar
    @Binding private var date: Date
    private let content: (Date) -> Day
    private let trailing: (Date) -> Trailing
    private let header: (Date) -> Header
    private let title: (Date) -> Title
    
    // Constants
    private let daysInWeek = 7
    var isLoading = false

    @FetchRequest var entries: FetchedResults<Entry>
    @FetchRequest var V0: FetchedResults<V0_main>
    
    public init(
        calendar: Calendar,
        date: Binding<Date>,
        @ViewBuilder content: @escaping (Date) -> Day,
        @ViewBuilder trailing: @escaping (Date) -> Trailing,
        @ViewBuilder header: @escaping (Date) -> Header,
        @ViewBuilder title: @escaping (Date) -> Title
    ) {
        self.calendar = calendar
        self._date = date
        self.content = content
        self.trailing = trailing
        self.header = header
        self.title = title
        
        _entries = FetchRequest<Entry>(sortDescriptors: [NSSortDescriptor(key: "sleepStart", ascending: true)],
                                       predicate: NSPredicate(
                                        format: "sleepStart >= %@ && sleepStart < %@",
                                        Calendar.current.startOfDay(for: date.wrappedValue) as CVarArg,
                                        Calendar.current.startOfDay(for: date.wrappedValue + 86400) as CVarArg))
        _V0 = FetchRequest<V0_main>(sortDescriptors: [NSSortDescriptor(key: "time", ascending: true)],
                                        predicate: NSPredicate(
                                            format: "time >= %@ && time <= %@",
                                            Calendar.current.startOfDay(for: date.wrappedValue) as CVarArg,
                                            Calendar.current.startOfDay(for: date.wrappedValue + 86400) as CVarArg))
    }
    
    public var body: some View {
        let month = date.startOfMonth(using: calendar)
        let days = makeDays()
        if isLoading{
            LoadingView()
        }else{
            VStack {
                
                Section(header: title(month)) { }
                
                VStack {
                    VStack{
                        LazyVGrid(columns: Array(repeating: GridItem(), count: daysInWeek)) {
                            ForEach(days.prefix(daysInWeek), id: \.self, content: header)
                        }
                        
                        Divider()
                        
                        LazyVGrid(columns: Array(repeating: GridItem(), count: daysInWeek)) {
                            ForEach(days, id: \.self) { date in
                                if calendar.isDate(date, equalTo: month, toGranularity: .month) {
                                    content(date)
                                } else {
                                    trailing(date)
                                }
                            }
                        }
                        
                        
                        Capsule()
                            .fill(Color.secondary)
                            .frame(width: 30, height: 3)
                            .padding(.bottom, 20)
                        
                    }.background(Color.white)
                        .cornerRadius(20)
                    
                    VStack{
                        
                        NavigationView{
                            VStack{
                                HStack{
                                    Text("내 수면")
                                        .bold()
                                        .font(.title2)
                                        .padding([.top, .leading, .trailing], 15)
                                    Spacer()
                                }
                                HStack{
                                    HStack{
                                        Image("thumbUp")
                                        VStack{
                                            Text("Positive")
                                                .font(.caption)
                                            Text("\(getTimeDuration(original: Double(goodDuration)*60.0))")
                                                .bold()
                                                .font(.title3)
                                                .foregroundColor(.green)
                                        }
                                    }.padding(10)
                                    HStack{
                                        Image("thumbDown")
                                        VStack{
                                            Text("Negative")
                                                .font(.caption)
                                            Text("\(getTimeDuration(original: Double(badDuration)*60.0))")
                                                .bold()
                                                .font(.title3)
                                                .foregroundColor(.red)
                                        }
                                    }.padding(10)
                                }
                                ZStack{
                                    VStack{
                                        List(self.entries.indices, id: \.self) { index in
                                            
                                            let sleepStart = entries[index].sleepStart!
                                            let sleepEnd = entries[index].sleepEnd!
                                            let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: entries[index].sleepEnd!)!
                                            if (index == 0) {
                                                NavigationLink{
                                                    CalendarDetailView(entry: entries[index])
                                                        .environment(\.managedObjectContext, managedObjectContext)
                                                }label:{
                                                    CalendarCardViewFirst(entry: EntryAwareness(sleepStart: sleepStart, sleepEnd: sleepEnd))
                                                }.frame(height:130)
                                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                                    .listRowSeparator(.hidden)
                                                    .background(Color(red: 0.948, green: 0.953, blue: 0.962))
                                                if index == entries.endIndex-1{
                                                    CalendarCardAwarenessView(entry: EntryAwareness(sleepStart: entries[index].sleepEnd!, sleepEnd: min(Date.now, endOfDay)))
                                                        .frame(height:110)
                                                        .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                                        .listRowSeparator(.hidden)
                                                        .background(Color(red: 0.948, green: 0.953, blue: 0.962))
                                                }
                                            }else{
                                                CalendarCardAwarenessView(entry: EntryAwareness(sleepStart: entries[index-1].sleepEnd!, sleepEnd: entries[index].sleepStart!))
                                                    .frame(height:110)
                                                    .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                                    .listRowSeparator(.hidden)
                                                    .background(Color(red: 0.948, green: 0.953, blue: 0.962))
                                                
                                                if index == entries.endIndex-1{
                                                    
                                                    if sleepEnd > endOfDay{
                                                        NavigationLink{
                                                            CalendarDetailView(entry: entries[index])
                                                                .environment(\.managedObjectContext, managedObjectContext)
                                                        }label:{
                                                            CalendarCardView(entry: EntryAwareness(sleepStart: sleepStart, sleepEnd: endOfDay))
                                                        }.frame(height:110)
                                                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                                            .listRowSeparator(.hidden)
                                                            .background(Color(red: 0.948, green: 0.953, blue: 0.962))
                                                    }else{
                                                        NavigationLink{
                                                            CalendarDetailView(entry: entries[index])
                                                                .environment(\.managedObjectContext, managedObjectContext)
                                                        }label:{
                                                            CalendarCardView(entry: EntryAwareness(sleepStart: sleepStart, sleepEnd: sleepEnd))
                                                        }.frame(height:110)
                                                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                                            .listRowSeparator(.hidden)
                                                            .background(Color(red: 0.948, green: 0.953, blue: 0.962))
                                                        CalendarCardAwarenessView(entry: EntryAwareness(sleepStart: entries[index].sleepEnd!, sleepEnd: min(Date.now, endOfDay)))
                                                            .frame(height:110)
                                                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                                            .listRowSeparator(.hidden)
                                                            .background(Color(red: 0.948, green: 0.953, blue: 0.962))
                                                    }
                                                }else{
                                                    NavigationLink{
                                                        CalendarDetailView(entry: entries[index])
                                                            .environment(\.managedObjectContext, managedObjectContext)
                                                    }label:{
                                                        CalendarCardView(entry: EntryAwareness(sleepStart: sleepStart, sleepEnd: sleepEnd))
                                                            .frame(height:110)
                                                            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0))
                                                            .listRowSeparator(.hidden)
                                                            .background(Color(red: 0.948, green: 0.953, blue: 0.962))
                                                    }
                                                }
                                            }
                                        }
                                        .cornerRadius(20)
                                    }
                                }.padding([.bottom, .leading, .trailing], 5)
                                    .cornerRadius(20)
                                    .onChange(of: date){ theDate in
                                        goodDuration = 0
                                        badDuration = 0
                                        var checkTime: [EntryAwareness] = []
                                        for idx in entries.indices{
                                            
                                            if idx > 0{
                                                checkTime.append(EntryAwareness(sleepStart: entries[idx-1].sleepEnd!, sleepEnd: entries[idx].sleepStart!))
                                            }
                                            if idx == entries.endIndex-1{
                                                let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: entries[idx].sleepEnd!)!
                                                if entries[idx].sleepEnd! > endOfDay{
                                                    continue
                                                }
                                                checkTime.append(EntryAwareness(sleepStart: entries[idx].sleepEnd!, sleepEnd: min(Date.now, endOfDay)))
                                            }
                                        }
                                        for sleepTime in checkTime{
                                            let sleepStart = sleepTime.sleepStart
                                            let sleepEnd = sleepTime.sleepEnd
                                            for tempV in V0{
                                                let tempTime = tempV.time!
                                                if tempTime >= sleepStart && tempTime <= sleepEnd{
                                                    let y_data = [tempV.y, tempV.x, tempV.n, tempV.h]
                                                    let C = 3.37*0.5*(1+coef_y*y_data[1] + coef_x * y_data[0])
                                                    let D_up = (2.46+10.2+C) //sleep thres
                                                    let awareness = D_up - y_data[3]
                                                    if awareness > 0{
                                                        goodDuration += 5
                                                    }else{
                                                        badDuration += 5
                                                    }
                                                }
                                            }
                                        }
                                    }
                                    .onAppear{
                                        goodDuration = 0
                                        badDuration = 0
                                        var checkTime: [EntryAwareness] = []
                                        for idx in entries.indices{
                                            
                                            if idx > 0{
                                                checkTime.append(EntryAwareness(sleepStart: entries[idx-1].sleepEnd!, sleepEnd: entries[idx].sleepStart!))
                                            }
                                            if idx == entries.endIndex-1{
                                                let endOfDay = calendar.date(bySettingHour: 23, minute: 59, second: 59, of: entries[idx].sleepEnd!)!
                                                if entries[idx].sleepEnd! > endOfDay{
                                                    continue
                                                }
                                                checkTime.append(EntryAwareness(sleepStart: entries[idx].sleepEnd!, sleepEnd: min(Date.now, endOfDay)))
                                            }
                                        }
                                        for sleepTime in checkTime{
                                            let sleepStart = sleepTime.sleepStart
                                            let sleepEnd = sleepTime.sleepEnd
                                            for tempV in V0{
                                                let tempTime = tempV.time!
                                                if tempTime >= sleepStart && tempTime <= sleepEnd{
                                                    let y_data = [tempV.y, tempV.x, tempV.n, tempV.h]
                                                    let C = 3.37*0.5*(1+coef_y*y_data[1] + coef_x * y_data[0])
                                                    let D_up = (2.46+10.2+C) //sleep thres
                                                    let awareness = D_up - y_data[3]
                                                    if awareness > 0{
                                                        goodDuration += 5
                                                    }else{
                                                        badDuration += 5
                                                    }
                                                }
                                            }
                                        }
                                    }
                            }
                        }
                    }.cornerRadius(20)
                        .padding([.bottom, .leading, .trailing], 10)
                        .padding([.top], 3)
                }.background(Color(red: 0.948, green: 0.953, blue: 0.962))
            }
            .onAppear{
                readSleep(from: lastSleep, to: Date.now)
                lastSleep = Date.now
            }
        }
    }
}

// MARK: - Conformances

extension CalendarViewComponent: Equatable {
    public static func == (lhs: CalendarViewComponent<Day, Header, Title, Trailing>, rhs: CalendarViewComponent<Day, Header, Title, Trailing>) -> Bool {
        lhs.calendar == rhs.calendar && lhs.date == rhs.date
    }
}

// MARK: - Helpers

private extension CalendarViewComponent {
    func makeDays() -> [Date] {
        guard let monthInterval = calendar.dateInterval(of: .month, for: date),
              let monthFirstWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.start),
              let monthLastWeek = calendar.dateInterval(of: .weekOfMonth, for: monthInterval.end - 1)
        else {
            return []
        }
        
        let dateInterval = DateInterval(start: monthFirstWeek.start, end: monthLastWeek.end)
        return calendar.generateDays(for: dateInterval)
    }
}

private extension Calendar {
    func generateDates(
        for dateInterval: DateInterval,
        matching components: DateComponents
    ) -> [Date] {
        var dates = [dateInterval.start]

        enumerateDates(
            startingAfter: dateInterval.start,
            matching: components,
            matchingPolicy: .nextTime
        ) { date, _, stop in
            guard let date = date else { return }

            guard date < dateInterval.end else {
                stop = true
                return
            }

            dates.append(date)
        }

        return dates
    }

    func generateDays(for dateInterval: DateInterval) -> [Date] {
        generateDates(
            for: dateInterval,
            matching: dateComponents([.hour, .minute, .second], from: dateInterval.start)
        )
    }
}

private extension Date {
    func startOfMonth(using calendar: Calendar) -> Date {
        calendar.date(
            from: calendar.dateComponents([.year, .month], from: self)
        ) ?? self
    }
}

private extension DateFormatter {
    convenience init(dateFormat: String, calendar: Calendar) {
        self.init()
        self.dateFormat = dateFormat
        self.calendar = calendar
    }
}

// MARK: - Previews
//
//#if DEBUG
//struct CalendarView_Previews: PreviewProvider {
//    static var previews: some View {
//        ScheduleView(calendar: Calendar(identifier: .gregorian))
//            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
//#endif

struct ScheduleView_Previews: PreviewProvider {
    static var previews: some View {
        ScheduleView(calendar: Calendar(identifier: .gregorian))
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
