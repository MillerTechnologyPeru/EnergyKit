//
//  EncryptedData.swift
//  CoreLock
//
//  Created by Alsey Coleman Miller on 8/11/18.
//

import Foundation

public struct EncryptedData: Equatable, Codable {
    
    /// HMAC signature, signed by secret.
    public let authentication: Authentication
    
    /// Crypto IV
    public let initializationVector: InitializationVector
    
    /// Encrypted data
    public let encryptedData: Data
}

public extension EncryptedData {
    
    init(encrypt data: Data, with key: PrivateKey) throws {
        
        do {
            let (encryptedData, iv) = try EnergyKit.encrypt(key: key.data, data: data)
            self.authentication = Authentication(key: key)
            self.initializationVector = iv
            self.encryptedData = encryptedData
        }
        
        catch { throw AuthenticationError.encryptionError(error) }
    }
    
    func decrypt(with key: PrivateKey) throws -> Data {
        
        guard authentication.isAuthenticated(with: key)
            else { throw AuthenticationError.invalidAuthentication }
        
        // attempt to decrypt
        do { return try EnergyKit.decrypt(key: key.data, iv: initializationVector, data: encryptedData) }
        catch { throw AuthenticationError.decryptionError(error) }
    }
}
