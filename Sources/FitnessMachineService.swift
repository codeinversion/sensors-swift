//
//  FitnessMachineService.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2017 Kinetic. All rights reserved.
//

import CoreBluetooth
import Signals

//
// https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.service.fitness_machine.xml
//
/// :nodoc:
open class FitnessMachineService: Service, ServiceProtocol {
    
    public static var uuid: String { return "1826" }
    
    public static var characteristicTypes: Dictionary<String, Characteristic.Type> = [
        Feature.uuid:                       Feature.self,
        ControlPoint.uuid:                  ControlPoint.self,
        Status.uuid:                        Status.self,
        TreadmillData.uuid:                 TreadmillData.self,
        CrossTrainerData.uuid:              CrossTrainerData.self,
        StepClimberData.uuid:               StepClimberData.self,
        StairClimberData.uuid:              StairClimberData.self,
        RowerData.uuid:                     RowerData.self,
        IndoorBikeData.uuid:                IndoorBikeData.self,
        TrainingStatus.uuid:                TrainingStatus.self,
        SupportedSpeedRange.uuid:           SupportedSpeedRange.self,
        SupportedInclinationRange.uuid:     SupportedInclinationRange.self,
        SupportedResistanceLevelRange.uuid: SupportedResistanceLevelRange.self,
        SupportedPowerRange.uuid:           SupportedPowerRange.self,
        SupportedHeartRateRange.uuid:       SupportedHeartRateRange.self
    ]
    
    open var feature: Feature? { return characteristic() }
    open var controlPoint: ControlPoint? { return characteristic() }
    open var status: Status? { return characteristic() }
    open var treadmillData: TreadmillData? { return characteristic() }
    open var crossTrainerData: CrossTrainerData? { return characteristic() }
    open var stepClimberData: StepClimberData? { return characteristic() }
    open var stairClimberData: StairClimberData? { return characteristic() }
    open var rowerData: RowerData? { return characteristic() }
    open var indoorBikeData: IndoorBikeData? { return characteristic() }
    open var trainingStatus: TrainingStatus? { return characteristic() }
    open var supportedSpeedRange: SupportedSpeedRange? { return characteristic() }
    open var supportedInclinationRange: SupportedInclinationRange? { return characteristic() }
    open var supportedResistanceLevelRange: SupportedResistanceLevelRange? { return characteristic() }
    open var supportedPowerRange: SupportedPowerRange? { return characteristic() }
    open var supportedHeartRateRange: SupportedHeartRateRange? { return characteristic() }
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.fitness_machine_feature.xml
    //
    open class Feature: Characteristic {
        
        public static let uuid: String = "2ACC"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            readValue()
        }
        
        public var machine: FitnessMachineSerializer.MachineFeatures?
        public var targetSettings: FitnessMachineSerializer.TargetSettingFeatures?
        
