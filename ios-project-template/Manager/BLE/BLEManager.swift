//
//  BLEManager.swift
//  ios-project-template
//
//  Created by Vic Tsai on 2025/2/13.
//

import Foundation
import CoreBluetooth
import Combine

class BLEManager: NSObject, ObservableObject {
    static let shared = BLEManager()
    
    private var centralManager: CBCentralManager!
    
    var connectedPeripheral: CBPeripheral?
    
    var discoveredPeripherals: [CBPeripheral] = []
    
    private var scanCompleteSubject = PassthroughSubject<Void, Error>()
    
    private var characteristicsCache: [CBUUID: CBCharacteristic] = [:]
    
    private var scanSubject = PassthroughSubject<CBPeripheral, Never>()

    private var connectSubject = PassthroughSubject<Result<CBPeripheral, Error>, Error>()
    
    private var responseSubjects: [CBUUID: PassthroughSubject<Data, Never>] = [:]

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: .main)
    }
    
    deinit {
        responseSubjects.forEach { $0.value.send(completion: .finished) }
        responseSubjects.removeAll()
    }
    
    // MARK: - scan
    func startScanning(withServices services: [CBUUID]? = nil) -> AnyPublisher<CBPeripheral, Never> {
        guard centralManager.state == .poweredOn else {
            print("Bluetooth state is off")
            ErrorPublisher.shared.sendError(error: BluetoothError.centralNotPoweredOn)
            return Empty().eraseToAnyPublisher()
        }
        scanSubject = PassthroughSubject<CBPeripheral, Never>()
        discoveredPeripherals.removeAll()
        
        print("Starting scanning...")
        centralManager.scanForPeripherals(withServices: [BLEConstants.service.uuid], options: nil)
        
        return scanSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - connect
    func connect(to peripheral: CBPeripheral) -> AnyPublisher<CBPeripheral, Error> {
        peripheral.delegate = self
        centralManager.connect(peripheral, options: nil)
        
        // Reset scan complete subject for this new connection
        scanCompleteSubject = PassthroughSubject<Void, Error>()
        
        return connectSubject
            .compactMap { result in
                switch result {
                case .success(let connectedPeripheral):
                    return connectedPeripheral
                case .failure:
                    return nil
                }
            }
            .first()
            .timeout(10, scheduler: DispatchQueue.main, customError: { [weak self] in
                self?.centralManager.cancelPeripheralConnection(peripheral)
                return BluetoothError.connectionTimeout
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func waitForCharacteristics() -> AnyPublisher<Void, Error> {
        return scanCompleteSubject
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - write
    func write(characteristicUUID: CBUUID, data: Data) {
        guard let peripheral = connectedPeripheral, let characteristic = characteristicsCache[characteristicUUID] else { return }
        peripheral.writeValue(data, for: characteristic, type: .withResponse)
    }
    
    func read(characteristicUUID: CBUUID) -> AnyPublisher<Data, Never> {
        guard let peripheral = connectedPeripheral, let characteristic = characteristicsCache[characteristicUUID] else {
            return Empty().eraseToAnyPublisher()
        }
        peripheral.readValue(for: characteristic)
        return observeResponse(for: characteristicUUID)
    }

    // MARK: - stop scan
    func stopScanning() {
        print("Stop scanning...")
        centralManager.stopScan()
        scanSubject.send(completion: .finished)
    }
    
    // MARK: - disconnect
    func disconnect() {
        guard let peripheral = connectedPeripheral else { return }
        print("Bluetooth disconnect")
        centralManager.cancelPeripheralConnection(peripheral)
        connectedPeripheral = nil
    }
    
    func observeResponse(for characteristicUUID: CBUUID) -> AnyPublisher<Data, Never> {
        if responseSubjects[characteristicUUID] == nil {
            responseSubjects[characteristicUUID] = PassthroughSubject<Data, Never>()
        }
        return responseSubjects[characteristicUUID]!
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func setNotify(charUUID: CBUUID, isEnabled: Bool) {
        guard let connectedPeripheral = connectedPeripheral, let char = characteristicsCache[charUUID] else { return }
        connectedPeripheral.setNotifyValue(isEnabled, for: char)
    }
    
    func clearResponse(charUUID: CBUUID) {
        responseSubjects.removeValue(forKey: charUUID)
    }
    
}

// MARK: - CBCentralManagerDelegate
extension BLEManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            print("Bluetooth state is on")
        case .poweredOff:
            print("Bluetooth state is off")
        case .unsupported:
            print("Unsupported")
        default:
            print("Unknown state")
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if !discoveredPeripherals.contains(where: { $0.identifier == peripheral.identifier }) {
            discoveredPeripherals.append(peripheral)
            scanSubject.send(peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        connectedPeripheral = peripheral
        connectSubject.send(.success(peripheral))
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        print("Bluetooth disconnected")
        connectedPeripheral = nil
        if let err = error {
            print("Disconnect error: \(err.localizedDescription)")
            ErrorPublisher.shared.sendError(error: err)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("connect failed: \(error?.localizedDescription ?? "unknow error")")
        if let err = error {
            connectSubject.send(.failure(err))
        }
    }
}

// MARK: - CBPeripheralDelegate
extension BLEManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if let error = error {
            print("Failed to discover services: \(error.localizedDescription)")
            scanCompleteSubject.send(completion: .failure(error))
            return
        }
        
        guard let services = peripheral.services else { return }
        
        for service in services {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
            characteristicsCache[characteristic.uuid] = characteristic
            print("Cached characteristic: \(characteristic.uuid)")
        }
        
        if let services = peripheral.services, services.allSatisfy({ $0.characteristics != nil }) {
            scanCompleteSubject.send()
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print("Write failed: \(error.localizedDescription)")
        } else {
            print("Write succeeded for characteristic \(characteristic.uuid)")
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard error == nil, let value = characteristic.value else {
            print("Error receiving response: \(error?.localizedDescription ?? "Unknown error")")
            return
        }

        if let subject = responseSubjects[characteristic.uuid] {
            subject.send(value)
        } else {
            print("No subscriber for characteristic \(characteristic.uuid)")
        }
    }
}

enum BluetoothError: Error, LocalizedError {
    case centralNotPoweredOn
    case connectionTimeout
    
    var errorDescription: String? {
        switch self {
        case .centralNotPoweredOn:
            return "Bluetooth is not powered on."
        case .connectionTimeout:
            return "The connection attempt timed out."
        }
    }
}

