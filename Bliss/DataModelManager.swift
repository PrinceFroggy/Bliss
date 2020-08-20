//
//  DataModelManager.swift
//  Bliss
//
//  Created by Andrew Solesa on 2020-02-09.
//  Copyright © 2020 KSG. All rights reserved.
//

import CoreData


class DataModelManager
{
    private var cdStack: CDStack!
    
    var ds_context: NSManagedObjectContext!
    var ds_model: NSManagedObjectModel!
    
    var YSPackage: YSPackage?
    
    init()
    {
        cdStack = CDStack(model: self)
        ds_context = CDStack.context
        ds_model = CDStack.persistentContainer.managedObjectModel
    }
    
    func ds_save()
    {
        CDStack.save()
    }
    
}

