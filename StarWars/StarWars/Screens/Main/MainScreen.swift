//
//  ContentView.swift
//  StarWars
//
//  Created by Кирилл Тила on 19.07.2022.
//

import SwiftUI
import CoreData

struct MainScreen: View {

    @StateObject var viewModel: MainViewModel
    
    var body: some View {
        VStack {
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

private extension MainScreen {
    
    var resultScreen: some View {
        NavigationView {
            List {
                ForEach(viewModel.data, id: \.id) { film in
                    NavigationLink {
                        CharactersScreen(viewModel: .init(networkdService: viewModel.networkService,
                                                          film: film))
                    } label: {
                        VStack {
                            cell(.init(title: film.title,
                                       year: film.year,
                                       director: film.director,
                                       producer: film.producer,
                                       episode: film.episode,
                                       charactersURL: film.charactersURL))
                        }
                    }
                }
            }
            .navigationTitle("Star Wars Films")
        }
    }

    @ViewBuilder
    func cell(_ film: FilmModel) -> some View {
        VStack(alignment: .leading) {
            Text(film.title)
                .bold()
            + Text(" \(film.episode)")
            Text("Director: \(film.director)")
            Text("Producer: \(film.producer)")
            Text("Year: ") +
            Text(film.year)
                .italic()
                .foregroundColor(.red)
        }
        .multilineTextAlignment(.leading)
    }

}

struct MainScreen_Previews: PreviewProvider {
    static var previews: some View {
        MainScreen(viewModel: MainViewModel())
            .environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
    }
}
