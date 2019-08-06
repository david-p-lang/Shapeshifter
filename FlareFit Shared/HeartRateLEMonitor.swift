//
//  HeartRateLEMonitor.swift
//  Shapeshifter
//
//  Created by David Lang on 6/10/15.
//  Copyright (c) 2015 David Lang. All rights reserved.
//

import Foundation
import CoreBluetooth


class HeartRateLEMonitor:NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    
    var centralManager:CBCentralManager!
    var thePeripheral: CBPeripheral!
    var heartRateCharacteristic: CBCharacteristic!
    var currentHeartRate = 0
    var blueToothReady = false
    var bluetoothConnected = false
    
    var InfoService:CBUUID = CBUUID(string: "180A")
    var HeartRateService:CBUUID = CBUUID(string: "180D")
    var HeartRateCharUUID:CBUUID = CBUUID(string: "2A37")
    var HeartRateLocation:CBUUID = CBUUID(string: "2A38")
    var HRManu:CBUUID = CBUUID(string: "2A29")
    var batteryLevelCharUUID:CBUUID = CBUUID(string: "2A19")
    var serialNumberUUID:CBUUID = CBUUID(string: "2A25")
    
    var heartRateCBServiceCollection:[AnyObject] = [CBUUID(string: "180D")]
    var heartRateCBService:CBService!
    var periphs:[AnyObject]!
    var knownMonitors = ""
    
    var heartRateCheckerCount = 0
    var heartRateCheckerNew = ""
    var heartRateCheckerOld = ""
    
    
    var notification = NotificationCenter.default
    
    // Mark: -Central Manager Startup
    func startUpCentralManager() {
        print("Initializing central manager")
        let HRMQueue: DispatchQueue = DispatchQueue(label: "com.agilityfittech.HRMQueue", attributes: .concurrent)

        centralManager = CBCentralManager(delegate: self, queue: HRMQueue)
    }
    // Mark: -DISCOVER DEVICES
    func discoverDevices() {
        print("discovering devices")
        if bluetoothConnected == false {
            
            self.periphs = centralManager.retrieveConnectedPeripherals(withServices: [self.HeartRateService])
            print("system connected peripherals: \(periphs.count)")
            
            //Create Notification for peripheral list
            if periphs.count > 0 {
                for _ in 1...periphs.count {
                    notification.post(name: Notification.Name(rawValue: "devices"), object: nil, userInfo: ["theDevices":"checkPeriphs"])
                }
            }
            
            
        }
        if self.periphs.count == 0 {
            print("Still scanning for a device")
            centralManager.scanForPeripherals(withServices: [HeartRateService], options: nil)
        }
    }
    //==============================STOP SCANNING============================
    func stopScanning() {
        centralManager.stopScan()
    }
    //=============================USER SCAN FOR PERIPHERAL========================
    func scanForMonitor() {
        centralManager.scanForPeripherals(withServices: [HeartRateService], options: nil)
    }
    //=============================CHECK HEART RATE CONNECTION=====================
    func checkHeartRateConnection() {
        switch self.thePeripheral.state {
        case .disconnected:
            bluetoothConnected = false
        default:
            bluetoothConnected = false
        }
    }
    
    //===========================CENTRAL MANAGER FUNCTIONS=========================
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        NSLog("checking state")
        var theLEState = ""
        switch (central.state) {
        case .poweredOff:
            theLEState = "Bluetooth is powered off"
        case .poweredOn:
            theLEState = "Bluetooth is ready"
            blueToothReady = true;
        case .resetting:
            theLEState = "Bluetooth on your device is resetting"
        case .unauthorized:
            theLEState = "Bluetooth on your device is unauthorized"
        case .unknown:
            theLEState = "Bluetooth on your device is unknown"
        case .unsupported:
            theLEState = "Bluetooth type needed is unsupported on this platform"
        }
        NSLog(theLEState)
        notification.post(name: Notification.Name(rawValue: "bluetoothStatus"), object: nil, userInfo: ["theBTState":theLEState])
        if blueToothReady {
            discoverDevices()
        }
    }
    
    func centralManager(_ central: CBCentralManager!, didRetrievePeripherals peripherals: [AnyObject]!) {
        print("--didretrieveIdentifiedPeripheral")
    }
    func centralManager(_ central: CBCentralManager!, didRetrieveConnectedPeripherals peripherals: [AnyObject]!) {
        print("--didretrieveConnectedPeripheral")
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        NSLog("--didconnectperipheral")
        peripheral.delegate = self
        switch (peripheral.state) {
        case .connected:
            NSLog("the central manager reports the peripheral state is connected")
            notification.post(name: Notification.Name(rawValue: "peripheralStatus"), object: nil, userInfo: ["thePeripheralState":"Connected"])
            self.thePeripheral = peripheral
            self.thePeripheral.discoverServices(nil)
            centralManager.stopScan()
            bluetoothConnected = true
        case .disconnected:
            bluetoothConnected = false
            NSLog("peripheral state is disconnected")
        case .connecting:
            NSLog("peripheral state is connecting")
        default:
            NSLog("peripheral state is connecting")
        }
        
    }
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        NSLog("did fail connect")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        NSLog("Discovered \(String(describing: peripheral.name))")
        self.thePeripheral = peripheral
        notification.post(name: Notification.Name(rawValue: "peripheralStatus"), object: nil, userInfo: ["thePeripheralState":"DidDiscover"])
        centralManager.connect(peripheral, options: nil)
        _ = "Disconnected"
        switch (peripheral.state) {
        case .connected:
            NSLog("peripheral state is connected")
            notification.post(name: Notification.Name(rawValue: "peripheralStatus"), object: nil, userInfo: ["thePeripheralState":"Connected"])
            bluetoothConnected = true
            centralManager.stopScan()
            return
        case .disconnected:
            NSLog("peripheral state is disconnected")
            bluetoothConnected = false
        case .connecting:
            NSLog("peripheral state is connecting")
        default:
            print(peripheral.state)
        }
    }
    
    //==============================PERIPHERAL FUNCTIONS==================================
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        NSLog("did discover services")
        if peripheral.services != nil {
            heartRateCBServiceCollection = peripheral.services!
            for heartRateCBService in heartRateCBServiceCollection {
                NSLog("Discovered service: \(heartRateCBService.uuid)")
                if (heartRateCBService.uuidString == "Heart Rate") {
                    
                }
                self.thePeripheral.discoverCharacteristics(nil, for: heartRateCBService as! CBService)
            }
        }
        
    }
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        NSLog("did discover characteristics")
        for chars in service.characteristics! {
            thePeripheral.setNotifyValue(true, for: chars )
            heartRateCharacteristic = chars
            thePeripheral.readValue(for: heartRateCharacteristic)
            self.thePeripheral.setNotifyValue(true, for: heartRateCharacteristic)
        }
        
    }
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic,
                    error: Error?)
    {
        if characteristic.uuid == HeartRateCharUUID {
            
            //--
            guard let characteristicData = characteristic.value else {return}
            
            let byteArray = [UInt8](characteristicData)
            var bpm = 0
            let firstBitValue = byteArray[0] & 0x01
            if firstBitValue == 0 {
                bpm = Int(byteArray[1])
            } else {
                bpm = (Int(byteArray[1]) << 8) + Int(byteArray[2])
            }
            
            
            let outputBPM = String(bpm)
            print("-->"+outputBPM)
            currentHeartRate = Int(outputBPM)!
            
            
            
            notification.post(name: Notification.Name(rawValue: "heartRateBroadcast"), object: nil, userInfo: ["message":outputBPM])
            
            //=====
            
            
            
            
        }
        
    }
}
