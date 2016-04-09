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
    
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var connectBarItem: UIBarButtonItem!
    
    var peripheralObj: CBPeripheral?
    var centralManager = CBCentralManager()
    var serviceDict = [CharacterInfo]()
    var cellIndexPath: NSIndexPath?

    //MARK - viewController lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        peripheralObj?.delegate = self
        peripheralObj?.discoverServices(nil)
        centralManager.delegate = self
        
        uuidLabel.text = peripheralObj?.identifier.UUIDString
        switch (peripheralObj?.state)! {
        case CBPeripheralState.Connected:
            statusLabel.text = "Connected"
            statusLabel.textColor = UIColor.blackColor()
            connectBarItem.enabled = false
        case CBPeripheralState.Disconnected:
            statusLabel.text = "Disconnected\nReconnect by top right button or back to choose another device"
            statusLabel.textColor = UIColor.redColor()
            connectBarItem.enabled = true
        default:
            break
        }
        tableView.delegate = self
        tableView.dataSource = self
        
        self.title = peripheralObj?.name == nil ? "Name unavailable" : peripheralObj?.name
        self.navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK - peripheral delegate
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        for service: CBService in peripheral.services! {
            serviceDict.append(CharacterInfo(service: service))
            peripheral.discoverCharacteristics(nil, forService: service)
            let indexSet = NSIndexSet(index: serviceDict.count - 1)
            tableView.insertSections(indexSet, withRowAnimation: UITableViewRowAnimation.Left)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        for character: CBCharacteristic in service.characteristics! {
            for info: CharacterInfo in serviceDict {
                if info.serviceObj == service {
                    info.characterArray.append(character)
                    let indexPath = NSIndexPath(forRow: info.characterArray.count - 1, inSection: serviceDict.indexOf(info)!)
                    tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
                }
            }
        }
    }
    
    //MARK - centralManager delegate
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case CBCentralManagerState.PoweredOn:
            break
        case CBCentralManagerState.PoweredOff:
            CustomAlertController.showErrorAlertController("BLE turned off", message: "Please turn on your Bluetooth", target: self)
        default:
            CustomAlertController.showErrorAlertController("Unknown Error", message: "Unknown error, please try again", target: self)
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
        CustomAlertController.showErrorAlertController("Peripheral connect error", message: "Connect to device error, please try again", target: self)
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        CustomAlertController.showErrorAlertController("Peripheral disconnected", message: "Please reconnect your device", target: self)
        statusLabel.text = "Disconnected\nReconnect by top right button or back to choose another device"
        statusLabel.textColor = UIColor.redColor()
        connectBarItem.enabled = true
    }
    
    //MARK - tableView datasource & delegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return serviceDict.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceDict[section].characterArray.count
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return serviceDict[section].serviceObj.UUID.UUIDString
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("serviceCell") as! ServiceTableViewCell
        let character = serviceDict[indexPath.section].characterArray[indexPath.row]
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
    
    //MARK methods and Selectors
    
    @IBAction func dropDownProcess(sender: AnyObject) {
        let buttonPosition = sender.convertPoint(CGPointZero, toView: tableView)
        let indexPath = tableView.indexPathForRowAtPoint(buttonPosition)
        openHiddenSubViewAtIndexPath(indexPath!)
    }
    
    func openHiddenSubViewAtIndexPath(indexPath: NSIndexPath) {
        cellIndexPath = cellIndexPath == indexPath ? nil : indexPath
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }
    
    @IBAction func connectSelfPeripheral(sender: AnyObject) {
        serviceDict.removeAll()
        tableView.reloadData()
        centralManager.connectPeripheral(peripheralObj!, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if cellIndexPath != nil {
            if let cell = tableView.cellForRowAtIndexPath(cellIndexPath!) as? ServiceTableViewCell {
                switch segue.identifier! {
                case "read":
                    let readVC = segue.destinationViewController as! RWNCTableViewController
                    readVC.prepareInfo = RWNCPrepareInfo(identifier: RWNCIdentifier.read, peripheral: peripheralObj, character: cell.cellCharacter)
                case "write":
                     let writeVC = segue.destinationViewController as! RWNCTableViewController
                    if let property = cell.cellCharacter?.properties {
                        if property.rawValue & CBCharacteristicProperties.Write.rawValue > 0 {
                            writeVC.prepareInfo = RWNCPrepareInfo(identifier: RWNCIdentifier.write, peripheral: peripheralObj, character: cell.cellCharacter)
                        } else {
                            writeVC.prepareInfo = RWNCPrepareInfo(identifier: RWNCIdentifier.writeWithNoResponse, peripheral: peripheralObj, character: cell.cellCharacter)
                        }
                    }
                case "notify":
                    let notifyVC = segue.destinationViewController as! RWNCTableViewController
                    notifyVC.prepareInfo = RWNCPrepareInfo(identifier: RWNCIdentifier.notify, peripheral: peripheralObj, character: cell.cellCharacter)
                case "descriptor":
                    let descriptorVC = segue.destinationViewController as! RWNCTableViewController
                    descriptorVC.prepareInfo = RWNCPrepareInfo(identifier: RWNCIdentifier.descriptor, peripheral: peripheralObj, character: cell.cellCharacter)
                default:
                    break
                }
            }
        }
    }

    

}
