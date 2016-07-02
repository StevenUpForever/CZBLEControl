//
//  PeripheralControlViewController.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 16/4/3.
//  Copyright © 2016年 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralControlViewController: UIViewController, CBPeripheralDelegate, CBCentralManagerDelegate, UITableViewDelegate, UITableViewDataSource {
    
    //IBOutlets
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var connectBarItem: UIBarButtonItem!
    
    let viewModel = PeripheralViewModel()

    //MARK: - viewController lifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uuidLabel.text = viewModel.uuidString
        
        viewModel.loadUI {[unowned self] (connected) in
            if connected {
                self.connectedUI()
            } else {
                self.disconnectedUI()
            }
        }
        
    }
    
    //MARK - centralManager delegate
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case .PoweredOn:
            break
        case .PoweredOff:
            CustomAlertController.showCancelAlertController("BLE turned off", message: "Please turn on your Bluetooth", target: self)
        default:
            CustomAlertController.showCancelAlertController("Unknown Error", message: "Unknown error, please try again", target: self)
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        statusLabel.text = "Connected"
        statusLabel.textColor = UIColor.blackColor()
        connectBarItem.enabled = false
        
        peripheralObj = peripheral
        peripheralObj?.discoverServices(nil)
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        CustomAlertController.showCancelAlertController("Peripheral connect error", message: "Connect to device error, please try again", target: self)
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        CustomAlertController.showCancelAlertController("Peripheral disconnected", message: "Please reconnect your device", target: self)
        statusLabel.text = "Disconnected\nReconnect by top right button or back to choose another device"
        statusLabel.textColor = UIColor.redColor()
        connectBarItem.enabled = true
    }
    
    //MARK: - tableView datasource & delegate
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return serviceArray.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceArray[section].characterArray.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return serviceArray[section].serviceObj.UUID.UUIDString
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("serviceCell") as! ServiceTableViewCell
        let character = serviceArray[indexPath.section].characterArray[indexPath.row]
        cell.loadData(character)
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        openHiddenSubViewAtIndexPath(indexPath)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if cellIndexPath == indexPath {
            return 180.0
        } else {
            return 95.0
        }
    }
    
    //MARK: - Selectors
    
    @IBAction func dropDownProcess(sender: AnyObject) {
        let buttonPosition = sender.convertPoint(CGPointZero, toView: tableView)
        let indexPath = tableView.indexPathForRowAtPoint(buttonPosition)
        openHiddenSubViewAtIndexPath(indexPath!)
    }
    
    private func openHiddenSubViewAtIndexPath(indexPath: NSIndexPath) {
        cellIndexPath = cellIndexPath == indexPath ? nil : indexPath
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }
    
    @IBAction func connectSelfPeripheral(sender: AnyObject) {
        serviceArray.removeAll()
        tableView.reloadData()
        centralManager.connectPeripheral(peripheralObj!, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if cellIndexPath != nil {
            if let cell = tableView.cellForRowAtIndexPath(cellIndexPath!) as? ServiceTableViewCell {
                
                    //Prepare for destination viewController
                if let RWNCVC = segue.destinationViewController as? RWNCTableViewController {
                        
                RWNCVC.peripheralObj = peripheralObj
                RWNCVC.characterObj = cell.cellCharacter
                RWNCVC.navigationItem.title = cell.cellCharacter?.UUID.UUIDString
                
                switch segue.identifier! {
                case "read":
                    RWNCVC.identifier = .read
                    
                case "write":
                    RWNCVC.identifier = .write
                    
                case "writeWithoutResponse":
                    RWNCVC.identifier = .writeWithNoResponse
                    
                case "notify":
                    RWNCVC.identifier = .notify
                    
                default:
                    RWNCVC.identifier = .none
                    }
                }
            }
        }
    }
    
    //MARK: - private methods
    
    private func connectedUI() {
        statusLabel.text = "Connected"
        statusLabel.textColor = UIColor.blackColor()
        connectBarItem.enabled = false
    }
    
    private func disconnectedUI() {
        statusLabel.text = "Disconnected\nReconnect by top right button or back to choose another device"
        statusLabel.textColor = UIColor.redColor()
        connectBarItem.enabled = true
    }
    
    
}
