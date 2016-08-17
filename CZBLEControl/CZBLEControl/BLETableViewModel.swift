//
//  BLETableViewModel.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 6/30/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLETableViewModel: NSObject {
    
    let centralManager = CBCentralManager()
    
    //Selected indexPath for selection action
    
    var SelectedIndexPath = NSIndexPath()
    
    var peripheralArray = [PeripheralInfo]()
    var selectedPeripheralInfo: PeripheralInfo?
    
    var date = NSDate.timeIntervalSinceReferenceDate()
    
    func scanPeripheralInLifeCycle(viewWillAppear: Bool) {
        if viewWillAppear && !centralManager.isScanning {
            centralManager.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        } else if !viewWillAppear && centralManager.isScanning {
            centralManager.stopScan()
        }
    }
    
    func connectPeripheralWithSelectedRow(indexPath: NSIndexPath, callBack: (poweredOn: Bool) -> Void) {
        SelectedIndexPath = indexPath
        if centralManager.state != .PoweredOn {
            callBack(poweredOn: false)
        } else {
            dispatch_async(dispatch_get_main_queue(), {
                callBack(poweredOn: true)
            })
        }
    }
    
    //Connect peripheral method
    
    func connectToPeripheral(cellViewModel: BLECellViewModel) {
        guard let peripheral = cellViewModel.peripheral else {
            return
        }
        centralManager.connectPeripheral(peripheral, options: nil)
    }
    
    //Segue to destination viewController
    
    func pushToPeripheralController(segue: UIStoryboardSegue) {
        if segue.identifier == "peripheralControl" {
            if let peripheralVC = segue.destinationViewController as? PeripheralControlViewController {
                if let validPeripheral = selectedPeripheralInfo?.peripheral {
                    peripheralVC.viewModel.loadBLEObjects(validPeripheral, central: centralManager)
                    peripheralVC.viewModel.centralManager = centralManager
                    peripheralVC.navigationItem.title = validPeripheral.name ?? "Name Unavailable"
                }
            }
        }
    }
    
    func scanPeripheral() {
        if !self.centralManager.isScanning {
            centralManager.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    func clearAllPeripherals(callBack: (indexPaths: [NSIndexPath]) -> Void) {
        var indexPathArray = [NSIndexPath]()
        for i in 0 ..< peripheralArray.count {
            indexPathArray.append(NSIndexPath(forRow: i, inSection: 0))
        }
        peripheralArray.removeAll()
        
        callBack(indexPaths: indexPathArray)
    }
    
    func discoverPeripheral(peripheral: CBPeripheral, RSSI: NSNumber, adData: [String: AnyObject], callBack: (newRow: Bool, indexPath: NSIndexPath) -> Void) {
        if NSDate.timeIntervalSinceReferenceDate() - date > 1.5 {
            
            var index = 0
            while index < peripheralArray.count {
                if peripheralArray[index].peripheral == peripheral {
                    peripheralArray[index].RSSI = RSSI
                    let indexPath = NSIndexPath(forRow: index, inSection: 0)
                    
                    callBack(newRow: true, indexPath: indexPath)
                    
                    break
                }
                index += 1
            }
            if peripheralArray.count == 0 || index == peripheralArray.count  {
                peripheralArray.append(PeripheralInfo(peripheral: peripheral, RSSI: RSSI, adData: adData))
                let indexPath = NSIndexPath(forRow: peripheralArray.count - 1, inSection: 0)
                
                callBack(newRow: false, indexPath: indexPath)
                
            }
            
            date = NSDate.timeIntervalSinceReferenceDate()
            
        }
    }
    
    func replaceSelectedPeripheral() -> NSIndexPath {
        if SelectedIndexPath.row < peripheralArray.count {
            selectedPeripheralInfo = peripheralArray[SelectedIndexPath.row]
        }
        return SelectedIndexPath
    }
    

}
