//
//  Sensor.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2017 Kinetic. All rights reserved.
//

import CoreBluetooth
import Signals

/**
 Sensor wraps a CoreBluetooth Peripheral and manages the hierarchy of Services and Characteristics.
 */
open class Sensor: NSObject {
    
    // Internal Constructor. SensorManager manages the instantiation and destruction of Sensor objects
    /// :nodoc:
    required public init(peripheral: CBPeripheral, advertisements: [CBUUID] = []) {
        self.peripheral = peripheral
        self.advertisements = advertisements
        
        super.init()
        
        peripheral.delegate = self
        peripheral.addObserver(self, forKeyPath: "state", options: [.new, .old], context: &myContext)
    }
    
    deinit {
        peripheral.removeObserver(self, forKeyPath: "state")
        peripheral.delegate = nil
        rssiPingTimer?.invalidate()
    }
    
    /// Backing CoreBluetooth Peripheral
    public let peripheral: CBPeripheral
    
    /// Discovered Services
    public fileprivate(set) var services = Dictionary<String, Service>()
    
    /// Advertised UUIDs
    public let advertisements: [CBUUID]
    
    /// Raw Advertisement Data
    public internal(set) var advertisementData: [String: Any]? {
        didSet {
            onAdvertisementDataUpdated => advertisementData
        }
    }
    
    /// Advertisement Data Changed Signal
    public let onAdvertisementDataUpdated = Signal<([String: Any]?)>()
    
    /// Name Changed Signal
    public let onNameChanged = Signal<Sensor>()
    
    /// State Changed Signal
    public let onStateChanged = Signal<Sensor>()
    
    /// Service Discovered Signal
    public let onServiceDiscovered = Signal<(Sensor, Service)>()
    
    /// Service Features Identified Signal
    public let onServiceFeaturesIdentified = Signal<(Sensor, Service)>()
    
    /// Characteristic Discovered Signal
    public let onCharacteristicDiscovered = Signal<(Sensor, Characteristic)>()
    
    /// Characteristic Value Updated Signal
    public let onCharacteristicValueUpdated = Signal<(Sensor, Characteristic)>()
    
    /// Characteristic Value Written Signal
    public let onCharacteristicValueWritten = Signal<(Sensor, Characteristic)>()
    
    /// RSSI Changed Signal
    public let onRSSIChanged = Signal<(Sensor, Int)>()
    
    /// Most recent RSSI value
    public internal(set) var rssi: Int = Int.min {
        didSet {
            onRSSIChanged => (self, rssi)
        }
    }
    
    /// Last time of Sensor Communication with the Sensor Manager (Time Interval since Reference Date)
    public fileprivate(set) var lastSensorActivity = Date.timeIntervalSinceReferenceDate
    
    /**
     Get a service by its UUID or by Type
     
     - parameter uuid: UUID string
     - returns: Service
     */
    public func service<T: Service>(_ uuid: String? = nil) -> T? {
        if let uuid = uuid {
            return services[uuid] as? T
        }
        for service in services.values {
            if let s = service as? T {
                return s
            }
        }
        return nil
    }
    
    /**
     Check if a Sensor advertised a specific UUID Service
     
     - parameter uuid: UUID string
     - returns: `true` if the sensor advertised the `uuid` service
     */
    open func advertisedService(_ uuid: String) -> Bool {
        let service = CBUUID(string: uuid)
        for advertisement in advertisements {
            if advertisement.isEqual(service) {
                return true
            }
        }
        return false
    }
    
    
    
    
    
    
    
    
    
    
    
    //////////////////////////////////////////////////////////////////
    // Private / Internal Classes, Properties and Constants
    //////////////////////////////////////////////////////////////////
    
    internal weak var serviceFactory: SensorManager.ServiceFactory?
    private var rssiPingTimer: Timer?
    private var myContext = 0
    
