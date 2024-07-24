
public protocol TurnType: AnyObject {
    var players: [Player] { get set }
    var board: Board { get set }
    
}

open class Turn: TurnType, Codable {
    public var players: [Player]
    
    public var board: Board
    
    public init(players: [Player], board: Board) {
        self.players = players
        self.board = board
    }
}
