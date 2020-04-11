//
//  EnergyService.swift
//  
//
//  Created by Alsey Coleman Miller on 4/10/20.
//

import Foundation
import Bluetooth
import GATT

public struct EnergyService: GATTProfileService {
    
    public static let uuid = BluetoothUUID(rawValue: "6F8A5763-BEE1-49F3-9BF4-AA02F3D7E570")!
    
    public static let isPrimary: Bool = true
    
    public static let characteristics: [GATTProfileCharacteristic.Type] = [
        Identifier.self,
        DeviceType.self,
        DeviceName.self,
    ]
}

public extension EnergyService {
    
    struct DeviceType: GATTProfileCharacteristic {
                
        public static let uuid = BluetoothUUID(rawValue: "2759174B-495B-49EE-831A-B6C783D0FDE3")!
        
        public static let service: GATTProfileService.Type = EnergyService.self
        
        internal static var length: Int { return MemoryLayout<EnergyDeviceType.RawValue>.size }
        
        public let type: EnergyDeviceType
        
        public init(type: EnergyDeviceType) {
            self.type = type
        }
        
        public init?(data: Data) {
            guard data.count == Swift.type(of: self).length,
                let type = EnergyDeviceType(rawValue: data[0])
                else { return nil }
            self.init(type: type)
        }
        
        public var data: Data {
            return Data([type.rawValue])
        }
    }
    
    struct Identifier: GATTProfileCharacteristic {
        
        public static let uuid = BluetoothUUID(rawValue: "A3B6C75A-7C19-4A20-BD1A-ED07059BD51E")!
        
        public static let service: GATTProfileService.Type = EnergyService.self
        
        public let identifier: UUID
        
        public init(identifier: UUID) {
            self.identifier = identifier
        }
        
        public init?(data: Data) {
            guard let uuid = UUID(data: data)
                else { return nil }
            self.init(identifier: uuid)
        }
        
        public var data: Data {
            return identifier.data
        }
    }
    
    struct DeviceName: GATTProfileCharacteristic {
        
        public static let uuid = BluetoothUUID(rawValue: "E2966BF0-5215-46E8-BD92-ABFF342C3C30")!
        
        public static let service: GATTProfileService.Type = EnergyService.self
        
        public let name: String
        
        public init(name: String) {
            assert(name.utf8.count <= 256, "String too long")
            self.name = name
        }
        
        public init?(data: Data) {
            guard let string = String(data: data, encoding: .utf8)
                else { return nil }
            self.init(name: string)
        }
        
        public var data: Data {
            return Data(name.utf8)
        }
    }
}
