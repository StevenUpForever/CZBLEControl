//
//  CentralManagerDelegate.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 6/30/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth

class CentralManagerDelegate: NSObject, CBCentralManagerDelegate {
    
    //MARK: - CBCentralManager delegate
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        
        switch central.state {
        case .PoweredOn:
            centralManager.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        case .Unsupported:
            CustomAlertController.showCancelAlertController("Not support", message: "Your device doesn't support BLE", target: self)
        case .PoweredOff:
            CustomAlertController.showCancelAlertController("BLE turned off", message: "Please turn on your Bluetooth", target: self)
        case .Unknown:
            CustomAlertController.showCancelAlertController("Unknown Error", message: "Unknown error, please try again", target: self)
        case .Unauthorized:
            CustomAlertController.showCancelAlertController("Unauthorized", message: "Your device is unauthorized to use Bluetooth low energy", target: self)
        default:
            CustomAlertController.showCancelAlertController("Unknown Error", message: "Unknown error, please try again", target: self)
        }
    }
}
