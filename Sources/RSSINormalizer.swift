//
//  RSSINormalizer.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2017 Kinetic. All rights reserved.
//

import Foundation

/**
 Normalize a raw RSSI value to a linear scale.
 
 Derived from Android's RSSI signal level calculator
 https://github.com/android/platform_frameworks_base/blob/master/wifi/java/android/net/wifi/WifiManager.java#L1654
 */
public class RSSINormalizer {
    
    /**
     Calculates the level of the signal. This should be used any time a signal is being shown to the user.
     
     - parameter rssi: The power of the signal measured in RSSI.
     - parameter numLevels: The number of levels to consider in the calculated level.
     - parameter rssiMin: Lower bound of expected RSSI values (results in 0 Signal Level).
     - parameter rssiMax: Upper bound of expected RSSI values (results in `numLevels-1` Signal Level).
     - returns: A level of the signal, given in the range of 0 to numLevels-1 (both inclusive).
     */
    public static func calculateSignalLevel(_ rssi: Int, numLevels: Int, rssiMin: Int = -100, rssiMax: Int = -65) -> Int {
        if rssi <= rssiMin {
            return 0
        } else if rssi >= rssiMax {
            return numLevels - 1
        }
        let inputRange = Float(rssiMax - rssiMin)
        let outputRange = Float(numLevels - 1)
        return Int(Float(rssi - rssiMin) * outputRange / inputRange)
    }
    
}
