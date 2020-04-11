//
//  Device.swift
//  
//
//  Created by Alsey Coleman Miller on 4/9/20.
//

import Foundation

/// Energy Device
public struct EnergyDevice: Codable, Equatable, Hashable {
    
    /// Device identifier.
    public let identifier: UUID
    
    /// Device type.
    public let type: EnergyDeviceType
    
    /// Device name.
    public let name: String
}

/// Device Kind
public enum EnergyDeviceType: UInt8, Codable {
    
    case controller     = 0x00
    case powerSource    = 0x01
    case accessory      = 0x02
}
