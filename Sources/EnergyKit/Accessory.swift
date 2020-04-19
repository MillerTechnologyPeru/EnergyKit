//
//  Accessory.swift
//  
//
//  Created by Alsey Coleman Miller on 4/9/20.
//

import Foundation

/// Powered accessory that consumes energy.
public struct Accessory: Codable, Equatable, Hashable {
    
    public static var deviceType: EnergyDeviceType { return .accessory }
    
    /// Voltage system compatible with the accessory
    public let voltage: VoltageSystem
    
    /// Category of the accessory.
    public let type: AccessoryType
    
    /// Accessory state.
    public var state: State
    
    /// Watts currently consuming.
    public var activePower: UInt16
}

// MARK: - Supporting Types

public enum AccessoryType: UInt8, Codable {
    
    /// Standard wall outlet
    case outlet     = 0x01
    
    /// Lighting
    case light      = 0x02
    
    /// House electric appliance
    case appliance  = 0x03
    
    /// Utility (e.g. water pump)
    case utility    = 0x04
}

public extension Accessory {
    
    enum State: UInt8, Codable {
        
        /// Disable the accessory
        case off            = 0x00
        
        /// Enable the accessory
        case on             = 0x01
        
        /// Keep the accessory enabled but in low power mode (e.g. dim lights).
        case lowEnergyMode  = 0x02
    }
}
