//
//  AuthenticationError.swift
//
//
//  Created by Alsey Coleman Miller on 4/10/20.
//

import Foundation

public enum EnergyAuthenticationError: Error {
    
    /// Invalid authentication HMAC signature.
    case invalidAuthentication
    
    /// Could not decrypt value.
    case decryptionError(Error)
    
    /// Could not encrypt value.
    case encryptionError(Error)
}

internal typealias AuthenticationError = EnergyAuthenticationError
