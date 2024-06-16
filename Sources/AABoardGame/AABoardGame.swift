import Foundation

// Unit Class
class Unit: Hashable, Equatable {
    enum UnitType: Hashable {
        case infantry, tank, fighter, bomber, battleship
    }
    
    let type: UnitType
    let attack: Int
    let defense: Int
    let movement: Int
    let cost: Int
    
    init(type: UnitType, attack: Int, defense: Int, movement: Int, cost: Int) {
        self.type = type
        self.attack = attack
        self.defense = defense
        self.movement = movement
        self.cost = cost
    }
    
    static func == (lhs: Unit, rhs: Unit) -> Bool {
        return lhs.type == rhs.type &&
        lhs.attack == rhs.attack &&
        lhs.defense == rhs.defense &&
        lhs.movement == rhs.movement &&
        lhs.cost == rhs.cost
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(attack)
        hasher.combine(defense)
        hasher.combine(movement)
        hasher.combine(cost)
    }
}

// Territory Class
class Territory: Hashable, Equatable {
    let name: String
    var owner: Player?
    var units: Set<Unit> = []
    var adjacentTerritories: Set<Territory> = []
    
    init(name: String) {
        self.name = name
    }
    
    func addUnit(unit: Unit) {
        units.insert(unit)
    }
    
    func removeUnit(unit: Unit) {
        units.remove(unit)
    }
    
    func changeOwner(newOwner: Player) {
        self.owner = newOwner
    }
    
    static func == (lhs: Territory, rhs: Territory) -> Bool {
        return lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}

// Player Class
class Player {
    let name: String
    var resources: Int
    var territories: Set<Territory> = []
    var units: Set<Unit> = []
    var purchaseQueue: [(Unit, Territory)] = []
    
    init(name: String, resources: Int) {
        self.name = name
        self.resources = resources
    }
    
    func collectResources() {
        for territory in territories {
            resources += 10  // Simplified resource collection: each territory gives 10 resources
        }
    }
    
    func purchaseUnit(unit: Unit, to territory: Territory) -> Bool {
        if resources >= unit.cost {
            resources -= unit.cost
            purchaseQueue.append((unit, territory))
            return true
        }
        return false
    }
    
    func deployUnits() {
        for (unit, territory) in purchaseQueue {
            units.insert(unit)
            territory.addUnit(unit: unit)
        }
        purchaseQueue.removeAll()
    }
}

// Board Class
class Board {
    var territories: Set<Territory> = []
    
