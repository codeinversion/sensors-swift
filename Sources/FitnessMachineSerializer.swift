//
//  FitnessMachineSerializer.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2017 Kinetic. All rights reserved.
//

import Foundation

/// :nodoc:
open class FitnessMachineSerializer {
    
    public struct MachineFeatures: OptionSet {
        public let rawValue: UInt32
        
        public static let AverageSpeedSupported                 = MachineFeatures(rawValue: 1 << 0)
        public static let CadenceSupported                      = MachineFeatures(rawValue: 1 << 1)
        public static let TotalDistanceSupported                = MachineFeatures(rawValue: 1 << 2)
        public static let InclinationSupported                  = MachineFeatures(rawValue: 1 << 3)
        public static let ElevationGainSupported                = MachineFeatures(rawValue: 1 << 4)
        public static let PaceSupported                         = MachineFeatures(rawValue: 1 << 5)
        public static let StepCountSupported                    = MachineFeatures(rawValue: 1 << 6)
        public static let ResistanceLevelSupported              = MachineFeatures(rawValue: 1 << 7)
        public static let StrideCountSupported                  = MachineFeatures(rawValue: 1 << 8)
        public static let ExpendedEnergySupported               = MachineFeatures(rawValue: 1 << 9)
        public static let HeartRateMeasurementSupported         = MachineFeatures(rawValue: 1 << 10)
        public static let MetabolicEquivalentSupported          = MachineFeatures(rawValue: 1 << 11)
        public static let ElapsedTimeSupported                  = MachineFeatures(rawValue: 1 << 12)
        public static let RemainingTimeSupported                = MachineFeatures(rawValue: 1 << 13)
        public static let PowerMeasurementSupported             = MachineFeatures(rawValue: 1 << 14)
        public static let ForceOnBeltAndPowerOutputSupported    = MachineFeatures(rawValue: 1 << 15)
        public static let UserDataRetentionSupported            = MachineFeatures(rawValue: 1 << 16)
        
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
    
    public struct TargetSettingFeatures: OptionSet {
        public let rawValue: UInt32
        
        public static let SpeedTargetSettingSupported                               = TargetSettingFeatures(rawValue: 1 << 0)
        public static let InclinationTargetSettingSupported                         = TargetSettingFeatures(rawValue: 1 << 1)
        public static let ResistanceTargetSettingSupported                          = TargetSettingFeatures(rawValue: 1 << 2)
        public static let PowerTargetSettingSupported                               = TargetSettingFeatures(rawValue: 1 << 3)
        public static let HeartRateTargetSettingSupported                           = TargetSettingFeatures(rawValue: 1 << 4)
        public static let TargetedExpendedEnergyConfigurationSupported              = TargetSettingFeatures(rawValue: 1 << 5)
        public static let TargetedStepNumberConfigurationSupported                  = TargetSettingFeatures(rawValue: 1 << 6)
        public static let TargetedStrideNumberConfigurationSupported                = TargetSettingFeatures(rawValue: 1 << 7)
        public static let TargetedDistanceConfigurationSupported                    = TargetSettingFeatures(rawValue: 1 << 8)
        public static let TargetedTrainingTimeConfigurationSupported                = TargetSettingFeatures(rawValue: 1 << 9)
        public static let TargetedTimeInTwoHeartRateZonesConfigurationSupported     = TargetSettingFeatures(rawValue: 1 << 10)
        public static let TargetedTimeInThreeHeartRateZonesConfigurationSupported   = TargetSettingFeatures(rawValue: 1 << 11)
        public static let TargetedTimeInFiveHeartRateZonesConfigurationSupported    = TargetSettingFeatures(rawValue: 1 << 12)
        public static let IndoorBikeSimulationParametersSupported                   = TargetSettingFeatures(rawValue: 1 << 13)
        public static let WheelCircumferenceConfigurationSupported                  = TargetSettingFeatures(rawValue: 1 << 14)
        public static let SpinDownControlSupported                                  = TargetSettingFeatures(rawValue: 1 << 15)
        public static let TargetedCadenceConfigurationSupported                     = TargetSettingFeatures(rawValue: 1 << 16)
        
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
    
