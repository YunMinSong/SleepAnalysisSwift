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

func readSleep(from startDate: Date?, to endDate: Date?) {
    
    let persistenceController = PersistenceController.shared
    let context = persistenceController.container.viewContext
    
    if HKHealthStore.isHealthDataAvailable(){
        let healthStore = HKHealthStore()
        
        // first, we define the object type we want
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis) else {
            return
        }
        
        // we create a predicate to filter our data
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: .strictStartDate)
        
        // I had a sortDescriptor to get the recent data first
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)
        
        // we create our query with a block completion to execute
        let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: 30, sortDescriptors: [sortDescriptor]) { (query, result, error) in
            if error != nil {
                // handle error
                return
            }
            if let result = result {
                // do something with those data
                for item in result {
                    if let sample = item as? HKCategorySample {
                        let startDate = sample.startDate
                        let endDate = sample.endDate
                        let sleepTimeForOneDay = sample.endDate.timeIntervalSince(sample.startDate)/60.0/60.0
                        print("Start: ", startDate.formatted(date: .numeric, time: .shortened))
                        print("End: ", endDate.formatted(date: .numeric, time: .shortened))
                        print("Sleep Time: ", sleepTimeForOneDay)
                        let entry = Entry(context: context)
                        entry.sleepStart = startDate
                        entry.sleepEnd = endDate
                        do {
                            try context.save()
                        } catch {
                            // handle the Core Data error
                        }
                    }
                }
            }
        }
        
        // finally, we execute our query
        healthStore.execute(query)
    }
}
