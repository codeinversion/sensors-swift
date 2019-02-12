//
//  SensorManager.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2017 Kinetic. All rights reserved.
//

import CoreBluetooth
import Signals

/**
 An extensible Bluetooth LE Sensor Manager with concrete Service and Characteristic types, hierarchy, forwarding and observation to simplify BLE.
 */
public class SensorManager: NSObject {
    
    /**
     This is a lazy instance. You can opt to NOT call it and control the lifecycle of the SensorManager yourself if desired.
     
     No internal reference is made to this instance.
     */
    public static let instance = SensorManager()
    
    /**
     All SensorManager logging is directed through this closure. Set it to nil to turn logging off
     or set your own closure at the project level to direct all logging to your logger of choice.
     */
    public static var logSensorMessage: ((_: String) -> ())? = { message in
        print(message)
    }
    
    /**
     Initializes the Sensor Manager.
     
     - parameter powerAlert: Whether the system should display a warning dialog
     if Bluetooth is powered off when the central manager is instantiated.
     
     - returns: Sensor Manager instance
     */
    public init(powerAlert: Bool = false) {
        super.init()
        
        let options: [String: AnyObject] = [
            CBCentralManagerOptionShowPowerAlertKey: NSNumber(booleanLiteral: powerAlert)
        ]
        centralManager = CBCentralManager(delegate: self, queue: nil, options: options)
    }
    
    /// Sensor Manager State
    public enum ManagerState {
        /// Off
        case off
        /// On, Scanning Disabled
        case idle
        /// Passive Scan for BLE sensors
        case passiveScan
        /// Aggressive Scan for BLE sensors
        case aggressiveScan
    }
    
    /// Current Sensor Manager State
    public var state: ManagerState = .off {
        didSet {
            if oldValue != state {
                stateUpdated()
            }
        }
    }
    
    /// Customizable Sensor Class Type
    public var SensorType: Sensor.Type = Sensor.self
    
    /**
     All Discovered Sensors.
     
     Note: sensors may no longer be connectable. Call `removeInactiveSensors` to trim.
     */
    public var sensors: [Sensor] {
        return Array(sensorsById.values)
    }
    
    /**
     Set the Service Types to scan for. Will also create the Services when discovered.
     
     - parameter serviceTypes: Service Types Array
     */
    public func setServicesToScanFor(_ serviceTypes: [ServiceProtocol.Type]) {
        addServiceTypes(serviceTypes)
        serviceFactory.servicesToDiscover = serviceTypes.map { type in
            return CBUUID(string: type.uuid)
        }
    }
    
    /**
     Add Service Types to Create when discovered after connecting to a Sensor.
     
     - parameter serviceTypes: Service Types Array
     */
    public func addServiceTypes(_ serviceTypes: [ServiceProtocol.Type]) {
        for type in serviceTypes {
            serviceFactory.serviceTypes[type.uuid] = type.serviceType
        }
    }
    
    /**
     Attempt to connect to a sensor.
     
     - parameter sensor: The sensor to connect to.
     */
    public func connectToSensor(_ sensor: Sensor) {
        SensorManager.logSensorMessage?("SensorManager: Connecting to sensor ...")
        centralManager.connect(sensor.peripheral, options: nil)
    }
    
    /**
     Disconnect from a sensor.
     
     - parameter sensor: The sensor to disconnect from.
     */
    public func disconnectFromSensor(_ sensor: Sensor) {
        SensorManager.logSensorMessage?("SensorManager: Disconnecting from sensor ...")
        centralManager.cancelPeripheralConnection(sensor.peripheral)
    }
    
    /**
     Removes inactive sensors from the Sensor Manager.
     
     - parameter inactiveTime: Trim sensors that have not communicated
     with the Sensor Manager with the last `inactiveTime` TimeInterval
     */
    public func removeInactiveSensors(_ inactiveTime: TimeInterval) {
        let now = Date.timeIntervalSinceReferenceDate
        for sensor in sensors {
            if now - sensor.lastSensorActivity > inactiveTime {
                if let sensor = sensorsById.removeValue(forKey: sensor.peripheral.identifier.uuidString) {
                    onSensorRemoved => sensor
                }
            }
        }
    }
    
    /// Bluetooth State Change Signal
    public let onBluetoothStateChange = Signal<CBCentralManagerState>()
    
    /// Sensor Discovered Signal
    public let onSensorDiscovered = Signal<Sensor>()
    
    /// Sensor Connected Signal
    public let onSensorConnected = Signal<Sensor>()
    
    /// Sensor Connection Failed Signal
    public let onSensorConnectionFailed = Signal<Sensor>()
    
    /// Sensor Disconnected Signal
    public let onSensorDisconnected = Signal<(Sensor, NSError?)>()
    
    /// Sensor Removed Signal
    public let onSensorRemoved = Signal<Sensor>()
    
    //////////////////////////////////////////////////////////////////
    // Private / Internal Classes, Properties and Constants
    //////////////////////////////////////////////////////////////////
    
    public fileprivate(set) var centralManager: CBCentralManager!
    
    internal class ServiceFactory {
        fileprivate(set) var serviceTypes = Dictionary<String, Service.Type>()
        
        var serviceUUIDs: [CBUUID]? {
            return serviceTypes.count > 0 ? serviceTypes.keys.map { uuid in
                return CBUUID(string: uuid)
            } : nil
        }
        
        var servicesToDiscover: [CBUUID] = []
    }
    
