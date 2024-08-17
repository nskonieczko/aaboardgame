import Foundation

public protocol GameStateType: AnyObject, Codable {
    var players: [Player] { get }
    var board: Board { get }
    var gameHistory: [String] { get }
    var isGameOver: Bool { get }
    var turnCount: Int { get }
    var currentTurnSequence: AATurnSequence { get }
    
    func saveGame() throws -> Bool
}

public class GameState<Turn: TurnSequence>: GameStateType {
    public var turnCount: Int = 0
    public var currentTurnSequence: AATurnSequence = .diplomaticActions
    public var board: Board
    public var players: [Player] = []
    public var gameHistory: [String] = []
    public var turnSequence: Turn
    private var plugins: [GameStatePluginType]
    public var wars: Set<(Country, Country)> = []

    func declareWar(between country1: Country, and country2: Country) {
        wars.insert((country1, country2))
    }

    func isAtWar(_ country1: Country, with country2: Country) -> Bool {
        return wars.contains((country1, country2)) || wars.contains((country2, country1))
    }

    public var isGameOver: Bool {
        plugins.reduce(false) { isGameOver, plugin in
            isGameOver || plugin.isEndOfGame(with: self)
        }
    }
    
    public init(board: Board,
                players: [Player],
                gameHistory: [String] = [],
                turnSequence: Turn,
                plugins: [GameStatePluginType] = []) {
        
        self.board = board
        self.gameHistory = gameHistory
        self.players = players
        self.turnSequence = turnSequence
        self.plugins = plugins
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(board, forKey: .board)
        try container.encode(players, forKey: .players)
        try container.encode(gameHistory, forKey: .gameHistory)
        try container.encode(turnSequence, forKey: .turnSequence)
    }

    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.board = try container.decode(Board.self, forKey: .board)
        self.players = try container.decode([Player].self, forKey: .players)
        self.gameHistory = try container.decode([String].self, forKey: .gameHistory)
        self.turnSequence = try container.decode(Turn.self, forKey: .turnSequence)
        self.plugins = []
    }

    private enum CodingKeys: String, CodingKey {
        case board
        case players
        case gameHistory
        case turnSequence
        case plugins
    }
    
    public func saveGame() throws -> Bool {
        return false
    }
}

public protocol GameStatePluginType: Codable {
    var id: UUID { get }
    var dependencies: [UUID] { get }
    
    func isEndOfGame(with gameState: GameStateType) -> Bool
}

class AxisVictoryPointsPlugin: GameStatePluginType {
    var id: UUID
    var dependencies: [UUID]
    private let state: GameStateType

    init(id: UUID, dependencies: [UUID] = [], state: GameStateType) {
        self.id = id
        self.dependencies = dependencies
        self.state = state
    }
    
    func isEndOfGame(with gameState: GameStateType) -> Bool {
        let totalAxisVictoryPoints = gameState.players
            .filter { Country.axis.contains($0.country) }
            .reduce(0) { $0 + $1.victoryPoints }
        
        return totalAxisVictoryPoints >= 13
        && state.turnCount == 8
        && state.currentTurnSequence == .collectIncome
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decode(UUID.self, forKey: .id)
        self.dependencies = try container.decode([UUID].self, forKey: .dependencies)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(dependencies, forKey: .dependencies)
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case dependencies
    }
}

