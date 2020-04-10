//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 4/9/20.
//

import Foundation

/// Powered accessory that consumes energy.
public struct Accessory: Device, Codable, Equatable, Hashable {
    
    public static var deviceKind: DeviceKind { return .accessory }
    
    /// Device identifier.
    public let identifier: UUID
    
    /// Accessory name.
    public let name: String
    
    /// Voltage system compatible with the accessory
    public let voltage: VoltageSystem
    
    /// Category of the accessory.
    public let category: Category
    
    /// Identifier of the accessories' power source.
    public let powerSource: UUID
    
    /// Watts currently consuming.
    public var watts: UInt16
    
    /// Whether the device is on. 
    public var isOn: Bool
}

// MARK: - Supporting Types

public extension Accessory {
    
    enum Category: UInt8, Codable {
        
        /// Standard wall outlet
        case outlet     = 0x01
        
        /// Lighting
        case light      = 0x02
        
        /// House electric appliance
        case appliance  = 0x03
        
        /// Utility (e.g. water pump)
        case utility    = 0x04
    }
}
