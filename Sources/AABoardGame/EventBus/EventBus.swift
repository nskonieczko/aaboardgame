import Combine
import Foundation

public enum EventBusError: Error {
    case eventNotFound(String)
    case cannotSubscribe
    case issueLocatingPublisher
    case cannotEncodedData
}

public protocol EventableTopic: Sendable, Codable, Hashable, CustomStringConvertible {}
public typealias Eventable = Codable & Identifiable & Sendable & Hashable
public typealias EventDataModelType = Codable & Identifiable & Sendable & Hashable
public typealias AsyncEventStream = AsyncStream<Event>

public enum EventTopic: EventableTopic {
    case action(PlayerAction)
    case gameEvent(Phase)
    case userInteraction(UserInteraction)
    case territory(Territory)
    case request(DataRequest)
    case response(DataResponse)
    
    public var description: String {
        switch self {
        case .action(let playerAction):
            return "Player Action: \(playerAction.description)"
        case .gameEvent(let phase):
            return "Game Event: \(phase.description)"
        case .userInteraction(let userInteraction):
            return "\(userInteraction.description)"
        case .territory(let territory):
            return "\(territory.description)"
        case .request(let request):
            return "\(request.description)"
        case .response(let response):
            return "\(response.description)"
        }
    }
    
    public enum PlayerAction: String, EventableTopic {
        case purchase
        case move
        case attack
        
        public var description: String { rawValue.capitalized }
    }
    
    public enum Phase: String, EventableTopic {
        case newPhase
        case territoryPurchase
        case playerMove
        
        public var description: String { rawValue.capitalized }
    }
    
    public enum UserInteraction: EventableTopic {
        case selectToolbar
        case selectTerritory(EventTopic.Territory? = nil)
        
        public var description: String {
            switch self {
            case .selectToolbar:
                return "Select Toolbar"
            case .selectTerritory(let territory):
                if let territory = territory {
                    return "\(territory.description)"
                } else {
                    return "None"
                }
            }
        }
    }
    
    public enum Territory: String, EventableTopic {
        case unitedStates = "United States"
        
        public var description: String { rawValue }
    }
    
    public enum DataRequest: EventableTopic {
        case getTerritory(Territory)
        
        public var description: String {
            switch self {
            case .getTerritory(let territory):
                return "\(territory.description)"
            }
        }
    }
    
    public enum DataResponse: EventableTopic {
        case territoryResponse(Territory)
        
        public var description: String {
            switch self {
            case .territoryResponse(let territory):
                return territory.description
            }
        }
    }
}


public struct Event: Eventable {
    public var id: UUID = UUID()
    public var topic: EventTopic
    public var data: AnyEncodable?
    
    public init(topic: EventTopic, data: AnyEncodable?) {
        self.topic = topic
        self.data = data
    }
}

public class EventBus: ObservableObject {
    public static let shared = EventBus()
    
    private init() { }
    
    public var subscribers: [EventTopic: [(Event?) -> Void]] = [:]
    private let queue = DispatchQueue(label: "EventBusQueue", attributes: .concurrent)
    
    public func subscribe(for topics: EventTopic...) -> AsyncEventStream {
        return AsyncStream { continuation in
            for topic in topics {
                let subscriber: ((Event?)) -> Void = { event in
                    if let event {
                        continuation.yield(event)
                    } else {
                        continuation.finish()
                    }
                }
                
                if subscribers[topic] == nil {
                    subscribers[topic] = []
                }
                
                subscribers[topic]?.append(subscriber)
                
                continuation.onTermination = { [weak self] _ in
                    self?.subscribers[topic]?.removeAll(where: { $0 as AnyObject === subscriber as AnyObject })
                    if self?.subscribers[topic]?.isEmpty == true {
                        self?.subscribers.removeValue(forKey: topic)
                    }
                }
            }
        }
    }
    
    public func notify(topic: EventTopic, event: Event? = nil) {
        queue.async {
            guard let eventSubscribers = self.subscribers[topic] else {
                return
            }
            
            
            for subscriber in eventSubscribers {
                self.logPrint(topic.description)
                subscriber(event)
            }
        }
    }
    
    private func logPrint(_ value: String) {
        debugPrint("[EventBus Logger: \(Date())]: \(value)")
    }
    
    public func createEvent<T: Codable>(from topic: EventTopic, type: T.Type = String.self, data: Data? = nil) throws -> Event {
        guard let data = data else {
            return Event(topic: topic, data: nil)
        }
        
        do {
            let jsonEncoder = JSONEncoder()
            let encodedData = try jsonEncoder.encode(data)
            return Event(
                topic: topic,
                data: .init(
                    data: encodedData,
                    type: type
                )
            )
        } catch {
            debugPrint("Failed to encode data for event topic: \(topic.description)")
            throw EventBusError.cannotEncodedData
        }
    }
    
    public func createEvent<T: Codable>(from topic: EventTopic, type: T.Type = String.self, data: Encodable? = nil) throws -> Event {
        guard let data else {
            return Event(topic: topic, data: nil)
        }
        
        do {
            let jsonEncoder = JSONEncoder()
            let encodedData = try jsonEncoder.encode(data)
            return Event(
                topic: topic,
                data: .init(
                    data: encodedData,
                    type: type
                )
            )
        } catch {
            debugPrint("Failed to encode data for event topic: \(topic.description)")
            throw EventBusError.cannotEncodedData
        }
    }
}

public struct AnyEncodable: Codable, Equatable, Hashable, Sendable {
    public let data: Data
    
    // Optional initializer that checks if the data can be encoded and decoded by the type
    public init?<T: Codable>(data: Data, type: T.Type) {
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        
        // Attempt to decode the data
        guard let decodedObject = try? decoder.decode(T.self, from: data) else {
            return nil
        }
        
        // Attempt to encode the object back to data
        guard let reencodedData = try? encoder.encode(decodedObject), reencodedData == data else {
            return nil
        }
        
        self.data = data
    }
    
    public func decoded<T: Codable>(as type: T.Type) -> T? {
        do {
            let decodedObject = try JSONDecoder().decode(type, from: data)
            return decodedObject
        } catch {
            print("Failed to decode JSON: \(error)")
            return nil
        }
    }
    
    func typeFromString(_ typeName: String) -> Codable.Type? {
        return NSClassFromString(typeName) as? Codable.Type
    }
}

