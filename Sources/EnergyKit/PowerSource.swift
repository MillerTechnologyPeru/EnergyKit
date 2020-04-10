//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 4/9/20.
//

import Foundation

public final class PowerSource: Device, Codable, Equatable, Hashable {
    
    public static var deviceKind: DeviceKind { return .powerSource }
    
    /// Device identifier.
    public let identifier: UUID
    
    /// Accessory name.
    public let name: String
    
    /// Voltage system compatible with its accessories.
    public let voltage: VoltageSystem
    
    /// Category of the power source.
    public let category: Category
    
    /// Output active power
    public let outputActivePower: UInt
    
    /// Output load percent. 
    public var outputLoadPercent: UInt
}

// MARK: - Supporting Types

public extension PowerSource {
    
    /// Power Source Category
    enum Category: UInt8 {
        
        case solar      = 0x01
        case generator  = 0x02
        case grid       = 0x03
    }
}

public extension PowerSource {
    
    /// Solar Power Source
    struct Solar: Codable, Equatable, Hashable {
        
        /// Output load percent.
        public var outputLoadPercent: UInt8
        
        /// Battery voltage
        ///
        /// The units is V.
        public var batteryVoltage: Float
        
        /// Battery charging current
        ///
        /// The units is A.
        public var batteryChargingCurrent: UInt
        
        /// Battery capacity
        ///
        /// The units is %.
        public var batteryCapacity: UInt
    }
}
