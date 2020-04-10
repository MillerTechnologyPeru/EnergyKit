//
//  PowerSource.swift
//  
//
//  Created by Alsey Coleman Miller on 4/9/20.
//

import Foundation

/// Power Source Device
public struct PowerSource: EnergyDeviceProtocol, Codable, Equatable, Hashable {
    
    public static var deviceType: EnergyDeviceType { return .powerSource }
    
    /// Device identifier.
    public let identifier: UUID
    
    /// Accessory name.
    public let name: String
    
    /// Voltage system compatible with its accessories.
    public let voltage: VoltageSystem
    
    /// Category of the power source.
    public let category: Category
    
    /// Output active power
    public var outputActivePower: UInt16
    
    /// Output load percent. 
    public var outputLoadPercent: UInt8
}

// MARK: - Supporting Types

public protocol PowerSourceProtocol: EnergyDeviceProtocol {
    
    /// Category of the power source.
    static var category: PowerSource.Category { get }
    
    /// Output active power
    var outputActivePower: UInt16 { get }
    
    /// Output load percent.
    var outputLoadPercent: UInt8 { get }
}

public extension PowerSource {
    
    /// Power Source Category
    enum Category: UInt8, Codable {
        
        case solar      = 0x01
        case generator  = 0x02
        case grid       = 0x03
        case hybrid     = 0x04
    }
}

public extension PowerSource {
    
    /// Solar Power Source
    struct Solar: Codable, Equatable, Hashable {
        
        /// PV Input current for battery.
        ///
        /// The units is A.
        public var solarInputCurrent: UInt
        
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
        public var batteryChargingCurrent: UInt
        
        /// Battery discharge current
        ///
        /// The units is A.
        public var batteryDischargeCurrent: UInt
        
        /// Battery capacity
        ///
        /// The units is %.
        public var batteryCapacity: UInt
        
        /// AC output voltage
        ///
        /// The units is V.
        public var outputVoltage: Float
    }
}

public extension PowerSource {

    /// Generator Power Source
    struct Generator: Codable, Equatable, Hashable {
        
        
    }
}
