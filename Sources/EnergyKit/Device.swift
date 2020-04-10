//
//  Device.swift
//  
//
//  Created by Alsey Coleman Miller on 4/9/20.
//

import Foundation

/// Energy Device
public enum EnergyDevice: Equatable, Hashable {
    
    case controller(Controller)
    case powerSource(PowerSource)
    case accessory(Accessory)
}

// MARK: - Properties

public extension EnergyDevice {
    
    var type: EnergyDeviceType {
        switch self {
        case .controller: return .controller
        case .powerSource: return .powerSource
        case .accessory: return .accessory
        }
    }
    
    var identifier: UUID {
        switch self {
        case let .controller(device): return device.identifier
        case let .powerSource(device): return device.identifier
        case let .accessory(device): return device.identifier
        }
    }
    
    var name: String {
        switch self {
        case let .controller(device): return device.name
        case let .powerSource(device): return device.name
        case let .accessory(device): return device.name
        }
    }
}

// MARK: - RawRepresentable

extension EnergyDevice: RawRepresentable {
    
    public init?(rawValue: EnergyDeviceProtocol) {
        if let device = rawValue as? Controller {
            self = .controller(device)
        } else if let device = rawValue as? PowerSource {
            self = .powerSource(device)
        } else if let device = rawValue as? Accessory {
            self = .accessory(device)
        } else {
            return nil
        }
    }
    
    public var rawValue: EnergyDeviceProtocol {
        switch self {
        case let .controller(device): return device
        case let .powerSource(device): return device
        case let .accessory(device): return device
        }
    }
}

/// Energy device
public protocol EnergyDeviceProtocol {
    
    static var deviceType: EnergyDeviceType { get }
    
    var identifier: UUID { get }
    
    var name: String { get }
}

/// Device Kind
public enum EnergyDeviceType: UInt8, Codable {
    
    case controller     = 0x00
    case powerSource    = 0x01
    case accessory      = 0x02
}
