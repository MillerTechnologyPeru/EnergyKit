//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 4/9/20.
//

import Foundation

/// Energy Controller
public final class Controller {
    
    public let configuration: EnergyConfiguration
    
    public init(configuration: EnergyConfiguration) {
        self.configuration = configuration
    }
    
    public private(set) var powerSources = [UUID: PowerSource]()
    
    public private(set) var accessories = [UUID: Accessory]()
}
