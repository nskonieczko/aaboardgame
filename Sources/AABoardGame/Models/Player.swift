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
    var name: String { get }
    var territories: Set<Territory>  { get set }
    var units: [AnyUnit]  { get set }
    var purchaseQueue: [AnyUnit]  { get set }
    var wallet: Int { get set }
}

public class Player: AnyPlayer {
    public var id: UUID
    public var name: String
    public var territories: Set<Territory>
    public var units: [AnyUnit]
    public var purchaseQueue: [AnyUnit]
    public var wallet: Int

    public init(id: UUID = UUID(), 
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
    }
//    
//    enum CodingKeys: String, CodingKey {
//        case id, name, territories, units, purchaseQueue, wallet
//    }

//    public required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        id = try container.decode(UUID.self, forKey: .id)
//        name = try container.decode(String.self, forKey: .name)
//        territories = try container.decode(Set<Territory>.self, forKey: .territories)
//        units = try container.decode([AnyUnit].self, forKey: .units)
//        purchaseQueue = try container.decode([AnyUnit].self, forKey: .purchaseQueue)
//        wallet = try container.decode(Int.self, forKey: .wallet)
//    }
//
//    public func encode(to encoder: Encoder) throws {
//        var container = encoder.container(keyedBy: CodingKeys.self)
//        try container.encode(id, forKey: .id)
//        try container.encode(name, forKey: .name)
//        try container.encode(territories, forKey: .territories)
//        try container.encode(units, forKey: .units)
//        try container.encode(purchaseQueue, forKey: .purchaseQueue)
//        try container.encode(wallet, forKey: .wallet)
//    }
}

public enum TerrainType {
    case land, water
}
