import Foundation

public typealias TerritoryID = UUID

public class Territory: Hashable, Equatable, Codable {
    public enum Category: String, Codable {
        case land
        case sea
        case inpassable
        case unknown
    }
    
    public let country: Country
    public var name: String {
        country.rawValue
    }
    public var identifier = TerritoryID()
    public var owner: Player?
    public var units: [AnyUnit] = []
    public var adjacentTerritories: Set<TerritoryID>
    // IPCs - Industial Production Certificates
    public var industrialOutput: Int {
        country.industrialOutput
    }
    
//    var `type`: Territory.Category = .unknown
    
    public init(country: Country, industrialOutput: Int, adjacentTerritories: Set<TerritoryID> = []) {
        self.adjacentTerritories = adjacentTerritories
        self.country = country
    }
    
    public static func == (lhs: Territory, rhs: Territory) -> Bool {
        return lhs.name == rhs.name
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
}
