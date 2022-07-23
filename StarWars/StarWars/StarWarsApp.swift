//
//  StarWarsApp.swift
//  StarWars
//
//  Created by Кирилл Тила on 19.07.2022.
//

import SwiftUI

@main
struct StarWarsApp: App {
    
    @Environment(\.scenePhase) var scenePhase
    
    private var persistenceController: PersistenceController {
        return .shared
    }
    
    var body: some Scene {
        WindowGroup {
            MainScreen(viewModel: MainViewModel())
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .background: persistenceController.save()
            case .inactive: persistenceController.save()
            case .active: return
            @unknown default: return
            }
        }
    }
 
}
