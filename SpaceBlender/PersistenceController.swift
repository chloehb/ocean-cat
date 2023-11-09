//
//  PersistanceController.swift
//  SpaceBlender
//
//  Created by akai on 10/27/23.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "AllData")

        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                fatalError("Error: \(error)")
            }
        }
    }
}
