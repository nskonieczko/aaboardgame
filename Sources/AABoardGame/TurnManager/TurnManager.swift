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
    var title: String { get }
    var description: String { get }
    var phase: SequenceType { get }
    var allowedActions: [any TurnAction] { get }
    func canPerform(action: any TurnAction) -> Bool
}

struct DiplomaticActionsPhase: TurnPhase {
    let title: String = "Diplomatic Action"
    let description: String = "Action Taken to be Diplomatic"
    var phase: AATurnSequence = .diplomaticActions
    var allowedActions: [any TurnAction] = [DiplomaticAction()]

    func canPerform(action: any TurnAction) -> Bool {
        return allowedActions.contains(where: { type(of: $0) == type(of: action) })
    }
}

struct PurchasingUnitsPhase: TurnPhase {
    let title: String = "Diplomatic Action"
    let description: String = "Action Taken to be Diplomatic"
    var phase: AATurnSequence = .purchasingUnits
    var allowedActions: [any TurnAction] = []

    func canPerform(action: any TurnAction) -> Bool {
        return allowedActions.contains(where: { type(of: $0) == type(of: action) })
    }
}

public struct DiplomaticAction: TurnAction {
    public typealias SequenceType = AATurnSequence
    public let sequence: SequenceType = .diplomaticActions
//    public let message: String
    // handle Russia specific things about delcaring war
    
    public func perform() {
        /*
         Any change from the starting diplomatic state.
         some start at war, if anything changes with that, that would be a diplolomatic
         strict nutrel territory
         
         this is not heavily used
         you can only make landing of pieces if
         
         landing pieces and nuetruel
         
         strict nuterul all come together once you attack.
         */
        
        
    }
}

public struct PurchasingUnitAction: TurnAction {
    public typealias SequenceType = AATurnSequence
    public let sequence: SequenceType = .purchasingUnits
    public func perform() {
        print("Performing Purchasing Unit Action")
    }
}

public struct CollectIncomeAction: TurnAction {
    public typealias SequenceType = AATurnSequence
    public let sequence: SequenceType = .mobilizeNewUnits
    public func perform() {
        print("Performing Purchasing Unit Action")
    }
}

public struct ResearchAndDevelopmentAction: TurnAction {
    public typealias SequenceType = AATurnSequence
    public let sequence: SequenceType = .mobilizeNewUnits
    public func perform() {
        print("Performing Purchasing Unit Action")
    }
}

public struct MobilizeNewUnitsAction: TurnAction {
    public typealias SequenceType = AATurnSequence
    public let sequence: SequenceType = .mobilizeNewUnits
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
    
    /*
     
     Purchasing
     
     - listing what units cost
     - collected invome from previous round.
     - J1, Japan oes their stuff, collects their IPC.
     - J2, purchase unites:
     - just buy units, facilties and research and development.
     
     */
}

public struct NonCombatAction: TurnAction {
    public typealias SequenceType = AATurnSequence
    public let sequence: SequenceType = .nonCombatActions
    public func perform() {
        print("Performing Non-Combat Action")
    }
    
    /*
     Planes are the fucky shit
     - so lets say they have 4 moves, they use 2 to move to 2 territories away. They have to to resolve in their non combat phase otherwise they lose the plane. Its just illegal to to do that.
     
     - can only activate friendly nuetrals during the non combat phase.
     - activation means - move at least one ground unit specfically into that friend nuetral. non strict nuetral
     - unfriend, friendly and strict
     - Bulgaria is a pro axis -
     - strict nuetrals:
     - Tibet is an example, no activating their units normally. you have to attack and kill the people on their. Once this happens, all other strict nuterals become pro allied or pro axis. Trip wire secenario
     - Monkey wrench time: some strict nuetral have roundals - portugal - all of these are then porugal.
     - so they are strict nuterals but, if you attack there is no trip wire.
     - So if turkey or monogolia become attacked by axis, then the remaining territories become controlled by russia (this is a real rule but just chill bro)
     */
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
            
            // Turn Sequence check: done
            // Player check: todo
            // Board Check: todo
            // Game State?: todo
            
            return true
        } else {
            return false
        }
    }
    
    public func canPerform(action: any TurnAction) -> Bool {
        currentSequence.canPerform(action: action)
    }
}
