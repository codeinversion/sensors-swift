//
//  HeartRateSerializer.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2017 Kinetic. All rights reserved.
//

import Foundation

/// :nodoc:
open class HeartRateSerializer {
    
    public struct MeasurementData {
        public enum ContactStatus {
            case notSupported
            case notDetected
            case detected
        }
        public var heartRate: UInt16 = 0
        public var contactStatus: ContactStatus = .notSupported
        public var energyExpended: UInt16?
        public var rrInterval: UInt16?
    }
    
    public enum BodySensorLocation: UInt8 {
        case other      = 0
        case chest      = 1
        case wrist      = 2
        case finger     = 3
        case hand       = 4
        case earLobe    = 5
        case foot       = 6
    }
    
    public static func readMeasurement(_ data: Data) -> MeasurementData {
        var measurement = MeasurementData()
        
        let bytes = data.map { $0 }
        if bytes.count < 2 {
            return measurement
        }
        
        var index: Int = 0
        let flags = bytes[index++=];
        
        if flags & 0x01 == 0 {
            measurement.heartRate = UInt16(bytes[index++=])
        } else if bytes.count > 2 {
            measurement.heartRate = UInt16(bytes[index++=]) | UInt16(bytes[index++=]) << 8
        }
        
        let contactStatusBits = (flags | 0x06) >> 1
        if contactStatusBits == 2 {
            measurement.contactStatus = .notDetected
        } else if contactStatusBits == 3 {
            measurement.contactStatus = .detected
        }
        if flags & 0x08 == 0x08 && bytes.count > 4 {
            measurement.energyExpended = UInt16(bytes[index++=]) | UInt16(bytes[index++=]) << 8
        }
        if flags & 0x10 == 0x10 && bytes.count > 6 {
            measurement.rrInterval = UInt16(bytes[index++=]) | UInt16(bytes[index++=]) << 8
        }
        return measurement
    }
    
    
    public static func readSensorLocation(_ data: Data) -> BodySensorLocation? {
        let bytes = data.map { $0 }
        if bytes.count == 0 { return nil }
        return BodySensorLocation(rawValue: bytes[0])
    }
    
    public static func writeResetEnergyExpended() -> [UInt8] {
        return [0x01]
    }
    
}
