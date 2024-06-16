import XCTest
@testable import AABoardGame

final class AABoardGameTests: XCTestCase {
    var board: Board!
    var player1: Player!
    var player2: Player!
    var gameEngine: GameEngine!
    
    override func setUp() {
        board = Board()
        player1 = Player(name: "Allies", resources: 100)
        player2 = Player(name: "Axis", resources: 100)
        gameEngine = GameEngine(board: board, players: [player1, player2])
    }
    
    func testExample() throws {
        gameEngine.startGame()
        
        gameEngine.nextTurn()
    }
}
