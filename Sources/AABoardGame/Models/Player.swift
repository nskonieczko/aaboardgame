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

public protocol Player: AnyObject {
    var id: UUID { get }
    var name: String { get }
    var territories: Set<Territory>  { get set }
    var units: [AnyUnit]  { get set }
    var purchaseQueue: [AnyUnit]  { get set }
    var wallet: Int { get set }
}

public class AnyPlayer: Player, Codable {
    private let _getId: () -> UUID
    private let _getName: () -> String
    private let _getTerritories: () -> Set<Territory>
    private let _setTerritories: (Set<Territory>) -> Void
    private let _getUnits: () -> [AnyUnit]
    private let _setUnits: ([AnyUnit]) -> Void
    private let _getPurchaseQueue: () -> [AnyUnit]
    private let _setPurchaseQueue: ([AnyUnit]) -> Void
    private let _getWallet: () -> Int
    private let _setWallet: (Int) -> Void
    
    public var id: UUID {
        return _getId()
    }
    
    public var name: String {
        return _getName()
    }
    
    public var territories: Set<Territory> {
        get {
            return _getTerritories()
        }
        set {
            _setTerritories(newValue)
        }
    }
    
    public var units: [AnyUnit] {
        get {
            return _getUnits()
        }
        set {
            _setUnits(newValue)
        }
    }
    
    public var purchaseQueue: [AnyUnit] {
        get {
            return _getPurchaseQueue()
        }
        set {
            _setPurchaseQueue(newValue)
        }
    }
    
    public var wallet: Int {
        get {
            return _getWallet()
        }
        set {
            _setWallet(newValue)
        }
    }
    
    public init<P: Player>(_ player: P) {
        _getId = { player.id }
        _getName = { player.name }
        _getTerritories = { player.territories }
        _setTerritories = { player.territories = $0 }
        _getUnits = { player.units }
        _setUnits = { player.units = $0 }
        _getPurchaseQueue = { player.purchaseQueue }
        _setPurchaseQueue = { player.purchaseQueue = $0 }
        _getWallet = { player.wallet }
        _setWallet = { player.wallet = $0 }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(territories, forKey: .territories)
        try container.encode(units, forKey: .units)
        try container.encode(purchaseQueue, forKey: .purchaseQueue)
        try container.encode(wallet, forKey: .wallet)
    }
    
    public required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let name = try container.decode(String.self, forKey: .name)
        let territories = try container.decode(Set<Territory>.self, forKey: .territories)
        let units = try container.decode([AnyUnit].self, forKey: .units)
        let purchaseQueue = try container.decode([AnyUnit].self, forKey: .purchaseQueue)
        let wallet = try container.decode(Int.self, forKey: .wallet)
        
        _getId = { id }
        _getName = { name }
        _getTerritories = { territories }
        _setTerritories = { _ in }
        _getUnits = { units }
        _setUnits = { _ in }
        _getPurchaseQueue = { purchaseQueue }
        _setPurchaseQueue = { _ in }
        _getWallet = { wallet }
        _setWallet = { _ in }
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case name
        case territories
        case units
        case purchaseQueue
        case wallet
    }
}

public struct PurchaseUnitTransaction: Event {
    public let id: UUID = UUID()
    public let numberOfUnits: Int
//    public let `type`: Territory.Category
    public let territory: Territory
}

public struct NewPhase: Event {
    public let id: UUID = UUID()
    public let phase: any Sequence
}

public enum TerrainType {
    case land, water
}
