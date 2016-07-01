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
    let centralManagerDelegate = BLETableViewCentralManager()
    
    let refresh = UIRefreshControl()
    
    var SelectedIndexPath = NSIndexPath()
    
    var peripheralArray = [PeripheralInfo]()
    private var peripheralObj: CBPeripheral?
    
    private var target: UITableViewController?
    
    override init() {
        super.init()
        centralManager.delegate = centralManagerDelegate
        
        refresh.addTarget(self, action: #selector(BLETableViewModel.tableViewRefresh(_:)), forControlEvents: .ValueChanged)
    }
    
    func addTargetForViewModel(target: UITableViewController) {
        self.target = target
        self.target!.view.addSubview(refresh)
    }
    
    func scanPeripheralInLifeCycle(viewWillAppear: Bool) {
        if viewWillAppear && !centralManager.isScanning {
            centralManager.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        } else if !viewWillAppear && centralManager.isScanning {
            centralManager.stopScan()
        }
    }
    
    func connectPeripheralWithSelectedRow(indexPath: NSIndexPath) {
        SelectedIndexPath = indexPath
        
        guard let initializedTarget = target else {
            print("viewModel didn't invoke set target")
            return
        }
        let cell = initializedTarget.tableView.cellForRowAtIndexPath(indexPath) as! BLETableViewCell
            
        if centralManager.state != .PoweredOn {
            CustomAlertController.showCancelAlertController("Connection error", message: "Please check your device and open Bluetooth", target: initializedTarget)
        } else {
            if !cell.indicator.isAnimating() {
                cell.indicator.startAnimating()
            }
            if let connectPeripheral = cell.peripheralInfo?.peripheral {
                centralManager.connectPeripheral(connectPeripheral, options: nil)
            } else {
                CustomAlertController.showCancelAlertController("Peripheral error", message: "Cannot find such peripheral", target: initializedTarget)
            }
        }

    }
    
    //MARK: - Selectors
    
    func tableViewRefresh(refreshControl: UIRefreshControl) {
        guard let initializedTarget = target else {
            print("viewModel didn't invoke set target")
            return
        }
        
        var indexPathArray = [NSIndexPath]()
        for i in 0 ..< peripheralArray.count {
            indexPathArray.append(NSIndexPath(forRow: i, inSection: 0))
        }
        peripheralArray.removeAll()
        
        initializedTarget.tableView.deleteRowsAtIndexPaths(indexPathArray, withRowAnimation: .Right)
        
        if !self.centralManager.isScanning {
            centralManager.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
        refreshControl.endRefreshing()
    }

}
