//
//  DatabaseProtocol.swift
//  assignment2
//
//  Created by Yujie Wu on 30/9/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import Foundation

enum DatabaseChange {
    case add
    case remove
    case update
}

enum ListenerType {
    case colorData
    case temperatureData
    case currentValue
    case all
}

protocol DatabaseListener: AnyObject {
    var listenerType: ListenerType {get set}
    func onColorChange(change: DatabaseChange, colorDataList: [ColorData])
    func onTemperatureChange(change: DatabaseChange, temperatureDataList: [TemperatureData])
    func onCurrentValuesChange(change: DatabaseChange, currentValueDataList: [CurrentValue])
}

protocol DatabaseProtocol: AnyObject {
    func addListener(listener: DatabaseListener)
    func removeListener(listener: DatabaseListener)
}
