//
//  Persistence.swift
//  StarWars
//
//  Created by Кирилл Тила on 19.07.2022.
//

import CoreData

struct PersistenceController {
    
    public static let shared = PersistenceController()
    public let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "StarWars")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }

}

extension PersistenceController {

    @discardableResult
    public func save() -> Error? {
        let conntext = container.viewContext
        if conntext.hasChanges {
            do {
                try conntext.save()
                return nil
            } catch {
                return error
            }
        }
        return nil
    }
    
}
