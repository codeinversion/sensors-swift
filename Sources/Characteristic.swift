//
//  Characteristic.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2017 Kinetic. All rights reserved.
//

import CoreBluetooth
import Signals

/**
 Base Characteristic Implementation. Extend this class with a concrete definition of a BLE characteristic.
 */
open class Characteristic {
    
    /// Parent Service
    public private(set) weak var service: Service?
    
    /// Value Updated Signal
    public let onValueUpdated = Signal<Characteristic>()
    
    /// Value Written Signal
    public let onValueWritten = Signal<Characteristic>()
    
    /// Backing CoreBluetooth Characteristic
    public internal(set) var cbCharacteristic: CBCharacteristic!
    
    /// Timestamp of when the Value was last updated
    public private(set) var valueUpdatedTimestamp: Double?
    
    /// Timestamp of when the Value was last written to
    public private(set) var valueWrittenTimestamp: Double?
    
    
    // Internal Constructor. SensorManager manages the instantiation and destruction of Characteristic objects
    /// :nodoc:
    required public init(service: Service, cbc: CBCharacteristic) {
        self.service = service
        self.cbCharacteristic = cbc
    }
    
    /**
     Called when the Value of the Characteristic was read.
     */
    open func valueUpdated() {
        valueUpdatedTimestamp = Date.timeIntervalSinceReferenceDate
        onValueUpdated => self
    }
    
    /**
     Called when the Value of the Characteristic was successfully written.
     */
    open func valueWritten() {
        valueWrittenTimestamp = Date.timeIntervalSinceReferenceDate
        onValueWritten => self
    }
    
    /**
     Initiate a Read of the Characteritic's Value. `valueUpdated` will be called and `onValueUpdated` will trigger when read.
     */
    public func readValue() {
        cbCharacteristic.read()
    }
    
    /// The Value of the Characteristic
    public var value: Data? {
        return cbCharacteristic.value
    }
        
}


/**
 Base Implementation of a Characteristic with a UTF8 String value. Initiates a `readValue` on instantiation.
 */
open class UTF8Characteristic: Characteristic {
    
    /// The UTF8 Value of the Characteristic
    public var stringValue: String? {
        if let value = value {
            return String(data: value, encoding: String.Encoding.utf8)
        }
        return nil
    }
    
    /// :nodoc:
    required public init(service: Service, cbc: CBCharacteristic) {
        super.init(service: service, cbc: cbc)
        
        readValue()
    }
    
}
