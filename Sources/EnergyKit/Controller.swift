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
    
    private var accessories = [UUID: Accessory]()
    
    private var powerSources = [UUID: PowerSource]()
    
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
        
        accessories.removeAll(keepingCapacity: true)
        powerSources.removeAll(keepingCapacity: true)
        for (device, peripheral) in devices {
            do {
                switch device.type {
                case .controller:
                    continue
                case .accessory:
                    guard let privateKey = configuration.privateKeys[device.identifier]
                        else { self.log?("Error: Missing private key for \(device.type) \(device.identifier)") }
                    let accessory = try deviceManager.readAccessory(for: peripheral, privateKey: privateKey)
                    accessories[device.identifier] = accessory
                case .powerSource:
                    guard let privateKey = configuration.privateKeys[device.identifier]
                        else { self.log?("Error: Missing private key for \(device.type) \(device.identifier)") }
                    let powerSource = try deviceManager.readPowerSource(for: peripheral, privateKey: privateKey)
                    powerSources[device.identifier] = powerSource
                }
            } catch {
                self.log?("Error: Unable to read encryped information for \(device.type) \(device.identifier)")
            }
        }
    }
}
