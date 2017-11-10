//
//  CyclingSerializer.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2017 Kinetic. All rights reserved.
//

import Foundation


/// :nodoc:
public protocol CyclingMeasurementData {
    var timestamp: Double { get }
    var cumulativeWheelRevolutions: UInt32? { get }
    var lastWheelEventTime: UInt16? { get }
    var cumulativeCrankRevolutions: UInt16? { get }
    var lastCrankEventTime: UInt16? { get }
}

/// :nodoc:
open class CyclingSerializer {
    
    public enum SensorLocation: UInt8 {
        case other          = 0
        case topOfShoe      = 1
        case inShoe         = 2
        case hip            = 3
        case frontWheel     = 4
        case leftCrank      = 5
        case rightCrank     = 6
        case leftPedal      = 7
        case rightPedal     = 8
        case frontHub       = 9
        case rearDropout    = 10
        case chainstay      = 11
        case rearWheel      = 12
        case rearHub        = 13
        case chest          = 14
        case spider         = 15
        case chainRing      = 16
    }
    
    open static func readSensorLocation(_ data: Data) -> SensorLocation? {
        let bytes = (data as NSData).bytes.bindMemory(to: UInt8.self, capacity: data.count)
        return SensorLocation(rawValue: bytes[0])
    }
    
    open static func calculateWheelKPH(_ current: CyclingMeasurementData, previous: CyclingMeasurementData, wheelCircumferenceCM: Double, wheelTimeResolution: Int) -> Double? {
        guard let cwr1 = current.cumulativeWheelRevolutions else { return nil }
        guard let cwr2 = previous.cumulativeWheelRevolutions else { return nil }
        guard let lwet1 = current.lastWheelEventTime else { return nil }
        guard let lwet2 = previous.lastWheelEventTime else { return nil }
        
        let wheelRevsDelta: UInt32 = deltaWithRollover(cwr1, old: cwr2, max: UInt32.max)
        let wheelTimeDelta: UInt16 = deltaWithRollover(lwet1, old: lwet2, max: UInt16.max)
        
        let wheelTimeSeconds = Double(wheelTimeDelta) / Double(wheelTimeResolution)
        if wheelTimeSeconds > 0 {
            let wheelRPM = Double(wheelRevsDelta) / (wheelTimeSeconds / 60)
            let cmPerKm = 0.00001
            let minsPerHour = 60.0
            return wheelRPM * wheelCircumferenceCM * cmPerKm * minsPerHour
        }
        return 0
    }
    
    open static func calculateCrankRPM(_ current: CyclingMeasurementData, previous: CyclingMeasurementData) -> Double? {
        guard let ccr1 = current.cumulativeCrankRevolutions else { return nil }
        guard let ccr2 = previous.cumulativeCrankRevolutions else { return nil }
        guard let lcet1 = current.lastCrankEventTime else { return nil }
        guard let lcet2 = previous.lastCrankEventTime else { return nil }
        
        let crankRevsDelta: UInt16 = deltaWithRollover(ccr1, old: ccr2, max: UInt16.max)
        let crankTimeDelta: UInt16 = deltaWithRollover(lcet1, old: lcet2, max: UInt16.max)
        
        let crankTimeSeconds = Double(crankTimeDelta) / 1024
        if crankTimeSeconds > 0 {
            return Double(crankRevsDelta) / (crankTimeSeconds / 60)
        }
        return 0
    }
    
    private static func deltaWithRollover<T: BinaryInteger>(_ new: T, old: T, max: T) -> T {
        return old > new ? max - old + new : new - old
    }
    
}
