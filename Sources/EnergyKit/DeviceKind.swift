//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 4/9/20.
//

/// Device Kind
public enum DeviceKind: UInt8 {
    
    case controller     = 0x00
    case powerSource    = 0x01
    case accessory      = 0x02
}
