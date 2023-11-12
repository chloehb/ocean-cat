//
//  SpaceBlenderApp.swift
//  SpaceBlender
//
//  Created by akai on 10/7/23.
//

import SwiftUI

@main
struct SpaceBlenderApp: App {
    let persistenceController = PersistenceController.shared
//    let dataController = DataController.shared
//    @StateObject private var dataController = DataController()
    
    init() {
    }
    var body: some Scene {
        WindowGroup {
            NavigationStack {
                MainView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
//                    .environment(\.managedObjectContext, dataController.container.viewContext)
            }
        }
    }
}
