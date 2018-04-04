//
//  Timer.swift
//  SwiftySensors iOS
//
//  Created by Josh Levine on 4/3/18.
//  Copyright © 2018 Kinetic. All rights reserved.
//

import Foundation

extension Timer {    
    class func schedule(intervalFromNow: TimeInterval, block: @escaping (CFRunLoopTimer?) -> Void) -> Timer? {
        let fireDate = intervalFromNow + CFAbsoluteTimeGetCurrent()
        let timer = CFRunLoopTimerCreateWithHandler(kCFAllocatorDefault, fireDate, intervalFromNow, 0, 0, block)
        CFRunLoopAddTimer(CFRunLoopGetCurrent(), timer, CFRunLoopMode.commonModes)
        return timer
    }
}
