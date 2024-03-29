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
                                .cornerRadius(100)
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
                                .foregroundColor(.black)
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
            
        }.background(Color.white)
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
    @State var addButton: Bool = false
    
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
    
    @FetchRequest var fullEntries: FetchedResults<Entry>
    @FetchRequest var entries: FetchedResults<Entry>
    @FetchRequest var fullV0: FetchedResults<V0_main>
    @FetchRequest var V0: FetchedResults<V0_main>
    @FetchRequest var awareness: FetchedResults<Awareness>
    
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
        _awareness = FetchRequest<Awareness>(sortDescriptors: [NSSortDescriptor(key: "date", ascending: true)])
        _fullV0 = FetchRequest<V0_main>(sortDescriptors: [NSSortDescriptor(key: "time", ascending: true)])
        _fullEntries = FetchRequest<Entry>(sortDescriptors: [NSSortDescriptor(key: "sleepStart", ascending: true)])
    }
    
    public var body: some View {
        let month = date.startOfMonth(using: calendar)
        let days = makeDays()
        if isLoading{
            LoadingView()
        }else{
            ScrollView() {
                VStack {
                    ScheduleHeaderView()
                        .padding()
                        .background(.white)
                    
                    Section(header: title(month)) { }
                        .padding(.horizontal)
                        .padding(.vertical, 5.0)
                        .foregroundColor(.black)
                    
                    VStack {
                        VStack{
                            LazyVGrid(columns: Array(repeating: GridItem(), count: daysInWeek)) {
                                ForEach(days.prefix(daysInWeek), id: \.self, content: header)
                            }.padding(.top, 10.0)
                            
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
                                .fill(Color.black)
                                .frame(width: 56, height: 3)
                                .padding(.bottom, 20)
                            
                        }.background(Color.white)
                            .cornerRadius(16)
                            .padding()
                        
                        VStack{
                            
                            NavigationView{
                                VStack{
                                    HStack{
                                        Text("내 수면")
                                            .bold()
                                            .font(.title2)
                                            .padding([.top, .leading, .trailing], 15)
                                        Spacer()
                                        NavigationLink{
                                            AddSleepView()
                                        }label:{
                                            Image("plus").resizable().scaledToFit()
                                                .frame(width:30, height: 30)
                                                .padding()
                                        }
                                        
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
                                            .cornerRadius(16)
                                        }
                                    }.padding([.bottom, .leading, .trailing], 5)
                                        .cornerRadius(14)
                                    }
                                }.onChange(of: date){ theDate in
                                        goodDuration = 0
                                        badDuration = 0
                                        for aware in awareness{
                                            let awareDate = Calendar.current.dateComponents([.year, .month, .day],from: aware.date!)
                                            let currentDate = Calendar.current.dateComponents([.year, .month, .day], from: theDate)
                                            if awareDate == currentDate{
                                                goodDuration = Int(aware.goodDuration)
                                                badDuration = Int(aware.badDuration)
                                                break
                                            }
                                        }
                                    }
                                    .onAppear{
                                        goodDuration = 0
                                        badDuration = 0
                                        for aware in awareness{
                                            let awareDate = Calendar.current.dateComponents([.year, .month, .day],from: aware.date!)
                                            let currentDate = Calendar.current.dateComponents([.year, .month, .day], from: date)
                                            if awareDate == currentDate{
                                                goodDuration = Int(aware.goodDuration)
                                                badDuration = Int(aware.badDuration)
                                                break
                                            }
                                        }
                                }
                        }.cornerRadius(16)
                            .padding([.leading, .bottom, .trailing])
                        }
                    }.background(Color(red: 0.948, green: 0.953, blue: 0.962))
                }
                .onAppear{
                    readSleep(from: lastSleep, to: Date.now)
                    lastSleep = Date.now
                    updateGoodBadDuration(startDate: Date.now.addingTimeInterval(-1*60*60*24*14) , endDate:Date.now, entries: fullEntries, V0: fullV0, awareness: awareness)
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
