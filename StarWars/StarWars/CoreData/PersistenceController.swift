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

private extension PersistenceController {
    
    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    var backgroundContext: NSManagedObjectContext {
        return container.newBackgroundContext()
    }
    
}

    // MARK: - FILMS METHODS
extension PersistenceController {
    
    public func saveFilms(from films: [FilmModel]) {
        films.forEach({ film in
            let context = backgroundContext
            context.perform {
                let filmsContext: Film = .init(context: context)
                filmsContext.title = film.title
                filmsContext.year = film.year
                filmsContext.director = film.director
                filmsContext.producer = film.producer
                filmsContext.episode = Int16(film.episode)
                filmsContext.charactersURL = film.charactersURL
                save(context: context)
            }
        })
    }
    
    public func getFilms() -> [FilmModel]? {
        let fetchRequest: NSFetchRequest = Film.fetchRequest()
        let sort: NSSortDescriptor = .init(key: #keyPath(Film.episode), ascending: true)
        fetchRequest.sortDescriptors = [sort]
        do {
            let films = try viewContext.fetch(fetchRequest)
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
            let saveContext = backgroundContext
            let films = try saveContext.fetch(filmFetchRequest)
            let film = films.first!
            models.forEach({ character in
                saveContext.perform {
                    let characterContext: Character = .init(context: saveContext)
                    characterContext.addToCharacterToFilm(film)
                    characterContext.name = character.name
                    characterContext.gender = character.gender
                    characterContext.birthYear = character.birthYear
                    characterContext.homeWorldURL = character.homeworld
                    film.addToFilmToCharaters(characterContext)
                    save(context: saveContext)
                }
            })
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
            let characters = try viewContext.fetch(fetchRequest)
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
            let saveContext = backgroundContext
            let planetContext: Planet = .init(context: saveContext)
            let fetchReques: NSFetchRequest = Character.fetchRequest()
            let predicate: NSPredicate = .init(format: "%K == %@", #keyPath(Character.name), characterName)
            fetchReques.predicate = predicate
            let character: Character = try saveContext.fetch(fetchReques).first!
            saveContext.perform {
                planetContext.addToHomeworldToCharacter(character)
                planetContext.name = model.name
                planetContext.diameter = model.diameter
                planetContext.climate = model.climate
                planetContext.gravity = model.gravity
                planetContext.terrain = model.terrain
                planetContext.population = model.population
                character.characterToHomeworld = planetContext
                save(context: saveContext)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func getPlanet(for characterName: String) -> PlanetModel? {
        let fetchRequest: NSFetchRequest = Planet.fetchRequest()
        let predicate: NSPredicate = .init(format: "ANY homeworldToCharacter.name = %@", characterName)
        fetchRequest.predicate = predicate
        do {
            let planets = try viewContext.fetch(fetchRequest)
            return planets.isEmpty ? nil : .convertFromCoreData(model: planets.first!)
        } catch let error as NSError {
            print("Cloud not fetch: \(error), \(error.userInfo)")
            return nil
        }
    }
    
}

extension PersistenceController {
    
    public func save(context: NSManagedObjectContext = PersistenceController.shared.viewContext) {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch let error as NSError {
            print("Saving Error: \(error.userInfo)")
        }
    }

}
