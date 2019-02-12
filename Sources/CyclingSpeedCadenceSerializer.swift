//
//  CyclingSpeedCadenceSerializer.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2017 Kinetic. All rights reserved.
//

import Foundation

/// :nodoc:
open class CyclingSpeedCadenceSerializer {
    
    struct MeasurementFlags: OptionSet {
        let rawValue: UInt8
        
        static let WheelRevolutionDataPresent   = MeasurementFlags(rawValue: 1 << 0)
        static let CrankRevolutionDataPresent   = MeasurementFlags(rawValue: 1 << 1)
    }
    
    public struct Features: OptionSet {
        public let rawValue: UInt16
        
        public static let WheelRevolutionDataSupported         = Features(rawValue: 1 << 0)
        public static let CrankRevolutionDataSupported         = Features(rawValue: 1 << 1)
        public static let MultipleSensorLocationsSupported     = Features(rawValue: 1 << 2)
        
        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }
    }
    
    public struct MeasurementData: CyclingMeasurementData, CustomDebugStringConvertible {
        public var timestamp: Double = 0
        public var cumulativeWheelRevolutions: UInt32?
        public var lastWheelEventTime: UInt16?
        public var cumulativeCrankRevolutions: UInt16?
        public var lastCrankEventTime: UInt16?
        
        public var debugDescription: String {
            return "\(cumulativeWheelRevolutions ?? 0)  \(lastWheelEventTime ?? 0)  \(cumulativeCrankRevolutions ?? 0)  \(lastCrankEventTime ?? 0)"
        }
    }
    
    
    public static func readFeatures(_ data: Data) -> Features {
        let bytes = data.map { $0 }
        let rawFeatures: UInt16 = UInt16(bytes[0]) | UInt16(bytes[1]) << 8
        return Features(rawValue: rawFeatures)
    }
    
    public static func readMeasurement(_ data: Data) -> MeasurementData {
        var measurement = MeasurementData()
        
        let bytes = data.map { $0 }
        var index: Int = 0
        
        let rawFlags: UInt8 = bytes[index++=]
        let flags = MeasurementFlags(rawValue: rawFlags)
        
        if flags.contains(.WheelRevolutionDataPresent) {
            var cumulativeWheelRevolutions = UInt32(bytes[index++=])
            cumulativeWheelRevolutions |= UInt32(bytes[index++=]) << 8
            cumulativeWheelRevolutions |= UInt32(bytes[index++=]) << 16
            cumulativeWheelRevolutions |= UInt32(bytes[index++=]) << 24
            measurement.cumulativeWheelRevolutions = cumulativeWheelRevolutions
            measurement.lastWheelEventTime = UInt16(bytes[index++=]) | UInt16(bytes[index++=]) << 8
        }
        
        if flags.contains(.CrankRevolutionDataPresent) {
            measurement.cumulativeCrankRevolutions = UInt16(bytes[index++=]) | UInt16(bytes[index++=]) << 8
            measurement.lastCrankEventTime = UInt16(bytes[index++=]) | UInt16(bytes[index++=]) << 8
        }
        
        measurement.timestamp = Date.timeIntervalSinceReferenceDate
        
        return measurement
    }
    
}
