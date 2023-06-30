import SwiftUI
import CoreData

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
