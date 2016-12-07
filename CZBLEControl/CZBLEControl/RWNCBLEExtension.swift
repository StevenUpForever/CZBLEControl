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
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            break
        case .poweredOff:
            CustomAlertController.showCancelAlertController(NSLocalizedString("BLE turned off", comment: ""), message: NSLocalizedString("Please turn on your Bluetooth", comment: ""), target: self)
        default:
            CustomAlertController.showCancelAlertController(NSLocalizedString("Unknown Error", comment: ""), message: NSLocalizedString("Unknown error, please try again", comment: ""), target: self)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        let alertController = UIAlertController(title: NSLocalizedString("Connect error", comment: ""), message: NSLocalizedString("Cannot connet device, please try again", comment: ""), preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Back", comment: ""), style: .default, handler: { (action) in
            if let nav = self.navigationController {
                nav.popViewController(animated: true)
            }
        }))
        alertController.addAction(UIAlertAction(title: NSLocalizedString("Stay", comment: ""), style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    //MARK: - CBPeripheral delegate
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print(error?.localizedDescription ?? "Haven't update value for characteristic")
        } else {
            let indexPath = viewModel.appendDataToValueArray(characteristic)
            if indexPath != nil {
                tableView.insertRows(at: [indexPath!], with: .left)
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        actionBarItem.image = characteristic.isNotifying ? UIImage(named: "unnotifyItem") : UIImage(named: "notifyItem")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if error != nil {
            print(error?.localizedDescription ?? "Didn't write value")
        } else {
            peripheral.readValue(for: characteristic)
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        if error != nil {
            print(error?.localizedDescription ?? "Didn't update value")
        } else {
            let indexPath = viewModel.appendDataToDescriptorArray(descriptor)
            if indexPath != nil {
                tableView.insertRows(at: [indexPath!], with: .left)
            }
        }
    }
    
}
