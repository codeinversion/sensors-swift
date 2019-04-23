//
//  CharacteristicViewController.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2017 Kinetic. All rights reserved.
//

import UIKit
import SwiftySensors

class CharacteristicViewController: UIViewController {
    
    var characteristic: Characteristic!
    
    @IBOutlet var nameLabel: UILabel!
    
    @IBOutlet var valueTextView: UITextView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        nameLabel.text = "\(characteristic!)".components(separatedBy: ".").last
        
        characteristic.onValueUpdated.subscribe(with: self) { [weak self] characteristic in
            self?.refreshValue()
        }
        
        if let cp = characteristic as? FitnessMachineService.ControlPoint {
            cp.requestControl()
        }
        
        refreshValue()
        
    }
    
    private func refreshValue() {
        print("Value Updated")
        if let value = characteristic.value {
            valueTextView.text = "0x\(value.hexEncodedString())"
        } else {
            valueTextView.text = ""
        }
//        if let cp = characteristic as? FitnessMachineService.ControlPoint {
//            print(cp.response)
            writeButtonHandler(self)
//        }
    }
    
    @IBAction func readButtonHandler(_ sender: AnyObject) {
        characteristic.readValue()
    }
    
    private var power: Int16 = 50
    @IBAction func writeButtonHandler(_ sender: AnyObject) {
        if let cp = characteristic as? FitnessMachineService.ControlPoint {
            cp.setTargetPower(watts: power)
            power += 1
        }
    }
}

extension Data {
    
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
}
