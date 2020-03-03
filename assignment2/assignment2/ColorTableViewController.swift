//
//  ColorTableViewController.swift
//  assignment2
//
//  Created by Yujie Wu on 30/9/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit

class ColorTableViewController: UITableViewController, DatabaseListener{
    
    let SECTION_COLOR = 0
    let CELL_COLOR = "rgbCell"
    
    var allRGB: [ColorData] = []
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
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    
    var listenerType = ListenerType.colorData
    
    func onColorChange(change: DatabaseChange, colorDataList: [ColorData]) {
        allRGB = colorDataList
        self.tableView.reloadData()
    }
    
    
    func onTemperatureChange(change: DatabaseChange, temperatureDataList: [TemperatureData]) {
        // Won't be called.
    }
    
    func onCurrentValuesChange(change: DatabaseChange, currentValueDataList: [CurrentValue]) {
        // won't use
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allRGB.count
    }
    
    /*
     This method is to set the height of each cell
     */
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    /*
     This method is to put values into the rgb cell
     */
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rgbCell = tableView.dequeueReusableCell(withIdentifier: CELL_COLOR, for: indexPath) as! ColorTableViewCell
        let color = allRGB[indexPath.row]
            
        rgbCell.timeLabel.text = color.timeStamp
        rgbCell.sensorName.text = color.sensorName
        
        if color.red != "" {
            let red = Float(color.red)?.squareRoot()
            let green = Float(color.green)?.squareRoot()
            let blue = Float(color.blue)?.squareRoot()
            rgbCell.colorView.backgroundColor = UIColor(red: CGFloat(red!)/255.0, green: CGFloat(green!)/255.0, blue: CGFloat(blue!)/255.0, alpha: 0.8)
        }
        
        return rgbCell
        
    }
    
    func displayMessage(title: String, message: String) {
        // Setup an alert to show user details about the Person
        // UIAlertController manages an alert instance
        let alertController = UIAlertController(title: title, message: message, preferredStyle: UIAlertController.Style.alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertAction.Style.default,handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }

}
