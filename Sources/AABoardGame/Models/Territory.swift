import Foundation

public typealias TerritoryID = UUID

public class Territory: Hashable, Equatable, Codable {
    public enum Category: String, Codable {
        case land
        case sea
        case inpassable
        case unknown
    }
    
    public let name: String
    public var identifier = TerritoryID()
    public var owner: AnyPlayer?
    public var units: [AnyUnit] = []
    public var adjacentTerritories: Set<TerritoryID>
    // IPCs - Industial Production Certificates
    public var industrialOutput: Int
    
//    var `type`: Territory.Category = .unknown
    
    public init(name: String, industrialOutput: Int, adjacentTerritories: Set<TerritoryID> = []) {
        self.name = name
        self.adjacentTerritories = adjacentTerritories
        self.industrialOutput = industrialOutput
    }
    
    public static func == (lhs: Territory, rhs: Territory) -> Bool {
        return lhs.name == rhs.name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
