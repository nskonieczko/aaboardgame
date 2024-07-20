public protocol BoardRequirement: Codable {
    var territories: Set<Territory> { get }
    
    func initializeBoard()
}
