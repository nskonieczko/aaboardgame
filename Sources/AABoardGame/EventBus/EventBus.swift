import Combine
import Foundation

public enum EventBusError: Error {
    case eventNotFound(String)
    case cannotSubscribe
    case issueLocatingPublisher
}

public enum EventTopic: Sendable, Codable {
    case newPhase
    case territoryPurchase
    case playerMove
}

public typealias Eventable = Codable & Identifiable & Sendable & Hashable
public typealias EventDataModelType = Codable & Identifiable & Sendable & Hashable
public typealias AsyncEventStream<T: EventDataModelType> = AsyncStream<Event<T>>

public struct Event<T: EventDataModelType>: Eventable {
    public var id: UUID = UUID()
    public var topic: EventTopic
    public var model: T
}

public struct DefaultEventModel: EventDataModelType {
    public var id: UUID = UUID()
}

public class EventBus {
    static let shared = EventBus()
    
    private init() { }
    
    public var subscribers: [EventTopic: [(any Eventable) -> Void]] = [:]
    
    public func subscribe<T: Eventable>(for topics: EventTopic...) -> AsyncEventStream<T> {
        return AsyncStream { continuation in
            for topic in topics {
                let subscriber: (any Eventable) -> Void = { event in
                    if let event = event as? Event<T> {
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
    
    public func notify<T: Eventable>(eventType: EventTopic, event: Event<T>) {
        guard let eventSubscribers = subscribers[eventType] else {
            return
        }
        
        debugPrint("The following subscribers: \(eventSubscribers)")
        
        for subscriber in eventSubscribers {
            subscriber(event)
        }
    }
}