    open static func readFeatures(_ data: Data) -> (machine: MachineFeatures, targetSettings: TargetSettingFeatures) {
        let bytes = (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count)
        var rawMachine: UInt32 = ((UInt32)(bytes[0]))
        rawMachine |= ((UInt32)(bytes[1])) << 8
        rawMachine |= ((UInt32)(bytes[2])) << 16
        rawMachine |= ((UInt32)(bytes[3])) << 24
        var rawTargetSettings: UInt32 = ((UInt32)(bytes[4]))
        rawTargetSettings |= ((UInt32)(bytes[5])) << 8
        rawTargetSettings |= ((UInt32)(bytes[6])) << 16
        rawTargetSettings |= ((UInt32)(bytes[7])) << 24
        return (MachineFeatures(rawValue: rawMachine), TargetSettingFeatures(rawValue: rawTargetSettings))
    }
    
    
    public struct TrainerStatusFlags: OptionSet {
        public let rawValue: UInt8
        
        static let TrainingStatusStringPresent  = TrainerStatusFlags(rawValue: 1 << 0)
        static let ExtendedStringPresent        = TrainerStatusFlags(rawValue: 1 << 2)
        
        public init(rawValue: UInt8) {
            self.rawValue = rawValue
        }
    }
    
    public enum TrainingStatusField: UInt8 {
        case other                          = 0x00
        case idle                           = 0x01
        case warmingUp                      = 0x02
        case lowIntensityInterval           = 0x03
        case highIntensityInterval          = 0x04
        case recoveryInterval               = 0x05
        case isometric                      = 0x06
        case heartRateControl               = 0x07
        case fitnessTest                    = 0x08
        case speedOutsideControlRegionLow   = 0x09
        case speedOutsideControlRegionHigh  = 0x0A
        case coolDown                       = 0x0B
        case wattControl                    = 0x0C
        case manualMode                     = 0x0D
        case preWorkout                     = 0x0E
        case postWorkout                    = 0x0F
    }
    
    public struct TrainingStatus {
        public var flags: TrainerStatusFlags = TrainerStatusFlags()
        public var status: TrainingStatusField = .other
        public var statusString: String?
    }
    
    open static func readTrainingStatus(_ data: Data) -> TrainingStatus {
        var status = TrainingStatus()
        let bytes = (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count)
        status.flags = TrainerStatusFlags(rawValue: bytes[0])
        status.status = TrainingStatusField(rawValue: bytes[1]) ?? .other
        if status.flags.contains(.TrainingStatusStringPresent) {
            // ToDo: parse bytes 2-16 into a string (UTF8)
            status.statusString = "ToDo"
        }
        return status
    }
    
    
    public enum ControlOpCode: UInt8 {
        case requestControl                         = 0x00
        case reset                                  = 0x01
        case setTargetSpeed                         = 0x02
        case setTargetInclincation                  = 0x03
        case setTargetResistanceLevel               = 0x04
        case setTargetPower                         = 0x05
        case setTargetHeartRate                     = 0x06
        case startOrResume                          = 0x07
        case stopOrPause                            = 0x08
        case setTargetedExpendedEnergy              = 0x09
        case setTargetedNumberOfSteps               = 0x0A
        case setTargetedNumberOfStrides             = 0x0B
        case setTargetedDistance                    = 0x0C
        case setTargetedTrainingTime                = 0x0D
        case setTargetedTimeInTwoHeartRateZones     = 0x0E
        case setTargetedTimeInThreeHeartRateZones   = 0x0F
        case setTargetedTimeInFiveHeartRateZones    = 0x10
        case setIndoorBikeSimulationParameters      = 0x11
        case setWheelCircumference                  = 0x12
        case spinDownControl                        = 0x13
        case setTargetedCadence                     = 0x14
        case responseCode                           = 0x80
    }
    
    
    public enum ResultCode: UInt8 {
        case reserved               = 0x00
        case success                = 0x01
        case opCodeNotSupported     = 0x02
        case invalidParameter       = 0x03
        case operationFailed        = 0x04
        case controlNotPermitted    = 0x05
    }
    
    public struct ControlPointResponse {
        public var requestOpCode: UInt8 = 0
        public var resultCode: UInt8 = 0
    }
    
    open static func readControlPointResponse(_ data: Data) -> ControlPointResponse {
        let bytes = (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count)
        var response = ControlPointResponse()
        // bytes[0] == 0x80
        response.requestOpCode = bytes[1]
        response.resultCode = bytes[2]
        // bytes 3-19 == response paramaters ...
        
        return response
    }
    
    open static func setIndoorBikeSimulationParameters(windSpeed: Int16, grade: Int16, crr: UInt8, cw: UInt8) -> [UInt8] {
        // windSpeed = meters / second  res 0.001
        // grade = percentage           res 0.01
        // crr = unitless               res 0.0001
        // cw = kg / meter              res 0.01
        return [
            ControlOpCode.setIndoorBikeSimulationParameters.rawValue,
            UInt8(windSpeed & 0xFF), UInt8(windSpeed >> 8),
            UInt8(grade & 0xFF), UInt8(grade >> 8),
            crr,
            cw
        ]
    }
    
