//
//  ContentView.swift
//  StarWars
//
//  Created by Кирилл Тила on 19.07.2022.
//

import SwiftUI
import CoreData

struct MainScreen: View {

    @Environment(\.managedObjectContext) private var viewContext
    @StateObject var viewModel: MainViewModel
    
    var body: some View {
        VStack {
            switch (viewModel.state) {
            case .initial: Text("Initial")
            case .loading: Text("Loading...")
            case .empty: Text("No Results")
            case .error: Text("Error")
            case .results:
                NavigationView {
                    List {
                        ForEach(viewModel.data, id: \.id) { film in
                            NavigationLink {
                                Text(film.title)
                            } label: {
                                cell(film)
                            }
                        }
                    }
                    .navigationTitle("Star Wars Films")
                }
            }
        }
        .onAppear {
            viewModel.send(.onAppear)
        }
    }

}

private extension MainScreen {

    @ViewBuilder
    func cell(_ film: Film) -> some View {
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
