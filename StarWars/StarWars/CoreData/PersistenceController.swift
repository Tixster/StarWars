//
//  PersistenceController.swift
//  StarWars
//
//  Created by Кирилл Тила on 19.07.2022.
//

import CoreData

struct PersistenceController {
    
    private init() {
        container = NSPersistentContainer(name: "StarWars")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
    
    public static let shared = PersistenceController()
    public let container: NSPersistentContainer

}

    // MARK: - FILMS METHODS
extension PersistenceController {
    
    public func saveFilms(from films: [FilmModel]) {
        films.forEach({ film in
            let filmsContext: Film = .init(context: container.viewContext)
            filmsContext.title = film.title
            filmsContext.year = film.year
            filmsContext.director = film.director
            filmsContext.producer = film.producer
            filmsContext.episode = Int16(film.episode)
            filmsContext.charactersURL = film.charactersURL
        })
        save()
    }
    
    public func getFilms() -> [FilmModel]? {
        let fetchRequest: NSFetchRequest = Film.fetchRequest()
        let sort: NSSortDescriptor = .init(key: #keyPath(Film.episode), ascending: true)
        fetchRequest.sortDescriptors = [sort]
        do {
            let films = try container.viewContext.fetch(fetchRequest)
            let filmsModels = films.map({ return FilmModel.convertFromCoreData(model: $0) })
            return films.isEmpty ? nil : filmsModels
        } catch let error as NSError {
            print("Cloud not fetch: \(error), \(error.userInfo)")
            return nil
        }
    }

}

    // MARK: - CHARACTERS METHODS
extension PersistenceController {
    
    public func saveCharacters(from models: [CharacterModel], for filmTitle: String) {
        let filmFetchRequest: NSFetchRequest = Film.fetchRequest()
        let filmPredicate: NSPredicate = .init(format: "%K == %@", #keyPath(Film.title), filmTitle)
        filmFetchRequest.predicate = filmPredicate
        do {
            let films = try container.viewContext.fetch(filmFetchRequest)
            let film = films.first!
            models.forEach({ character in
                let characterContext: Character = .init(context: container.viewContext)
                characterContext.name = character.name
                characterContext.gender = character.gender
                characterContext.birthYear = character.birthYear
                characterContext.homeWorldURL = character.homeworld
                characterContext.addToCharacterToFilm(film)
                film.addToFilmToCharaters(characterContext)
            })
            save()
        } catch let error as NSError {
            print("Cloud not fetch: \(error), \(error.userInfo)")
        }
    }
    
    public func getCharacters(for filmTitle: String) -> [CharacterModel]? {
        let fetchRequest: NSFetchRequest = Character.fetchRequest()
        let sortDescriptor: NSSortDescriptor = .init(key: #keyPath(Character.name), ascending: true)
        let predicate: NSPredicate = .init(format: "ANY characterToFilm.title = %@", filmTitle)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.predicate = predicate
        do {
            let characters = try container.viewContext.fetch(fetchRequest)
            let charactersModels = characters.map({ return CharacterModel.convertFromCoreData(model: $0) })
            return characters.isEmpty ? nil : charactersModels
        } catch let error as NSError {
            print("Cloud not fetch: \(error), \(error.userInfo)")
            return nil
        }
    }
    
}

// MARK: - PLANET METHODS
extension PersistenceController {
    
    func savePlanet(from model: PlanetModel, for characterName: String) {
        do {
            let planetContext: Planet = .init(context: container.viewContext)
            let fetchReques: NSFetchRequest = Character.fetchRequest()
            let predicate: NSPredicate = .init(format: "%K == %@", #keyPath(Character.name), characterName)
            fetchReques.predicate = predicate
            let character: Character = try container.viewContext.fetch(fetchReques).first!
            character.characterToHomeworld = planetContext
            planetContext.addToHomeworldToCharacter(character)
            planetContext.name = model.name
            planetContext.diameter = model.diameter
            planetContext.climate = model.climate
            planetContext.gravity = model.gravity
            planetContext.terrain = model.terrain
            planetContext.population = model.population
            save()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getPlanet(for characterName: String) -> PlanetModel? {
        let fetchRequest: NSFetchRequest = Planet.fetchRequest()
        let predicate: NSPredicate = .init(format: "ANY homeworldToCharacter.name = %@", characterName)
        fetchRequest.predicate = predicate
        do {
            let planets = try container.viewContext.fetch(fetchRequest)
            return planets.isEmpty ? nil : .convertFromCoreData(model: planets.first!)
        } catch let error as NSError {
            print("Cloud not fetch: \(error), \(error.userInfo)")
            return nil
        }
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