        override open func valueUpdated() {
            if let value = cbCharacteristic.value {
                let result = FitnessMachineSerializer.readFeatures(value)
                machine = result.machine
                targetSettings = result.targetSettings
            }
            super.valueUpdated()
            
            if let service = service {
                service.sensor.onServiceFeaturesIdentified => (service.sensor, service)
            }
        }
        
    }
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.fitness_machine_control_point.xml
    //
    open class ControlPoint: Characteristic {
        
        public static let uuid: String = "2AD9"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            cbCharacteristic.notify(true)
        }
        
        public var response: FitnessMachineSerializer.ControlPointResponse?
        override open func valueUpdated() {
            if let value = cbCharacteristic.value {
                response = FitnessMachineSerializer.readControlPointResponse(value)
            }
            super.valueUpdated()
        }
        
        open func setTargetPower(watts: Int16) {
            cbCharacteristic.write(Data(bytes: FitnessMachineSerializer.setTargetPower(watts: watts)), writeType: .withResponse)
        }
        
        open func setTargetResistanceLevel(level: Int16) {
            cbCharacteristic.write(Data(bytes: FitnessMachineSerializer.setTargetResistanceLevel(level: level)), writeType: .withResponse)
        }
        
        open func setIndoorBikeSimulationParameters(windSpeed: Int16, grade: Int16, crr: UInt8, cw: UInt8) {
            cbCharacteristic.write(Data(bytes: FitnessMachineSerializer.setIndoorBikeSimulationParameters(windSpeed: windSpeed, grade: grade, crr: crr, cw: cw)), writeType: .withResponse)
        }
        
        open func startSpindownProcess() {
            cbCharacteristic.write(Data(bytes: FitnessMachineSerializer.startSpinDownControl()), writeType: .withResponse)
        }
    }
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.fitness_machine_status.xml
    //
    open class Status: Characteristic {
        
        public static let uuid: String = "2ADA"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            cbCharacteristic.notify(true)
        }
        
        override open func valueUpdated() {
            if let value = cbCharacteristic.value {
            }
            super.valueUpdated()
        }
        
    }
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.training_status.xml
    //
    open class TrainingStatus: Characteristic {
        
        public static let uuid: String = "2AD3"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            cbCharacteristic.notify(true)
            readValue()
        }
        
        public var data: FitnessMachineSerializer.TrainingStatus?
        override open func valueUpdated() {
            if let value = cbCharacteristic.value {
                data = FitnessMachineSerializer.readTrainingStatus(value)
            }
            super.valueUpdated()
        }
        
    }
    
    
    
    
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.treadmill_data.xml
    //
    open class TreadmillData: Characteristic {
        
        public static let uuid: String = "2ACD"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            cbCharacteristic.notify(true)
        }
        
        override open func valueUpdated() {
            if let value = cbCharacteristic.value {
                // TODO: deserialize value
            }
            super.valueUpdated()
        }
        
    }
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.cross_trainer_data.xml
    //
    open class CrossTrainerData: Characteristic {
        
        public static let uuid: String = "2ACE"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            cbCharacteristic.notify(true)
        }
        
        override open func valueUpdated() {
            if let value = cbCharacteristic.value {
                // TODO: deserialize value
            }
            super.valueUpdated()
        }
        
    }
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.step_climber_data.xml
    //
    open class StepClimberData: Characteristic {
        
        public static let uuid: String = "2ACF"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            cbCharacteristic.notify(true)
        }
        
        override open func valueUpdated() {
            if let value = cbCharacteristic.value {
                // TODO: deserialize value
            }
            super.valueUpdated()
        }
        
    }
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.stair_climber_data.xml
    //
    open class StairClimberData: Characteristic {
        
        public static let uuid: String = "2AD0"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            cbCharacteristic.notify(true)
        }
        
        override open func valueUpdated() {
            if let value = cbCharacteristic.value {
                // TODO: deserialize value
            }
            super.valueUpdated()
        }
        
    }
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.rower_data.xml
    //
    open class RowerData: Characteristic {
        
        public static let uuid: String = "2AD1"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            cbCharacteristic.notify(true)
        }
        
        override open func valueUpdated() {
            if let value = cbCharacteristic.value {
                // TODO: deserialize value
            }
            super.valueUpdated()
        }
        
    }
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.indoor_bike_data.xml
    //
    open class IndoorBikeData: Characteristic {
        
        public static let uuid: String = "2AD2"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            cbCharacteristic.notify(true)
        }
        
        public var data: FitnessMachineSerializer.IndoorBikeData?
        override open func valueUpdated() {
            if let value = cbCharacteristic.value {
                data = FitnessMachineSerializer.readIndoorBikeData(value)
            }
            super.valueUpdated()
        }
        
    }

    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.supported_speed_range.xml
    //
    open class SupportedSpeedRange: Characteristic {
        
        public static let uuid: String = "2AD4"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            readValue()
        }
        
        override open func valueUpdated() {
            if let value = cbCharacteristic.value {
                // TODO: deserialize value
            }
            super.valueUpdated()
        }
        
    }
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.supported_inclination_range.xml
    //
    open class SupportedInclinationRange: Characteristic {
        
        public static let uuid: String = "2AD5"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            readValue()
        }
        
        override open func valueUpdated() {
            if let value = cbCharacteristic.value {
                // TODO: deserialize value
            }
            super.valueUpdated()
        }
        
    }
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.supported_resistance_level_range.xml
    //
    open class SupportedResistanceLevelRange: Characteristic {
        
        public static let uuid: String = "2AD6"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            readValue()
        }
        
        public var data: FitnessMachineSerializer.SupportedResistanceLevelRange?
        override open func valueUpdated() {
            if let value = cbCharacteristic.value {
                data = FitnessMachineSerializer.readSupportedResistanceLevelRange(value)
            }
            super.valueUpdated()
        }
        
        // -1.0 to 1.0
        public func convert(percent: Double) -> Int16 {
            if let data = data {
                if data.minimumResistanceLevel >= 0 {
                    return Int16(data.minimumResistanceLevel + (percent * (data.maximumResistanceLevel - data.minimumResistanceLevel)))
                } else {
                    let absMax = max(fabs(data.minimumResistanceLevel), data.maximumResistanceLevel)
                    return Int16(max(data.minimumResistanceLevel, min(percent * absMax, data.maximumResistanceLevel)))
                }
            }
            return 0
        }
    }
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.supported_power_range.xml
    //
    open class SupportedPowerRange: Characteristic {
        
        public static let uuid: String = "2AD8"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            readValue()
        }
        
        var data: FitnessMachineSerializer.SupportedPowerRange?
        
        override open func valueUpdated() {
            if let value = cbCharacteristic.value {
                data = FitnessMachineSerializer.readSupportedPowerRange(value)
            }
            super.valueUpdated()
        }
        
    }
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.supported_heart_rate_range.xml
    //
    open class SupportedHeartRateRange: Characteristic {
        
        public static let uuid: String = "2AD7"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            readValue()
        }
        
        override open func valueUpdated() {
            if let value = cbCharacteristic.value {
                // TODO: deserialize value
            }
            super.valueUpdated()
        }
        
    }
    
}



