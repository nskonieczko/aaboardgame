import Foundation

public class Unit: Hashable, Equatable {
    public enum UnitType: Hashable {
        case infantry, tank, fighter, bomber, battleship
    }
    
    let type: UnitType
    let attack: Int
    let defense: Int
    let movement: Int
    let cost: Int
    
    public init(type: UnitType, attack: Int, defense: Int, movement: Int, cost: Int) {
        self.type = type
        self.attack = attack
        self.defense = defense
        self.movement = movement
        self.cost = cost
    }
    
    public static func == (lhs: Unit, rhs: Unit) -> Bool {
        return lhs.type == rhs.type &&
        lhs.attack == rhs.attack &&
        lhs.defense == rhs.defense &&
        lhs.movement == rhs.movement &&
        lhs.cost == rhs.cost
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(type)
        hasher.combine(attack)
        hasher.combine(defense)
        hasher.combine(movement)
        hasher.combine(cost)
    }
}
