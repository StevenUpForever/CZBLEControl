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
    
    var SelectedIndexPath = IndexPath()
    
    var peripheralArray = [PeripheralInfo]()
    var selectedPeripheralInfo: PeripheralInfo?
    
    var date = Date.timeIntervalSinceReferenceDate
    
    func scanPeripheralInLifeCycle(_ viewWillAppear: Bool) {
        if viewWillAppear && !centralManager.isScanning {
            centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        } else if !viewWillAppear && centralManager.isScanning {
            centralManager.stopScan()
        }
    }
    
    func connectPeripheralWithSelectedRow(_ indexPath: IndexPath, callBack: @escaping (_ poweredOn: Bool) -> Void) {
        SelectedIndexPath = indexPath
        if centralManager.state != .poweredOn {
            callBack(false)
        } else {
            DispatchQueue.main.async(execute: {
                callBack(true)
            })
        }
    }
    
    //Connect peripheral method
    
    func connectToPeripheral(_ cellViewModel: BLECellViewModel) {
        guard let peripheral = cellViewModel.peripheral else {
            return
        }
        centralManager.connect(peripheral, options: nil)
    }
    
    //Segue to destination viewController
    
    func pushToPeripheralController(_ segue: UIStoryboardSegue) {
        if segue.identifier == "peripheralControl" {
            if let peripheralVC = segue.destination as? PeripheralControlViewController {
                if let validPeripheral = selectedPeripheralInfo?.peripheral {
                    peripheralVC.viewModel.loadBLEObjects(validPeripheral, central: centralManager)
                    peripheralVC.viewModel.centralManager = centralManager
                    peripheralVC.navigationItem.title = validPeripheral.name ?? NSLocalizedString("Name Unavailable", comment: "")
                }
            }
        }
    }
    
    func scanPeripheral() {
        if !self.centralManager.isScanning {
            centralManager.scanForPeripherals(withServices: nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    func clearAllPeripherals(_ callBack: (_ indexPaths: [IndexPath]) -> Void) {
        var indexPathArray = [IndexPath]()
        for i in 0 ..< peripheralArray.count {
            indexPathArray.append(IndexPath(row: i, section: 0))
        }
        peripheralArray.removeAll()
        
        callBack(indexPathArray)
    }
    
    func discoverPeripheral(_ peripheral: CBPeripheral, RSSI: NSNumber, adData: [String: AnyObject], callBack: (_ newRow: Bool, _ indexPath: IndexPath) -> Void) {
        if Date.timeIntervalSinceReferenceDate - date > 1.5 {
            
            var index = 0
            while index < peripheralArray.count {
                if peripheralArray[index].peripheral == peripheral {
                    peripheralArray[index].RSSI = RSSI
                    let indexPath = IndexPath(row: index, section: 0)
                    
                    callBack(true, indexPath)
                    
                    break
                }
                index += 1
            }
            if peripheralArray.count == 0 || index == peripheralArray.count  {
                peripheralArray.append(PeripheralInfo(peripheral: peripheral, RSSI: RSSI, adData: adData))
                let indexPath = IndexPath(row: peripheralArray.count - 1, section: 0)
                
                callBack(false, indexPath)
                
            }
            
            date = Date.timeIntervalSinceReferenceDate
            
        }
    }
    
    func replaceSelectedPeripheral() -> IndexPath {
        if (SelectedIndexPath as NSIndexPath).row < peripheralArray.count {
            selectedPeripheralInfo = peripheralArray[(SelectedIndexPath as NSIndexPath).row]
        }
        return SelectedIndexPath
    }
    

}
