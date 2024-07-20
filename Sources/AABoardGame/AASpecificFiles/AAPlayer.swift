import Foundation

public class AAPlayer: Player, Codable {
    public var id = UUID()
    public let name: String
    public var territories: Set<Territory> = []
    public var resources: Double
    public var units: [AnyUnit] = []
    public var purchaseQueue: [AnyUnit] = []
    public var wallet: Int = 0
    
    public init(name: String, resources: Double) {
        self.name = name
        self.resources = resources
    }
}
