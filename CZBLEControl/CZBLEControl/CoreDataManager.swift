//
//  CoreDataManager.swift
//  CZBLEControl
//
//  Created by Steven Jia on 8/9/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
    static let sharedInstance = CoreDataManager()
    
    //MARK: Object management - Save Stack
    
    func saveValueData(_ title: String, dataArray: [(String, String)], completionHandler: @escaping statusMessageHandler) {
        let context = managedObjectContext
        let dataListObj = NSEntityDescription.insertNewObject(forEntityName: "DataList", into: context) as! DataList
        dataListObj.name = title
        dataListObj.listToData = NSSet(set: createDataSet(context, dataArray: dataArray, section: "Values"))
        do {
            try context.save()
            completionHandler(true, "Save data successfully")
        } catch let error as NSError {
            completionHandler(false, "Save data error: " + error.localizedDescription)
        }
    }
    
    func saveWriteAndValueData(_ title: String, writeArray: [(String, String)], valueArray: [(String, String)], completionHandler: @escaping statusMessageHandler) {
        let context = managedObjectContext
        let dataListObj = NSEntityDescription.insertNewObject(forEntityName: "DataList", into: context) as! DataList
        dataListObj.name = title
        let set = createDataSet(context, dataArray: writeArray, section: "Write values").union(createDataSet(context, dataArray: valueArray, section: "Read values"))
        dataListObj.listToData = NSSet(set: set)
        do {
            try context.save()
            completionHandler(true, "Save data successfully")
        } catch let error as NSError {
            completionHandler(false, "Save data error: " + error.localizedDescription)
        }
    }
    
    private func createDataSet(_ context: NSManagedObjectContext, dataArray: [(String, String)], section: String) -> Set<BLEData> {
        var resSet = Set<BLEData>()
        for tuple in dataArray {
            let obj = NSEntityDescription.insertNewObject(forEntityName: "BLEData", into: context) as! BLEData
            obj.dataString = tuple.0
            obj.date = tuple.1
            obj.section = section
            resSet.insert(obj)
        }
        return resSet
    }
    
    //MARK: Object management - Fetch Stack
    
    func loadBLEData(completionHandler: (_ results: [DataList]?, _ message: String) -> Void) {
        let request = NSFetchRequest<DataList>(entityName: "DataList")
        do {
            let result = try managedObjectContext.fetch(request)
            completionHandler(result, "Load data successfully")
        } catch {
            completionHandler(nil, "Load data failed")
        }
    }
    
    func deleteDataList(dataList: DataList, completionHandler: statusMessageHandler) {
        let context = managedObjectContext
        context.delete(dataList)
        do {
            try context.save()
            completionHandler(true, "Save data successfully")
        } catch let error as NSError {
            completionHandler(false, "Save data error: " + error.localizedDescription)
        }
    }
    
    // MARK: - Core Data stack
    
    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "ChengzhiJia.CZBLEControl" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "CZBLEControl", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            
            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }
    
    
}
