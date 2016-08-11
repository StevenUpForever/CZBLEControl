//
//  BLETableViewController.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 16/4/3.
//  Copyright © 2016年 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth
import Crashlytics

class BLETableViewController: UITableViewController, CBCentralManagerDelegate {
    
    let viewModel = BLETableViewModel()
    
    let refresh = UIRefreshControl()
    
    //MARK: - viewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh.addTarget(self, action: #selector(BLETableViewController.tableViewRefresh(_:)), forControlEvents: .ValueChanged)
        view.addSubview(refresh)
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "titleView"))
        
    }
    
    //Begin/Stop scan peripheral in lifeCycle when the view is appearing or dissappearing
    
    override func viewWillAppear(animated: Bool) {
        viewModel.centralManager.delegate = self
        viewModel.scanPeripheralInLifeCycle(true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        viewModel.scanPeripheralInLifeCycle(false)
    }
    
    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.peripheralArray.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BLECell", forIndexPath: indexPath) as! BLETableViewCell
        cell.loadData(viewModel.peripheralArray[indexPath.row])
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        viewModel.connectPeripheralWithSelectedRow(indexPath) { [weak self] (poweredOn) in
            if let strongSelf = self {
                if !poweredOn {
                    CustomAlertController.showCancelAlertController("Connection error", message: "Please check your device and open Bluetooth", target: strongSelf)
                } else {
                    let cell = tableView.cellForRowAtIndexPath(indexPath) as! BLETableViewCell
                    if !cell.indicator.isAnimating() {
                        cell.indicator.startAnimating()
                    }
                    strongSelf.viewModel.connectToPeripheral(cell.viewModel)
                }
            }
        }
    }
    
    //When deselect the cell, stop the animation of indicator on the deselected cell
    
    override func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        endIndicatorLoading(indexPath)
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 73.0
    }
    
    //MARK: - CBCentralManager delegate
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case .PoweredOn:
            viewModel.scanPeripheral()
        case .Unsupported:
            CustomAlertController.showCancelAlertController("BLE Unsupported", message: "Your device doesn't support BLE", target: self)
        case .PoweredOff:
            CustomAlertController.showCancelAlertController("BLE turned off", message: "Please turn on your Bluetooth", target: self)
            viewModel.clearAllPeripherals({[unowned self] (indexPaths) in
                self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Right)
            })
        case .Unknown:
            CustomAlertController.showCancelAlertController("BLE Device error", message: "Unknown error, please try again", target: self)
        case .Unauthorized:
            CustomAlertController.showCancelAlertController("BLE unauthorized", message: "Your device is unauthorized to use Bluetooth", target: self)
        default:
            CustomAlertController.showCancelAlertController("BLE Device error", message: "Unknown error, please try again", target: self)
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        
        viewModel.discoverPeripheral(peripheral, RSSI: RSSI, adData: advertisementData) {[weak self] (newRow, indexPath) in
            if let strongSelf = self {
                if newRow {
                    if let cell = strongSelf.tableView.cellForRowAtIndexPath(indexPath) as? BLETableViewCell {
                        cell.loadData(strongSelf.viewModel.peripheralArray[indexPath.row])
                    }
                } else {
                    strongSelf.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
                }
            }
        }
        
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        endIndicatorLoading(viewModel.replaceSelectedPeripheral())
        performSegueWithIdentifier("peripheralControl", sender: self)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        endIndicatorLoading(viewModel.replaceSelectedPeripheral())
        CustomAlertController.showCancelAlertController("Connect error", message: "Cannot connet device, please try again", target: self)
    }

    //MARK: - Other selectors
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        viewModel.pushToPeripheralController(segue)
    }
    
    func endIndicatorLoading(indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? BLETableViewCell {
            if cell.indicator.isAnimating() {
                cell.indicator.stopAnimating()
            }
        }
    }
    
    //MARK: - Selectors
    
    func tableViewRefresh(refreshControl: UIRefreshControl) {
        viewModel.clearAllPeripherals {[unowned self] (indexPaths) in
            self.tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Right)
        }
        viewModel.scanPeripheral()
        refreshControl.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
