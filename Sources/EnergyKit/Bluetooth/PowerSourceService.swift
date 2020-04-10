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
        Request.self,
    ]
    
    public let identifier: UUID
    
    public let type: EnergyDeviceType
    
    public let name: String
}

public extension PowerSourceService {
    
    struct Request: TLVCharacteristic, Codable, Equatable {
        
        public static let uuid = BluetoothUUID(rawValue: "C430EFCE-604D-48F3-A241-5F7B781E4F90")!
        
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
        
        public static let uuid = BluetoothUUID(rawValue: "6AFA0D36-4567-4486-BEE5-E14A622B805F")!
        
        public static let service: GATTProfileService.Type = PowerSourceService.self
        
        public static let properties: Bluetooth.BitMaskOptionSet<GATT.Characteristic.Property> = [.read]
        
        public let encryptedData: EncryptedData
        
        public init(from decoder: Decoder) throws {
            self.encryptedData = try EncryptedData(from: decoder)
        }
        
        public func encode(to encoder: Encoder) throws {
            try encryptedData.encode(to: encoder)
        }
        
        public init(request: PowerSource, sharedSecret: KeyData) throws {
            
            let requestData = try Swift.type(of: self).encoder.encode(request)
            self.encryptedData = try EncryptedData(encrypt: requestData, with: sharedSecret)
        }
        
        public func decrypt(with sharedSecret: KeyData) throws -> PowerSource {
            
            let data = try encryptedData.decrypt(with: sharedSecret)
            guard let value = try? Swift.type(of: self).decoder.decode(PowerSource.self, from: data)
                else { throw GATTError.invalidData(data) }
            return value
        }
    }
}
