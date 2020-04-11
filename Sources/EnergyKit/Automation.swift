//
//  Automation.swift
//  
//
//  Created by Alsey Coleman Miller on 4/10/20.
//

import Foundation

public struct Automation: Codable, Equatable, Hashable {
    
    public let identifier: UUID
    
    public let name: String
    
    public let condition: Condition
    
    public let action: Action
}

public extension Automation {
    
    struct Condition: Codable, Equatable, Hashable {
        
        public let device: UUID
        
        public let value: Value
    }
}

public extension Automation {
    
    struct Action: Codable, Equatable, Hashable {
        
        public let device: UUID
        
        public let state: DeviceState
    }
}

public extension Automation {
    
    enum Value: Equatable, Hashable {
        
        case state(DeviceState)
        case activePower(UInt16)
        case loadPercent(UInt8)
        case batteryCapacity(UInt8)
    }
}

public extension Automation.Value {
    
    var property: Automation.Property {
        switch self {
        case .state: return .state
        case .activePower: return .activePower
        case .loadPercent: return .loadPercent
        case .batteryCapacity: return .batteryCapacity
        }
    }
}

extension Automation.Value: Codable {
    
    internal enum CodingKeys: String, CodingKey {
        case property
        case value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let property = try container.decode(Automation.Property.self, forKey: .property)
        switch property {
        case .state:
            let value = try container.decode(Automation.DeviceState.self, forKey: .value)
            self = .state(value)
        case .activePower:
            let value = try container.decode(UInt16.self, forKey: .value)
            self = .activePower(value)
        case .loadPercent:
            let value = try container.decode(UInt8.self, forKey: .value)
            self = .loadPercent(value)
        case .batteryCapacity:
            let value = try container.decode(UInt8.self, forKey: .value)
            self = .batteryCapacity(value)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(property, forKey: .property)
        switch self {
        case let .state(value):
            try container.encode(value, forKey: .value)
        case let .activePower(value):
            try container.encode(value, forKey: .value)
        case let .loadPercent(value):
            try container.encode(value, forKey: .value)
        case let .batteryCapacity(value):
            try container.encode(value, forKey: .value)
        }
    }
}

public extension Automation {
    
    enum Property: String, Codable {
        
        case state
        case activePower
        case loadPercent
        case batteryCapacity
    }
}

public extension Automation {
    
    enum DeviceState: String, Codable {
        
        case off
        case on
        case lowEnergyMode
    }
}

public protocol AutomationEvaluatable {
    
    func evaluate(_ value: Automation.Value) -> Bool
}
