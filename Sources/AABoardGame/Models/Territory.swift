import Foundation

public class Territory: Hashable, Equatable {
    public enum Category: String {
        case land
        case sea
        case inpassable
        case unknown
    }
    
    let name: String
    var owner: Player?
    var units: Set<Unit> = []
    var adjacentTerritories: Set<Territory> = []
    var industrialOutput: Int = 0
    var `type`: Territory.Category = .unknown
    
    public init(name: String) {
        self.name = name
    }
    
    public func addUnit(unit: Unit) {
        units.insert(unit)
    }
    
    public func removeUnit(unit: Unit) {
        units.remove(unit)
    }
    
    public func changeOwner(newOwner: Player) {
        self.owner = newOwner
    }
    
    public static func == (lhs: Territory, rhs: Territory) -> Bool {
        return lhs.name == rhs.name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
