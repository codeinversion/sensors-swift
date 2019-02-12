//
//  CyclingPowerSerializer.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2017 Kinetic. All rights reserved.
//

import Foundation

/// :nodoc:
open class CyclingPowerSerializer {
    
    public struct Features: OptionSet {
        public let rawValue: UInt32
        
        public static let PedalPowerBalanceSupported                   = Features(rawValue: 1 << 0)
        public static let AccumulatedTorqueSupported                   = Features(rawValue: 1 << 1)
        public static let WheelRevolutionDataSupported                 = Features(rawValue: 1 << 2)
        public static let CrankRevolutionDataSupported                 = Features(rawValue: 1 << 3)
        public static let ExtremeMagnitudesSupported                   = Features(rawValue: 1 << 4)
        public static let ExtremeAnglesSupported                       = Features(rawValue: 1 << 5)
        public static let TopAndBottomDeadSpotAnglesSupported          = Features(rawValue: 1 << 6)
        public static let AccumulatedEnergySupported                   = Features(rawValue: 1 << 7)
        public static let OffsetCompensationIndicatorSupported         = Features(rawValue: 1 << 8)
        public static let OffsetCompensationSupported                  = Features(rawValue: 1 << 9)
        public static let ContentMaskingSupported                      = Features(rawValue: 1 << 10)
        public static let MultipleSensorLocationsSupported             = Features(rawValue: 1 << 11)
        public static let CrankLengthAdjustmentSupported               = Features(rawValue: 1 << 12)
        public static let ChainLengthAdjustmentSupported               = Features(rawValue: 1 << 13)
        public static let ChainWeightAdjustmentSupported               = Features(rawValue: 1 << 14)
        public static let SpanLengthAdjustmentSupported                = Features(rawValue: 1 << 15)
        public static let SensorMeasurementContext                     = Features(rawValue: 1 << 16)
        public static let InstantaneousMeasurementDirectionSupported   = Features(rawValue: 1 << 17)
        public static let FactoryCalibrationDateSupported              = Features(rawValue: 1 << 18)
        
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
    
    public static func readFeatures(_ data: Data) -> Features {
        let bytes = data.map { $0 }
        var rawFeatures: UInt32 = 0
        if bytes.count > 0 { rawFeatures |= UInt32(bytes[0]) }
        if bytes.count > 1 { rawFeatures |= UInt32(bytes[1]) << 8 }
        if bytes.count > 2 { rawFeatures |= UInt32(bytes[2]) << 16 }
        if bytes.count > 3 { rawFeatures |= UInt32(bytes[3]) << 24 }
        return Features(rawValue: rawFeatures)
    }
    
    struct MeasurementFlags: OptionSet {
        let rawValue: UInt16
        
        static let PedalPowerBalancePresent         = MeasurementFlags(rawValue: 1 << 0)
        static let AccumulatedTorquePresent         = MeasurementFlags(rawValue: 1 << 2)
        static let WheelRevolutionDataPresent       = MeasurementFlags(rawValue: 1 << 4)
        static let CrankRevolutionDataPresent       = MeasurementFlags(rawValue: 1 << 5)
        static let ExtremeForceMagnitudesPresent    = MeasurementFlags(rawValue: 1 << 6)
        static let ExtremeTorqueMagnitudesPresent   = MeasurementFlags(rawValue: 1 << 7)
        static let ExtremeAnglesPresent             = MeasurementFlags(rawValue: 1 << 8)
        static let TopDeadSpotAnglePresent          = MeasurementFlags(rawValue: 1 << 9)
        static let BottomDeadSpotAnglePresent       = MeasurementFlags(rawValue: 1 << 10)
        static let AccumulatedEnergyPresent         = MeasurementFlags(rawValue: 1 << 11)
        static let OffsetCompensationIndicator      = MeasurementFlags(rawValue: 1 << 12)
    }
    
    public struct MeasurementData: CyclingMeasurementData {
        public var timestamp: Double = 0
        public var instantaneousPower: Int16 = 0
        public var pedalPowerBalance: UInt8?
        public var pedalPowerBalanceReference: Bool?
        public var accumulatedTorque: UInt16?
        
        public var cumulativeWheelRevolutions: UInt32?
        public var lastWheelEventTime: UInt16?
        
        public var cumulativeCrankRevolutions: UInt16?
        public var lastCrankEventTime: UInt16?
        
