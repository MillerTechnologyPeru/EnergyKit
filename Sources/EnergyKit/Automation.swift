//
//  Automation.swift
//  
//
//  Created by Alsey Coleman Miller on 4/10/20.
//

import Foundation
import Predicate

public struct Automation: Codable, Equatable, Hashable {
    
    public let identifier: UUID
    
    public let name: String
    
    public let condition: Condition
    
    public let action: Action
}

public extension Automation {
    
    struct Condition: Codable, Equatable, Hashable {
        
        public let device: UUID
        
        public let predicate: Predicate
    }
}

public extension Automation {
    
    struct Action: Codable, Equatable, Hashable {
        
        public let device: UUID
        
        public let state: DeviceState
    }
}

public extension Automation {
    
    enum DeviceState: String, Codable {
        
        case off
        case on
        case lowEnergyMode
    }
}
