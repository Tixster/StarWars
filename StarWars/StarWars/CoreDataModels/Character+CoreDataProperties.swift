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
    @NSManaged public var characterToFilm: Film?
    @NSManaged public var characterToHomeworld: Planet?

}

extension Character : Identifiable {

}
