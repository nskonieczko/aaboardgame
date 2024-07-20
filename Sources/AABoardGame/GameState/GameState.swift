import Foundation

public protocol GameStateType: AnyObject, Codable {
    var players: [AnyPlayer] { get }
    var board: Board { get }
    var gameHistory: [String] { get }
    
    func saveGame() throws -> Bool
}

public class GameState: GameStateType {
    public var board: Board
    public var players: [AnyPlayer] = []
    public var gameHistory: [String] = []
//    public var currentPhase: TurnPhase = .beginningOfTurn
    
    public init(board: Board, players: [AnyPlayer], gameHistory: [String] = []) {
        self.board = board
        self.gameHistory = gameHistory
        self.players = players
    }
    
    public func saveGame() throws -> Bool {
        return false
    }
}
