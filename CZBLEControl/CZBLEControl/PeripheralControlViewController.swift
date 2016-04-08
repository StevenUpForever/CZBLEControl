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
    var cellIndexPath = NSIndexPath()

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
        cell.uuidLabel.text = character.UUID.UUIDString
        cell.propertyLabel.text = getPropertitesName(character.properties)
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        cellIndexPath = indexPath
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if cellIndexPath == indexPath {
            return 160.0
        } else {
            return 90.0
        }
    }
    
    //MARK methods and Selectors
    func getPropertitesName(property: CBCharacteristicProperties) -> String {
        var propertyStr = "Propertites:"
        if property.rawValue & CBCharacteristicProperties.Broadcast.rawValue > 0 {
            propertyStr += "/Broadcast"
        }
        if property.rawValue & CBCharacteristicProperties.AuthenticatedSignedWrites.rawValue > 0 {
            propertyStr += "/AuthenticatedSignedWrites"
        }
        if property.rawValue & CBCharacteristicProperties.ExtendedProperties.rawValue > 0 {
            propertyStr += "/ExtendedProperties"
        }
        if property.rawValue & CBCharacteristicProperties.Indicate.rawValue > 0 {
            propertyStr += "/Indicate"
        }
        if property.rawValue & CBCharacteristicProperties.IndicateEncryptionRequired.rawValue > 0 {
            propertyStr += "/IndicateEncryptionRequired"
        }
        if property.rawValue & CBCharacteristicProperties.Notify.rawValue > 0 {
            propertyStr += "/Notify"
        }
        if property.rawValue & CBCharacteristicProperties.NotifyEncryptionRequired.rawValue > 0 {
            propertyStr += "/NotifyEncryptionRequired"
        }
        if property.rawValue & CBCharacteristicProperties.Read.rawValue > 0 {
            propertyStr += "/Read"
        }
        if property.rawValue & CBCharacteristicProperties.Write.rawValue > 0 {
            propertyStr += "/Write"
        }
        if property.rawValue & CBCharacteristicProperties.WriteWithoutResponse.rawValue > 0 {
            propertyStr += "/WriteWithoutResponse"
        }
        return propertyStr
    }
    
    @IBAction func connectSelfPeripheral(sender: AnyObject) {
        serviceDict.removeAll()
        tableView.reloadData()
        
        centralManager.connectPeripheral(peripheralObj!, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }

    

}
