//
//  PowerSourceService.swift
//  
//
//  Created by Alsey Coleman Miller on 4/10/20.
//

import Foundation
import Bluetooth
import GATT
import TLVCoding

/// GATT Power Source Service
public struct PowerSourceService: GATTProfileService {
    
    public static let uuid = BluetoothUUID(rawValue: "9565C26D-E717-4524-A38E-8DADA4C04909")!
    
    public static let isPrimary: Bool = true
    
    public static let characteristics: [GATTProfileCharacteristic.Type] = [
        InformationRequest.self,
        InformationResponse.self,
        ActionRequest.self,
        ActionResponse.self
    ]
}

// MARK: - InformationRequest

public extension PowerSourceService {
    
    struct InformationRequest: TLVCharacteristic, Codable, Equatable {
        
        public static let uuid = BluetoothUUID(rawValue: "C430EFCE-604D-48F3-A241-5F7B781E4F90")!
        
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

public extension PowerSourceService {
    
    struct InformationResponse: GATTEncryptedNotification, Equatable {
        
        public static let uuid = BluetoothUUID(rawValue: "6AFA0D36-4567-4486-BEE5-E14A622B805F")!
        
        public static let service: GATTProfileService.Type = PowerSourceService.self
        
        public static let properties: Bluetooth.BitMaskOptionSet<GATT.Characteristic.Property> = [.notify]
        
        public typealias Notification = PowerSource
        
        public let chunk: Chunk
        
        public init(chunk: Chunk) {
            self.chunk = chunk
        }
    }
}

// MARK: - ActionRequest

public extension PowerSourceService {
    
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
        
        public init(_ value: PowerSource.State, sharedSecret: PrivateKey) throws {
            
            let valueData = try Swift.type(of: self).encoder.encode(value)
            self.encryptedData = try EncryptedData(encrypt: valueData, with: sharedSecret)
        }
        
        public func decrypt(with sharedSecret: PrivateKey) throws -> PowerSource.State {
            
            let data = try encryptedData.decrypt(with: sharedSecret)
            guard let value = try? Swift.type(of: self).decoder.decode(PowerSource.State.self, from: data)
                else { throw GATTError.invalidData(data) }
            return value
        }
    }
}

// MARK: - ActionResponse

public extension PowerSourceService {
    
    struct ActionResponse: GATTEncryptedNotification, Equatable {
        
        public static let uuid = BluetoothUUID(rawValue: "C7330D59-E08B-4B54-9639-5DC2121EC439")!
        
        public static let service: GATTProfileService.Type = PowerSourceService.self
        
        public static let properties: Bluetooth.BitMaskOptionSet<GATT.Characteristic.Property> = [.notify]
        
        public typealias Notification = GATTErrorNotification
        
        public let chunk: Chunk
        
        public init(chunk: Chunk) {
            self.chunk = chunk
        }
    }
}
