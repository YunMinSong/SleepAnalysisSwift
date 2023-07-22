import SwiftUI
import CoreData

func toLocalTime(date: Date) -> Date {
        
        // 1) Get the current TimeZone's seconds from GMT. Since I am in Chicago this will be: 60*60*5 (18000)
        let timezoneOffset = TimeZone.current.secondsFromGMT()
        
        // 2) Get the current date (GMT) in seconds since 1970. Epoch datetime.
        let epochDate = date.timeIntervalSince1970
        
        // 3) Perform a calculation with timezoneOffset + epochDate to get the total seconds for the
        //    local date since 1970.
        //    This may look a bit strange, but since timezoneOffset is given as -18000.0, adding epochDate and timezoneOffset
        //    calculates correctly.
        let timezoneEpochOffset = (epochDate + Double(timezoneOffset))
        
        
        // 4) Finally, create a date using the seconds offset since 1970 for the local date.
        return Date(timeIntervalSince1970: timezoneEpochOffset)
    }

func updateGoodBadDuration(startDate: Date, endDate: Date, entries: FetchedResults<Entry>, V0: FetchedResults<V0_main>, awareness: FetchedResults<Awareness>){
    
    let persistenceController = PersistenceController.shared
    let context = persistenceController.container.viewContext
    
    let startDateMorning = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: startDate)!
    let endDateNight = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: endDate)!
    
    for aware in awareness{
        if startDateMorning <= aware.date! && aware.date! <= endDateNight{
            context.delete(aware)
        }
    }
    
    var goodDuration = 0
    var badDuration = 0
    var checkTime: [EntryAwareness] = []
    for idx in entries.indices{
        
        let endDateNight = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: entries[idx].sleepEnd!)
        let EendDate = Calendar.current.dateComponents([.year, .month, .day],from: entries[idx].sleepEnd!)
        
        if(idx == entries.endIndex-1){
            checkTime.append(EntryAwareness(sleepStart: entries[idx].sleepEnd!, sleepEnd: endDateNight!))
            goodDuration = 0
            badDuration = 0
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
            checkTime = []
            
            let entry = Awareness(context: context)
            entry.date = Calendar.current.date(from:EendDate)
            entry.goodDuration = Int64(goodDuration)
            entry.badDuration = Int64(badDuration)
            
            if context.hasChanges{
                do {
                    try context.save()
                } catch let nserror as NSError{
                    // handle the Core Data error
                    print("Unresolved error \(nserror), \(nserror.userInfo)")
                    
                }
            }
            break
        }
        let startDateMorningNext = Calendar.current.date(bySettingHour: 0, minute: 0, second: 0, of: entries[idx+1].sleepStart!)
        let EstartDateTomorrow = Calendar.current.dateComponents([.year, .month, .day],from: entries[idx+1].sleepStart!)

        if (EstartDateTomorrow != EendDate){
            checkTime.append(EntryAwareness(sleepStart: entries[idx].sleepEnd!, sleepEnd: endDateNight!))
            goodDuration = 0
            badDuration = 0
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
            checkTime = []
            
            let entry = Awareness(context: context)
            entry.date = Calendar.current.date(from:EendDate)
            entry.goodDuration = Int64(goodDuration)
            entry.badDuration = Int64(badDuration)
            
            if context.hasChanges{
                do {
                    try context.save()
                } catch let nserror as NSError{
                    // handle the Core Data error
                    print("Unresolved error \(nserror), \(nserror.userInfo)")
                    
                }
            }
            checkTime.append(EntryAwareness(sleepStart: startDateMorningNext!, sleepEnd: entries[idx+1].sleepStart!))
        }else{
            checkTime.append(EntryAwareness(sleepStart: entries[idx].sleepEnd!, sleepEnd: entries[idx+1].sleepStart!))
        }
    }
    
    
}

func updateOnsetDate(current_time: Date, sleep_onset: Date, work_onset: Date, work_offset: Date)->(Date, Date, Date){
    if sleep_onset <= current_time && current_time <= work_onset{
        return (current_time.addingTimeInterval(60*10), work_onset, work_offset)
    }
    if work_onset <= current_time && current_time <= work_offset{
        var new_sleep_onset = sleep_onset
        let new_work_onset = work_onset
        let new_work_offset = work_offset
        while new_sleep_onset < current_time{
            new_sleep_onset = new_sleep_onset.addingTimeInterval(60*60*24.0)
        }
        while new_work_onset < new_sleep_onset{
            new_sleep_onset = new_sleep_onset.addingTimeInterval(60*60*24.0)
        }
        while new_work_offset < new_work_onset{
            new_sleep_onset = new_sleep_onset.addingTimeInterval(60*60*24.0)
        }
        return (new_sleep_onset, new_work_onset, new_work_offset)
    }
    return (sleep_onset, work_onset, work_offset)
    
}

func doUpdate(needUpdate: Bool, lastUpdated: Date)->Bool{
    if needUpdate{
        return true
    }
    if Date.now.timeIntervalSince(lastUpdated) > 60.0*60.0*2{
        return true
    }
    return false
}
