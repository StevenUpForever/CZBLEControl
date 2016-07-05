//
//  PeripheralControlViewController.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 16/4/3.
//  Copyright © 2016年 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralControlViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, peripheralTableViewDelegate {
    
    //IBOutlets
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var connectBarItem: UIBarButtonItem!
    
    let viewModel = PeripheralViewModel()
    
    var selectedIndexPath: NSIndexPath?

    //MARK: - viewController lifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uuidLabel.text = viewModel.uuidString
        viewModel.delegate = self
        
        viewModel.loadUI {[unowned self] (connected) in
            if connected {
                self.connectedUI()
            } else {
                self.disconnectedUI()
            }
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        viewModel.centralManager?.delegate = self
    }
    
    //MARK - centralManager delegate
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case .PoweredOn:
            break
        case .PoweredOff:
            CustomAlertController.showCancelAlertControllerWithBlock("BLE turned off", message: "Turn on your Bluetooth, going back", target: self, actionHandler: { (action) in
                self.navigationController?.popToRootViewControllerAnimated(true)
            })
        default:
            CustomAlertController.showCancelAlertController("Unknown Error", message: "Unknown error, please try again", target: self)
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        connectedUI()
        
        viewModel.scanCharacteristics(peripheral)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        CustomAlertController.showCancelAlertController("Peripheral connect error", message: "Connect to device error, please try again", target: self)
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        CustomAlertController.showCancelAlertController("Peripheral disconnected", message: "Please reconnect your device", target: self)
        
        disconnectedUI()
    }
    
    //MARK: - tableView datasource & delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.serviceArray.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.serviceArray[section].characterArray.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.serviceArray[section].uuidString
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("serviceCell") as! ServiceTableViewCell
        let character = viewModel.serviceArray[indexPath.section].characterArray[indexPath.row]
        cell.loadCellUI(character)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        openHiddenSubViewAtIndexPath(indexPath)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return selectedIndexPath == indexPath ? 180.0 : 95.0
    }
    
    //MARK: - Selectors
    
    @IBAction func dropDownProcess(sender: AnyObject) {
        let buttonPosition = sender.convertPoint(CGPointZero, toView: tableView)
        if let indexPath = tableView.indexPathForRowAtPoint(buttonPosition) {
            openHiddenSubViewAtIndexPath(indexPath)
        }
    }
    
    private func openHiddenSubViewAtIndexPath(indexPath: NSIndexPath) {
        selectedIndexPath = selectedIndexPath == indexPath ? nil : indexPath
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }
    
    @IBAction func connectSelfPeripheral(sender: AnyObject) {
        viewModel.reConnectPeripheral()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard let notNilSelectedIndexPath = selectedIndexPath else {
            return
        }
        if let cell = tableView.cellForRowAtIndexPath(notNilSelectedIndexPath) as? ServiceTableViewCell {
            
            //Prepare for destination viewController
            if let RWNCVC = segue.destinationViewController as? RWNCTableViewController {
                
                viewModel.segueAction(RWNCVC, cellViewModel: cell.viewModel, segue: segue)
                
            }
        }
    }
    
    //MARK: - custom peripheral delegate
    
    func updateTableViewSectionUI(indexSet: NSIndexSet) {
        tableView.insertSections(indexSet, withRowAnimation: .Left)
    }
    
    func updateTableViewRowUI(indexPaths: [NSIndexPath]) {
        tableView.insertRowsAtIndexPaths(indexPaths, withRowAnimation: UITableViewRowAnimation.Left)
    }
    
    //MARK: - private methods
    
    func connectedUI() {
        statusLabel.text = "Connected"
        statusLabel.textColor = UIColor.blackColor()
        connectBarItem.enabled = false
    }
    
    func disconnectedUI() {
        statusLabel.text = "Disconnected\nReconnect by top right button or back to choose another device"
        statusLabel.textColor = UIColor.redColor()
        connectBarItem.enabled = true
    }
    
    
}
