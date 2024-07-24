import Foundation

public enum PlayerError: Error {
    case ownershipForbidden
    case insufficientFunds
    
    var localizedDescription: String {
        switch self {
        case .ownershipForbidden:
            return "User does not posses this territory"
            
        case .insufficientFunds:
            return "Insufficient Funds"
        }
    }
}

internal protocol AnyPlayer: AnyObject, Codable {
    var id: UUID { get }
    var country: Country { get }
    var name: String { get }
    var territories: Set<Territory>  { get set }
    var units: [AnyUnit]  { get set }
    var purchaseQueue: [AnyUnit]  { get set }
    var wallet: Int { get set }
}

public class Player: AnyPlayer {
    public var country: Country
    public var id: UUID
    public var name: String
    public var territories: Set<Territory>
    public var units: [AnyUnit]
    public var purchaseQueue: [AnyUnit]
    public var wallet: Int
    
    public init(id: UUID = UUID(),
                country: Country,
                name: String,
                territories: Set<Territory> = [],
                units: [AnyUnit] = [],
                purchaseQueue: [AnyUnit] = [],
                wallet: Int = 0) {
        
        self.id = id
        self.name = name
        self.territories = territories
        self.units = units
        self.purchaseQueue = purchaseQueue
        self.wallet = wallet
        self.country = country
    }
}

public enum TerrainType {
    case land, water
}
