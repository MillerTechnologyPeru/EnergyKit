//
//  AccessoryService.swift
//  
//
//  Created by Alsey Coleman Miller on 4/10/20.
//


import Foundation
import Bluetooth
import GATT
import TLVCoding

/// GATT Energy Accessory Service
public struct AccessoryService: GATTProfileService {
    
    public static let uuid = BluetoothUUID(rawValue: "CFC0F8A3-DDF5-4D30-9CA3-1701C5E9064E")!
    
    public static let isPrimary: Bool = true
    
    public static let characteristics: [GATTProfileCharacteristic.Type] = [
        Request.self,
        Response.self
    ]
}

public extension AccessoryService {
    
    struct Request: TLVCharacteristic, Codable, Equatable {
        
        public static let uuid = BluetoothUUID(rawValue: "D28123FD-AB48-45E1-939E-D0D5F7CB0DD8")!
        
        public static let service: GATTProfileService.Type = PowerSourceService.self
        
        public static let properties: Bluetooth.BitMaskOptionSet<GATT.Characteristic.Property> = [.write]
        
        /// Identifier of key making request.
        public let identifier: UUID
        
        /// HMAC of key and nonce, and HMAC message
        public let authentication: Authentication
        
        public init(identifier: UUID,
                    authentication: Authentication) {
            
            self.identifier = identifier
            self.authentication = authentication
        }
    }
    
    struct Response: TLVCharacteristic, Codable, Equatable {
        
        public static let uuid = BluetoothUUID(rawValue: "C7330D59-E08B-4B54-9639-5DC2121EC439")!
        
        public static let service: GATTProfileService.Type = PowerSourceService.self
        
        public static let properties: Bluetooth.BitMaskOptionSet<GATT.Characteristic.Property> = [.read]
        
        public let encryptedData: EncryptedData
        
        public init(from decoder: Decoder) throws {
            self.encryptedData = try EncryptedData(from: decoder)
        }
        
        public func encode(to encoder: Encoder) throws {
            try encryptedData.encode(to: encoder)
        }
        
        public init(_ value: Accessory, sharedSecret: KeyData) throws {
            
            let valueData = try Swift.type(of: self).encoder.encode(value)
            self.encryptedData = try EncryptedData(encrypt: valueData, with: sharedSecret)
        }
        
        public func decrypt(with sharedSecret: KeyData) throws -> Accessory {
            
            let data = try encryptedData.decrypt(with: sharedSecret)
            guard let value = try? Swift.type(of: self).decoder.decode(Accessory.self, from: data)
                else { throw GATTError.invalidData(data) }
            return value
        }
    }
}
