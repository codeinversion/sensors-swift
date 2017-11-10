//
//  AppDelegate.swift
//  SwiftySensorsExample
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2017 Kinetic. All rights reserved.
//

import UIKit
import SwiftySensors

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // Customize what services you want to scan for
        SensorManager.instance.setServicesToScanFor([
            CyclingPowerService.self,
            CyclingSpeedCadenceService.self,
            HeartRateService.self])
        
        // Add additional services we want to have access to (but don't want to specifically scan for)
        SensorManager.instance.addServiceTypes([DeviceInformationService.self])
        
        // Set the scan mode (see documentation)
        SensorManager.instance.state = .aggressiveScan
        
        // Capture SwiftySensors log messages and print them to the console. You can inject your own logging system here if desired.
        SensorManager.logSensorMessage = { message in
            print(message)
        }
        
        return true
    }
    
}
