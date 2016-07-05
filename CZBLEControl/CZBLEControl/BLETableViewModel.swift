//
//  BLETableViewModel.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 6/30/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth

//Delegate to send action to BLETableView to update UI

@objc protocol BLETableViewModelDelegate: class {
    func differentManagerStatus(errorMessage: String)
    func didGetResultConnectToPeripheral(success: Bool, indexPath: NSIndexPath)
    func needUpdateTableViewUI(indexPaths: [NSIndexPath])
    func updateNewTableViewRow(existed: Bool, indexPath: NSIndexPath)
}

class BLETableViewModel: NSObject, CBCentralManagerDelegate {
    
    let centralManager = CBCentralManager()
    
    let refresh = UIRefreshControl()
    
    //Selected indexPath for selection action
    
    var SelectedIndexPath = NSIndexPath()
    
    //
    
    var peripheralArray = [PeripheralInfo]()
    var selectedPeripheralInfo: PeripheralInfo?
    
    weak var delegate: BLETableViewModelDelegate?
    
    var date = NSDate.timeIntervalSinceReferenceDate()
    
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
                    peripheralVC.viewModel.loadBLEObjects(validPeripheral)
                    peripheralVC.viewModel.centralManager = centralManager
                    peripheralVC.navigationItem.title = validPeripheral.name ?? "Name Unavailable"
                }
            }
        }
    }
    
    //MARK: - CBCentralManager delegate
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case .PoweredOn:
            centralManager.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        case .Unsupported:
            delegate?.differentManagerStatus("Your device doesn't support BLE")
        case .PoweredOff:
            clearAllPeripherals()
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
        
        //Call related code period every 1.5 seconds and update UI to make better user experience
        
        if NSDate.timeIntervalSinceReferenceDate() - date > 1.5 {
        
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
            
            date = NSDate.timeIntervalSinceReferenceDate()
            
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
        clearAllPeripherals()
        
        if !self.centralManager.isScanning {
            centralManager.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
        refreshControl.endRefreshing()
    }
    
    //Clear all array elements and call clear UI delegate
    
    private func clearAllPeripherals() {
        var indexPathArray = [NSIndexPath]()
        for i in 0 ..< peripheralArray.count {
            indexPathArray.append(NSIndexPath(forRow: i, inSection: 0))
        }
        peripheralArray.removeAll()
        delegate?.needUpdateTableViewUI(indexPathArray)
    }

}
