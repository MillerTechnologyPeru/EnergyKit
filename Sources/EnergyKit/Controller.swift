//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 4/9/20.
//

import Foundation

/// Energy Controller
public struct Controller: EnergyDeviceProtocol, Codable, Equatable, Hashable {
    
    public static var deviceType: EnergyDeviceType { return .controller }
    
    /// Device identifier.
    public let identifier: UUID
    
    /// Accessory name.
    public let name: String
}
