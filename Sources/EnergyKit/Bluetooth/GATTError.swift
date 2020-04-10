//
//  Error.swift
//
//
//  Created by Alsey Coleman Miller on 4/10/20.
//

import Foundation
import Bluetooth

/// EnergyKit GATT Error
public enum EnergyGATTError: Error {
    
    /// Invalid data.
    case invalidData(Data?)
    
    /// Could not complete GATT operation. 
    case couldNotComplete
}

internal typealias GATTError = EnergyGATTError
