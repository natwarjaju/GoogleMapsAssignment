//
//  Assingment_quiniApp.swift
//  Assingment_quini
//
//  Created by Natwar Jaju on 05/05/21.
//

import SwiftUI

@main
struct Assingment_quiniApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
