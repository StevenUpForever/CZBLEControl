//
//  RWNCTableViewController.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 16/4/8.
//  Copyright © 2016年 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth

class RWNCTableViewController: UITableViewController, CBCentralManagerDelegate, RWNCDelegate {
    
    let viewModel = RWNCViewModel()
    
    //IBOutlets
    @IBOutlet weak var connectBarItem: UIBarButtonItem!
    @IBOutlet weak var actionBarItem: UIBarButtonItem!

    //MARK: - viewController lifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        viewModel.centralManager.delegate = self
        viewModel.delegate = self
        
        viewModel.setUIElement( actionBarItem, connectBarItem: connectBarItem, fallBackAction: {[unowned self] in
            
            self.showfallBackAlertController()
            
            }) { 
                CustomAlertController.showCancelAlertController("Peripheral not connected", message: "Peripheral is disconnected, please connect with refresh button", target: self)
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        viewModel.centralManager?.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        if viewModel.identifier == .none {
            showfallBackAlertController()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        viewModel.disconnectPeripheral()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.sectionNum()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rowNum(section)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        
        viewModel.cellText(cell, indexPath: indexPath)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sectionTitle(section)
    }
    
    //MARK: - CBCentral delegate
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case CBCentralManagerState.PoweredOn:
            break
        case CBCentralManagerState.PoweredOff:
            CustomAlertController.showCancelAlertController("BLE turned off", message: "Please turn on your Bluetooth", target: self)
        default:
            CustomAlertController.showCancelAlertController("Unknown Error", message: "Unknown error, please try again", target: self)
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        connectBarItem.enabled = false
        viewModel.replacePeripheral(peripheral)
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        CustomAlertController.showCancelAlertController("Peripheral disconnected", message: "Please reconnect your device", target: self)
        connectBarItem.enabled = true
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        CustomAlertController.showCancelAlertController("Peripheral connect error", message: "Connect to device error, please try again", target: self)
    }
    
    //MARK: - IBActions and Selectors
    
    @IBAction func connectProcess(sender: AnyObject) {
        viewModel.reconnectPeripheral()
    }
    
    @IBAction func actionProcess(sender: UIBarButtonItem) {
        viewModel.actionButtonProcess(sender, target: self)
    }
    
    //MARK: - viewModel delegate
    
    func updateTableViewUI(indexPath: NSIndexPath) {
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
    }
    
    func replaceNotifyImage(image: UIImage?) {
        actionBarItem.image = image
    }
    
    //MARK: - private methods
    
    private func showfallBackAlertController() {
        CustomAlertController.showCancelAlertControllerWithBlock("Peripheral not found", message: "Peripheral or characteristic not found, going back", target: self, actionHandler: { (action) in
            self.navigationController?.popViewControllerAnimated(true)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