    /// :nodoc:
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &myContext {
            if keyPath == "state" {
                peripheralStateChanged()
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    fileprivate var rssiPingEnabled: Bool = false {
        didSet {
            if rssiPingEnabled {
                if rssiPingTimer == nil {
                    rssiPingTimer = Timer.scheduledTimer(timeInterval: SensorManager.RSSIPingInterval, target: self, selector: #selector(Sensor.rssiPingTimerHandler), userInfo: nil, repeats: true)
                }
            } else {
                rssi = Int.min
                rssiPingTimer?.invalidate()
                rssiPingTimer = nil
            }
        }
    }
}


// Private Funtions
extension Sensor {
    
    fileprivate func peripheralStateChanged() {
        switch peripheral.state {
        case .connected:
            rssiPingEnabled = true
        case .connecting:
            break
        case .disconnected:
            fallthrough
        default:
            rssiPingEnabled = false
            services.removeAll()
        }
        SensorManager.logSensorMessage?("Sensor: peripheralStateChanged: \(peripheral.state.rawValue)")
        onStateChanged => self
    }
    
    fileprivate func serviceDiscovered(_ cbs: CBService) {
        if let service = services[cbs.uuid.uuidString], service.cbService == cbs {
            return
        }
        if let ServiceType = serviceFactory?.serviceTypes[cbs.uuid.uuidString] {
            let service = ServiceType.init(sensor: self, cbs: cbs)
            services[cbs.uuid.uuidString] = service
            onServiceDiscovered => (self, service)
            
            SensorManager.logSensorMessage?("Sensor: Service Created: \(service)")
            if let sp = service as? ServiceProtocol {
                let charUUIDs: [CBUUID] = type(of: sp).characteristicTypes.keys.map { uuid in
                    return CBUUID(string: uuid)
                }
                peripheral.discoverCharacteristics(charUUIDs.count > 0 ? charUUIDs : nil, for: cbs)
            }
        } else {
            SensorManager.logSensorMessage?("Sensor: Service Ignored: \(cbs)")
        }
    }
    
    fileprivate func characteristicDiscovered(_ cbc: CBCharacteristic, cbs: CBService) {
        guard let service = services[cbs.uuid.uuidString] else { return }
        if let characteristic = service.characteristic(cbc.uuid.uuidString), characteristic.cbCharacteristic == cbc {
            return
        }
        guard let sp = service as? ServiceProtocol else { return }
        
        if let CharType = type(of: sp).characteristicTypes[cbc.uuid.uuidString] {
            let characteristic = CharType.init(service: service, cbc: cbc)
            service.characteristics[cbc.uuid.uuidString] = characteristic
            
            characteristic.onValueUpdated.subscribe(with: self) { [weak self] c in
                if let s = self {
                    s.onCharacteristicValueUpdated => (s, c)
                }
            }
            characteristic.onValueWritten.subscribe(with: self) { [weak self] c in
                if let s = self {
                    s.onCharacteristicValueWritten => (s, c)
                }
            }
            
            SensorManager.logSensorMessage?("Sensor: Characteristic Created: \(characteristic)")
            onCharacteristicDiscovered => (self, characteristic)
        } else {
            SensorManager.logSensorMessage?("Sensor: Characteristic Ignored: \(cbc)")
        }
    }
    
    @objc func rssiPingTimerHandler() {
        if peripheral.state == .connected {
            peripheral.readRSSI()
        }
    }
    
    internal func markSensorActivity() {
        lastSensorActivity = Date.timeIntervalSinceReferenceDate
    }
    
}


extension Sensor: CBPeripheralDelegate {
    
    /// :nodoc:
    public func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        onNameChanged => self
        markSensorActivity()
    }
    
    /// :nodoc:
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        guard let cbss = peripheral.services else { return }
        for cbs in cbss {
            serviceDiscovered(cbs)
        }
        markSensorActivity()
    }
    
    /// :nodoc:
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let cbcs = service.characteristics else { return }
        for cbc in cbcs {
            characteristicDiscovered(cbc, cbs: service)
        }
        markSensorActivity()
    }
    
    /// :nodoc:
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let service = services[characteristic.service.uuid.uuidString] else { return }
        guard let char = service.characteristics[characteristic.uuid.uuidString] else { return }
        if char.cbCharacteristic !== characteristic {
            char.cbCharacteristic = characteristic
        }
        char.valueUpdated()
        markSensorActivity()
    }
    
    /// :nodoc:
    public func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        guard let service = services[characteristic.service.uuid.uuidString] else { return }
        guard let char = service.characteristics[characteristic.uuid.uuidString] else { return }
        if char.cbCharacteristic !== characteristic {
            char.cbCharacteristic = characteristic
        }
        char.valueWritten()
        markSensorActivity()
    }
    
    /// :nodoc:
    public func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        if RSSI.intValue < 0 {
            rssi = RSSI.intValue
            markSensorActivity()
        }
    }
    
}

