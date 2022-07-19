//
//  StarWarsApp.swift
//  StarWars
//
//  Created by Кирилл Тила on 19.07.2022.
//

import SwiftUI

@main
struct StarWarsApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            MainScreen(viewModel: MainViewModel())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
