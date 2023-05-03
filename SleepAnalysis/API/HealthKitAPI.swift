//
//  HealthKitAPI.swift
//  SleepAnalysis
//
//  Created by Reinatt Wijaya on 2022/11/11.
//

import HealthKit
import CoreData

func requestSleepAuthorization() {
    
    if HKHealthStore.isHealthDataAvailable(){
        let healthStore = HKHealthStore()
        if let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) {
            let setType = Set<HKSampleType>(arrayLiteral: sleepType)
            healthStore.requestAuthorization(toShare: setType, read: setType) { (success, error) in
                
                if !success || error != nil {
                    // handle error
                    return
                }
                
                // handle success
            }
        }
    }
}

func readSleep(from startDateQ: Date?, to endDateQ: Date?) {
    
    let persistenceController = PersistenceController.shared
    let context = persistenceController.container.viewContext
    
    
    if HKHealthStore.isHealthDataAvailable(){
        let healthStore = HKHealthStore()
        
        // first, we define the object type we want
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            return
        }
        
        // we create a predicate to filter our data
        let predicate = HKQuery.predicateForSamples(withStart: startDateQ!, end: endDateQ!, options: .strictStartDate)
        
        // I had a sortDescriptor to get the recent data first
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: true)
        
        // we create our query with a block completion to execute
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 500, sortDescriptors: [sortDescriptor]) { (query, result, error) in
            if error != nil {
                // handle error
                return
            }
            if let result = result {
                // do something with those data
                var gSleepStart : Date = Date(timeIntervalSince1970: 0)
                var gSleepEnd : Date = Date(timeIntervalSince1970: 0)
                let check: Date = gSleepStart
                for item in result {
                    if let sample = item as? HKCategorySample {
                        
                        //init
                        let startDate = sample.startDate
                        let endDate = sample.endDate
                        
                        if gSleepStart == check {
                            gSleepStart = startDate
                            gSleepEnd = endDate
                            continue
                        }
                        
                        //check with g values
                        let distanceWithG = startDate.timeIntervalSince(gSleepEnd)
                        //if the distance is less than half an hour, update the end date
                        if distanceWithG <= 1800.0{
                            gSleepEnd = endDate
                            continue
                        }
                        
                        //if it is not, then save g values and set g values to the next startDate
                        let entry = Entry(context: context)
                        entry.sleepStart = gSleepStart
                        entry.sleepEnd = gSleepEnd
                        
                        if context.hasChanges{
                            do {
                                try context.save()
                            } catch let nserror as NSError{
                                // handle the Core Data error
                                print("Unresolved error \(nserror), \(nserror.userInfo)")
                                
                            }
                        }
                        
                        gSleepStart = startDate
                        gSleepEnd = endDate
                    }
                }
                let entry = Entry(context: context)
                entry.sleepStart = gSleepStart
                entry.sleepEnd = gSleepEnd

                if gSleepStart != check && gSleepEnd.timeIntervalSince(gSleepStart) > 1800.0{
                    do {
                        try context.save()
                    } catch {
                        // handle the Core Data error
                    }
                }
            }
        }
        
        // finally, we execute our query
        healthStore.execute(query)
    }
}
