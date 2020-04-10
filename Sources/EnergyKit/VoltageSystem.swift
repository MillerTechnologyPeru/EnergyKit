//
//  VoltageSystem.swift
//  
//
//  Created by Alsey Coleman Miller on 4/9/20.
//

/// Voltage System
public enum VoltageSystem: UInt16, Codable {
    
    case dc12       = 12
    case dc24       = 24
    case ac110      = 110
    case ac220      = 220
    case ac360      = 360
}
