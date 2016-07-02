//
//  BLETableViewModel.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 6/30/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol BLETableViewModelDelegate: class {
    func didGetResultConnectToPeripheral(success: Bool, indexPath: NSIndexPath)
    func needUpdateTableViewUI(indexPaths: [NSIndexPath])
    func updateNewTableViewRow(existed: Bool, indexPath: NSIndexPath)
    func differentManagerStatus(errorMessage: String)
}

class BLETableViewModel: NSObject, CBCentralManagerDelegate {
    
    let centralManager = CBCentralManager()
    
    let refresh = UIRefreshControl()
    
    var SelectedIndexPath = NSIndexPath()
    
    var peripheralArray = [PeripheralInfo]()
    var selectedPeripheralInfo: PeripheralInfo?
    
    weak var delegate: BLETableViewModelDelegate?
    
    override init() {
        super.init()
        centralManager.delegate = self
        
        refresh.addTarget(self, action: #selector(BLETableViewModel.tableViewRefresh(_:)), forControlEvents: .ValueChanged)
    }
    
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
    
    func connectToPeripheral(peripheral: CBPeripheral) {
        centralManager.connectPeripheral(peripheral, options: nil)
    }
    
    //MARK: - CBCentralManager delegate
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case .PoweredOn:
            centralManager.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        case .Unsupported:
            delegate?.differentManagerStatus("Your device doesn't support BLE")
        case .PoweredOff:
            delegate?.differentManagerStatus("Please turn on your Bluetooth")
        case .Unknown:
            delegate?.differentManagerStatus("Unknown error, please try again")
        case .Unauthorized:
            delegate?.differentManagerStatus("Your device is unauthorized to use Bluetooth")
        default:
            delegate?.differentManagerStatus("Unknown error, please try again")
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        //If array contains this peripheral, replace relate object with it due to new RSSI number
        
        var index = 0
        while index < peripheralArray.count {
            if peripheralArray[index].peripheral == peripheral {
                peripheralArray[index].RSSI = RSSI
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                delegate?.updateNewTableViewRow(true, indexPath: indexPath)
                break
            }
            index += 1
        }
        if peripheralArray.count == 0 || index == peripheralArray.count  {
            peripheralArray.append(PeripheralInfo(peripheral: peripheral, RSSI: RSSI, adData: advertisementData))
            let indexPath = NSIndexPath(forRow: peripheralArray.count - 1, inSection: 0)
            delegate?.updateNewTableViewRow(false, indexPath: indexPath)
        }
        
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        selectedPeripheralInfo = peripheralArray[SelectedIndexPath.row]
        delegate?.didGetResultConnectToPeripheral(true, indexPath: SelectedIndexPath)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        delegate?.didGetResultConnectToPeripheral(false, indexPath: SelectedIndexPath)
    }
    
    //MARK: - Selectors
    
    func tableViewRefresh(refreshControl: UIRefreshControl) {
        
        var indexPathArray = [NSIndexPath]()
        for i in 0 ..< peripheralArray.count {
            indexPathArray.append(NSIndexPath(forRow: i, inSection: 0))
        }
        peripheralArray.removeAll()
        delegate?.needUpdateTableViewUI(indexPathArray)
        
        if !self.centralManager.isScanning {
            centralManager.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
        refreshControl.endRefreshing()
    }

}
