//
//  HeartRateService.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2017 Kinetic. All rights reserved.
//

import CoreBluetooth
import Signals

//
// https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.service.heart_rate.xml
//
/// :nodoc:
open class HeartRateService: Service, ServiceProtocol {
    
    public static var uuid: String { return "180D" }
    
    public static var characteristicTypes: Dictionary<String, Characteristic.Type> = [
        Measurement.uuid:           Measurement.self,
        BodySensorLocation.uuid:    BodySensorLocation.self,
        ControlPoint.uuid:          ControlPoint.self
    ]
    
    open var measurement: Measurement? { return characteristic() }
    
    open var bodySensorLocation: BodySensorLocation? { return characteristic() }
    
    open var controlPoint: ControlPoint? { return characteristic() }
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.heart_rate_measurement.xml
    //
    open class Measurement: Characteristic {
        
        public static let uuid: String = "2A37"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            cbCharacteristic.notify(true)
            
            service.sensor.onServiceFeaturesIdentified => (service.sensor, service)
        }
        
        open private(set) var currentMeasurement: HeartRateSerializer.MeasurementData?
        
        override open func valueUpdated() {
            if let value = cbCharacteristic.value {
                currentMeasurement = HeartRateSerializer.readMeasurement(value)
            }
            super.valueUpdated()
        }
        
    }
    
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.body_sensor_location.xml
    //
    open class BodySensorLocation: Characteristic {
        
        public static let uuid: String = "2A38"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            readValue()
        }
        
        open private(set) var location: HeartRateSerializer.BodySensorLocation?
        
        override open func valueUpdated() {
            if let value = cbCharacteristic.value {
                location = HeartRateSerializer.readSensorLocation(value)
            }
            super.valueUpdated()
        }
    }
    
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.heart_rate_control_point.xml
    //
    open class ControlPoint: Characteristic {
        
        public static let uuid: String = "2A39"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            cbCharacteristic.notify(true)
        }
        
        open func resetEnergyExpended() {
            cbCharacteristic.write(Data(HeartRateSerializer.writeResetEnergyExpended()), writeType: .withResponse)
        }
        
        override open func valueUpdated() {
            // TODO: Unsure what value is read from the CP after we reset the energy expended (not documented?)
            super.valueUpdated()
        }
        
    }
    
}


