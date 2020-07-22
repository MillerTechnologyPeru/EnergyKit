//
//  Automation.swift
//  
//
//  Created by Alsey Coleman Miller on 4/10/20.
//

import Foundation
import Predicate

public struct Automation: Codable, Equatable, Hashable {
    
    // MARK: - Properties
    
    public let id: UUID
    
    public let name: String
    
    public let condition: Condition
    
    public let action: Action
    
    // MARK: - Initialization
    
    public init(id: UUID,
                name: String,
                condition: Condition,
                action: Action) {
        
        self.id = id
        self.name = name
        self.condition = condition
        self.action = action
    }
}

// MARK: - Identifiable

extension Automation: Identifiable { }

// MARK: - Supporting Types

public extension Automation {
    
    struct Condition: Codable, Equatable, Hashable {
        
        public let device: UUID
        
        public let predicate: Predicate
        
        public init(device: UUID, predicate: Predicate) {
            self.device = device
            self.predicate = predicate
        }
    }
}

public extension Automation {
    
    struct Action: Codable, Equatable, Hashable {
        
        public let device: UUID
        
        public let state: DeviceState
        
        public init(device: UUID, state: DeviceState) {
            self.device = device
            self.state = state
        }
    }
}

public extension Automation {
    
    enum DeviceState: String, Codable {
        
        case off
        case on
        case lowEnergyMode
    }
}
