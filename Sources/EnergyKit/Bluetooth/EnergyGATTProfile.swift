//
//  EnergyGATTProfile.swift
//  
//
//  Created by Alsey Coleman Miller on 4/10/20.
//

import Foundation
import Bluetooth
import GATT

public enum EnergyGATTProfile: GATTProfile {
    
    public static let services: [GATTProfileService.Type] = [
        EnergyService.self
    ]
}
