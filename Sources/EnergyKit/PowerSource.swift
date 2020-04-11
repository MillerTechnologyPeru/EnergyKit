//
//  PowerSource.swift
//  
//
//  Created by Alsey Coleman Miller on 4/9/20.
//

import Foundation

/// Power Source
public enum PowerSource: Equatable, Hashable {
    
    /// Solar energy power source
    case solar(Solar)
    
    /// Electric generator power source
    case generator(Generator)
}

// MARK: - Codable

extension PowerSource: Codable {
    
    internal enum CodingKeys: String, CodingKey {
        case type
        case powerSource
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(PowerSourceType.self, forKey: .type)
        switch type {
        case .solar:
            let powerSource = try container.decode(Solar.self, forKey: .powerSource)
            self = .solar(powerSource)
        case .generator:
            let powerSource = try container.decode(Generator.self, forKey: .powerSource)
            self = .generator(powerSource)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case let .solar(powerSource):
            try container.encode(powerSource, forKey: .powerSource)
            try container.encode(PowerSourceType.solar, forKey: .type)
        case let .generator(powerSource):
            try container.encode(powerSource, forKey: .powerSource)
            try container.encode(PowerSourceType.generator, forKey: .type)
        }
    }
}

// MARK: - Supporting Types

public protocol PowerSourceProtocol {
    
    /// Power Source
    static var powerSourceType: PowerSourceType { get }
    
    /// Voltage system compatible with its accessories.
    var voltage: VoltageSystem { get }
    
    /// Power source state.
    var state: PowerSource.State { get }
    
    /// Output active power
    var activePower: UInt16 { get }
    
    /// Output load percent.
    var loadPercent: UInt8 { get }
}

/// Power Source Category
public enum PowerSourceType: UInt8, Codable {
    
    case solar      = 0x01
    case generator  = 0x02
    //case grid       = 0x03
}

public extension PowerSource {
    
    /// Power Source State
    enum State: UInt8, Codable {
        
        /// Power source is disabled
        case off            = 0x00
        
        /// Power source is enabled
        case on             = 0x01
    }
}

public extension PowerSource {
    
    /// Solar Power Source
    struct Solar: PowerSourceProtocol, Codable, Equatable, Hashable {
        
        public static let powerSourceType: PowerSourceType = .solar
        
        /// Voltage system compatible with its accessories.
        public let voltage: VoltageSystem
        
        /// Power source state
        public var state: PowerSource.State
        
        /// Output active power
        public var activePower: UInt16
        
        /// Output load percent.
        public var loadPercent: UInt8
        
        /// PV Input current for battery.
        ///
        /// The units is A.
        public var solarInputCurrent: UInt16
        
        /// PV Input voltage
        ///
        /// The units is V.
        public var solarInputVoltage: Float
        
        /// Battery voltage
        ///
        /// The units is V.
        public var batteryVoltage: Float
        
        /// Battery charging current
        ///
        /// The units is A.
        public var batteryChargingCurrent: UInt16
        
        /// Battery discharge current
        ///
        /// The units is A.
        public var batteryDischargeCurrent: UInt16
        
        /// Battery capacity
        ///
        /// The units is %.
        public var batteryCapacity: UInt8
    }
}

public extension PowerSource {

    /// Generator Power Source
    struct Generator: PowerSourceProtocol, Codable, Equatable, Hashable {
        
        public static let powerSourceType: PowerSourceType = .generator
        
        /// Voltage system compatible with its accessories.
        public let voltage: VoltageSystem
        
        /// Power source state
        public var state: PowerSource.State
        
        /// Output active power
        public var activePower: UInt16
        
        /// Output load percent.
        public var loadPercent: UInt8
    }
}
