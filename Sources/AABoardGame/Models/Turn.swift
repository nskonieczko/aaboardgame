
public protocol TurnType: AnyObject {
    var players: [AnyPlayer] { get set }
    var board: Board { get set }
    
}

open class Turn: TurnType, Codable {
    public var players: [AnyPlayer]
    
    public var board: Board
    
    public init(players: [AnyPlayer], board: Board) {
        self.players = players
        self.board = board
    }
}
