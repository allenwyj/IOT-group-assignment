//
//  CurrentValue.swift
//  assignment2
//
//  Created by Yujie Wu on 1/10/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit

class CurrentValue: NSObject {
    var id: String
    var timeStamp: String
    var red: String
    var green: String
    var blue: String
    var temperature: String
    var pressure: String
    
    override init() {
        id = ""
        red = ""
        green = ""
        blue = ""
        timeStamp = ""
        temperature = ""
        pressure = ""
    }
}
