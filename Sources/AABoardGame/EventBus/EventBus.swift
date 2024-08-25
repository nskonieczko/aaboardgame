import Combine
import Foundation

public enum EventBusError: Error {
    case eventNotFound(String)
    case cannotSubscribe
    case issueLocatingPublisher
    case cannotEncodeData
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
        case playerPhaseChanged
        
        public var description: String { rawValue.capitalized }
    }
    
    public enum UserInteraction: EventableTopic {
        case selectToolbar
        case recenterMap
        case selectNextPhase
        case selectPhase
        case endTurn
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
            case .selectNextPhase:
                return "Select Next Phase"
            case .endTurn:
                return "Select End Turn"
            case .selectPhase:
                return "Selected Phase"
            case .recenterMap:
                return "Recenter Map"
            }
        }
    }
    
    public enum Territory: String, EventableTopic {
        case unitedStates = "United States"
        
        public var description: String { rawValue }
    }
    
    public enum DataRequest: EventableTopic {
        case getTerritory(Territory)
        case getCurrentPhase
        
        public var description: String {
            switch self {
            case .getTerritory(let territory):
                return "\(territory.description)"
            case .getCurrentPhase:
                return "Current Phase"
            }
        }
    }
    
    public enum DataResponse: EventableTopic {
        case territoryResponse(Territory)
        case currentPhaseResponse
        
        public var description: String {
            switch self {
            case .territoryResponse(let territory):
                return territory.description
                
            case let .currentPhaseResponse:
                return "Current Phase Response"
            }
        }
    }
}


public struct Event: Eventable {
    public var id: UUID = UUID()
    public var topic: EventTopic
    public var action: TurnAction?
    public var data: AnyEncodable?
    
    public init(
        topic: EventTopic,
        data: AnyEncodable? = nil,
        action: TurnAction? = nil
    ) {
        self.topic = topic
        self.data = data
        self.action = action
    }
    
    public static func == (lhs: Event, rhs: Event) -> Bool {
        lhs.id == rhs.id
    }
}

class ContinuationWrapper {
    let continuation: AsyncStream<Event?>.Continuation
    
    init(continuation: AsyncStream<Event?>.Continuation) {
        self.continuation = continuation
    }
}

public class EventBus: ObservableObject {
    public static let shared = EventBus()
    
    private init() { }
    
    private var topicSubscribers: [EventTopic: [ContinuationWrapper]] = [:]
    private let queue = DispatchQueue(label: "EventBusQueue", attributes: .concurrent)
    
    public func subscribe(for topics: EventTopic...) -> AsyncStream<Event?> {
        AsyncStream { continuation in
            let wrapper = ContinuationWrapper(continuation: continuation)
            
            queue.async(flags: .barrier) {
                for topic in topics {
                    if self.topicSubscribers[topic] == nil {
                        self.topicSubscribers[topic] = []
                    }
                    
                    self.topicSubscribers[topic]?.append(wrapper)
                }
                
                continuation.onTermination = { [weak self] _ in
                    guard let self = self else { return }
                    
                    self.queue.async(flags: .barrier) {
                        for topic in topics {
                            self.topicSubscribers[topic]?.removeAll(where: { $0 === wrapper })
                            if self.topicSubscribers[topic]?.isEmpty == true {
                                self.topicSubscribers.removeValue(forKey: topic)
                            }
                        }
                    }
                }
            }
        }
    }
    
    public func notify(topic: EventTopic, event: Event? = nil) {
        queue.async {
            guard let continuations = self.topicSubscribers[topic] else {
                print("No subscribers for topic: \(topic)")
                return
            }
            
            for wrapper in continuations {
                wrapper.continuation.yield(event)
            }
        }
    }
    
    public func createEvent<T: Codable>(
        from topic: EventTopic,
        type: T.Type = String.self,
        encodable: Encodable? = nil
    ) throws -> Event {
        guard let encodable = encodable else {
            return Event(topic: topic, data: nil)
        }
        
        do {
            let jsonEncoder = JSONEncoder()
            let encodedData = try jsonEncoder.encode(encodable)
            return Event(
                topic: topic,
                data: .init(
                    data: encodedData,
                    type: type
                )
            )
        } catch {
            debugPrint("Failed to encode data for event topic: \(topic)")
            throw EventBusError.cannotEncodeData
        }
    }
    
    public func createEvent<T: Codable>(
        from topic: EventTopic,
        type: T.Type = String.self,
        encodable: Encodable? = nil,
        action: TurnAction? = nil
    ) throws -> Event {
        guard let encodable = encodable else {
            return Event(topic: topic, data: nil, action: action)
        }
        
        do {
            let jsonEncoder = JSONEncoder()
            let encodedData = try jsonEncoder.encode(encodable)
            return Event(
                topic: topic,
                data: .init(
                    data: encodedData,
                    type: type
                ),
                action: action
            )
        } catch {
            debugPrint("Failed to encode data for event topic: \(topic)")
            throw EventBusError.cannotEncodeData
        }
    }
}
public enum RequestTopic {
    case getCurrentPhase
}

public enum ResponseTopic {
    case currentPhaseResponse
}

public struct AnyEncodable: Codable, Equatable, Hashable, Sendable {
    public let data: Data
    
    public init?<T: Codable>(data: Data, type: T.Type) {
        let decoder = JSONDecoder()
        let encoder = JSONEncoder()
        
        guard let decodedObject = try? decoder.decode(T.self, from: data) else {
            return nil
        }
        
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
}

