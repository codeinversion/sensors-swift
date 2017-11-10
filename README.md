# Swifty Sensors
![iOS](https://img.shields.io/badge/iOS-8.2%2B-blue.svg)
![macOS](https://img.shields.io/badge/macOS-10.11%2B-blue.svg)
![Swift 3.0](https://img.shields.io/badge/swift-3.0-orange.svg)
![License](https://img.shields.io/badge/license-MIT-lightgrey.svg)
[![CocoaPods](https://cocoapod-badges.herokuapp.com/v/SwiftySensors/badge.svg)](https://cocoapods.org/pods/SwiftySensors)

Bluetooth LE Sensor Manager for iOS and macOS.

[Full API Documentation](http://cocoadocs.org/docsets/SwiftySensors/)

## Installation
### CocoaPods
```
use_frameworks!
pod 'SwiftySensors'
```
### Manual
Copy all of the swift files in the `Sources` directory into you project.

### Swift Package Manager
Add this repo url to your dependencies list:
```
dependencies: [
    .Package(url: "https://github.com/kinetic-fit/sensors-swift", Version(X, X, X))
]
```
*Note: If you are using the [Swifty Sensors Kinetic Plugin](https://github.com/kinetic-fit/sensors-swift-kinetic), you cannot use the Swift Package Manager at this time due to no support for objective-c libraries.*

## Usage

See the Example iOS App for a basic example of:
- scanning for **sensors**
- connecting to **sensors**
- discovering **services**
- discovering **characteristics**
- reading values
- **characteristic** notifications

Initialization of a SensorManager is straightforward.

1. Set the **services** you want to scan for
2. Add additional **services** you want to discover on *sensor* (but not scan for in advertisement data)
3. Set the **scan mode** of the manager

```
// Customize what services you want to scan for
SensorManager.instance.setServicesToScanFor([
    CyclingPowerService.self,
    CyclingSpeedCadenceService.self,
    HeartRateService.self
])

// Add additional services we want to have access to (but don't want to specifically scan for)
SensorManager.instance.addServiceTypes([DeviceInformationService.self])

// Set the scan mode (see documentation)
SensorManager.instance.state = .aggressiveScan

// Capture SwiftySensors log messages and print them to the console. You can inject your own logging system here if desired.
SensorManager.logSensorMessage = { message in
    print(message)
}
```

SwiftySensors uses [Signals](https://github.com/artman/Signals) to make observation of the various events easy.
```
// Subscribe to Sensor Discovery Events
SensorManager.instance.onSensorDiscovered.subscribe(on: self) { sensor in
    // sensor has been discovered (but not connected to yet)
}

// Subscribe to value changes on a Characteristic
characteristic.onValueUpdated.subscribe(on: self) { characteristic in
    // characteristic.value was just updated
}
```

All Services and Characteristics are concrete classes to make working with Bluetooth LE sensors much easier.

Example Heart Rate Sensor Hierarchy:
```
Sensor
    - HeartRateService
        - Measurement
        - BodySensorLocation
    - DeviceInformationService
        - SoftwareRevision
        - ModelNumber
        - SerialNumber
        - ...
```

To connect to a Sensor:
```
SensorManager.instance.connectToSensor(sensor)
```

Subscribing to value updates and getting the deserialized value of a Heart Rate Sensor:
```
// The sensor could be selected by a user, selected by a matching algorithm on the sensor's advertised services, etc.
let sensor = < Heart Rate Sensor >

// The function service() on a sensor will try to find the appropriate return type requested
guard let hrService: HeartRateService = sensor.service() else { return }

// The function characteristic() on a service will try to find the appropriate return type requested
guard let hrMeasurement: HeartRateService.Measurement = hrService.characteristic() else { return }
// ... the HeartRateService class also defines the `measurement` property, which is equivalent to the above

hrMeasurement.onValueUpdated.subscribe(on: self) { characteristic in
    // The Measurement characteristic has a deserialized value of the sensor data
    let heartRate = hrMeasurement.currentMeasurement.heartRate    
}
```

## Current Concrete Services and Characteristics
- [Cycling Power](https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.service.cycling_power.xml)
  - [Measurement](https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.cycling_power_measurement.xml)
  - [Feature](https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.cycling_power_feature.xml)
  - [Sensor Location](https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.sensor_location.xml)
  - [Control Point](https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.cycling_power_control_point.xml)
- [Cycling Speed and Cadence](https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.service.cycling_speed_and_cadence.xml)
  - [Measurement](https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.csc_measurement.xml)
  - [Feature](https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.csc_feature.xml)
  - [Sensor Location](https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.sensor_location.xml)
- [Heart Rate](https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.service.heart_rate.xml)
  - [Measurement](https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.heart_rate_measurement.xml)
  - [Body Sensor Location](https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.body_sensor_location.xml)
  - [Control Point](https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=heart_rate_control_point.xml)
- [Device Information](https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.service.device_information.xml)
  - [ManufacturerName](https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.manufacturer_name_string.xml)
  - [ModelNumber](https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.model_number_string.xml)
  - [SerialNumber](https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.serial_number_string.xml)
  - [HardwareRevision](https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.hardware_revision_string.xml)
  - [FirmwareRevision](https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.firmware_revision_string.xml)
  - [SoftwareRevision](https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.software_revision_string.xml)
  - [SystemID](https://www.bluetooth.com/specifications/gatt/viewer?attributeXmlFile=org.bluetooth.characteristic.software_revision_string.xml)

### Extensions and 3rd Party Services
- [Wahoo Trainer Characteristic Extension](https://github.com/kinetic-fit/sensors-swift-wahoo) for the Cycling Power Service
- [Kinetic Sensors](https://github.com/kinetic-fit/sensors-swift-kinetic)

## Injecting Types; Writing Services, Characteristics, Extensions
Adding custom functionality specific to your needs is fairly straightforward.

```
// Customize the Sensor class that the manager instantiates for each sensor
SensorManager.instance.SensorType = < Custom Sensor Class : Extends Sensor >
```

Look at HeartRateService for a simple example of writing your own Service class.

To add new Characteristic types to an existing Service that is not a part of the official spec, take a look at the [Wahoo Trainer Characteristic Extension](https://github.com/kinetic-fit/sensors-swift-wahoo).
**This is NOT a normal solution adopted by BLE sensor manufaturers, but occassionally they break the rules.**

## Serializers
The serialization / deserialization of characteristic data is isolated outside of the Characteristic classes and can be used alone. This can be useful if you already have a Sensor management stack and just need the logic to correctly deserialize various BLE messages.
```
use_frameworks!
pod 'SwiftySensors/Serializers'
```

## Known bugs
None.

## ToDos
There are many official BLE specs that need to be implemented.

## Projects Using SwiftySensors
- [Kinetic Fit](https://itunes.apple.com/us/app/kinetic-fit/id1023388296?mt=8)

Let us know if you want your App listed here!


[Full API Documentation](http://cocoadocs.org/docsets/SwiftySensors/)
