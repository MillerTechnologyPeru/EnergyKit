//
//  File.swift
//  
//
//  Created by Alsey Coleman Miller on 4/9/20.
//

import Foundation
import Bluetooth
import GATT
import Dispatch
import Predicate

/// Energy Controller
public final class EnergyController <Central: CentralProtocol> {
    
    // MARK: - Properties
    
    public let configuration: EnergyConfiguration
        
    public var log: ((String) -> ())?
    
    internal let deviceManager: EnergyDeviceManager<Central>
    
    internal lazy var remoteDevices = configuration.devices
        .filter { $0.type != .controller }
        .map { $0.identifier }
    
    private var devices = [EnergyDevice: EnergyPeripheral<Central>]()
    
    private var deviceCache = [UUID: DeviceState]()
    
    // MARK: - Initialization
    
    public init(configuration: EnergyConfiguration,
                central: Central) {
        self.configuration = configuration
        self.deviceManager = EnergyDeviceManager(central: central)
        self.deviceManager.log = { [weak self] in self?.log?("\($0)") }
    }
    
    // MARK: - Methods
    
    public func run() {
        scan()
        readEncryptedState()
    }
    
    internal func scan() {
        
        var bluetoothDevices = [Central.Peripheral: EnergyPeripheral<Central>]()
        if devices.capacity < remoteDevices.count {
            devices.reserveCapacity(remoteDevices.count)
        }
        if devices.isEmpty == false {
            devices.removeAll(keepingCapacity: true)
        }
        do {
            try self.deviceManager.scan(duration: 10) { (peripheral) in
                bluetoothDevices[peripheral.scanData.peripheral] = peripheral
            }
        } catch {
            self.log?("Error: Unable to scan: \(error)")
        }
        self.log?("Found \(bluetoothDevices.count) devices")
        for peripheral in bluetoothDevices.values {
            do {
                let device = try self.deviceManager.readInformation(for: peripheral)
                self.devices[device] = peripheral
            } catch {
                self.log?("Error: Unable to read information for \(peripheral.scanData.peripheral)")
            }
        }
    }
    
    internal func readEncryptedState() {
        
        deviceCache.removeAll(keepingCapacity: true)
        for (device, peripheral) in devices {
            do {
                switch device.type {
                case .controller:
                    continue
                case .accessory:
                    guard let privateKey = configuration.privateKeys[device.identifier]
                        else { self.log?("Error: Missing private key for \(device.type) \(device.identifier)"); continue }
                    let accessory = try deviceManager.readAccessory(for: peripheral, privateKey: privateKey)
                    deviceCache[device.identifier] = .accessory(accessory)
                case .powerSource:
                    guard let privateKey = configuration.privateKeys[device.identifier]
                        else { self.log?("Error: Missing private key for \(device.type) \(device.identifier)"); continue }
                    let powerSource = try deviceManager.readPowerSource(for: peripheral, privateKey: privateKey)
                    deviceCache[device.identifier] = .powerSource(powerSource)
                }
            } catch {
                self.log?("Error: Unable to read encryped information for \(device.type) \(device.identifier)")
            }
        }
    }
    
    internal func processAutomations() {
        
        for automation in configuration.automation {
            
            self.log?("Evaluating automation \(automation.identifier)")
            
            // evaluate condition
            guard let deviceState = deviceCache[automation.condition.device] else {
                self.log?("Error: Missing state for device \(automation.condition.device)")
                continue
            }
            
            do { try deviceState.evaluate(with: automation.condition.predicate) }
            catch { self.log?("Error: Invalid predicate \(automation.condition.predicate.description) (\(error))") }
            
            
        }
    }
}

// MARK: - Supporting Types

internal extension EnergyController {
    
    enum DeviceState: Equatable {
        
        case accessory(Accessory)
        case powerSource(PowerSource)
    }
}

extension EnergyController.DeviceState: PredicateEvaluatable {
    
    func evaluate(with predicate: Predicate) throws -> Bool {
        switch self {
        case let .accessory(accessory):
            return try accessory.evaluate(with: predicate)
        case let .powerSource(powerSource):
            return try powerSource.evaluate(with: predicate)
        }
    }
}
