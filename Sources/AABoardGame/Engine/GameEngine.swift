import Foundation
import Combine

public enum GameError: Error {
    case cannotMoveToNextPlayer
}

// germany, japany, us, uk, china, italy, commonwealth, france, russia
/*
turnsequence: 
 - Diplomatic actions (declare war),
 - purchasing units (not placed, "mobilization zone"),
 - conduct combat moves 
    (moves all units in combat moves only)-- [aircraft],
 - non-combat phase
    [aircraft (cannot land in sea zones and territories that control at the beginning of ur turn, also they can land in aircraft carries), any units that did not do combat, cant move into area where enemy is] or territory you just took.
 - Mobilization phase
        - After that it’s the Mobilization phase, where you place down your units. They must be placed in a territory where you have a major or minor industrial complex.
 - collect income
   : income tracker, bonus incomes, add up all terrirories economic value.
*/

extension Encodable {
    func encoded() -> Data? {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(self)
            return data
        } catch {
            print("Failed to encode object: \(error)")
            return nil
        }
    }
}

public class GameEngine: ObservableObject {
    private var plugins: [GameStatePluginType] = []
    private var gameState: GameStateType
    private var players: [AAPlayer] = []
    private let turnManager: TurnManager!
    
    private var board: Board {
        gameState.board
    }
    
    public init(gameState: GameStateType, plugins: [GameStatePluginType] = []) {
        self.gameState = gameState
        self.plugins = plugins
        self.turnManager = TurnManager(initialPhase: .diplomaticActions, gameState: gameState)
        startGame()
    }
    
    deinit {
        print()
    }
    
    public func startGame() {
        board.initializeBoard()
        initializePlayers()
        // Additional game start logic
        // main game loop
        
        // Declare winner
        
        subscribe()
    }
    
    private func subscribe() {
        Task {
            let eventBusStream = EventBus.shared.subscribe(
                for: .request(.getTerritory(.unitedStates)),
                .userInteraction(.selectPhase)
            )
            
            for await event in eventBusStream {
                handleEvent(event)
            }
        }
    }
    
    private func handleEvent(_ event: Event?) {
        guard let event else {
            return
        }
        
        switch event.topic {
        case .request(.getTerritory(.unitedStates)):
            let event = try? EventBus.shared.createEvent(
                from: .response(.territoryResponse(.unitedStates)),
                type: AABoardGame.Territory.self,
                encodable: AABoardGame.Territory(country: .unitedStates, industrialOutput: 77)
            )
            EventBus.shared.notify(
                topic: .response(.territoryResponse(.unitedStates)),
                event: event
            )
            
        case .userInteraction(.selectPhase):
            guard let action = event.action else {
                return
            }
            
            if turnManager.perform(action: action) {
                debugPrint("Successfully performed action")
            }
            
        case .action(_):
            break
        case .gameEvent(_):
            break
        case .userInteraction(.selectToolbar):
            break
        case .userInteraction(.selectNextPhase):
            break
        case .userInteraction(.endTurn):
            break
        case .userInteraction(.selectTerritory(_)):
            break
        case .territory(_):
            break
        case .request(.getCurrentPhase):
            break
        case .response(_):
            break
        case .userInteraction(.recenterMap):
            break
        case .userInteraction(.recenterMap):
            break
        }
    }
    
    public func initializePlayers() {
        // Assign initial territories and units (simplified)
    }
    
    public func nextTurn() throws {
        
//        let currentPlayer = players[currentPlayerIndex]
        
        // Collect resources
        //        currentPlayer.collectResources()
        
        // Deploy purchased units at the end of the current player's turn
        //        currentPlayer.deployUnits()
        
//        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
    }
    
}