    fileprivate let serviceFactory = ServiceFactory()
    fileprivate var sensorsById = Dictionary<String, Sensor>()
    fileprivate var activityUpdateTimer: Timer?
    static internal let RSSIPingInterval: TimeInterval = 2
    static internal let ActivityInterval: TimeInterval = 5
    static internal let InactiveInterval: TimeInterval = 4
}


// Private Funtions
extension SensorManager {
    
    fileprivate func stateUpdated() {
        if centralManager.state != .poweredOn { return }
        
        activityUpdateTimer?.invalidate()
        activityUpdateTimer = nil
        
        switch state {
        case .off:
            stopScan()
            
            for sensor in sensors {
                disconnectFromSensor(sensor)
            }
            SensorManager.logSensorMessage?("Shutting Down SensorManager")
            
        case .idle:
            stopScan()
            startActivityTimer()
            
        case .passiveScan:
            scan(false)
            startActivityTimer()
            
        case .aggressiveScan:
            scan(true)
            startActivityTimer()
        }
    }
    
    fileprivate func stopScan() {
        centralManager.stopScan()
    }
    
    fileprivate func startActivityTimer() {
        activityUpdateTimer?.invalidate()
        activityUpdateTimer = Timer.scheduledTimer(timeInterval: SensorManager.ActivityInterval, target: self, selector: #selector(SensorManager.rssiUpateTimerHandler(_:)), userInfo: nil, repeats: true)
    }
    
    fileprivate func scan(_ aggressive: Bool) {
        let options: [String: AnyObject] = [
            CBCentralManagerScanOptionAllowDuplicatesKey: aggressive as AnyObject
        ]
        let serviceUUIDs = serviceFactory.servicesToDiscover.count > 0 ? serviceFactory.servicesToDiscover : nil
        centralManager.scanForPeripherals(withServices: serviceUUIDs, options: options)
        SensorManager.logSensorMessage?("SensorManager: Scanning for Services")
        if let serviceUUIDs = serviceUUIDs {
            for peripheral in centralManager.retrieveConnectedPeripherals(withServices: serviceUUIDs) {
                let _ = sensorForPeripheral(peripheral, create: true)
            }
        }
    }
    
    
    @objc func rssiUpateTimerHandler(_ timer: Timer) {
        let now = Date.timeIntervalSinceReferenceDate
        for sensor in sensors {
            if now - sensor.lastSensorActivity > SensorManager.InactiveInterval {
                sensor.rssi = Int.min
            }
        }
    }
    
    fileprivate func sensorForPeripheral(_ peripheral: CBPeripheral, create: Bool, advertisements: [CBUUID] = [], data: [String: Any]? = nil) -> Sensor? {
        if let sensor = sensorsById[peripheral.identifier.uuidString] {
            sensor.advertisementData = data
            return sensor
        }
        if !create {
            return nil
        }
        let sensor = SensorType.init(peripheral: peripheral, advertisements: advertisements)
        sensor.serviceFactory = serviceFactory
        sensor.advertisementData = data
        sensorsById[peripheral.identifier.uuidString] = sensor
        onSensorDiscovered => sensor
        SensorManager.logSensorMessage?("SensorManager: Created Sensor for Peripheral: \(peripheral)")
        return sensor
    }
    
}



extension SensorManager: CBCentralManagerDelegate {
    
    /// :nodoc:
    public func centralManager(_ manager: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        SensorManager.logSensorMessage?("CBCentralManager: didFailToConnectPeripheral: \(peripheral) :: \(error?.localizedDescription ?? "No Error Given")")
        
        if let sensor = sensorForPeripheral(peripheral, create: false) {
            onSensorConnectionFailed => sensor
        }
    }
    
    /// :nodoc:
    public func centralManager(_ manager: CBCentralManager, didConnect peripheral: CBPeripheral) {
        SensorManager.logSensorMessage?("CBCentralManager: didConnectPeripheral: \(peripheral)")
        
        if let sensor = sensorForPeripheral(peripheral, create: true) {
            peripheral.discoverServices(serviceFactory.serviceUUIDs)
            onSensorConnected => sensor
        }
    }
    
    /// :nodoc:
    public func centralManager(_ manager: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        SensorManager.logSensorMessage?("CBCentralManager: didDisconnectPeripheral: \(peripheral)")
        
        // Error Codes:
        //  0   = Unknown error. possibly a major crash?
        //  6   = Connection timed out unexpectedly (pulled the battery out, lost connection due to distance)
        //  10  = The connection has failed unexpectedly.
        
        if let sensor = sensorForPeripheral(peripheral, create: false) {
            onSensorDisconnected => (sensor, error as NSError?)
            if error != nil {
                sensorsById.removeValue(forKey: sensor.peripheral.identifier.uuidString)
                onSensorRemoved => sensor
            }
        }
    }
    
    /// :nodoc:
    public func centralManager(_ manager: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if let uuids = advertisementData[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID] {
            if let sensor = sensorForPeripheral(peripheral, create: true, advertisements: uuids, data: advertisementData) {
                if RSSI.intValue < 0 {
                    sensor.rssi = RSSI.intValue
                    sensor.markSensorActivity()
                }
            }
        }
    }
    
    /// :nodoc:
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        SensorManager.logSensorMessage?("centralManagerDidUpdateState: \(central.state.rawValue)")
        
        switch central.state {
        case .unknown:
            break
        case .resetting:
            break
        case .unsupported:
            break
        case .unauthorized:
            break
        case .poweredOff:
            break
        case .poweredOn:
            stateUpdated()
        }
        
        onBluetoothStateChange => CBCentralManagerState(rawValue: central.state.rawValue)!
    }
    
}

