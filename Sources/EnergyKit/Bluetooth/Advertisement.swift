//
//  Advertisement.swift
//  
//
//  Created by Alsey Coleman Miller on 4/9/20.
//

import Foundation
import Bluetooth

#if os(macOS) || os(Linux)

public extension BluetoothHostControllerInterface {
    
    /// LE Advertise with iBeacon
    func setEnergyAdvertisingData(identifier: UUID, rssi: Int8, commandTimeout: HCICommandTimeout = .default) throws {
        
        do { try enableLowEnergyAdvertising(false) }
        catch HCIError.commandDisallowed { }
        
        let beacon = AppleBeacon(uuid: identifier, rssi: rssi)
        let flags: GAPFlags = [.lowEnergyGeneralDiscoverableMode, .notSupportedBREDR]
        
        try iBeacon(beacon, flags: flags, interval: .min, timeout: commandTimeout)
        
        do { try enableLowEnergyAdvertising() }
        catch HCIError.commandDisallowed { }
    }
    
    /// LE Scan Response
    func setEnergyScanResponse(commandTimeout: HCICommandTimeout = .default) throws {
        
        do { try enableLowEnergyAdvertising(false) }
        catch HCIError.commandDisallowed { }
        
        let serviceUUID: GAPIncompleteListOf128BitServiceClassUUIDs = [UUID(bluetooth: LockService.uuid)]
        
        let encoder = GAPDataEncoder()
        let data = try encoder.encodeAdvertisingData(serviceUUID)
        
        try setLowEnergyScanResponse(data, timeout: commandTimeout)
        
        do { try enableLowEnergyAdvertising() }
        catch HCIError.commandDisallowed { }
    }
    
    /// LE Advertise with iBeacon for data changed
    func setEnergyNotificationAdvertisement(rssi: Int8, commandTimeout: HCICommandTimeout = .default) throws {
        
        do { try enableLowEnergyAdvertising(false) }
        catch HCIError.commandDisallowed { }
        
        let beacon = AppleBeacon(uuid: .lockNotificationBeacon, rssi: rssi)
        let flags: GAPFlags = [.lowEnergyGeneralDiscoverableMode, .notSupportedBREDR]
        try iBeacon(beacon, flags: flags, interval: .min, timeout: commandTimeout)
        
        do { try enableLowEnergyAdvertising() }
        catch HCIError.commandDisallowed { }
    }
}

#endif
