internal protocol AnyBoard: AnyObject, Codable {
    var territories: Set<Territory> { get }
    
    func initializeBoard()
}
