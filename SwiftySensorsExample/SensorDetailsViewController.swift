//
//  SensorDetailsViewController.swift
//  SwiftySensors
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2017 Kinetic. All rights reserved.
//

import UIKit
import SwiftySensors

class SensorDetailsViewController: UIViewController {
    
    var sensor: Sensor!
    
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var connectButton: UIButton!
    @IBOutlet var tableView: UITableView!
    
    fileprivate var services: [Service] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sensor.onServiceDiscovered.subscribe(with: self) { [weak self] sensor, service in
            self?.rebuildData()
        }
        sensor.onStateChanged.subscribe(with: self) { [weak self] sensor in
            self?.updateConnectButton()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        nameLabel.text = sensor.peripheral.name
        updateConnectButton()
        
        rebuildData()
    }
    
    fileprivate func rebuildData() {
        services = Array(sensor.services.values)
        tableView.reloadData()
    }
    
    fileprivate func updateConnectButton() {
        switch sensor.peripheral.state {
        case .connected:
            connectButton.setTitle("Connected", for: UIControlState())
            connectButton.isEnabled = true
        case .connecting:
            connectButton.setTitle("Connecting", for: UIControlState())
            connectButton.isEnabled = false
        case .disconnected:
            connectButton.setTitle("Disconnected", for: UIControlState())
            connectButton.isEnabled = true
            
            rebuildData()
        case .disconnecting:
            connectButton.setTitle("Disconnecting", for: UIControlState())
            connectButton.isEnabled = false
        }
    }
    
    @IBAction func connectButtonHandler(_ sender: AnyObject) {
        if sensor.peripheral.state == .connected {
            SensorManager.instance.disconnectFromSensor(sensor)
        } else if sensor.peripheral.state == .disconnected {
            SensorManager.instance.connectToSensor(sensor)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let serviceDetails = segue.destination as? ServiceDetailsViewController {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            if indexPath.row >= services.count { return }
            serviceDetails.service = services[indexPath.row]
        }
    }
}



extension SensorDetailsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let serviceCell = tableView.dequeueReusableCell(withIdentifier: "ServiceCell")!
        let service = services[indexPath.row]
        
        serviceCell.textLabel?.text = "\(service)".components(separatedBy: ".").last
        return serviceCell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return services.count
    }
    
}

