//
//  TurnManager.swift
//  AABoardGame
//
//  Created by Nick Konieczko on 7/22/24.
//

import Foundation

public protocol TurnActionType: Sendable, Codable, Hashable {
    associatedtype Sequence: TurnSequence
    var runnableDuringSequence: Sequence { get }
    var id: UUID { get }
    func perform()
}


open class TurnAction: TurnActionType {
    public typealias Sequence = AATurnSequence
    public var runnableDuringSequence: Sequence
    public let id: UUID = UUID()
    
    public init(sequence: Sequence) {
        self.runnableDuringSequence = sequence
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(runnableDuringSequence)
    }
    
    public func perform() {}
}

extension TurnAction: Equatable {
    public static func == (lhs: TurnAction, rhs: TurnAction) -> Bool {
        lhs.id == rhs.id
    }
}

public protocol TurnPhase {
    associatedtype SequenceType: TurnSequence
    var title: String { get }
    var description: String { get }
    var phase: SequenceType { get }
    var allowedActions: [any TurnActionType] { get }
    func canPerform(action: any TurnActionType) -> Bool
}

public class ChangePhaseAction: TurnAction {
    public var toSequence: AATurnSequence
    
    public init(to sequence: AATurnSequence) {
        self.toSequence = sequence
        super.init(sequence: sequence)
    }
    
    required init(from decoder: any Decoder) throws {
        fatalError("init(from:) has not been implemented")
    }
    
    override public func perform() {
        let event = try? EventBus.shared.createEvent(
            from: .gameEvent(.playerPhaseChanged),
            encodable: toSequence
        )
        EventBus.shared.notify(topic: .gameEvent(.playerPhaseChanged), event: event)
    }
}

struct DiplomaticActionsPhase: TurnPhase {
    let title: String = "Diplomatic Action"
    let description: String = "Action Taken to be Diplomatic"
    var phase: AATurnSequence = .diplomaticActions
    var allowedActions: [any TurnActionType] = [DiplomaticAction()]
    
    func canPerform(action: any TurnActionType) -> Bool {
        return allowedActions.contains(where: { type(of: $0) == type(of: action) })
    }
}

struct PurchasingUnitsPhase: TurnPhase {
    let title: String = "Diplomatic Action"
    let description: String = "Action Taken to be Diplomatic"
    var phase: AATurnSequence = .purchasingUnits
    var allowedActions: [any TurnActionType] = []
    
    func canPerform(action: any TurnActionType) -> Bool {
        return allowedActions.contains(where: { type(of: $0) == type(of: action) })
    }
}

public struct DiplomaticAction: TurnActionType {
    public typealias SequenceType = AATurnSequence
    public let runnableDuringSequence: SequenceType = .diplomaticActions
    public let id: UUID = UUID()
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

public struct PurchasingUnitAction: TurnActionType {
    public typealias SequenceType = AATurnSequence
    public let runnableDuringSequence: SequenceType = .purchasingUnits
    public let id: UUID = UUID()
    
    public func perform() {
        print("Performing Purchasing Unit Action")
    }
}

public struct CollectIncomeAction: TurnActionType {
    public let id: UUID = UUID()
    public typealias SequenceType = AATurnSequence
    public let runnableDuringSequence: SequenceType = .mobilizeNewUnits
    public func perform() {
        print("Performing Purchasing Unit Action")
    }
}

public struct ResearchAndDevelopmentAction: TurnActionType {
    public let id: UUID = UUID()
    public typealias SequenceType = AATurnSequence
    public let runnableDuringSequence: SequenceType = .mobilizeNewUnits
    public func perform() {
        print("Performing Purchasing Unit Action")
    }
}

public struct MobilizeNewUnitsAction: TurnActionType {
    public let id: UUID = UUID()
    public typealias SequenceType = AATurnSequence
    public let runnableDuringSequence: SequenceType = .mobilizeNewUnits
    public func perform() {
        print("Performing Purchasing Unit Action")
    }
}

public struct CombatAction: TurnActionType {
    public let id: UUID = UUID()
    public typealias SequenceType = AATurnSequence
    public let runnableDuringSequence: SequenceType = .combatActions
    
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

public struct NonCombatAction: TurnActionType {
    public let id: UUID = UUID()
    public typealias SequenceType = AATurnSequence
    public let runnableDuringSequence: SequenceType = .nonCombatActions
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
    var currentSequence: AATurnSequence { get }
    
    func advance() -> Bool
    func perform(action: TurnAction) -> Bool
    func canPerform(action: TurnAction) -> Bool
}

public class TurnManager: TurnManagerProtocol {
    private(set) public var currentSequence: AATurnSequence
    private let gameState: GameStateType
    
    public init(initialPhase: AATurnSequence, gameState: GameStateType) {
        self.currentSequence = initialPhase
        self.gameState = gameState
        
        Task {
            await listeners()
        }
    }
    
    public func advance() -> Bool {
        do {
            currentSequence = try currentSequence.next() as! AATurnSequence
        } catch {
            // Handle error
            return false
        }
        return true
    }
    
    public func perform(action: TurnAction) -> Bool {
        if canPerform(action: action) {
            // do stuff
            
            // Turn Sequence check: done
            // Player check: todo
            // Board Check: todo
            // Game State?: todo
            switch action {
            case action as ChangePhaseAction:
                guard let newAction = action as? ChangePhaseAction else {
                    return false
                }
                
                currentSequence = newAction.toSequence
                gameState.currentTurnSequence = newAction.toSequence
                newAction.perform()
                return true
                
            default:
                fatalError("You did not implement the \(action) case")
            }
            
            return true
        } else {
            return false
        }
    }
    
    public func canPerform(action: TurnAction) -> Bool {
        if action is ChangePhaseAction {
            return true
        }
        
        guard action.runnableDuringSequence == currentSequence else {
            return false
        }
        
        return true
    }
    
    private func listeners() async {
        let stream = EventBus.shared.subscribe(for: .request(.getCurrentPhase), .userInteraction(.selectPhase))
        
        Task {
            do {
                for await event in stream {
                    let eventResponse = try EventBus.shared.createEvent(
                        from: .response(.currentPhaseResponse),
                        type: AATurnSequence.self,
                        encodable: currentSequence
                    )
                    
                    EventBus.shared.notify(topic: .response(.currentPhaseResponse), event: eventResponse)
                }
            } catch {
                print("Error handling event: \(error)")
            }
        }
    }
}
