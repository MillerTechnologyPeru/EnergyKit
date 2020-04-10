//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 4/9/20.
//

import Foundation

/// Powered accessory that consumes energy.
public struct Accessory {
    
    /// Accessory name
    public let name: String
    
    /// Voltage system compatible with the accessory
    public let voltage: VoltageSystem
    
    /// Watts currently consuming.
    public var watts: Int
    
    /// Category
    public let category: Category
}

public extension Accessory {
    
    public enum Category: UInt8 {
        
        /// Standard wall outlet
        enum outlet     = 0x01
        
        /// Lighting
        case light      = 0x02
        
        /// House electric appliance
        case appliance  = 0x03
        
        /// Utility (e.g. water pump)
        case utility    = 0x04
    }
}
