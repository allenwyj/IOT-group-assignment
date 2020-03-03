//
//  HomeViewController.swift
//  assignment2
//
//  Created by Yujie Wu on 30/9/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, DatabaseListener {
    
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var currentPressureLabel: UILabel!
    @IBOutlet weak var currentTimeStamp: UILabel!
    @IBOutlet weak var colorView: UITextView!
    @IBOutlet weak var safeLabel: UILabel!
    
    var allCurrentValues: [CurrentValue] = []
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
    
    var listenerType = ListenerType.currentValue

    func onColorChange(change: DatabaseChange, colorDataList: [ColorData]) {
        // won't call
    }
    
    func onTemperatureChange(change: DatabaseChange, temperatureDataList: [TemperatureData]) {
        // won't call
    }
    
    /*
     This method is to put details in the home screen. The fire condition is also informed here.
     - real-time temp >= 80 -> fire
     - real-time temp >= 70 -> fire risk is very high
     - real-time temp >= 60 -> fire risk is high
     - real-time temp >= 50 -> fire risk is medium
     - real-time temp < 50 -> fire risk is low
     */
    func onCurrentValuesChange(change: DatabaseChange, currentValueDataList: [CurrentValue]) {
        allCurrentValues = currentValueDataList
        
        let currentValue = allCurrentValues[0]
        
        currentTempLabel.text = "\(currentValue.temperature) °C"
        currentPressureLabel.text = "\(currentValue.pressure) kPa"
        currentTimeStamp.text = "Last Updated: \(currentValue.timeStamp)"
        
        
        let red = Float(currentValue.red)?.squareRoot()
        let green = Float(currentValue.green)?.squareRoot()
        let blue = Float(currentValue.blue)?.squareRoot()
        
        colorView.backgroundColor = UIColor(red: CGFloat(red!)/255.0, green: CGFloat(green!)/255.0, blue: CGFloat(blue!)/255.0, alpha: 0.8)
        
        let currentTemp = Double(currentValue.temperature)
        
        let fireColor:Double = 180
        let mediumTemp: Double = 50
        let highTemp:Double = 60
        let veryHighTemp: Double = 70
        let fireTemp:Double = 80
        var warningSign = ""
        //Check for very high temperature and high value on red color for fire
        if fireTemp.isLessThanOrEqualTo(currentTemp!) && fireColor.isLessThanOrEqualTo(Double(red!)){
            warningSign = "Fire!!!"
            safeLabel.textColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
        } else if veryHighTemp.isLessThanOrEqualTo(currentTemp!) {
            warningSign = "Very High"
            safeLabel.textColor = UIColor(red: 1, green: 0.2, blue: 0, alpha: 1)
        } else if highTemp.isLessThanOrEqualTo(currentTemp!) {
            warningSign = "High"
            safeLabel.textColor = UIColor(red: 1, green: 0.4, blue: 0, alpha: 1)
        } else if mediumTemp.isLessThanOrEqualTo(currentTemp!) {
            warningSign = "Medium"
            safeLabel.textColor = UIColor(red: 1, green: 0.6, blue: 0, alpha: 1)
        } else {
            warningSign = "Low"
            safeLabel.textColor = UIColor(red: 0, green: 1, blue: 0.3, alpha: 1)
        }
        
        if warningSign == "" {
            warningSign = "n.a."
        } else {
            safeLabel.text = "Fire Risk: \(warningSign)"
        }
        
    }
}
