//
//  DeviceManager.swift
//
//
//  Created by Alsey Coleman Miller on 4/10/20.
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
            guard let peripheral = EnergyPeripheral<Central>(scanData)
                else { return }
            
            event(peripheral)
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
            guard let peripheral = EnergyPeripheral<Central>(scanData)
                else { return }
            
            event(peripheral)
        }
    }
    
    /// Read the device information characteristics.
    public func readInformation(for peripheral: EnergyPeripheral<Central>,
                                timeout: TimeInterval = .gattDefaultTimeout) throws -> EnergyDevice {
        
        let peripheral = peripheral.scanData.peripheral
        log?("Read information for \(peripheral)")
        
        let timeout = Timeout(timeout: timeout)
        return try central.device(for: peripheral, timeout: timeout) { [unowned self] (cache) in
            return try self.readInformation(cache: cache, timeout: timeout)
        }
    }
    
    internal func readInformation(cache: GATTConnectionCache<Peripheral>,
                                  timeout: Timeout) throws -> EnergyDevice {
        
        let identifier = try central.read(EnergyService.Identifier.self, for: cache, timeout: timeout)
        let deviceType = try central.read(EnergyService.DeviceType.self, for: cache, timeout: timeout)
        let deviceName = try central.read(EnergyService.DeviceName.self, for: cache, timeout: timeout)
        
        return EnergyDevice(
            identifier: identifier.identifier,
            type: deviceType.type,
            name: deviceName.name
        )
    }
    
    /// Read the accessory information characteristic.
    public func readAccessory(for peripheral: EnergyPeripheral<Central>,
                              privateKey: PrivateKey,
                              timeout: TimeInterval = .gattDefaultTimeout) throws -> Accessory {
        
        let peripheral = peripheral.scanData.peripheral
        log?("Read accessory information for \(peripheral)")
        
        return try notificationResponse(
            write: AccessoryService.InformationRequest(authentication: Authentication(key: privateKey)),
            notify: AccessoryService.InformationResponse.self,
            for: peripheral,
            with: privateKey,
            timeout: timeout
        )
    }
    
    /// Read the power source information characteristic.
    public func readPowerSource(for peripheral: EnergyPeripheral<Central>,
                                privateKey: PrivateKey,
                                timeout: TimeInterval = .gattDefaultTimeout) throws -> PowerSource {
        
        let peripheral = peripheral.scanData.peripheral
        log?("Read power source information for \(peripheral)")
        
        return try notificationResponse(
            write: PowerSourceService.InformationRequest(authentication: Authentication(key: privateKey)),
            notify: PowerSourceService.InformationResponse.self,
            for: peripheral,
            with: privateKey,
            timeout: timeout
        )
    }
    
    internal func notificationResponse <Write, Notify> (
        write: @autoclosure () -> (Write),
        notify: Notify.Type,
        for peripheral: Central.Peripheral,
        with privateKey: PrivateKey,
        timeout: TimeInterval) throws -> Notify.Notification where Write: GATTCharacteristic, Notify: GATTEncryptedNotification {
        
        let timeout = Timeout(timeout: timeout)
        return try central.device(for: peripheral, timeout: timeout) { [unowned self] (cache) in
            let semaphore = Semaphore(timeout: timeout.timeout)
            var chunks = [Chunk]()
            chunks.reserveCapacity(2)
            var notificationValue: Notify.Notification?
            // notify
            try self.central.notify(Notify.self, for: cache, timeout: timeout) { (response) in
                switch response {
                case let .error(error):
                    semaphore.stopWaiting(error)
                case let .value(value):
                    let chunk = value.chunk
                    self.log?("Received chunk \(chunks.count + 1) (\(chunk.bytes.count) bytes)")
                    chunks.append(chunk)
                    assert(chunks.isEmpty == false)
                    guard chunks.length >= chunk.total
                        else { return } // wait for more chunks
                    do {
                        notificationValue = try Notify.from(chunks: chunks, privateKey: privateKey)
                        semaphore.stopWaiting()
                    } catch {
                        semaphore.stopWaiting(error)
                    }
                }
            }
            
            // Write data to characteristic
            try self.central.write(write(), for: cache, timeout: timeout)
            
            // handle disconnect
            self.central.didDisconnect = {
                guard $0 == cache.peripheral else { return }
                semaphore.stopWaiting(CentralError.disconnected)
            }
            
            /// Wait for all pending notifications
            while notificationValue == nil {
                try semaphore.wait() // wait for notification
            }
            
            // ignore disconnection
            central.didDisconnect = nil
            
            // stop notifications
            try self.central.notify(Notify.self, for: cache, timeout: Timeout(timeout: timeout.timeout), notification: nil)
            
            guard let notification = notificationValue
                else { assertionFailure(); throw CentralError.timeout }
            
            return notification
        }
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

internal final class Semaphore {
    
    let semaphore: DispatchSemaphore
    let timeout: TimeInterval
    private(set) var error: Swift.Error?
    
    init(timeout: TimeInterval) {
        
        self.timeout = timeout
        self.semaphore = DispatchSemaphore(value: 0)
        self.error = nil
    }
    
    func wait() throws {
        
        self.error = nil
        let dispatchTime: DispatchTime = .now() + timeout
        
        let success = semaphore.wait(timeout: dispatchTime) == .success
        
        if let error = self.error {
            throw error
        }
        
        guard success else { throw CentralError.timeout }
    }
    
    func stopWaiting(_ error: Swift.Error? = nil) {
        
        // store error
        self.error = error
        
        // stop blocking
        semaphore.signal()
    }
}
