//
//  TemperatureTableViewController.swift
//  assignment2
//
//  Created by Yujie Wu on 30/9/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit

class TemperatureTableViewController: UITableViewController, DatabaseListener {
    
    let SECTION_COLOR = 0
    let CELL_TEMP = "tempCell"
    
    var allTemp: [TemperatureData] = []
    weak var databaseController: DatabaseProtocol?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        databaseController?.addListener(listener: self)
    }
    
    /*
     This method is to set the height of each cell
     */
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    var listenerType = ListenerType.temperatureData
    
    func onColorChange(change: DatabaseChange, colorDataList: [ColorData]) {
        // won't call here
    }
    
    func onCurrentValuesChange(change: DatabaseChange, currentValueDataList: [CurrentValue]) {
        // won;t call here
    }
    
    func onTemperatureChange(change: DatabaseChange, temperatureDataList: [TemperatureData]) {
        allTemp = temperatureDataList
        tableView.reloadData()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allTemp.count
    }
    
    //Each row of the table
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tempCell = tableView.dequeueReusableCell(withIdentifier: CELL_TEMP, for: indexPath) as! TemperatureTableViewCell
        let temperatureData = allTemp[indexPath.row]
        
        tempCell.timeLabel.text = temperatureData.timeStamp
        tempCell.tempLabel.text = "\(temperatureData.temperature) °C"
        tempCell.pressureLabel.text = "\(temperatureData.pressure) kPa"
        tempCell.sensorName.text = temperatureData.sensorName
        
        return tempCell
    }
    
    func displayMessage(title: String, message: String) {
        // Setup an alert to show user details about the Person
        // UIAlertController manages an alert instance
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
}
