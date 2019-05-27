//
//  DataController.swift
//  VirtualTourist
//
//  Created by Waiel Eid on 25/5/19.
//  Copyright © 2019 Waiel Eid. All rights reserved.
//

import Foundation
import CoreData


class DataController {
    
    static let sharedInstance = DataController()
    
    let persistentContainer = NSPersistentContainer(name: "VirtualTourist")
    
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    func load(completion: (() -> ())? = nil) {
        persistentContainer.loadPersistentStores { (storeDescription, error) in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            completion?()
        }
    }
    
    
}
