//
//  Operators.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2017 Kinetic. All rights reserved.
//

import Foundation

public extension SignedInteger {
    
    /// Increment this SignedInteger by 1
    mutating func increment() {
        self = self.advanced(by: 1)
    }
    
    /// Decrement this SignedInteger by 1
    mutating func decrement() {
        self = self.advanced(by: -1)
    }
    
}

prefix operator ++=
postfix operator ++=
prefix operator --=
postfix operator --=

/// Increment this SignedInteger and return the new value
public prefix func ++= <T: SignedInteger>(v: inout T) -> T {
    v.increment()
    return v
}

/// Increment this SignedInteger and return the old value
public postfix func ++= <T: SignedInteger>(v: inout T) -> T {
    let result = v
    v.increment()
    return result
}

/// Decrement this SignedInteger and return the new value
public prefix func --= <T: SignedInteger>(v: inout T) -> T {
    v.decrement()
    return v
}

/// Decrement this SignedInteger and return the old value
public postfix func --= <T: SignedInteger>(v: inout T) -> T {
    let result = v
    v.decrement()
    return result
}
