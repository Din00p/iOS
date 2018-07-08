//
//  DataController.swift
//  DrSOS
//
//  Created by Dinoop Raj T on 08/07/18.
//  Copyright © 2018 doctorsos. All rights reserved.
//

import UIKit
import CoreData

class DataController: NSObject {
  var managedObjectContext: NSManagedObjectContext
  init(completionClosure: @escaping () -> ()) {
    let persistentContainer = NSPersistentContainer(name: "DrSOS")
    persistentContainer.loadPersistentStores() { (description, error) in
      if let error = error {
        fatalError("Failed to load Core Data stack: \(error)")
      }
    }
    
    // This resource is the same name as your xcdatamodeld contained in your project
    guard let modelURL = Bundle.main.url(forResource: "DrSOS", withExtension:"momd") else {
      fatalError("Error loading model from bundle")
    }
    // The managed object model for the application.
    // It is a fatal error for the application not to be able to find and load its model.
    guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
      fatalError("Error initializing mom from: \(modelURL)")
    }
    
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: mom)
    
    managedObjectContext =
      NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.mainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
    
    let queue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
    queue.async {
      guard let docURL =
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last else {
          fatalError("Unable to resolve document directory")
      }
      let storeURL = docURL.appendingPathComponent("DrSOS.sqlite")
      do {
        try persistentStoreCoordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                          configurationName: nil,
                                                          at: storeURL,
                                                          options: nil)
        
        // The callback block is expected to complete the User Interface and therefore
        // should be presented back on the main queue so that the user interface does not
        // need to be concerned with which queue this call is coming from.
        DispatchQueue.main.sync(execute: completionClosure)
      } catch {
        fatalError("Error migrating store: \(error)")
      }
    }
  }
}
