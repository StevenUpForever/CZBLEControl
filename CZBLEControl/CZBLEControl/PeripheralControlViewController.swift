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
    
    //BLE objects
    var peripheralObj: CBPeripheral?
    var centralManager = CBCentralManager()
    var cellIndexPath: NSIndexPath?
    
    //TableView array
    var serviceArray = [CharacterInfo]()

    //MARK: - viewController lifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        peripheralObj?.delegate = self
        peripheralObj?.discoverServices(nil)
        centralManager.delegate = self
        
        uuidLabel.text = peripheralObj?.identifier.UUIDString
        
        switch (peripheralObj?.state)! {
            
        case .Connected:
            
            statusLabel.text = "Connected"
            statusLabel.textColor = UIColor.blackColor()
            connectBarItem.enabled = false
            
        case .Disconnected:
            
            statusLabel.text = "Disconnected\nReconnect by top right button or back to choose another device"
            statusLabel.textColor = UIColor.redColor()
            connectBarItem.enabled = true
            
        default:
            print("Unknow connection status")
        }
        
    }
    
    //MARK: - peripheral delegate
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        //If find new service, insert it into peripheral array
        if let peripheralServiceArray = peripheral.services {
            for service: CBService in peripheralServiceArray {
                serviceArray.append(CharacterInfo(service: service))
                peripheral.discoverCharacteristics(nil, forService: service)
                let indexSet = NSIndexSet(index: serviceArray.count - 1)
                tableView.insertSections(indexSet, withRowAnimation: .Left)
            }
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        if let characterArray = service.characteristics {
            for character: CBCharacteristic in characterArray {
                for info in serviceArray {
                    
                    if info.serviceObj == service {
                        info.characterArray.append(character)
                        
                        if let sectionNum = serviceArray.indexOf(info) {
                            let indexPath = NSIndexPath(forRow: info.characterArray.count - 1, inSection: sectionNum)
                            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
                        }
                        
                    }
                }
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
                
                if segue.identifier != "write" {
                    //Prepare for destination viewController
                    if let RWNCVC = segue.destinationViewController as? RWNCTableViewController {
                        
                        RWNCVC.peripheralObj = peripheralObj
                        RWNCVC.characterObj = cell.cellCharacter
                        RWNCVC.navigationItem.title = cell.cellCharacter?.UUID.UUIDString
                        
                        switch segue.identifier! {
                        case "read":
                            RWNCVC.identifier = .read
                        case "writeWithoutResponse":
                            RWNCVC.identifier = .writeWithNoResponse
                        case "notify":
                            RWNCVC.identifier = .notify
                        case "descriptor":
                            RWNCVC.identifier = .descriptor
                        default:
                            RWNCVC.identifier = .none
                        }
                        
                    }
                    
                } else {
                    if let writeVC = segue.destinationViewController as? WriteTableViewController {
                        
                        writeVC.peripheralObj = peripheralObj
                        writeVC.characterObj = cell.cellCharacter
                        writeVC.navigationItem.title = cell.cellCharacter?.UUID.UUIDString
                        
                    }
                }
                
            }
        }
    }

    

}
