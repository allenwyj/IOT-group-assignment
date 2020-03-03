//
//  TemperatureData.swift
//  assignment2
//
//  Created by Yujie Wu on 30/9/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit

class TemperatureData: NSObject {
    var id: String
    var sensorName: String
    var timeStamp: String
    var temperature: String
    var pressure: String
    
    override init() {
        id = ""
        sensorName = ""
        timeStamp = ""
        temperature = ""
        pressure = ""
    }
}
