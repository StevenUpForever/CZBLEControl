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

class BLETableViewController: UITableViewController, BLETableViewModelDelegate {
    
    let viewModel = BLETableViewModel()
    
    //MARK: - viewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(viewModel.refresh)
        viewModel.delegate = self
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "titleView"))
        
    }
    
    //Begin/Stop scan peripheral in lifeCycle when the view is appearing or dissappearing
    
    override func viewWillAppear(animated: Bool) {
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
        viewModel.connectPeripheralWithSelectedRow(indexPath) { [unowned self] (poweredOn) in
            if !poweredOn {
                CustomAlertController.showCancelAlertController("Connection error", message: "Please check your device and open Bluetooth", target: self)
            } else {
                let cell = tableView.cellForRowAtIndexPath(indexPath) as! BLETableViewCell
                if !cell.indicator.isAnimating() {
                    cell.indicator.startAnimating()
                }
                self.viewModel.connectToPeripheral(cell.viewModel)
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
    
    //MARK: - custom delegate
    
    //Delegate to check the state when connect to peripheral and update related UI
    
    func didGetResultConnectToPeripheral(success: Bool, indexPath: NSIndexPath) {
        if success {
            endIndicatorLoading(indexPath)
            performSegueWithIdentifier("peripheralControl", sender: self)
        } else {
            endIndicatorLoading(indexPath)
            CustomAlertController.showCancelAlertController("Connect error", message: "Cannot connet device, please try again", target: self)
        }
    }
    
    //Delegate when need to delete all cells
    
    func needUpdateTableViewUI(indexPaths: [NSIndexPath]) {
        tableView.deleteRowsAtIndexPaths(indexPaths, withRowAnimation: .Right)
    }
    
    //Delegate to check if need to reload related cell or insert a new cell
    
    func updateNewTableViewRow(existed: Bool, indexPath: NSIndexPath) {
        if existed {
            if let cell = tableView.cellForRowAtIndexPath(indexPath) as? BLETableViewCell {
                cell.loadData(viewModel.peripheralArray[indexPath.row])
            }
        } else {
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        }
    }
    
    //Delegate from CBCentralManager updateState delegate with update related UI
    
    func differentManagerStatus(errorMessage: String) {
        CustomAlertController.showCancelAlertController("BLE Device error", message: errorMessage, target: self)
    }

    //MARK: - Other selectors
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "peripheralControl" {
            let peripheralVC = segue.destinationViewController as? PeripheralControlViewController
            peripheralVC?.peripheralObj = viewModel.selectedPeripheralInfo?.peripheral
            peripheralVC?.navigationItem.title = viewModel.selectedPeripheralInfo?.peripheral.name ?? "Name Unavailable"
        }
    }
    
    func endIndicatorLoading(indexPath: NSIndexPath) {
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? BLETableViewCell {
            if cell.indicator.isAnimating() {
                cell.indicator.stopAnimating()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
