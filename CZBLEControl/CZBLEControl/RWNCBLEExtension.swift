//
//  RWNCBLEExtension.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 9/5/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth

extension RWNCTableViewController: CBCentralManagerDelegate, CBPeripheralDelegate {
    
    //MARK: - CBCentral delegate
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case CBCentralManagerState.PoweredOn:
            break
        case CBCentralManagerState.PoweredOff:
            CustomAlertController.showCancelAlertController("BLE turned off", message: "Please turn on your Bluetooth", target: self)
        default:
            CustomAlertController.showCancelAlertController("Unknown Error", message: "Unknown error, please try again", target: self)
        }
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        let alertController = UIAlertController(title: "Peripheral disconnected", message: "Fallback or save your data", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "back", style: .Default, handler: { (action) in
            if let nav = self.navigationController {
                nav.popViewControllerAnimated(true)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Stay", style: .Cancel, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK: - CBPeripheral delegate
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if error != nil {
            print(error?.localizedDescription)
        } else {
            let indexPath = viewModel.appendDataToValueArray(characteristic)
            if indexPath != nil {
                tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Left)
            }
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        actionBarItem.image = characteristic.isNotifying ? UIImage(named: "unnotifyItem") : UIImage(named: "notifyItem")
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if error != nil {
            print(error?.localizedDescription)
        } else {
            peripheral.readValueForCharacteristic(characteristic)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForDescriptor descriptor: CBDescriptor, error: NSError?) {
        if error != nil {
            print(error?.localizedDescription)
        } else {
            let indexPath = viewModel.appendDataToDescriptorArray(descriptor)
            if indexPath != nil {
                tableView.insertRowsAtIndexPaths([indexPath!], withRowAnimation: .Left)
            }
        }
    }
    
}
