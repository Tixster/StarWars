//
//  StateMachine.swift
//  StarWars
//
//  Created by Кирилл Тила on 19.07.2022.
//

import Foundation

public class StateMachine<State, Event>: ObservableObject, StateMachineProtocol where State: Equatable {

    @Published public private(set) var state: State {
        willSet {
            leave(state)
        }
        didSet {
            enter(state)
            handleStateUpdate(oldValue, new: state)
        }
    }
    
    @Published public var stateError: Error?
    
    public init(_ initialState: State) {
        self.state = initialState
    }
    
    public func handleStateUpdate(_ oldState: State, new newState: State) {
        fatalError("Override handleStateUpdate(_:, new:) before continuing.")
    }
    
    public func handle(_ event: Event) -> State? {
        fatalError("Override handleEvent(_:) before continuing.")
    }
    
    @MainActor
    public func send(_ event: Event) {
        guard let state = handle(event) else { return }
        self.state = state
    }
    
    public func leave(_ state: State) { }
    public func enter(_ state: State) { }

}
