//
//  BLETableViewModel.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 6/30/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLETableViewModel: NSObject, CBCentralManagerDelegate {
    
    let centralManager = CBCentralManager()
    
    init(target: AnyObject) {
        centralManager.delegate = self
        
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(BLETableViewController.tableViewRefresh(_:)), forControlEvents: .ValueChanged)
        target.view.addSubview(refresh)
    }
    
    func scanPeripheralInLifeCycle()
    
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
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        //If array contains this peripheral, replace relate object with it due to new RSSI number
        if  peripheralArray.contains({ (blockInfo) -> Bool in
            blockInfo.peripheral == peripheral
        }) {
            
            for index in 0 ..< peripheralArray.count {
                if peripheralArray[index].peripheral == peripheral {
                    peripheralArray[index].RSSI = RSSI
                    let indexPath = NSIndexPath(forRow: index, inSection: 0)
                    if let cell = tableView.cellForRowAtIndexPath(indexPath) as? BLETableViewCell {
                        cell.loadData(peripheralArray[index])
                    }
                    break
                }
            }
            
            //If array doesn't contains such a peripheral, append it to array
        } else {
            peripheralArray.append(PeripheralInfo(peripheral: peripheral, RSSI: RSSI, adData: advertisementData))
            let indexPath = NSIndexPath(forRow: peripheralArray.count - 1, inSection: 0)
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        endIndicatorLoading(SelectedIndexPath)
        
        peripheralObj = peripheral
        self.performSegueWithIdentifier("peripheralControl", sender: self)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        
        endIndicatorLoading(SelectedIndexPath)
        
        CustomAlertController.showCancelAlertController("Connect error", message: "Cannot connet device, please try again", target: self)
    }

}
