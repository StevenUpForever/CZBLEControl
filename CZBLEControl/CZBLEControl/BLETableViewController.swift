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

class BLETableViewController: UITableViewController {
    
    let viewModel = BLETableViewModel()
    
    var SelectedIndexPath = NSIndexPath()
    
    //MARK: - viewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.addTargetForViewModel(self)
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "titleView"))
        
    }
    
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
            
            if centralManager.state != .PoweredOn {
                CustomAlertController.showCancelAlertController("Connection error", message: "Please check your device and open Bluetooth", target: self)
                
            } else {
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
            peripheralVC?.navigationItem.title = peripheralObj?.name ?? "Name Unavailable"
        }
    }
    
    func tableViewRefresh(refreshControl: UIRefreshControl) {
        
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
    
    //Private methods
    
    private func endIndicatorLoading(indexPath: NSIndexPath) {
        
        if let cell = tableView.cellForRowAtIndexPath(indexPath) as? BLETableViewCell {
            if cell.indicator.isAnimating() {
                cell.indicator.stopAnimating()
            }
        }
        
    }

}
