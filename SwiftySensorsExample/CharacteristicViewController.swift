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
        
        refreshValue()
        
        characteristic.onValueUpdated.subscribe(with: self) { [weak self] characteristic in
            self?.refreshValue()
        }
    }
    
    private func refreshValue() {
        if let value = characteristic.value {
            valueTextView.text = "0x\(value.hexEncodedString())"
        } else {
            valueTextView.text = ""
        }
    }
    
    @IBAction func readButtonHandler(_ sender: AnyObject) {
        characteristic.readValue()
    }
    
}

extension Data {
    
    func hexEncodedString() -> String {
        return map { String(format: "%02hhx", $0) }.joined()
    }
    
}
