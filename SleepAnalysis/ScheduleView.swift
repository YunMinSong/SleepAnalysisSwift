//
//  ScheduleView.swift
//  SleepAnalysis
//
//  Created by Reinatt Wijaya on 2022/11/06.
//

import SwiftUI
import CoreData
import HealthKit

//struct ScheduleView: View {
//    @AppStorage("clickCount") var clickCount: Int = 0
//    @State private var toggleOn: Bool = false
//
//    var body: some View {
//        VStack {
//            HStack{
//                Text("Schedule App")
//                Button(
//                    action: {clickCount = clickCount + 1},
//                    label: {Text("Click Count\(clickCount)")}
//                )
//                Spacer() //fill the space
//            }
//            Toggle(isOn: $toggleOn, label: {Text(toggleOn ? "Toggle" : "Not toggled")})
//        }
//        .padding()
//        .onAppear{
//            let FakeAPI = FakeAPI()
//            clickCount = FakeAPI.giveNumber()
//        }
//    }
//}

extension Date: RawRepresentable {
    private static let formatter = ISO8601DateFormatter()
    
    public var rawValue: String {
        Date.formatter.string(from: self)
    }
    
    public init?(rawValue: String) {
        self = Date.formatter.date(from: rawValue) ?? Date()
    }
}

struct ScheduleView: View {
    
    @AppStorage("lastSleep") var lastSleep: Date = Date.now.addingTimeInterval(-1*60.0*60.0*24.0*14.0)
    
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
        }
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

public struct CalendarDetailView: View{
    var entry : Entry
    public var body: some View{
        Text("Hi")
    }
}

public struct CalendarViewComponent<Day: View, Header: View, Title: View, Trailing: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.managedObjectContext) var managedObjectContext
    
    @AppStorage("lastSleep") var lastSleep: Date = Date.now.addingTimeInterval(-1*60.0*60.0*24.0*14.0)
    
    
    // Injected dependencies
    private var calendar: Calendar
    @Binding private var date: Date
    private let content: (Date) -> Day
    private let trailing: (Date) -> Trailing
    private let header: (Date) -> Header
    private let title: (Date) -> Title
    
    // Constants
    private let daysInWeek = 7
    
    @FetchRequest var entries: FetchedResults<Entry>
    
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
        
        _entries = FetchRequest<Entry>(sortDescriptors: [NSSortDescriptor(key: "sleepStart", ascending: false)],
                                       predicate: NSPredicate(
                                        format: "sleepStart >= %@ && sleepEnd <= %@",
                                        Calendar.current.startOfDay(for: date.wrappedValue) as CVarArg,
                                        Calendar.current.startOfDay(for: date.wrappedValue + 86400) as CVarArg))
    }
    
    public var body: some View {
        let month = date.startOfMonth(using: calendar)
        let days = makeDays()
        VStack {
            
            Section(header: title(month)) { }
            
            VStack {
                
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
                
                Button(action: {
                    print(lastSleep.description)
                    readSleep(from: lastSleep, to: Date.now)
                    lastSleep = Date.now
                }, label: {Text("Sync with Healthkit")})
                
//                Button(action: {
//                    
//                })
            }
            .frame(height: days.count == 42 ? 300 : 270)
            .shadow(color: colorScheme == .dark ? .white.opacity(0.4) : .black.opacity(0.35), radius: 5)
            
            List(entries) { entry in
                NavigationLink {
                    CalendarDetailView(entry: entry)
                } label: {
                    //                    CalendarCardView(entry: entry)
                    Text("Start of sleep: \(entry.sleepStart!.formatted(date: .omitted ,time: .shortened))")
                    Text("End of sleep: \(entry.sleepEnd!.formatted(date: .omitted, time: .shortened))")
                    Text("Duration of sleep: \(entry.sleepEnd!.timeIntervalSince(entry.sleepStart!)/60.0/60.0) hours")
                }
            }.listStyle(.plain)
        }.onAppear{
            requestSleepAuthorization()
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
