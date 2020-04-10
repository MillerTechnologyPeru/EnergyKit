//
//  Bool.swift
//
//
//  Created by Alsey Coleman Miller on 4/9/20.
//

internal extension Bool {
    
    init?(byteValue: UInt8) {
        switch byteValue {
        case 0x00: self = false
        case 0x01: self = true
        default: return nil
        }
    }
    
    var byteValue: UInt8 {
        return self ? 0x01 : 0x00
    }
}
