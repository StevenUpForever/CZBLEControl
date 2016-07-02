//
//  PeripheralViewModel.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 7/2/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralViewModel: NSObject {
    
    var peripheralObj: CBPeripheral?
    var centralManager = CBCentralManager()
    var cellIndexPath: NSIndexPath?
    
    var uuidString = "UUID unavailable"
    
    //TableView array
    
    var serviceArray = [CharacterInfo]()
    
    //Public delegate for centralManager and peripheral
    
    let managerDelegate = CentralManagerDelegate()
    let peripheralDelegate = PeripheralDelegate()
    
    func loadBLEObjects(peripheral: CBPeripheral) {
        
        peripheralObj = peripheral
        peripheralObj?.delegate = peripheralDelegate
        peripheralObj?.discoverServices(nil)
        
        uuidString = peripheralObj!.identifier.UUIDString
        
        centralManager.delegate = managerDelegate
    }
    
    func loadUI(callBack: (connected: Bool) -> Void) {
        if let state = peripheralObj?.state {
            switch state {
            case .Connected:
                callBack(connected: true)
                
            default:
                callBack(connected: false)
                
            }
        }
    }

}
