import Foundation

public class TestBoard: Board {
    private let jsonData = """
    {
        "": ""
    }
    """.data(using: .utf8)!
        
    public override func initializeBoard() {
        
    }
}

public class AABoard: Board {
    public override func initializeBoard() {
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
    }
    
    public func getTerritory(name: String) -> Territory? {
        return territories.first(where: { $0.name == name })
    }
    
    public func updateTerritory(territory: Territory) {
        // Update territory details
    }
}
