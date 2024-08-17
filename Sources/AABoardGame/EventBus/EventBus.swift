import Combine
import Foundation

public enum EventBusError: Error {
    case eventNotFound(String)
    case cannotSubscribe
    case issueLocatingPublisher
}

public protocol EventableTopic: Sendable, Codable {}

public enum EventTopic: Sendable, Codable, Hashable {
    case action(PlayerAction)
    case gameEvent(Phase)
    
    public enum PlayerAction: Sendable, Codable, Hashable {
        case purchase
        case move
        case attack
    }
    
    public enum Phase: Sendable, Codable, Hashable {
        case newPhase
        case territoryPurchase
        case playerMove
    }
}

public typealias Eventable = Codable & Identifiable & Sendable & Hashable
public typealias EventDataModelType = Codable & Identifiable & Sendable & Hashable
public typealias AsyncEventStream = AsyncStream<Event>

public struct Event: Eventable {
    public var id: UUID = UUID()
    public var topic: EventTopic
    public var data: AnyEncodable
    
    public init(topic: EventTopic, data: AnyEncodable) {
        self.topic = topic
        self.data = data
    }
}

public class EventBus {
    public static let shared = EventBus()
    
    private init() { }
    
    public var subscribers: [EventTopic: [(any Eventable) -> Void]] = [:]
    
    public func subscribe(for topics: EventTopic...) -> AsyncEventStream {
        return AsyncStream { continuation in
            for topic in topics {
                let subscriber: (any Eventable) -> Void = { event in
                    if let event = event as? Event {
                        continuation.yield(event)
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
    
    public func notify(eventType: EventTopic, event: Event) {
        guard let eventSubscribers = subscribers[eventType] else {
            return
        }
        
        debugPrint("The following subscribers: \(eventSubscribers)")
        
        for subscriber in eventSubscribers {
            subscriber(event)
        }
    }
}

public struct AnyEncodable: Codable, Equatable, Hashable, Sendable {
    public let type: String
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

        self.type = String(describing: T.self)
        self.data = data
    }

    // Decode the data to a specific type
    public func decode<T: Codable>(as type: T.Type) -> T? {
        guard let decodedObject = try? JSONDecoder().decode(type, from: data) else {
            return nil
        }
        return decodedObject
    }
}
