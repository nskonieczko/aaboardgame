import Foundation

public class Board {
    var territories: Set<Territory> = []
    
    public func initializeBoard() {
        /*
         All countries
         all adjacent counties to each one.
         Territory: USA
            Adjacent: Mexico, Canada
         */
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
    
    public func getTerritory(name: String) -> Territory? {
        return territories.first(where: { $0.name == name })
    }
    
    public func updateTerritory(territory: Territory) {
        // Update territory details
    }
}
