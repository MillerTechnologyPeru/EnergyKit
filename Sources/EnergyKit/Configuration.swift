//
//  Configuration.swift
//  
//
//  Created by Alsey Coleman Miller on 4/10/20.
//

import Foundation

/// Energy Configuration
public struct EnergyConfiguration: Codable, Equatable, Hashable {
    
    public var devices: [EnergyDevice]
    
    public var privateKeys: [UUID: PrivateKey]
    
    public var automation: [Automation]
    
    public init() {
        self.devices = []
        self.privateKeys = [:]
        self.automation = []
    }
}
