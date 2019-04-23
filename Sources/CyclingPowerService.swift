//
//  CyclingPowerSensor.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2017 Kinetic. All rights reserved.
//

import CoreBluetooth
import Signals

//
// https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.service.cycling_power.xml
//
/// :nodoc:
open class CyclingPowerService: Service, ServiceProtocol {
    
    public static var uuid: String { return "1818" }
    
    public static var characteristicTypes: Dictionary<String, Characteristic.Type> = [
        Measurement.uuid:       Measurement.self,
        Feature.uuid:           Feature.self,
        Vector.uuid:            Vector.self,
        SensorLocation.uuid:    SensorLocation.self,
        ControlPoint.uuid:      ControlPoint.self
    ]
    
    public var measurement: Measurement? { return characteristic() }
    
    public var feature: Feature? { return characteristic() }
    
    public var sensorLocation: SensorLocation? { return characteristic() }
    
    public var controlPoint: ControlPoint? { return characteristic() }
    
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.cycling_power_measurement.xml
    //
    open class Measurement: Characteristic {
        
        public static let uuid: String = "2A63"
        
        open private(set) var instantaneousPower: UInt?
        
        open private(set) var speedKPH: Double?
        
        open private(set) var crankRPM: Double?
        
        open var wheelCircumferenceCM: Double = 213.3
        
        open private(set) var measurementData: CyclingPowerSerializer.MeasurementData? {
            didSet {
                guard let current = measurementData else { return }
                instantaneousPower = UInt(current.instantaneousPower)
                
                guard let previous = oldValue else { return }
                speedKPH = CyclingSerializer.calculateWheelKPH(current, previous: previous, wheelCircumferenceCM: wheelCircumferenceCM, wheelTimeResolution: 2048)
                crankRPM = CyclingSerializer.calculateCrankRPM(current, previous: previous)
            }
        }
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            cbCharacteristic.notify(true)
        }
        
        override open func valueUpdated() {
            // cbCharacteristic is nil?
            if let value = cbCharacteristic.value {
                measurementData = CyclingPowerSerializer.readMeasurement(value)
            }
            super.valueUpdated()
        }
        
    }
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.cycling_power_vector.xml
    //
    open class Vector: Characteristic {
        
        public static let uuid: String = "2A64"
        
        open private(set) var vectorData: CyclingPowerSerializer.VectorData? {
            didSet {
//                guard let current = measurementData else { return }
//                instantaneousPower = UInt(current.instantaneousPower)
//
//                guard let previous = oldValue else { return }
//                speedKPH = CyclingSerializer.calculateWheelKPH(current, previous: previous, wheelCircumferenceCM: wheelCircumferenceCM, wheelTimeResolution: 2048)
//                crankRPM = CyclingSerializer.calculateCrankRPM(current, previous: previous)
            }
        }
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            cbCharacteristic.notify(true)
        }
        
        override open func valueUpdated() {
            if let value = cbCharacteristic.value {
                vectorData = CyclingPowerSerializer.readVector(value)
            }
            super.valueUpdated()
        }
        
    }
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.cycling_power_feature.xml
    //
    open class Feature: Characteristic {
        
        public static let uuid: String = "2A65"
        
        open private(set) var features: CyclingPowerSerializer.Features?
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            cbCharacteristic.read()
        }
        
        override open func valueUpdated() {
            if let value = cbCharacteristic.value {
                features = CyclingPowerSerializer.readFeatures(value)
            }
            
            super.valueUpdated()
            
            if let service = service {
                service.sensor.onServiceFeaturesIdentified => (service.sensor, service)
            }
        }
    }
    
    
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.sensor_location.xml
    //
    open class SensorLocation: Characteristic {
        
        public static let uuid: String = "2A5D"
        
        open private(set) var location: CyclingSerializer.SensorLocation?
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            cbCharacteristic.read()
        }
        
        override open func valueUpdated() {
            if let value = cbCharacteristic.value {
                location = CyclingSerializer.readSensorLocation(value)
            }
            super.valueUpdated()
        }
    }
    
    
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.cycling_power_control_point.xml
    //
    open class ControlPoint: Characteristic {
        
        public static let uuid: String = "2A66"
        
        static let writeType = CBCharacteristicWriteType.withResponse
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            cbCharacteristic.notify(true)
        }
        
        override open func valueUpdated() {
            // TODO: Process this response
            super.valueUpdated()
        }
    }
    
}
