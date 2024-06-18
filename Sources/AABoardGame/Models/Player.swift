import Foundation

public class Player {
    let name: String
    var resources: Int
    var territories: Set<Territory> = []
    var units: Set<Unit> = []
    var purchaseQueue: [(Unit, Territory)] = []
    var wallet: Int = 0
    
    public init(name: String, resources: Int) {
        self.name = name
        self.resources = resources
    }
    
    func collectResources() {
        for territory in territories {
            resources += 10  // Simplified resource collection: each territory gives 10 resources
        }
    }
    
    public func purchaseUnit(unit: Unit, to territory: Territory) -> Bool {
        if resources >= unit.cost {
            resources -= unit.cost
            purchaseQueue.append((unit, territory))
            return true
        }
        return false
    }
    
    public func deployUnits() {
        for (unit, territory) in purchaseQueue {
            units.insert(unit)
            territory.addUnit(unit: unit)
        }
        purchaseQueue.removeAll()
    }
}
