//
//  BLETableViewCentralManager.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 7/1/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLETableViewCentralManager: NSObject {
    
//    func centralManagerDidUpdateState(central: CBCentralManager) {
//        guard let initializedTarget = target else {
//            print("viewModel didn't invoke set target")
//        }
//        
//        switch central.state {
//        case .PoweredOn:
//            centralManager.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
//        case .Unsupported:
//            CustomAlertController.showCancelAlertController("Not support", message: "Your device doesn't support BLE", target: initializedTarget)
//        case .PoweredOff:
//            CustomAlertController.showCancelAlertController("BLE turned off", message: "Please turn on your Bluetooth", target: initializedTarget)
//        case .Unknown:
//            CustomAlertController.showCancelAlertController("Unknown Error", message: "Unknown error, please try again", target: initializedTarget)
//        case .Unauthorized:
//            CustomAlertController.showCancelAlertController("Unauthorized", message: "Your device is unauthorized to use Bluetooth low energy", target: initializedTarget)
//        default:
//            CustomAlertController.showCancelAlertController("Unknown Error", message: "Unknown error, please try again", target: initializedTarget)
//        }
//    }
//    
//    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
//        
//        guard let initializedTarget = target else {
//            print("viewModel didn't invoke set target")
//        }
//        
//        //If array contains this peripheral, replace relate object with it due to new RSSI number
//        
//        var index = 0
//        while index < peripheralArray.count {
//            if peripheralArray[index].peripheral == peripheral {
//                peripheralArray[index].RSSI = RSSI
//                let indexPath = NSIndexPath(forRow: index, inSection: 0)
//                
//                if let cell = initializedTarget.tableView.cellForRowAtIndexPath(indexPath) as? BLETableViewCell {
//                    cell.loadData(peripheralArray[index])
//                }
//                break
//            }
//            index += 1
//        }
//        if index < peripheralArray.count {
//            peripheralArray.append(PeripheralInfo(peripheral: peripheral, RSSI: RSSI, adData: advertisementData))
//            let indexPath = NSIndexPath(forRow: peripheralArray.count - 1, inSection: 0)
//            initializedTarget.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
//        }
//        
//    }
//    
//    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
//        guard let initializedTarget = target else {
//            print("viewModel didn't invoke set target")
//        }
//        endIndicatorLoading(SelectedIndexPath)
//        peripheralObj = peripheral
//        initializedTarget.performSegueWithIdentifier("peripheralControl", sender: self)
//    }
//    
//    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
//        guard let initializedTarget = target else {
//            print("viewModel didn't invoke set target")
//        }
//        
//        endIndicatorLoading(SelectedIndexPath)
//        
//        CustomAlertController.showCancelAlertController("Connect error", message: "Cannot connet device, please try again", target: initializedTarget)
//    }

}
