//
//  Device.swift
//  
//
//  Created by Alsey Coleman Miller on 4/9/20.
//

import Foundation

/// Energy device
public protocol Device {
    
    static var deviceKind: DeviceKind { get }
    
    var identifier: UUID { get }
    
    var name: String { get }
}

/// Device Kind
public enum DeviceKind: UInt8, Codable {
    
    case controller     = 0x00
    case powerSource    = 0x01
    case accessory      = 0x02
}
