import Foundation

public protocol GameStateType: AnyObject, Codable {
    var players: [Player] { get }
    var board: Board { get }
    var gameHistory: [String] { get }
    var isGameOver: Bool { get }
    
    func saveGame() throws -> Bool
}

public class GameState<Turn: TurnSequence>: GameStateType {
    public var board: Board
    public var players: [Player] = []
    public var gameHistory: [String] = []
    public var turnSequence: Turn

    public var isGameOver: Bool {
        false
    }
    
    public init(board: Board,
                players: [Player],
                gameHistory: [String] = [],
                turnSequence: Turn) {
        
        self.board = board
        self.gameHistory = gameHistory
        self.players = players
        self.turnSequence = turnSequence
    }
    
    public func saveGame() throws -> Bool {
        return false
    }
}

public protocol GameStatePluginType {
    var id: UUID { get }
    var dependencies: [UUID] { get }
    
    func isEndOfGame(with gameState: GameStateType) -> Bool
}
