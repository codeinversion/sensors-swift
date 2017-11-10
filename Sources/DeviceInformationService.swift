//
//  DeviceInformationService.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2017 Kinetic. All rights reserved.
//

import CoreBluetooth

//
// https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.service.device_information.xml
//
/// :nodoc:
open class DeviceInformationService: Service, ServiceProtocol {
    
    public static var uuid: String { return "180A" }
    
    public static var characteristicTypes: Dictionary<String, Characteristic.Type> = [
        ManufacturerName.uuid:  ManufacturerName.self,
        ModelNumber.uuid:       ModelNumber.self,
        SerialNumber.uuid:      SerialNumber.self,
        HardwareRevision.uuid:  HardwareRevision.self,
        FirmwareRevision.uuid:  FirmwareRevision.self,
        SoftwareRevision.uuid:  SoftwareRevision.self,
        SystemID.uuid:          SystemID.self
    ]
    
    open var manufacturerName: ManufacturerName? { return characteristic() }
    open var modelNumber: ModelNumber? { return characteristic() }
    open var serialNumber: SerialNumber? { return characteristic() }
    open var hardwareRevision: HardwareRevision? { return characteristic() }
    open var firmwareRevision: FirmwareRevision? { return characteristic() }
    open var softwareRevision: SoftwareRevision? { return characteristic() }
    open var systemID: SystemID? { return characteristic() }
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.manufacturer_name_string.xml
    //
    open class ManufacturerName: UTF8Characteristic {
        
        public static let uuid: String = "2A29"
        
    }
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.model_number_string.xml
    //
    open class ModelNumber: UTF8Characteristic {
        
        public static let uuid: String = "2A24"
        
    }
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.serial_number_string.xml
    //
    open class SerialNumber: UTF8Characteristic {
        
        public static let uuid: String = "2A25"
        
    }
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.hardware_revision_string.xml
    //
    open class HardwareRevision: UTF8Characteristic {
        
        public static let uuid: String = "2A27"
        
    }
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.firmware_revision_string.xml
    //
    open class FirmwareRevision: UTF8Characteristic {
        
        public static let uuid: String = "2A26"
        
    }
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.software_revision_string.xml
    //
    open class SoftwareRevision: UTF8Characteristic {
        public static let uuid: String = "2A28"
    }
    
    //
    // https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.software_revision_string.xml
    //
    open class SystemID: Characteristic {
        
        public static let uuid: String = "2A23"
        
        required public init(service: Service, cbc: CBCharacteristic) {
            super.init(service: service, cbc: cbc)
            
            readValue()
        }
    }
    
}
