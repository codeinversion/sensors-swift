//
//  SensorListViewController.swift
//  SwiftySensorsExample
//
//  https://github.com/kinetic-fit/sensors-swift
//
//  Copyright © 2017 Kinetic. All rights reserved.
//

import UIKit
import SwiftySensors

class SensorListViewController: UITableViewController {
    
    fileprivate var sensors: [Sensor] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        SensorManager.instance.onSensorDiscovered.subscribe(with: self) { [weak self] sensor in
            guard let s = self else { return }
            if !s.sensors.contains(sensor) {
                s.sensors.append(sensor)
                s.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        sensors = SensorManager.instance.sensors
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sensors.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sensorCell = tableView.dequeueReusableCell(withIdentifier: "SensorCell")!
        let sensor = sensors[indexPath.row]
        sensorCell.textLabel?.text = sensor.peripheral.name
        return sensorCell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let sensorDetails = segue.destination as? SensorDetailsViewController {
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            if indexPath.row >= sensors.count { return }
            sensorDetails.sensor = sensors[indexPath.row]
        }
    }
    
}
