//
//  CharactersScreen.swift
//  StarWars
//
//  Created by Кирилл Тила on 22.07.2022.
//

import SwiftUI
import Networking

struct CharactersScreen: View {
    
    @StateObject var viewModel: CharactersViewModel
    
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

private extension CharactersScreen {
    
    var resultScreen: some View {
        List {
            ForEach(0..<viewModel.data.count, id: \.self) { index in
                let result = viewModel.data[index]
                NavigationLink {
                    PlanetScreen(viewModel: .init(character: getResult(from: result).resultModel,
                                                  error: getResult(from: result).resultError))
                } label: {
                    VStack {
                        switch result {
                        case .success(let model):
                            cell(model)
                        case .failure(let error):
                            Text(error.localizedDescription)
                        }
                    }
                }
            }
        }
        .navigationTitle("Star Wars: \(viewModel.filmTitle)")
    }
    
    @ViewBuilder
    func cell(_ model: CharacterModel) -> some View {
        VStack(alignment: .leading) {
            Text(model.name)
                .bold()
            Text("Gender: \(model.gender)")
            Text("Birth Year: \(model.birthYear)")
        }
    }
    
    func getResult(from result: Result<CharacterModel, HTTPRequestError>) -> (resultModel: CharacterModel?, resultError: Error?) {
        switch result {
        case .success(let resultModel):
            return (resultModel, nil)
        case .failure(let resultError):
            return (nil, resultError)
        }
    }
    
}
