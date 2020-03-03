//
//  FirebaseController.swift
//  assignment2
//
//  Created by Yujie Wu on 30/9/19.
//  Copyright © 2019 Yujie Wu. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseFirestore

class FirebaseController: NSObject, DatabaseProtocol {
    
    var listeners = MulticastDelegate<DatabaseListener>()
    var authController: Auth
    var database: Firestore
    var rgbDataRef: CollectionReference?
    var tempDataRef: CollectionReference?
    var currentValuesRef: CollectionReference?
    var colorDataList: [ColorData]
    var temperatureDataList: [TemperatureData]
    var currentValueDataList: [CurrentValue]
    
    override init() {
        // To use Firebase in our application we first must run the FirebaseApp configure method
        FirebaseApp.configure()
        // We call auth and firestore to get access to these frameworks
        authController = Auth.auth()
        database = Firestore.firestore()
        colorDataList = [ColorData]()
        temperatureDataList = [TemperatureData]()
        currentValueDataList = [CurrentValue]()
        
        super.init()
        
        // This will START THE PROCESS of signing in with an anonymous account
        // The closure will not execute until its recieved a message back which can be any time later
        authController.signInAnonymously() { (authResult, error) in
            guard authResult != nil else {
                fatalError("Firebase authentication failed")
            }
            // Once we have authenticated we can attach our listeners to the firebase firestore
            self.setUpListeners()
        }
    }
    
    func setUpListeners() {
        rgbDataRef = database.collection("rgbData")
        tempDataRef = database.collection("tempData")
        currentValuesRef = database.collection("currentValues")
        
        rgbDataRef?.addSnapshotListener { querySnapshot, error in
            guard (querySnapshot?.documents) != nil else {
                
                return
            }
            self.parseRGBDataSnapshot(snapshot: querySnapshot!)
        }
        
        tempDataRef?.addSnapshotListener { querySnapshot, error in
            guard (querySnapshot?.documents) != nil else {
                
                return
            }
            self.parseTempDataSnapshot(snapshot: querySnapshot!)
        }
        
        currentValuesRef?.addSnapshotListener { querySnapshot, error in
            guard (querySnapshot?.documents) != nil else {
                
                return
            }
            self.parseCurrentValuesDataSnapshot(snapshot: querySnapshot!)
        }
    }
    
    func parseRGBDataSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { change in
            
            let documentRef = change.document.documentID
            let id = change.document.documentID
            
            // Firebase generates the new document then it modifies the document with putting fields.
            // The first step -> create a new document with document ID, listener will catch this change and start update the table,
            // The second step -> firebase modifies the fields of the new document, listener will catch this and go to .modified step.
            if change.type == .added {
                let newRGBData = ColorData()
                newRGBData.id = id
                colorDataList.append(newRGBData)
            }
            
            // Therefore, this is for the second time updateing ( the new document will created in the first
            // updating with empty field, it won't go through this)
            if change.document.data().isEmpty == false {
                let sensorName = change.document.data()["sensorName"] as! String
                let timeStamp = change.document.data()["timeStamp"] as! String
                let red = change.document.data()["red"] as! String
                let green = change.document.data()["green"] as! String
                let blue = change.document.data()["blue"] as! String
                
                // This is for modifying document data after updating in the firebase, and it's for putting values
                // into the new document that is sent by the server.
                if change.type == .modified || change.type == .added {
                    let index = getColorIndexByID(reference: documentRef)!
                    colorDataList[index].id = documentRef
                    colorDataList[index].sensorName = sensorName
                    colorDataList[index].timeStamp = timeStamp
                    colorDataList[index].red = red
                    colorDataList[index].green = green
                    colorDataList[index].blue = blue
                }
                
                if change.type == .removed {
                    if let index = getColorIndexByID(reference: documentRef) {
                        colorDataList.remove(at: index)
                    }
                }
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.colorData || listener.listenerType == ListenerType.all {
                listener.onColorChange(change: .update, colorDataList: colorDataList)
            }
        }
    }
    
