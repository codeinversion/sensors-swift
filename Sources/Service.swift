//
//  Service.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2017 Kinetic. All rights reserved.
//

import CoreBluetooth

/**
 The Service Protocol is used by the Sensor Manager to identify, organize and instantiate Services given a UUID string.
 */
public protocol ServiceProtocol: class {
    
    /// UUID string of the Service.
    static var uuid: String { get }
    
    /// Service Class Type to instantiate.
    static var serviceType: Service.Type { get }
    
    /// Characteristic Types (UUID key) to discover and instantiate.
    static var characteristicTypes: Dictionary<String, Characteristic.Type> { get }
    
}

extension ServiceProtocol where Self: Service {
    /// :nodoc:
    public static var serviceType: Service.Type { return self }
}

/**
 Compares the UUIDs of 2 Service Objects.
 
 - parameter lhs: Service Object
 - parameter rhs: Service Object
 - returns: `true` if the UUIDs of the two Service Objects match
 */
public func == (lhs: Service, rhs: Service) -> Bool {
    return lhs.cbService.uuid == rhs.cbService.uuid
}

/**
 Base Service Implementation. Extend this class with a concrete definition of a BLE service.
 */
open class Service: Equatable {
    
    /// Parent Sensor
    public private(set) weak var sensor: Sensor!
    
    /// Backing CoreBluetooth Service
    public let cbService: CBService
    
    /// All Characteristics owned by this Service
    public internal(set) var characteristics = Dictionary<String, Characteristic>()
    
    /**
     Get a characteristic by its UUID or by Type
     
     - parameter uuid: UUID string
     - returns: Characteristic
     */
    public func characteristic<T: Characteristic>(_ uuid: String? = nil) -> T? {
        if let uuid = uuid {
            return characteristics[uuid] as? T
        }
        for characteristic in characteristics.values {
            if let c = characteristic as? T {
                return c
            }
        }
        return nil
    }
    
    // Internal Constructor. SensorManager manages the instantiation and destruction of Service objects
    /// :nodoc:
    required public init(sensor: Sensor, cbs: CBService) {
        self.sensor = sensor
        self.cbService = cbs
    }
    
}