        public var maximumForceMagnitude: Int16?
        public var minimumForceMagnitude: Int16?
        public var maximumTorqueMagnitude: Int16?
        public var minimumTorqueMagnitude: Int16?
        public var maximumAngle: UInt16?
        public var minimumAngle: UInt16?
        public var topDeadSpotAngle: UInt16?
        public var bottomDeadSpotAngle: UInt16?
        public var accumulatedEnergy: UInt16?
    }
    
    
    public static func readMeasurement(_ data: Data) -> MeasurementData {
        var measurement = MeasurementData()
        
        let bytes = data.map { $0 }
        var index: Int = 0
        
        if bytes.count >= 2 {
            let rawFlags: UInt16 = UInt16(bytes[index++=]) | UInt16(bytes[index++=]) << 8
            let flags = MeasurementFlags(rawValue: rawFlags)
            
            if bytes.count >= 4 {
                measurement.instantaneousPower = Int16(bytes[index++=]) | Int16(bytes[index++=]) << 8
         
                if flags.contains(.PedalPowerBalancePresent) && bytes.count >= index {
                    measurement.pedalPowerBalance = bytes[index++=]
                    measurement.pedalPowerBalanceReference = rawFlags & 0x2 == 0x2
                }
                
                if flags.contains(.AccumulatedTorquePresent) && bytes.count >= index + 1 {
                    measurement.accumulatedTorque = UInt16(bytes[index++=]) | UInt16(bytes[index++=]) << 8
                }
                
                if flags.contains(.WheelRevolutionDataPresent) && bytes.count >= index + 6 {
                    var cumulativeWheelRevolutions = UInt32(bytes[index++=])
                    cumulativeWheelRevolutions |= UInt32(bytes[index++=]) << 8
                    cumulativeWheelRevolutions |= UInt32(bytes[index++=]) << 16
                    cumulativeWheelRevolutions |= UInt32(bytes[index++=]) << 24
                    measurement.cumulativeWheelRevolutions = cumulativeWheelRevolutions
                    measurement.lastWheelEventTime = UInt16(bytes[index++=]) | UInt16(bytes[index++=]) << 8
                }
                
                if flags.contains(.CrankRevolutionDataPresent) && bytes.count >= index + 4 {
                    measurement.cumulativeCrankRevolutions = UInt16(bytes[index++=]) | UInt16(bytes[index++=]) << 8
                    measurement.lastCrankEventTime = UInt16(bytes[index++=]) | UInt16(bytes[index++=]) << 8
                }
                
                if flags.contains(.ExtremeForceMagnitudesPresent) && bytes.count >= index + 4 {
                    measurement.maximumForceMagnitude = Int16(bytes[index++=]) | Int16(bytes[index++=]) << 8
                    measurement.minimumForceMagnitude = Int16(bytes[index++=]) | Int16(bytes[index++=]) << 8
                }
                
                if flags.contains(.ExtremeTorqueMagnitudesPresent) && bytes.count >= index + 4 {
                    measurement.maximumTorqueMagnitude = Int16(bytes[index++=]) | Int16(bytes[index++=]) << 8
                    measurement.minimumTorqueMagnitude = Int16(bytes[index++=]) | Int16(bytes[index++=]) << 8
                }
                
                if flags.contains(.ExtremeAnglesPresent) && bytes.count >= index + 3 {
                    // TODO: this bit shifting is not correct.
                    measurement.minimumAngle = UInt16(bytes[index++=]) | UInt16(bytes[index] & 0xF0) << 4
                    measurement.maximumAngle = UInt16(bytes[index++=]) | UInt16(bytes[index++=]) << 4
                }
                
                if flags.contains(.TopDeadSpotAnglePresent) && bytes.count >= index + 2 {
                    measurement.topDeadSpotAngle = UInt16(bytes[index++=]) | UInt16(bytes[index++=]) << 8
                }
                
                if flags.contains(.BottomDeadSpotAnglePresent) && bytes.count >= index + 2 {
                    measurement.bottomDeadSpotAngle = UInt16(bytes[index++=]) | UInt16(bytes[index++=]) << 8
                }
                
                if flags.contains(.AccumulatedEnergyPresent) && bytes.count >= index + 2 {
                    measurement.accumulatedEnergy = UInt16(bytes[index++=]) | UInt16(bytes[index++=]) << 8
                }
            }
        }
        measurement.timestamp = Date.timeIntervalSinceReferenceDate
        return measurement
    }
    
    struct VectorFlags: OptionSet {
        let rawValue: UInt8
        
        static let CrankRevolutionDataPresent   = VectorFlags(rawValue: 1 << 0)
        static let FirstCrankAnglePresent       = VectorFlags(rawValue: 1 << 1)
        static let InstantaneousForcesPresent   = VectorFlags(rawValue: 1 << 2)
        static let InstantaneousTorquesPresent  = VectorFlags(rawValue: 1 << 3)
    }
    
    public struct VectorData {
        public enum MeasurementDirection {
            case unknown
            case tangentialComponent
            case radialComponent
            case lateralComponent
        }
        public var instantaneousMeasurementDirection: MeasurementDirection = .unknown
        public var cumulativeCrankRevolutions: UInt16?
        public var lastCrankEventTime: UInt16?
        public var firstCrankAngle: UInt16?
        public var instantaneousForce: [Int16]?
        public var instantaneousTorque: [Double]?
    }
    
    
    
    
    public static func readVector(_ data: Data) -> VectorData {
        var vector = VectorData()
        
        let bytes = data.map { $0 }
        
        
        let flags = VectorFlags(rawValue: bytes[0])
        
        let measurementDirection = (bytes[0] & 0x30) >> 4
        switch measurementDirection {
        case 0:
            vector.instantaneousMeasurementDirection = .unknown
        case 1:
            vector.instantaneousMeasurementDirection = .tangentialComponent
        case 2:
            vector.instantaneousMeasurementDirection = .radialComponent
        case 3:
            vector.instantaneousMeasurementDirection = .lateralComponent
        default:
            vector.instantaneousMeasurementDirection = .unknown
        }
        var index: Int = 1
        
        if flags.contains(.CrankRevolutionDataPresent) {
            vector.cumulativeCrankRevolutions = UInt16(bytes[index++=]) | UInt16(bytes[index++=]) << 8
            vector.lastCrankEventTime = UInt16(bytes[index++=]) | UInt16(bytes[index++=]) << 8
        }
        if flags.contains(.FirstCrankAnglePresent) {
            vector.firstCrankAngle = UInt16(bytes[index++=]) | UInt16(bytes[index++=]) << 8
        }
        
        // These two arrays are mutually exclusive
        if flags.contains(.InstantaneousForcesPresent) {
            
        } else if flags.contains(.InstantaneousTorquesPresent) {
            let torqueRaw = Int16(bytes[index++=]) | Int16(bytes[index++=]) << 8
            let torque = Double(torqueRaw) / 32.0
            print(torque)
        }
        
        return vector
    }
    
}