    func initializeBoard() {
        let territoryNames = [
            "Eastern United States", "Western United States", "Central United States",
            "Canada", "Mexico", "United Kingdom", "Western Europe", "Eastern Europe",
            "Germany", "Russia", "China", "Japan", "India", "Australia",
            "Southeast Asia", "Africa", "South America"
        ]
        
        var territoryMap = [String: Territory]()
        
        for name in territoryNames {
            let territory = Territory(name: name)
            territories.insert(territory)
            territoryMap[name] = territory
        }
        
        // Define adjacencies (simplified example)
        territoryMap["Eastern United States"]?.adjacentTerritories = [territoryMap["Western United States"]!, territoryMap["Central United States"]!, territoryMap["Canada"]!]
        territoryMap["Western United States"]?.adjacentTerritories = [territoryMap["Eastern United States"]!, territoryMap["Central United States"]!, territoryMap["Mexico"]!]
        territoryMap["Central United States"]?.adjacentTerritories = [territoryMap["Eastern United States"]!, territoryMap["Western United States"]!]
        territoryMap["Canada"]?.adjacentTerritories = [territoryMap["Eastern United States"]!]
        territoryMap["Mexico"]?.adjacentTerritories = [territoryMap["Western United States"]!]
        territoryMap["United Kingdom"]?.adjacentTerritories = [territoryMap["Western Europe"]!, territoryMap["Eastern Europe"]!]
        territoryMap["Western Europe"]?.adjacentTerritories = [territoryMap["United Kingdom"]!, territoryMap["Germany"]!]
        territoryMap["Eastern Europe"]?.adjacentTerritories = [territoryMap["United Kingdom"]!, territoryMap["Germany"]!, territoryMap["Russia"]!]
        territoryMap["Germany"]?.adjacentTerritories = [territoryMap["Western Europe"]!, territoryMap["Eastern Europe"]!]
        territoryMap["Russia"]?.adjacentTerritories = [territoryMap["Eastern Europe"]!, territoryMap["China"]!]
        territoryMap["China"]?.adjacentTerritories = [territoryMap["Russia"]!, territoryMap["Japan"]!, territoryMap["India"]!]
        territoryMap["Japan"]?.adjacentTerritories = [territoryMap["China"]!, territoryMap["Southeast Asia"]!, territoryMap["Australia"]!]
        territoryMap["India"]?.adjacentTerritories = [territoryMap["China"]!, territoryMap["Southeast Asia"]!, territoryMap["Africa"]!]
        territoryMap["Australia"]?.adjacentTerritories = [territoryMap["Japan"]!, territoryMap["Southeast Asia"]!]
        territoryMap["Southeast Asia"]?.adjacentTerritories = [territoryMap["Japan"]!, territoryMap["India"]!, territoryMap["Australia"]!, territoryMap["Africa"]!]
        territoryMap["Africa"]?.adjacentTerritories = [territoryMap["Southeast Asia"]!, territoryMap["India"]!, territoryMap["South America"]!]
        territoryMap["South America"]?.adjacentTerritories = [territoryMap["Africa"]!, territoryMap["Mexico"]!]
        
        // Initial units for territories (simplified)
        territoryMap["Eastern United States"]?.addUnit(unit: Unit(type: .infantry, attack: 1, defense: 2, movement: 1, cost: 3))
        territoryMap["Germany"]?.addUnit(unit: Unit(type: .tank, attack: 3, defense: 3, movement: 2, cost: 5))
    }
    
    func getTerritory(name: String) -> Territory? {
        return territories.first(where: { $0.name == name })
    }
    
    func updateTerritory(territory: Territory) {
        // Update territory details
    }
}

// Game Engine Class
class GameEngine {
    var board: Board
    var players: [Player]
    var currentPlayerIndex: Int = 0
    
    init(board: Board, players: [Player]) {
        self.board = board
        self.players = players
    }
    
    func startGame() {
        board.initializeBoard()
        initializePlayers()
        // Additional game start logic
    }
    
    func initializePlayers() {
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
    
    func nextTurn() {
        let currentPlayer = players[currentPlayerIndex]
        
        // Collect resources
        currentPlayer.collectResources()
        
        // Deploy purchased units at the end of the current player's turn
        currentPlayer.deployUnits()
        
        currentPlayerIndex = (currentPlayerIndex + 1) % players.count
    }
    
    func handleMovement(player: Player, from: Territory, to: Territory, units: [Unit]) {
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
        print("\(units.count) units moved from \(from.name) to \(to.name)")
    }
    
    func handleCombat(attacker: Player, defender: Player, territory: Territory) {
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
    
    func rollDice(numberOfDice: Int) -> [Int] {
        var rolls = [Int]()
        for _ in 0..<numberOfDice {
            rolls.append(Int.random(in: 1...6))
        }
        return rolls
    }
    
    func calculateHits(rolls: [Int]) -> Int {
        return rolls.filter { $0 <= 3 }.count  // Assume a hit is a roll of 3 or less
    }
    
    func applyHits(units: inout Set<Unit>, hits: Int) {
        for _ in 0..<hits {
            if let unit = units.first {
                units.remove(unit)
            }
        }
    }
}

//// Example usage
//let board = Board()
//let player1 = Player(name: "Allies", resources: 100)
//let player2 = Player(name: "Axis", resources: 100)
//let gameEngine = GameEngine(board: board, players: [player1, player2])
//
//gameEngine.startGame()
