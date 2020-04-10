//
//  DeviceManager.swift
//  
//
//  Created by Alsey Coleman Miller on 4/9/20.
//

import Foundation
import Bluetooth
import GATT

/// EnergyKit GATT Central client.
public final class EnergyDeviceManager <Central: CentralProtocol> {
    
    public typealias Peripheral = Central.Peripheral
    
    public typealias Advertisement = Central.Advertisement
    
    // MARK: - Initialization
    
    public init(central: Central) {
        self.central = central
    }
    
    // MARK: - Properties
    
    /// GATT Central Manager.
    public let central: Central
    
    /// The log message handler.
    public var log: ((String) -> ())?
    
    /// Scans for nearby devices.
    ///
    /// - Parameter duration: The duration of the scan.
    ///
    /// - Parameter event: Callback for a found device.
    public func scan(duration: TimeInterval,
                     filterDuplicates: Bool = false,
                     event: @escaping ((EnergyPeripheral<Central>) -> ())) throws {
        
        log?("Scanning for \(String(format: "%.2f", duration))s")
        
        try central.scan(duration: duration, filterDuplicates: filterDuplicates) { (scanData) in
            
            // filter peripheral
            guard let device = EnergyPeripheral<Central>(scanData)
                else { return }
            
            event(device)
        }
    }
    
    /// Scans for nearby devices.
    ///
    /// - Parameter event: Callback for a found device.
    ///
    /// - Parameter scanMore: Callback for determining whether the manager
    /// should continue scanning for more devices.
    public func scan(filterDuplicates: Bool = false,
                     event: @escaping ((EnergyPeripheral<Central>) -> ())) throws {
        
        log?("Scanning...")
        
        try self.central.scan(filterDuplicates: filterDuplicates) { (scanData) in
            
            // filter peripheral
            guard let Energy = EnergyPeripheral<Central>(scanData)
                else { return }
            
            event(Energy)
        }
    }
    
    /// Read the device information characteristic.
    public func readInformation(for peripheral: Peripheral,
                                timeout: TimeInterval = .gattDefaultTimeout) throws -> EnergyDevice {
        
        log?("Read information for \(peripheral)")
        
        let timeout = Timeout(timeout: timeout)
        
        return try central.device(for: peripheral, timeout: timeout) { [unowned self] (cache) in
            
            return try self.readInformation(cache: cache, timeout: timeout)
        }
    }
    
    internal func readInformation(cache: GATTConnectionCache<Peripheral>,
                                  timeout: Timeout) throws -> EnergyDevice {
        
        let lockService = try central.read(EnergyService.self, for: cache, timeout: timeout)
        
        
    }
}

// MARK: - Supporting Types

public struct EnergyPeripheral <Central: CentralProtocol>: Equatable {
    
    /// Scan Data
    public let scanData: ScanData<Central.Peripheral, Central.Advertisement>
    
    /// Initialize from scan data.
    internal init?(_ scanData: ScanData<Central.Peripheral, Central.Advertisement>) {
        
        // filter peripheral
        guard let serviceUUIDs = scanData.advertisementData.serviceUUIDs,
            serviceUUIDs.contains(EnergyService.uuid)
            else { return nil }
        
        self.scanData = scanData
    }
}
