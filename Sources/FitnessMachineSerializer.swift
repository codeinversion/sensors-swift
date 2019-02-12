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
        
        public static let averageSpeedSupported                 = MachineFeatures(rawValue: 1 << 0)
        public static let cadenceSupported                      = MachineFeatures(rawValue: 1 << 1)
        public static let totalDistanceSupported                = MachineFeatures(rawValue: 1 << 2)
        public static let inclinationSupported                  = MachineFeatures(rawValue: 1 << 3)
        public static let elevationGainSupported                = MachineFeatures(rawValue: 1 << 4)
        public static let paceSupported                         = MachineFeatures(rawValue: 1 << 5)
        public static let stepCountSupported                    = MachineFeatures(rawValue: 1 << 6)
        public static let resistanceLevelSupported              = MachineFeatures(rawValue: 1 << 7)
        public static let strideCountSupported                  = MachineFeatures(rawValue: 1 << 8)
        public static let expendedEnergySupported               = MachineFeatures(rawValue: 1 << 9)
        public static let heartRateMeasurementSupported         = MachineFeatures(rawValue: 1 << 10)
        public static let metabolicEquivalentSupported          = MachineFeatures(rawValue: 1 << 11)
        public static let elapsedTimeSupported                  = MachineFeatures(rawValue: 1 << 12)
        public static let remainingTimeSupported                = MachineFeatures(rawValue: 1 << 13)
        public static let powerMeasurementSupported             = MachineFeatures(rawValue: 1 << 14)
        public static let forceOnBeltAndPowerOutputSupported    = MachineFeatures(rawValue: 1 << 15)
        public static let userDataRetentionSupported            = MachineFeatures(rawValue: 1 << 16)
        
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
    
    public struct TargetSettingFeatures: OptionSet {
        public let rawValue: UInt32
        
        public static let speedTargetSettingSupported                               = TargetSettingFeatures(rawValue: 1 << 0)
        public static let inclinationTargetSettingSupported                         = TargetSettingFeatures(rawValue: 1 << 1)
        public static let resistanceTargetSettingSupported                          = TargetSettingFeatures(rawValue: 1 << 2)
        public static let powerTargetSettingSupported                               = TargetSettingFeatures(rawValue: 1 << 3)
        public static let heartRateTargetSettingSupported                           = TargetSettingFeatures(rawValue: 1 << 4)
        public static let targetedExpendedEnergyConfigurationSupported              = TargetSettingFeatures(rawValue: 1 << 5)
        public static let targetedStepNumberConfigurationSupported                  = TargetSettingFeatures(rawValue: 1 << 6)
        public static let targetedStrideNumberConfigurationSupported                = TargetSettingFeatures(rawValue: 1 << 7)
        public static let targetedDistanceConfigurationSupported                    = TargetSettingFeatures(rawValue: 1 << 8)
        public static let targetedTrainingTimeConfigurationSupported                = TargetSettingFeatures(rawValue: 1 << 9)
        public static let targetedTimeInTwoHeartRateZonesConfigurationSupported     = TargetSettingFeatures(rawValue: 1 << 10)
        public static let targetedTimeInThreeHeartRateZonesConfigurationSupported   = TargetSettingFeatures(rawValue: 1 << 11)
        public static let targetedTimeInFiveHeartRateZonesConfigurationSupported    = TargetSettingFeatures(rawValue: 1 << 12)
        public static let indoorBikeSimulationParametersSupported                   = TargetSettingFeatures(rawValue: 1 << 13)
        public static let wheelCircumferenceConfigurationSupported                  = TargetSettingFeatures(rawValue: 1 << 14)
        public static let spinDownControlSupported                                  = TargetSettingFeatures(rawValue: 1 << 15)
        public static let targetedCadenceConfigurationSupported                     = TargetSettingFeatures(rawValue: 1 << 16)
        
        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
    
    public static func readFeatures(_ data: Data) -> (machine: MachineFeatures, targetSettings: TargetSettingFeatures) {
        let bytes = data.map { $0 }
        var rawMachine: UInt32 = UInt32(bytes[0])
        rawMachine |= UInt32(bytes[1]) << 8
        rawMachine |= UInt32(bytes[2]) << 16
        rawMachine |= UInt32(bytes[3]) << 24
        var rawTargetSettings: UInt32 = UInt32(bytes[4])
        rawTargetSettings |= UInt32(bytes[5]) << 8
        rawTargetSettings |= UInt32(bytes[6]) << 16
        rawTargetSettings |= UInt32(bytes[7]) << 24
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
    
    public static func readTrainingStatus(_ data: Data) -> TrainingStatus {
        var status = TrainingStatus()
        let bytes = data.map { $0 }
        status.flags = TrainerStatusFlags(rawValue: bytes[0])
        status.status = TrainingStatusField(rawValue: bytes[1]) ?? .other
        if status.flags.contains(.TrainingStatusStringPresent), bytes.count > 2 {
            let statusBytes = bytes.suffix(from: 2)
            status.statusString = String(bytes: statusBytes, encoding: .utf8)
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
        case unknown                                = 0xFF
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
        public var requestOpCode: ControlOpCode = .unknown
        public var resultCode: ResultCode = .opCodeNotSupported
        
        // Target Speed Params when the request is SpinDownControler
        public var targetSpeedLow: Float?
        public var targetSpeedHigh: Float?
    }
    
    public static func readControlPointResponse(_ data: Data) -> ControlPointResponse {
        let bytes = data.map { $0 }
        var response = ControlPointResponse()
        if bytes.count > 2, bytes[0] == ControlOpCode.responseCode.rawValue {
            response.requestOpCode = ControlOpCode(rawValue: bytes[1]) ?? .unknown
            response.resultCode = ResultCode(rawValue: bytes[2]) ?? .opCodeNotSupported
            
            if response.resultCode == .success && response.requestOpCode == .spinDownControl {
                // If success and spindown control response, the target high / low speeds are tacked onto the end
                if bytes.count > 6 {
                    response.targetSpeedLow =  Float(UInt16(bytes[3]) | UInt16(bytes[4]) << 8) / 100
                    response.targetSpeedHigh = Float(UInt16(bytes[5]) | UInt16(bytes[6]) << 8) / 100
                }
            }
        }
        
        return response
    }
    
    public struct IndoorBikeSimulationParameters: Equatable {
        
        let windSpeed: Double
        let grade: Double
        let crr: Double
        let crw: Double
        
        public static func ==(lhs: FitnessMachineSerializer.IndoorBikeSimulationParameters, rhs: FitnessMachineSerializer.IndoorBikeSimulationParameters) -> Bool {
            return abs(lhs.windSpeed - rhs.windSpeed) <= .ulpOfOne &&
                abs(lhs.grade - rhs.grade) <= .ulpOfOne &&
                abs(lhs.crr - rhs.crr) <= .ulpOfOne &&
                abs(lhs.crw - rhs.crw) <= .ulpOfOne
        }
    }
    
    public static func setIndoorBikeSimulationParameters(_ parameters: IndoorBikeSimulationParameters) -> [UInt8] {
        // windSpeed = meters / second  res 0.001
        // grade = percentage           res 0.01
        // crr = unitless               res 0.0001
        // cw = kg / meter              res 0.01
        let mpsN = Int16(parameters.windSpeed * 1000)
        let gradeN = Int16(parameters.grade * 100)
        let crrN = UInt8(Int(parameters.crr * 10000) & 0xFF)
        let crwN = UInt8(Int(parameters.crw * 100) & 0xFF)
        return [
            ControlOpCode.setIndoorBikeSimulationParameters.rawValue,
            UInt8(mpsN & 0xFF), UInt8(mpsN >> 8 & 0xFF),
            UInt8(gradeN & 0xFF), UInt8(gradeN >> 8 & 0xFF),
            crrN,
            crwN
        ]
    }
    
    public static func requestControl() -> [UInt8] {
        return [
            ControlOpCode.requestControl.rawValue
        ]
    }
    
    public static func reset() -> [UInt8] {
        return [
            ControlOpCode.reset.rawValue
        ]
    }
    
    public static func startOrResume() -> [UInt8] {
        return [
            ControlOpCode.startOrResume.rawValue
        ]
    }
    
    public static func stop() -> [UInt8] {
        return [
            ControlOpCode.stopOrPause.rawValue,
            0x01
        ]
    }
    
    public static func pause() -> [UInt8] {
        return [
            ControlOpCode.stopOrPause.rawValue,
            0x02
        ]
    }
    
    public static func setTargetResistanceLevel(level: Double) -> [UInt8] {
        // level = unitless     res 0.1
        let levelN = Int16(level * 10)
        return [
            ControlOpCode.setTargetResistanceLevel.rawValue,
            UInt8(levelN & 0xFF), UInt8(levelN >> 8 & 0xFF)
        ]
    }
    
    public static func setTargetPower(watts: Int16) -> [UInt8] {
        return [
            ControlOpCode.setTargetPower.rawValue,
            UInt8(watts & 0xFF), UInt8(watts >> 8 & 0xFF)
        ]
    }
    
    public static func startSpinDownControl() -> [UInt8] {
        return [
            ControlOpCode.spinDownControl.rawValue,
            0x01
        ]
    }
    
    public static func ignoreSpinDownControlRequest() -> [UInt8] {
        return [
            ControlOpCode.spinDownControl.rawValue,
            0x02
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
    
    
    public static func readIndoorBikeData(_ data: Data) -> IndoorBikeData {
        var bikeData = IndoorBikeData()
        let bytes = data.map { $0 }
        var index: Int = 0
        
        let rawFlags: UInt16 = UInt16(bytes[index++=]) | UInt16(bytes[index++=]) << 8
        bikeData.flags = IndoorBikeDataFlags(rawValue: rawFlags)
        
        if !bikeData.flags.contains(.MoreData) {
            let value: UInt16 = UInt16(bytes[index++=]) | UInt16(bytes[index++=]) << 8
            bikeData.instantaneousSpeed = Double(value) / 100.0
        }
        if bikeData.flags.contains(.AverageSpeedPresent) {
            let value: UInt16 = UInt16(bytes[index++=]) | UInt16(bytes[index++=]) << 8
            bikeData.averageSpeed = Double(value) / 100.0
        }
        if bikeData.flags.contains(.InstantaneousCadencePresent) {
            let value: UInt16 = UInt16(bytes[index++=]) | UInt16(bytes[index++=]) << 8
            bikeData.instantaneousCadence = Double(value) / 2.0
        }
        if bikeData.flags.contains(.AverageCadencePresent) {
            let value: UInt16 = UInt16(bytes[index++=]) | UInt16(bytes[index++=]) << 8
            bikeData.averageCadence = Double(value) / 2.0
        }
        if bikeData.flags.contains(.TotalDistancePresent) {
            var value: UInt32 = UInt32(bytes[index++=])
            value |= UInt32(bytes[index++=]) << 8
            value |= UInt32(bytes[index++=]) << 16
            bikeData.totalDistance = value
        }
        if bikeData.flags.contains(.ResistanceLevelPresent) {
            let value: Int16 = Int16(bytes[index++=]) | Int16(bytes[index++=]) << 8
            bikeData.resistanceLevel = value
        }
        if bikeData.flags.contains(.InstantaneousPowerPresent) {
            let value: Int16 = Int16(bytes[index++=]) | Int16(bytes[index++=]) << 8
            bikeData.instantaneousPower = value
        }
        if bikeData.flags.contains(.AveragePowerPresent) {
            let value: Int16 = Int16(bytes[index++=]) | Int16(bytes[index++=]) << 8
            bikeData.averagePower = value
        }
        if bikeData.flags.contains(.ExpendedEnergyPresent) {
            bikeData.totalEnergy = UInt16(bytes[index++=]) | UInt16(bytes[index++=]) << 8
            bikeData.energyPerHour = UInt16(bytes[index++=]) | UInt16(bytes[index++=]) << 8
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
            bikeData.elapsedTime = UInt16(bytes[index++=]) | UInt16(bytes[index++=]) << 8
        }
        if bikeData.flags.contains(.RemainingTimePresent) {
            bikeData.remainingTime = UInt16(bytes[index++=]) | UInt16(bytes[index++=]) << 8
        }
        return bikeData
    }
    
    
    public struct SupportedResistanceLevelRange {
        public var minimumResistanceLevel: Double = 0
        public var maximumResistanceLevel: Double = 0
        public var minimumIncrement: Double = 0
    }
    
    public static func readSupportedResistanceLevelRange(_ data: Data) -> SupportedResistanceLevelRange {
        let bytes = data.map { $0 }
        var response = SupportedResistanceLevelRange()
        let value1: Int16 = Int16(bytes[0]) | Int16(bytes[1]) << 8
        let value2: Int16 = Int16(bytes[2]) | Int16(bytes[3]) << 8
        let value3: UInt16 = UInt16(bytes[4]) | UInt16(bytes[5]) << 8
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
    
    public static func readSupportedPowerRange(_ data: Data) -> SupportedPowerRange {
        let bytes = data.map { $0 }
        var response = SupportedPowerRange()
        response.minimumPower = Int16(bytes[0]) | Int16(bytes[1]) << 8
        response.maximumPower = Int16(bytes[2]) | Int16(bytes[3]) << 8
        response.minimumIncrement = UInt16(bytes[4]) | UInt16(bytes[5]) << 8
        return response
    }
    
    
    
    
    public enum MachineStatusOpCode: UInt8 {
        case reservedForFutureUse                       = 0x00
        case reset                                      = 0x01
        case stoppedOrPausedByUser                      = 0x02
        case stoppedBySafetyKey                         = 0x03
        case startedOrResumedByUser                     = 0x04
        case targetSpeedChanged                         = 0x05
        case targetInclineChanged                       = 0x06
        case targetResistancLevelChanged                = 0x07
        case targetPowerChanged                         = 0x08
        case targetHeartRateChanged                     = 0x09
        case targetedExpendedEnergyChanged              = 0x0A
        case targetedNumberOfStepsChanged               = 0x0B
        case targetedNumberOfStridesChanged             = 0x0C
        case targetedDistanceChanged                    = 0x0D
        case targetedTrainingTimeChanged                = 0x0E
        case targetedTimeInTwoHeartRateZonesChanged     = 0x0F
        case targetedTimeInThreeHeartRateZonesChanged   = 0x10
        case targetedTimeInFiveHeartRateZonesChanged    = 0x11
        case indoorBikeSimulationParametersChanged      = 0x12
        case wheelCircumferenceChanged                  = 0x13
        case spinDownStatus                             = 0x14
        case targetedCadenceChanged                     = 0x15
        case controlPermissionLost                      = 0xFF
    }
    
    public struct MachineStatusMessage {
        public var opCode: MachineStatusOpCode = .reservedForFutureUse
        
        public enum SpinDownStatus: UInt8 {
            case reservedForFutureUse   = 0x00
            case spinDownRequested      = 0x01
            case success                = 0x02
            case error                  = 0x03
            case stopPedaling           = 0x04
        }
        
        public var spinDownStatus: SpinDownStatus?
        public var spinDownTime: TimeInterval?
        public var targetPower: Int16?
        public var targetResistanceLevel: Double?
        public var targetSimParameters: IndoorBikeSimulationParameters?
        
    }
    
    public static func readMachineStatus(_ data: Data) -> MachineStatusMessage {
        var message = MachineStatusMessage()
        
        let bytes = data.map { $0 }
        if bytes.count > 0 {
            message.opCode = MachineStatusOpCode(rawValue: bytes[0]) ?? .reservedForFutureUse
        }
        
        switch message.opCode {
        case .reservedForFutureUse:
            break
        case .reset:
            break
        case .stoppedOrPausedByUser:
            if bytes.count > 1 {
                // 0x01 = stop
                // 0x02 = pause
            }
            break
        case .stoppedBySafetyKey:
            break
        case .startedOrResumedByUser:
            break
        case .targetSpeedChanged:
            if bytes.count > 2 {
                // UInt16 km / hour w/ res 0.01
                // message.targetSpeed = UInt16(bytes[1]) | UInt16(bytes[2]) << 8
            }
            break
        case .targetInclineChanged:
            if bytes.count > 2 {
                // Int16 percent w/ res 0.1
                // message.targetIncline = Int16(bytes[1]) | Int16(bytes[2]) << 8
            }
            break
        case .targetResistancLevelChanged:
            if bytes.count > 2 {
                // ??? the spec cannot be correct here
                // If we go by the Supported Resistance Level Range characteristic,
                // this value *should* be a SInt16 w/ res 0.1
                message.targetResistanceLevel = Double(Int16(bytes[1]) | Int16(bytes[2]) << 8) / 10
            }
            break
        case .targetPowerChanged:
            if bytes.count > 2 {
                // Int16 watts w/ res 1
                message.targetPower = Int16(bytes[1]) | Int16(bytes[2]) << 8
            }
            break
        case .targetHeartRateChanged:
            if bytes.count > 1 {
                // UInt8 bpm w/ res 1
                // message.targetHeartRate = bytes[1]
            }
            break
        case .targetedExpendedEnergyChanged:
            if bytes.count > 2 {
                // UInt16 cals w/ res 1
                // message.targetedExpendedEnergy = UInt16(bytes[1]) | UInt16(bytes[2]) << 8
            }
            break
        case .targetedNumberOfStepsChanged:
            if bytes.count > 2 {
                // UInt16 steps w/ res 1
                // message.targetedNumberOfSteps = UInt16(bytes[1]) | UInt16(bytes[2]) << 8
            }
            break
        case .targetedNumberOfStridesChanged:
            if bytes.count > 2 {
                // UInt16 strides w/ res 1
                // message.targetedNumberOfStrides = UInt16(bytes[1]) | UInt16(bytes[2]) << 8
            }
            break
        case .targetedDistanceChanged:
            if bytes.count > 3 {
                // UInt24 meters w/ res 1
            }
            break
        case .targetedTrainingTimeChanged:
            if bytes.count > 2 {
                // UInt16 seconds w/ res 1
                // message.targetedTrainingTime = UInt16(bytes[1]) | UInt16(bytes[2]) << 8
            }
            break
        case .targetedTimeInTwoHeartRateZonesChanged:
            break
        case .targetedTimeInThreeHeartRateZonesChanged:
            break
        case .targetedTimeInFiveHeartRateZonesChanged:
            break
        case .indoorBikeSimulationParametersChanged:
            if bytes.count > 6 {
                let windSpeed = Double(Int16(bytes[1]) | Int16(bytes[2]) << 8) / 1000
                let grade = Double(Int16(bytes[3]) | Int16(bytes[4]) << 8) / 100
                let crr = Double(bytes[5]) / 10000
                let cwr = Double(bytes[6]) / 100
                message.targetSimParameters = IndoorBikeSimulationParameters(windSpeed: windSpeed, grade: grade, crr: crr, crw: cwr)
            }
            break
        case .wheelCircumferenceChanged:
            if bytes.count > 2 {
                // UInt16 mm w/ res 0.1
                // message.wheelCircumferenceChanged = UInt16(bytes[1]) | UInt16(bytes[2]) << 8
            }
            break
        case .spinDownStatus:
            if bytes.count > 1 {
                message.spinDownStatus = MachineStatusMessage.SpinDownStatus(rawValue: bytes[1])
                
                if message.spinDownStatus == .success || message.spinDownStatus == .error, bytes.count > 3 {
                    // Milliseconds attached: convert to seconds
                    message.spinDownTime = TimeInterval(UInt16(bytes[2]) | UInt16(bytes[3]) << 8) / 1000
                }
            }
            break
        case .targetedCadenceChanged:
            if bytes.count > 2 {
                // UInt16 rpm w/ res 0.5
                // message.targetedCadence = UInt16(bytes[1]) | UInt16(bytes[2]) << 8
            }
            break
        case .controlPermissionLost:
            break
            
        }
        return message
    }
    
}
