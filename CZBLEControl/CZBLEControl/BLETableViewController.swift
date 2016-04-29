//
//  BLETableViewController.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 16/4/3.
//  Copyright © 2016年 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLETableViewController: UITableViewController, CBCentralManagerDelegate {
    
    private let centralManager = CBCentralManager()
    private var peripheralArray = [PeripheralInfo]()
    private var peripheralObj: CBPeripheral?
    
    var SelectedIndexPath = NSIndexPath()
    
    //MARK: - viewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        centralManager.delegate = self
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "titleView"))
        
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(BLETableViewController.tableViewRefresh(_:)), forControlEvents: .ValueChanged)
        self.view.addSubview(refresh)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        if !centralManager.isScanning {
            centralManager.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if centralManager.isScanning {
            centralManager.stopScan()
        }
    }
    
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
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.peripheralArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BLECell", forIndexPath: indexPath) as! BLETableViewCell
        cell.loadData(self.peripheralArray[indexPath.row])
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        SelectedIndexPath = indexPath
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? BLETableViewCell {
            if cell.indicator.isAnimating() == false {
                cell.indicator.startAnimating()
            }
            if let connectPeripheral = cell.peripheralInfo?.peripheral {
                centralManager.connectPeripheral(connectPeripheral, options: nil)
            } else {
                CustomAlertController.showCancelAlertController("Peripheral error", message: "Cannot find such peripheral", target: self)
            }
        }
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        
        endIndicatorLoading(indexPath)
        
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 73.0
    }

    //MARK - Selectors
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "peripheralControl" {
            let peripheralVC = segue.destinationViewController as? PeripheralControlViewController
            peripheralVC?.peripheralObj = peripheralObj
            peripheralVC?.title = peripheralObj?.name
        }
    }
    
    //Private methods
    
    private func tableViewRefresh(refreshControl: UIRefreshControl) {
        
        var indexPathArray = [NSIndexPath]()
        for i in 0 ..< peripheralArray.count {
            indexPathArray.append(NSIndexPath(forRow: i, inSection: 0))
        }
        peripheralArray.removeAll()
        tableView.deleteRowsAtIndexPaths(indexPathArray, withRowAnimation: .Right)
        
        if self.centralManager.isScanning == false {
            centralManager.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
        refreshControl.endRefreshing()
    }
    
    private func endIndicatorLoading(indexPath: NSIndexPath) {
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? BLETableViewCell {
            if cell.indicator.isAnimating() {
                cell.indicator.stopAnimating()
            }
        }
        
    }

}
