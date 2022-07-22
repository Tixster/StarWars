//
//  Planet+CoreDataProperties.swift
//  StarWars
//
//  Created by Кирилл Тила on 23.07.2022.
//
//

import Foundation
import CoreData


extension Planet {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Planet> {
        return NSFetchRequest<Planet>(entityName: "Planet")
    }

    @NSManaged public var climate: String
    @NSManaged public var diameter: String
    @NSManaged public var gravity: String
    @NSManaged public var name: String
    @NSManaged public var population: String
    @NSManaged public var terrain: String
    @NSManaged public var homeworldToCharacter: Set<Character>

}

// MARK: Generated accessors for homeworldToCharacter
extension Planet {

    @objc(addHomeworldToCharacterObject:)
    @NSManaged public func addToHomeworldToCharacter(_ value: Character)

    @objc(removeHomeworldToCharacterObject:)
    @NSManaged public func removeFromHomeworldToCharacter(_ value: Character)

    @objc(addHomeworldToCharacter:)
    @NSManaged public func addToHomeworldToCharacter(_ values: NSSet)

    @objc(removeHomeworldToCharacter:)
    @NSManaged public func removeFromHomeworldToCharacter(_ values: NSSet)

}

extension Planet : Identifiable {

}
