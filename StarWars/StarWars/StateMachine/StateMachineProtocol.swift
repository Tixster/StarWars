//
//  StateMachineProtocol.swift
//  StarWars
//
//  Created by Кирилл Тила on 19.07.2022.
//

import Foundation

protocol StateMachineProtocol {
    associatedtype State: Equatable
    associatedtype Event
    
    var state: State { get }
    var stateError: Error? { get set }
    
    func handleStateUpdate(_ oldState: State, new newState: State)
    func handle(_ event: Event) -> State?
    func send(_ event: Event)
    func leave(_ state: State)
    func enter(_ state: State)
}
