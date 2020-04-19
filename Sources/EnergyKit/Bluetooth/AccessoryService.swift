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

// MARK: - InformationRequest

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
}

// MARK: - InformationResponse

public extension AccessoryService {
    
    struct InformationResponse: GATTEncryptedNotification, Equatable {
        
        public static let uuid = BluetoothUUID(rawValue: "C7330D59-E08B-4B54-9639-5DC2121EC439")!
        
        public static let service: GATTProfileService.Type = AccessoryService.self
        
        public static let properties: Bluetooth.BitMaskOptionSet<GATT.Characteristic.Property> = [.notify]
        
        public typealias Notification = Accessory
        
        public let chunk: Chunk
        
        public init(chunk: Chunk) {
            self.chunk = chunk
        }
    }
}

// MARK: - ActionRequest

public extension AccessoryService {
    
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
        
        public init(_ value: Accessory.State, privateKey: PrivateKey) throws {
            
            let valueData = try Swift.type(of: self).encoder.encode(value)
            self.encryptedData = try EncryptedData(encrypt: valueData, with: privateKey)
        }
        
        public func decrypt(with privateKey: PrivateKey) throws -> Accessory.State {
            
            let data = try encryptedData.decrypt(with: privateKey)
            guard let value = try? Swift.type(of: self).decoder.decode(Accessory.State.self, from: data)
                else { throw GATTError.invalidData(data) }
            return value
        }
    }
}

// MARK: - ActionResponse

public extension AccessoryService {
    
    struct ActionResponse: GATTEncryptedNotification, Equatable {
        
        public static let uuid = BluetoothUUID(rawValue: "C7330D59-E08B-4B54-9639-5DC2121EC439")!
        
        public static let service: GATTProfileService.Type = AccessoryService.self
        
        public static let properties: Bluetooth.BitMaskOptionSet<GATT.Characteristic.Property> = [.notify]
        
        public typealias Notification = GATTErrorNotification
        
        public let chunk: Chunk
        
        public init(chunk: Chunk) {
            self.chunk = chunk
        }
    }
}
