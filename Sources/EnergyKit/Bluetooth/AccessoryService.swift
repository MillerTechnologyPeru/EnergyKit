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
        InformationRequest.self,
        InformationResponse.self,
        ActionRequest.self,
        ActionResponse.self
    ]
}

public extension AccessoryService {
    
    struct InformationRequest: TLVCharacteristic, Codable, Equatable {
        
        public static let uuid = BluetoothUUID(rawValue: "D28123FD-AB48-45E1-939E-D0D5F7CB0DD8")!
        
        public static let service: GATTProfileService.Type = PowerSourceService.self
        
        public static let properties: Bluetooth.BitMaskOptionSet<GATT.Characteristic.Property> = [.write]
        
        /// HMAC of key and nonce, and HMAC message
        public let authentication: Authentication
        
        public init(authentication: Authentication) {
            self.authentication = authentication
        }
        
        public init(from decoder: Decoder) throws {
            self.authentication = try Authentication(from: decoder)
        }
        
        public func encode(to encoder: Encoder) throws {
            try authentication.encode(to: encoder)
        }
    }
    
    struct InformationResponse: TLVCharacteristic, Codable, Equatable {
        
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
        
        public init(_ value: Accessory, sharedSecret: PrivateKey) throws {
            
            let valueData = try Swift.type(of: self).encoder.encode(value)
            self.encryptedData = try EncryptedData(encrypt: valueData, with: sharedSecret)
        }
        
        public func decrypt(with sharedSecret: PrivateKey) throws -> Accessory {
            
            let data = try encryptedData.decrypt(with: sharedSecret)
            guard let value = try? Swift.type(of: self).decoder.decode(Accessory.self, from: data)
                else { throw GATTError.invalidData(data) }
            return value
        }
    }
    
    struct ActionRequest: TLVCharacteristic, Codable, Equatable {
        
        public static let uuid = BluetoothUUID(rawValue: "D28123FD-AB48-45E1-939E-D0D5F7CB0DD8")!
        
        public static let service: GATTProfileService.Type = PowerSourceService.self
        
        public static let properties: Bluetooth.BitMaskOptionSet<GATT.Characteristic.Property> = [.write]
        
        public let encryptedData: EncryptedData
        
        public init(from decoder: Decoder) throws {
            self.encryptedData = try EncryptedData(from: decoder)
        }
        
        public func encode(to encoder: Encoder) throws {
            try encryptedData.encode(to: encoder)
        }
        
        public init(_ value: Accessory.Action, sharedSecret: PrivateKey) throws {
            
            let valueData = try Swift.type(of: self).encoder.encode(value)
            self.encryptedData = try EncryptedData(encrypt: valueData, with: sharedSecret)
        }
        
        public func decrypt(with sharedSecret: PrivateKey) throws -> Accessory.Action {
            
            let data = try encryptedData.decrypt(with: sharedSecret)
            guard let value = try? Swift.type(of: self).decoder.decode(Accessory.Action.self, from: data)
                else { throw GATTError.invalidData(data) }
            return value
        }
    }
    
    struct ActionResponse: TLVCharacteristic, Codable, Equatable {
        
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
        
        public init(_ value: Value, sharedSecret: PrivateKey) throws {
            
            let valueData = try Swift.type(of: self).encoder.encode(value)
            self.encryptedData = try EncryptedData(encrypt: valueData, with: sharedSecret)
        }
        
        public func decrypt(with sharedSecret: PrivateKey) throws -> Value {
            
            let data = try encryptedData.decrypt(with: sharedSecret)
            guard let value = try? Swift.type(of: self).decoder.decode(Value.self, from: data)
                else { throw GATTError.invalidData(data) }
            return value
        }
        
        public struct Value: Codable, Equatable {
            
            public let success: Bool
            
            public let errorDescription: String?
        }
    }
}