    func parseTempDataSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { change in
            
            let documentRef = change.document.documentID
            let id = change.document.documentID
            
            // Firebase generates the new document then it modifies the document with putting fields.
            // The first step -> create a new document with document ID, listener will catch this change and start update the table,
            // The second step -> firebase modifies the fields of the new document, listener will catch this and go to .modified step.
            if change.type == .added {
                let newTempData = TemperatureData()
                newTempData.id = id
                temperatureDataList.append(newTempData)
            }
            
            // Therefore, this is for the second time updateing ( the new document will created in the first
            // updating with empty field, it won't go through this)
            if change.document.data().isEmpty == false {
                let sensorName = change.document.data()["sensorName"] as! String
                let timeStamp = change.document.data()["timeStamp"] as! String
                //let timeStamp = "Testing" // hard code, needs to be removed
                let pressure = change.document.data()["pressure"] as! String
                let temperature = change.document.data()["temperature"] as! String
                
                // This is for modifying document data after updating in the firebase, and it's for putting values
                // into the new document that is sent by the server.
                if change.type == .modified || change.type == .added {
                    let index = getTemperatureIndexByID(reference: documentRef)!
                    temperatureDataList[index].id = documentRef
                    temperatureDataList[index].sensorName = sensorName
                    temperatureDataList[index].timeStamp = timeStamp
                    temperatureDataList[index].pressure = pressure
                    temperatureDataList[index].temperature = temperature
                    
                }
                
                if change.type == .removed {
                    if let index = getTemperatureIndexByID(reference: documentRef) {
                        temperatureDataList.remove(at: index)
                    }
                }
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.temperatureData || listener.listenerType == ListenerType.all {
                listener.onTemperatureChange(change: .update, temperatureDataList: temperatureDataList)
            }
        }
    }
    
    func parseCurrentValuesDataSnapshot(snapshot: QuerySnapshot) {
        snapshot.documentChanges.forEach { change in
            
            let documentRef = change.document.documentID
            let id = change.document.documentID
            
            // Firebase generates the new document then it modifies the document with putting fields.
            // The first step -> create a new document with document ID, listener will catch this change and start update the table,
            // The second step -> firebase modifies the fields of the new document, listener will catch this and go to .modified step.
            if change.type == .added {
                let newCurrentValueData = CurrentValue()
                newCurrentValueData.id = id
                currentValueDataList.append(newCurrentValueData)
            }
            
            // Therefore, this is for the second time updateing ( the new document will created in the first
            // updating with empty field, it won't go through this)
            if change.document.data().isEmpty == false {
                let timeStamp = change.document.data()["timeStamp"] as! String
                let pressure = change.document.data()["pressure"] as! String
                let temperature = change.document.data()["temperature"] as! String
                let red = change.document.data()["red"] as! String
                let green = change.document.data()["green"] as! String
                let blue = change.document.data()["blue"] as! String
                
                // This is for modifying document data after updating in the firebase, and it's for putting values
                // into the new document that is sent by the server.
                if change.type == .modified || change.type == .added {
                    let index = 0
                    currentValueDataList[index].id = documentRef
                    currentValueDataList[index].timeStamp = timeStamp
                    currentValueDataList[index].pressure = pressure
                    currentValueDataList[index].temperature = temperature
                    currentValueDataList[index].red = red
                    currentValueDataList[index].green = green
                    currentValueDataList[index].blue = blue
                }
            }
        }
        
        listeners.invoke { (listener) in
            if listener.listenerType == ListenerType.currentValue || listener.listenerType == ListenerType.all {
                listener.onCurrentValuesChange(change: .update, currentValueDataList: currentValueDataList)
            }
        }
    }
    
    //get the index by ID
    func getColorIndexByID(reference: String) -> Int? {
        for colorData in colorDataList {
            if(colorData.id == reference) {
                return colorDataList.firstIndex(of: colorData)
            }
        }

        return nil
    }
    
    //get the index by ID
    func getTemperatureIndexByID(reference: String) -> Int? {
        for tempData in temperatureDataList {
            if(tempData.id == reference) {
                return temperatureDataList.firstIndex(of: tempData)
            }
        }
        
        return nil
    }
    
    func addListener(listener: DatabaseListener) {
        listeners.addDelegate(listener)
        
        if listener.listenerType == ListenerType.colorData || listener.listenerType == ListenerType.all {
            listener.onColorChange(change: .update, colorDataList: colorDataList)
        }

        if listener.listenerType == ListenerType.temperatureData || listener.listenerType == ListenerType.all {
            listener.onTemperatureChange(change: .update, temperatureDataList: temperatureDataList)
        }
        
        if listener.listenerType == ListenerType.temperatureData || listener.listenerType == ListenerType.all {
            listener.onCurrentValuesChange(change: .update, currentValueDataList: currentValueDataList)
        }
    }
    
    func removeListener(listener: DatabaseListener) {
        listeners.removeDelegate(listener)
    }
}
