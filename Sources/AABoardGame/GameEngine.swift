import Foundation

public class GameEngine {
    private var board: Board
    private var players: [Player]
    private var currentPlayerIndex: Int = 0
    
    public var currentPlayer: Player {
        players[currentPlayerIndex]
    }
    
    public init(board: Board, players: [Player]) {
        self.board = board
        self.players = players
    }
    
    public func startGame() {
        board.initializeBoard()
        initializePlayers()
        // Additional game start logic
    }
    
    public func initializePlayers() {
        let player1 = players[0]
        let player2 = players[1]
        
        player1.resources = 100
        player2.resources = 100
        
        // Assign initial territories and units (simplified)
        if let easternUS = board.getTerritory(name: "Eastern United States") {
            player1.territories.insert(easternUS)
            easternUS.owner = player1
        }
        
        if let germany = board.getTerritory(name: "Germany") {
            player2.territories.insert(germany)
            germany.owner = player2
        }
    }
    
    public func nextTurn() {
        let currentPlayer = players[currentPlayerIndex]
        
        // Collect resources
        currentPlayer.collectResources()
        
        // Deploy purchased units at the end of the current player's turn
        currentPlayer.deployUnits()
        
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
    }
    
    public func handleMovement(player: Player, from: Territory, to: Territory, units: [Unit]) {
        // Validate the movement
        guard from.owner === player,
              from.adjacentTerritories.contains(to),
              units.allSatisfy({ from.units.contains($0) }) else {
            print("Invalid movement")
            return
        }
        
        // Move units
        for unit in units {
            from.removeUnit(unit: unit)
            to.addUnit(unit: unit)
        }
        
        /*

         
         */
        print("\(units.count) units moved from \(from.name) to \(to.name)")
    }
    
    public func handleCombat(attacker: Player, defender: Player, territory: Territory) {
        guard let defendingPlayer = territory.owner, defendingPlayer !== attacker else {
            print("No combat needed")
            return
        }
        
        var attackStrength = 0
        var defenseStrength = 0
        
        for unit in territory.units {
            defenseStrength += unit.defense
        }
        
        var attackerUnits = attacker.units.filter { territory.units.contains($0) }
        
        for unit in attackerUnits {
            attackStrength += unit.attack
        }
        
        let attackRolls = rollDice(numberOfDice: attackStrength)
        let defenseRolls = rollDice(numberOfDice: defenseStrength)
        
        let attackHits = calculateHits(rolls: attackRolls)
        let defenseHits = calculateHits(rolls: defenseRolls)
        
        applyHits(units: &territory.units, hits: attackHits)
        applyHits(units: &attackerUnits, hits: defenseHits)
        
        if territory.units.isEmpty {
            territory.changeOwner(newOwner: attacker)
            territory.units = Set(attackerUnits)
            print("Attacker wins the battle for \(territory.name)")
        } else {
            print("Defender holds \(territory.name)")
        }
    }
    
    public func rollDice(numberOfDice: Int) -> [Int] {
        var rolls = [Int]()
        for _ in 0..<numberOfDice {
            rolls.append(Int.random(in: 1...6))
        }
        return rolls
    }
    
    public func calculateHits(rolls: [Int]) -> Int {
        return rolls.filter { $0 <= 3 }.count  // Assume a hit is a roll of 3 or less
    }
    
    public func applyHits(units: inout Set<Unit>, hits: Int) {
        for _ in 0..<hits {
            if let unit = units.first {
                units.remove(unit)
            }
        }
    }
}
