//
//  Notification.swift
//
//
//  Created by Alsey Coleman Miller on 19/4/20.
//

import Foundation
import Bluetooth
import GATT
import TLVCoding

public protocol GATTEncryptedNotification: GATTProfileCharacteristic {
    
    associatedtype Notification
    
    var chunk: Chunk { get }
    
    init(chunk: Chunk)
    
    static func from(chunks: [Chunk]) throws -> EncryptedData
    
    static func from(chunks: [Chunk], privateKey: PrivateKey) throws -> Notification
    
    static func split(_ value: EncryptedData, maximumUpdateValueLength: Int) throws -> [Self]
    
    static func split(_ value: Notification, privateKey: PrivateKey, maximumUpdateValueLength: Int) throws -> [Self]
}

public extension GATTEncryptedNotification {
    
    static var properties: Bluetooth.BitMaskOptionSet<GATT.Characteristic.Property> { return [.notify] }
    
    init?(data: Data) {
        guard let chunk = Chunk(data: data)
            else { return nil }
        
        self.init(chunk: chunk)
    }
    
    var data: Data {
        return chunk.data
    }
}

public extension GATTEncryptedNotification where Notification: Codable {
    
    static var encoder: TLVEncoder { return TLVEncoder.energy }
    
    static var decoder: TLVDecoder { return TLVDecoder.energy }
    
    static func from(chunks: [Chunk]) throws -> EncryptedData {
        
        let data = Data(chunks: chunks)
        guard let value = try? decoder.decode(EncryptedData.self, from: data)
            else { throw GATTError.invalidData(data) }
        return value
    }
    
    static func from(chunks: [Chunk], privateKey: PrivateKey) throws -> Notification {
        
        let encryptedData = try from(chunks: chunks)
        let data = try encryptedData.decrypt(with: privateKey)
        guard let value = try? decoder.decode(Notification.self, from: data)
            else { throw GATTError.invalidData(data) }
        return value
    }
    
    static func split(_ value: EncryptedData, maximumUpdateValueLength: Int) throws -> [Self] {
        
        let data = try encoder.encode(value)
        let chunks = Chunk.from(data, maximumUpdateValueLength: maximumUpdateValueLength)
        return chunks.map { .init(chunk: $0) }
    }
    
    static func split(_ value: Notification,
                      privateKey: PrivateKey,
                      maximumUpdateValueLength: Int) throws -> [Self] {
        
        let data = try encoder.encode(value)
        let encryptedData = try EncryptedData(encrypt: data, with: privateKey)
        return try split(encryptedData, maximumUpdateValueLength: maximumUpdateValueLength)
    }
}
