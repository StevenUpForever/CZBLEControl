//
//  BLETableViewController.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 16/4/3.
//  Copyright © 2016年 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLETableViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    private let centralManager = CBCentralManager()
    private let peripheralArray = NSMutableArray()
    private var peripheral: CBPeripheral?
    
    //MARK = viewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager.delegate = self
        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(BLETableViewController.tableViewRefresh(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(refresh)
        
    }
    
    //MARK - CBCentralManager delegate
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case CBCentralManagerState.PoweredOn:
            centralManager.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        case CBCentralManagerState.Unsupported:
            CustomAlertController.showErrorAlertController("Not support", message: "Your device doesn't support BLE", target: self)
        case CBCentralManagerState.PoweredOff:
            CustomAlertController.showErrorAlertController("BLE turned off", message: "Please turn on your Bluetooth", target: self)
        default:
            CustomAlertController.showErrorAlertController("Unknown Error", message: "Unknown error, please try again", target: self)
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        var index = 0
        while index < peripheralArray.count {
            if peripheralArray[index].peripheral == peripheral {
                peripheralArray.replaceObjectAtIndex(index, withObject: PeripheralInfo(peripheral: peripheral, RSSI: RSSI))
                tableView.reloadData()
                break
            }
            index += 1
        }
        if index == peripheralArray.count {
            self.peripheralArray.addObject(PeripheralInfo(peripheral: peripheral, RSSI: RSSI))
            self.tableView.reloadData()
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        self.performSegueWithIdentifier("peripheralControl", sender: self)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        
        CustomAlertController.showErrorAlertController("Connect error", message: "Cannot connet device, please try again", target: self)
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
        cell.loadData(self.peripheralArray.objectAtIndex(indexPath.row) as? PeripheralInfo)
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! BLETableViewCell
         cell.indicator.startAnimating()
        if let connectPeripheral = cell.peripheralInfo?.peripheral {
             self.centralManager.connectPeripheral(connectPeripheral, options: nil)
        } else {
            print("Error")
        }
    }
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = self.tableView.cellForRowAtIndexPath(indexPath) as? BLETableViewCell
        if cell?.indicator.isAnimating() == true {
            cell?.indicator.stopAnimating()
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 73.0
    }

    //MARK - other methods
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableViewRefresh(refreshControl: UIRefreshControl) {
        self.tableView.reloadData()
        if self.centralManager.isScanning == false {
            centralManager.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
        refreshControl.endRefreshing()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "peripheralControl" {
            _ = segue.destinationViewController as? PeripheralControlViewController
        }
    }

}
