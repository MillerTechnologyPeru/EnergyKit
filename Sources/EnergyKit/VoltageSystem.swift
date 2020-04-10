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

// MARK: - CustomStringConvertible

extension VoltageSystem: CustomStringConvertible {
    
    public var description: String {
        switch self {
        case .dc12: return "12VDC"
        case .dc24: return "12VDC"
        case .ac110: return "110VAC"
        case .ac220: return "220VAC"
        case .ac360: return "360VAC"
        }
    }
}