    open static func requestControl() -> [UInt8] {
        return [
            ControlOpCode.requestControl.rawValue
        ]
    }
    
    open static func reset() -> [UInt8] {
        return [
            ControlOpCode.reset.rawValue
        ]
    }
    
    open static func startOrResume() -> [UInt8] {
        return [
            ControlOpCode.startOrResume.rawValue
        ]
    }
    
    open static func stop() -> [UInt8] {
        return [
            ControlOpCode.stopOrPause.rawValue,
            0x01
        ]
    }
    
    open static func pause() -> [UInt8] {
        return [
            ControlOpCode.stopOrPause.rawValue,
            0x02
        ]
    }
    
    open static func setTargetResistanceLevel(level: Int16) -> [UInt8] {
        // level = unitless     res 0.1
        return [
            ControlOpCode.setTargetResistanceLevel.rawValue,
            UInt8(level & 0xFF), UInt8(level >> 8)
        ]
    }
    
    open static func setTargetPower(watts: Int16) -> [UInt8] {
        return [
            ControlOpCode.setTargetPower.rawValue,
            UInt8(watts & 0xFF), UInt8(watts >> 8)
        ]
    }
    
    open static func startSpinDownControl() -> [UInt8] {
        return [
            ControlOpCode.spinDownControl.rawValue,
            0x01
        ]
    }
    
    
    public struct IndoorBikeDataFlags: OptionSet {
        public let rawValue: UInt16
        
        public static let MoreData                      = IndoorBikeDataFlags(rawValue: 1 << 0)
        public static let AverageSpeedPresent           = IndoorBikeDataFlags(rawValue: 1 << 1)
        public static let InstantaneousCadencePresent   = IndoorBikeDataFlags(rawValue: 1 << 2)
        public static let AverageCadencePresent         = IndoorBikeDataFlags(rawValue: 1 << 3)
        public static let TotalDistancePresent          = IndoorBikeDataFlags(rawValue: 1 << 4)
        public static let ResistanceLevelPresent        = IndoorBikeDataFlags(rawValue: 1 << 5)
        public static let InstantaneousPowerPresent     = IndoorBikeDataFlags(rawValue: 1 << 6)
        public static let AveragePowerPresent           = IndoorBikeDataFlags(rawValue: 1 << 7)
        public static let ExpendedEnergyPresent         = IndoorBikeDataFlags(rawValue: 1 << 8)
        public static let HeartRatePresent              = IndoorBikeDataFlags(rawValue: 1 << 9)
        public static let MetabolicEquivalentPresent    = IndoorBikeDataFlags(rawValue: 1 << 10)
        public static let ElapsedTimePresent            = IndoorBikeDataFlags(rawValue: 1 << 11)
        public static let RemainingTimePresent          = IndoorBikeDataFlags(rawValue: 1 << 12)
        
        public init(rawValue: UInt16) {
            self.rawValue = rawValue
        }
    }
    
    
    public struct IndoorBikeData {
        public var flags: IndoorBikeDataFlags = IndoorBikeDataFlags(rawValue: 0)
        
