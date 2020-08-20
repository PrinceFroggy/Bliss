//
//  CDStack.swift
//  Bliss
//
//  Created by Andrew Solesa on 2020-02-09.
//  Copyright © 2020 KSG. All rights reserved.
//

import CoreData

class CDStack
{
    static var context = persistentContainer.viewContext
    
    static var persistentContainer: NSPersistentContainer =
    {
        let container = NSPersistentContainer(name: "Bliss")
        container.loadPersistentStores(completionHandler:
        { (storeDescription, error) in
            if let error = error as NSError?
            {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    init(model: DataModelManager)
    {
        
    }
    
    static func save()
    {
        let managedObjectContext = persistentContainer.viewContext
        
        if managedObjectContext.hasChanges
        {
            do
            {
                try managedObjectContext.save()
                print("CDStack Saved")
            }
            catch let error as NSError
            {
                if let details = error.userInfo["NSDetailedErrors"] as? [NSError]
                {
                    for detail in details
                    {
                        if let _ = detail.userInfo["NSValidationErrorKey"], let _ = detail.userInfo["NSValidationErrorObject"]
                        {
                            print("Error on save")
                        }
                    }
                }
                fatalError("CDStack save error \(error), \(error.userInfo)")
            }
        }
    }
    
    static func fetchRecordsForEntity(_ entity: String, inManagedObjectContext managedObjectContext: NSManagedObjectContext) -> [NSManagedObject] {
        // Create Fetch Request
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)

        // Helpers
        var result = [NSManagedObject]()

        do {
            // Execute Fetch Request
            
            let records = try CDStack.context.fetch(fetchRequest)

            if let records = records as? [NSManagedObject] {
                result = records
            }

        } catch {
            print("Unable to fetch managed objects for entity \(entity).")
        }

        return result
    }
    
}
