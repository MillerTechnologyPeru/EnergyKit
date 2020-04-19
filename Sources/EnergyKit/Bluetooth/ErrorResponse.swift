//
//  ErrorResponse.swift
//  
//
//  Created by Alsey Coleman Miller on 4/19/20.
//

import Foundation

public enum GATTErrorNotification: Equatable, Hashable {
    
    case success
    case failure(String)
}

extension GATTErrorNotification: Codable {
    
    internal enum CodingKeys: String, CodingKey {
        
        case success
        case failure
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let success = try container.decode(Bool.self, forKey: .success)
        if success {
            self = .success
        } else {
            let failure = try container.decode(String.self, forKey: .failure)
            self = .failure(failure)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .success:
            try container.encode(true, forKey: .success)
        case let .failure(failure):
            try container.encode(false, forKey: .success)
            try container.encode(failure, forKey: .failure)
        }
    }
}

internal extension GATTError {
    
    init?(_ notification: GATTErrorNotification) {
        switch notification {
        case .success:
            return nil
        case let .failure(failure):
            self = .errorResponse(failure)
        }
    }
}