        public var instantaneousSpeed: Double?
        public var averageSpeed: Double?
        public var instantaneousCadence: Double?
        public var averageCadence: Double?
        public var totalDistance: UInt32?
        public var resistanceLevel: Int16?
        public var instantaneousPower: Int16?
        public var averagePower: Int16?
        public var totalEnergy: UInt16?
        public var energyPerHour: UInt16?
        public var energyPerMinute: UInt8?
        public var heartRate: UInt8?
        public var metabolicEquivalent: Double?
        public var elapsedTime: UInt16?
        public var remainingTime: UInt16?
    }
    
    
    open static func readIndoorBikeData(_ data: Data) -> IndoorBikeData {
        var bikeData = IndoorBikeData()
        let bytes = (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count)
        var index: Int = 0
        
        let rawFlags: UInt16 = ((UInt16)(bytes[index++=])) | ((UInt16)(bytes[index++=])) << 8
        bikeData.flags = IndoorBikeDataFlags(rawValue: rawFlags)
        
        if bikeData.flags.contains(.MoreData) {
            let value: UInt16 = ((UInt16)(bytes[index++=])) | ((UInt16)(bytes[index++=])) << 8
            bikeData.instantaneousSpeed = Double(value) / 100.0
        }
        if bikeData.flags.contains(.AverageSpeedPresent) {
            let value: UInt16 = ((UInt16)(bytes[index++=])) | ((UInt16)(bytes[index++=])) << 8
            bikeData.averageSpeed = Double(value) / 100.0
        }
        if bikeData.flags.contains(.InstantaneousCadencePresent) {
            let value: UInt16 = ((UInt16)(bytes[index++=])) | ((UInt16)(bytes[index++=])) << 8
            bikeData.instantaneousCadence = Double(value) / 2.0
        }
        if bikeData.flags.contains(.AverageCadencePresent) {
            let value: UInt16 = ((UInt16)(bytes[index++=])) | ((UInt16)(bytes[index++=])) << 8
            bikeData.averageCadence = Double(value) / 2.0
        }
        if bikeData.flags.contains(.TotalDistancePresent) {
            let value: UInt32 = ((UInt32)(bytes[index++=])) | ((UInt32)(bytes[index++=])) << 8 | ((UInt32)(bytes[index++=])) << 16
            bikeData.totalDistance = value
        }
        if bikeData.flags.contains(.ResistanceLevelPresent) {
            let value: Int16 = ((Int16)(bytes[index++=])) | ((Int16)(bytes[index++=])) << 8
            bikeData.resistanceLevel = value
        }
        if bikeData.flags.contains(.InstantaneousPowerPresent) {
            let value: Int16 = ((Int16)(bytes[index++=])) | ((Int16)(bytes[index++=])) << 8
            bikeData.instantaneousPower = value
        }
        if bikeData.flags.contains(.AveragePowerPresent) {
            let value: Int16 = ((Int16)(bytes[index++=])) | ((Int16)(bytes[index++=])) << 8
            bikeData.averagePower = value
        }
        if bikeData.flags.contains(.ExpendedEnergyPresent) {
            bikeData.totalEnergy = ((UInt16)(bytes[index++=])) | ((UInt16)(bytes[index++=])) << 8
            bikeData.energyPerHour = ((UInt16)(bytes[index++=])) | ((UInt16)(bytes[index++=])) << 8
            bikeData.energyPerMinute = bytes[index++=]
        }
        if bikeData.flags.contains(.HeartRatePresent) {
            bikeData.heartRate = bytes[index++=]
        }
        if bikeData.flags.contains(.MetabolicEquivalentPresent) {
            let value: UInt8 = bytes[index++=]
            bikeData.metabolicEquivalent = Double(value) / 10.0
        }
        if bikeData.flags.contains(.ElapsedTimePresent) {
            bikeData.elapsedTime = ((UInt16)(bytes[index++=])) | ((UInt16)(bytes[index++=])) << 8            
        }
        if bikeData.flags.contains(.RemainingTimePresent) {
            bikeData.remainingTime = ((UInt16)(bytes[index++=])) | ((UInt16)(bytes[index++=])) << 8
        }
        return bikeData
    }
    
    
    public struct SupportedResistanceLevelRange {
        public var minimumResistanceLevel: Double = 0
        public var maximumResistanceLevel: Double = 0
        public var minimumIncrement: Double = 0
    }
    
    open static func readSupportedResistanceLevelRange(_ data: Data) -> SupportedResistanceLevelRange {
        let bytes = (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count)
        var response = SupportedResistanceLevelRange()
        let value1: Int16 = ((Int16)(bytes[0])) | ((Int16)(bytes[1])) << 8
        let value2: Int16 = ((Int16)(bytes[2])) | ((Int16)(bytes[3])) << 8
        let value3: UInt16 = ((UInt16)(bytes[4])) | ((UInt16)(bytes[5])) << 8
        response.minimumResistanceLevel = Double(value1) / 10.0
        response.maximumResistanceLevel = Double(value2) / 10.0
        response.minimumIncrement = Double(value3) / 10.0
        return response
    }
    
    public struct SupportedPowerRange {
        public var minimumPower: Int16 = 0
        public var maximumPower: Int16 = 0
        public var minimumIncrement: UInt16 = 0
    }
    
    open static func readSupportedPowerRange(_ data: Data) -> SupportedPowerRange {
        let bytes = (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count)
        var response = SupportedPowerRange()
        response.minimumPower = ((Int16)(bytes[0])) | ((Int16)(bytes[1])) << 8
        response.maximumPower = ((Int16)(bytes[2])) | ((Int16)(bytes[3])) << 8
        response.minimumIncrement = ((UInt16)(bytes[4])) | ((UInt16)(bytes[5])) << 8
        return response
    }
}
