//
//  Film+CoreDataProperties.swift
//  StarWars
//
//  Created by Кирилл Тила on 22.07.2022.
//
//

import Foundation
import CoreData


extension Film {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Film> {
        return NSFetchRequest<Film>(entityName: "Film")
    }

    @NSManaged public var director: String
    @NSManaged public var episode: Int16
    @NSManaged public var producer: String
    @NSManaged public var title: String
    @NSManaged public var year: String
    @NSManaged public var charactersURL: [String]
    @NSManaged public var filmToCharaters: Set<Character>

    public var characters: [Character] {
        let characters = filmToCharaters.sorted(by: {
            $0.name > $1.name
        })
        return characters
    }

}

// MARK: Generated accessors for filmToCharaters
extension Film {

    @objc(insertObject:inFilmToCharatersAtIndex:)
    @NSManaged public func insertIntoFilmToCharaters(_ value: Character, at idx: Int)

    @objc(removeObjectFromFilmToCharatersAtIndex:)
    @NSManaged public func removeFromFilmToCharaters(at idx: Int)

    @objc(insertFilmToCharaters:atIndexes:)
    @NSManaged public func insertIntoFilmToCharaters(_ values: [Character], at indexes: NSIndexSet)

    @objc(removeFilmToCharatersAtIndexes:)
    @NSManaged public func removeFromFilmToCharaters(at indexes: NSIndexSet)

    @objc(replaceObjectInFilmToCharatersAtIndex:withObject:)
    @NSManaged public func replaceFilmToCharaters(at idx: Int, with value: Character)

    @objc(replaceFilmToCharatersAtIndexes:withFilmToCharaters:)
    @NSManaged public func replaceFilmToCharaters(at indexes: NSIndexSet, with values: [Character])

    @objc(addFilmToCharatersObject:)
    @NSManaged public func addToFilmToCharaters(_ value: Character)

    @objc(removeFilmToCharatersObject:)
    @NSManaged public func removeFromFilmToCharaters(_ value: Character)

    @objc(addFilmToCharaters:)
    @NSManaged public func addToFilmToCharaters(_ values: NSOrderedSet)

    @objc(removeFilmToCharaters:)
    @NSManaged public func removeFromFilmToCharaters(_ values: NSOrderedSet)

}

extension Film : Identifiable {

}
