//
//  TurnManager.swift
//  AABoardGame
//
//  Created by Nick Konieczko on 7/22/24.
//

import Foundation

public protocol TurnAction {
    associatedtype Sequence: TurnSequence
    var sequence: Sequence { get }
    func perform()
}

public protocol TurnPhase {
    associatedtype SequenceType: TurnSequence
    var phase: SequenceType { get }
    var allowedActions: [any TurnAction] { get }
    func canPerform(action: any TurnAction) -> Bool
}

struct DiplomaticActionsPhase: TurnPhase {
    var phase: AATurnSequence = .diplomaticActions
    var allowedActions: [any TurnAction] = [DiplomaticAction()]

    func canPerform(action: any TurnAction) -> Bool {
        return allowedActions.contains(where: { type(of: $0) == type(of: action) })
    }
}

struct PurchasingUnitsPhase: TurnPhase {
    var phase: AATurnSequence = .purchasingUnits
    var allowedActions: [any TurnAction] = []

    func canPerform(action: any TurnAction) -> Bool {
        return allowedActions.contains(where: { type(of: $0) == type(of: action) })
    }
}

public struct DiplomaticAction: TurnAction {
    public typealias SequenceType = AATurnSequence
    public let sequence: SequenceType = .diplomaticActions
    public func perform() {
        print("Performing Diplomatic Action")
    }
}

public struct PurchasingUnitAction: TurnAction {
    public typealias SequenceType = AATurnSequence
    public let sequence: SequenceType = .purchasingUnits
    public func perform() {
        print("Performing Purchasing Unit Action")
    }
}

public struct CombatAction: TurnAction {
    public typealias SequenceType = AATurnSequence
    public let sequence: SequenceType = .combatActions
    public func perform() {
        print("Performing Combat Action")
    }
}

public struct NonCombatAction: TurnAction {
    public typealias SequenceType = AATurnSequence
    public let sequence: SequenceType = .nonCombatActions
    public func perform() {
        print("Performing Non-Combat Action")
    }
}

public protocol TurnManagerProtocol {
    var currentSequence: any TurnSequence { get }
    
    func advance() -> Bool
    func perform(action: any TurnAction) -> Bool
    func canPerform(action: any TurnAction) -> Bool
}

public class TurnManager: TurnManagerProtocol {
    private(set) public var currentSequence: any TurnSequence

    public init(initialPhase: any TurnSequence) {
        self.currentSequence = initialPhase
    }

    public func advance() -> Bool {
        do {
            currentSequence = try currentSequence.next()
        } catch {
            // Handle error
            return false
        }
        return true
    }
    
    public func perform(action: any TurnAction) -> Bool {
        if canPerform(action: action) {
            // do stuff
            return true
        } else {
            return false
        }
    }
    
    public func canPerform(action: any TurnAction) -> Bool {
        currentSequence.canPerform(action: action)
    }
}
