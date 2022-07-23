//
//  PlanetScreen.swift
//  StarWars
//
//  Created by Кирилл Тила on 22.07.2022.
//

import SwiftUI

struct PlanetScreen: View {
    
    @StateObject var viewModel: PlanetViewModel
    
    var body: some View {
        Group {
            switch (viewModel.state) {
            case .initial, .loading: ProgressView("Loading...")
            case .empty: Text("No Results")
            case .error: Text(viewModel.stateError?.localizedDescription ?? "")
            case .results: resultScreen
            }
        }
        .onAppear {
            viewModel.send(.onAppear)
        }
    }
}

private extension PlanetScreen {
    
    var resultScreen: some View {
        VStack(alignment: .leading) {
            Text("Diameter: \(viewModel.data.diameter)")
            Text("Population: \(viewModel.data.population)")
            Text("Terrain: \(viewModel.data.terrain)")
            Text("Gravity: \(viewModel.data.gravity)")
            Text("Climate: \(viewModel.data.climate)")
        }
        .navigationTitle("Homeworld: \(viewModel.data.name)")
    }
    
}
