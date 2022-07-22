//
//  CharactersScreen.swift
//  StarWars
//
//  Created by Кирилл Тила on 22.07.2022.
//

import SwiftUI

struct CharactersScreen: View {
    
    @StateObject var viewModel: CharactersViewModel
    
    var body: some View {
        Group {
            switch (viewModel.state) {
            case .initial: Text("Initial")
            case .loading: ProgressView("Loading...")
            case .empty: Text("No Results")
            case .error: Text(viewModel.stateError?.localizedDescription ?? "")
            case .results:
                List {
                    ForEach(0..<viewModel.data.count, id: \.self) { index in
                        NavigationLink {
                            Text("1234")
                        } label: {
                            VStack {
                                let result = viewModel.data[index]
                                switch result {
                                case .success(let model):
                                    VStack(alignment: .leading) {
                                        Text(model.name)
                                            .bold()
                                        Text("Gender: \(model.gender)")
                                        Text("Birth Year: \(model.birthYear)")
                                    }
                                    
                                case .failure(let error):
                                    Text(error.localizedDescription)
                                }
                            }
                        }
                    }
                }
                .navigationTitle("Star Wars Characters")
            }

        }
        .onAppear {
            viewModel.send(.onAppear)
        }
    }
}
