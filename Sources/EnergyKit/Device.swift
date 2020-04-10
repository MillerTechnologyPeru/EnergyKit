//
//  Device.swift
//  
//
//  Created by Alsey Coleman Miller on 4/9/20.
//

import Foundation

/// Device Kind
public enum EnergyDeviceType: UInt8, Codable {
    
    case controller     = 0x00
    case powerSource    = 0x01
    case accessory      = 0x02
}
