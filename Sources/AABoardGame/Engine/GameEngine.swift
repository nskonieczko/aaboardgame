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

public class GameEngine {
    private var gameState: GameStateType
    
    private var board: Board {
        gameState.board
    }
    
    public init(gameState: GameStateType) {
        self.gameState = gameState
    }
    
    public func startGame() {
        board.initializeBoard()
        initializePlayers()
        // Additional game start logic
        // main game loop
        
        while !gameState.isGameOver {
            // main game loop bruh
            
        }
    }
    
    private func subscribe() {
        do {
//            let eventBusStream: AsyncEventStream = EventBus.shared.subscribe(EndOfTurnEvent.self)
        } catch {
            debugPrint("Issue subscribing")
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
