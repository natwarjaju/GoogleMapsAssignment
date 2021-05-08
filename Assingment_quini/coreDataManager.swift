//
//  File.swift
//  Assingment_quini
//
//  Created by Natwar Jaju on 07/05/21.
//

import Foundation
import CoreData

class  coreDataManager {
    let persistentContainer: NSPersistentContainer

    init() {
        persistentContainer = NSPersistentContainer(name: "CoreDataModel")
        persistentContainer.loadPersistentStores {(decription, error) in
            if let error = error {
                fatalError("CoreDataManager" + error.localizedDescription)
            }
        }
    }

    func saveSearchedLocation(location: CLLocationCoordinate2D, name: String) {
        let searchedLocation = SearchedLocations(context: persistentContainer.viewContext)
        searchedLocation.name = name
        searchedLocation.latitude = location.latitude as Double
        searchedLocation.lognitude = location.longitude as Double

        do{
            try persistentContainer.viewContext.save()
        } catch {
            print("CoreDataManager:" + error.localizedDescription)
        }
    }

    func getSavedLocations() -> [SearchedLocations] {
        let fetchRequest: NSFetchRequest<SearchedLocations> = SearchedLocations.fetchRequest()

        do {
            return try persistentContainer.viewContext.fetch(fetchRequest).reversed()
        } catch {
            print("CoreDataMaager:" + error.localizedDescription)
            return []
        }
    }
    
}
