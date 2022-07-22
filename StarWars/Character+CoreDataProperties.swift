//
//  Character+CoreDataProperties.swift
//  StarWars
//
//  Created by Кирилл Тила on 22.07.2022.
//
//

import Foundation
import CoreData


extension Character {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Character> {
        return NSFetchRequest<Character>(entityName: "Character")
    }

    @NSManaged public var birthYear: String
    @NSManaged public var gender: String
    @NSManaged public var index: Int16
    @NSManaged public var name: String
    @NSManaged public var homeWorldURL: String
    @NSManaged public var characterToFilm: Set<Film>
    @NSManaged public var characterToHomeworld: Planet

}

// MARK: Generated accessors for characterToFilm
extension Character {
    
    @objc(addCharacterToFilmObject:)
    @NSManaged public func addToCharacterToFilm(_ value: Film)

    @objc(removeCharacterToFilmObject:)
    @NSManaged public func removeFromCharacterToFilm(_ value: Film)

    @objc(addCharacterToFilm:)
    @NSManaged public func addToCharacterToFilm(_ values: NSSet)

    @objc(removeCharacterToFilm:)
    @NSManaged public func removeFromCharacterToFilm(_ values: NSSet)

}

extension Character : Identifiable {

}
