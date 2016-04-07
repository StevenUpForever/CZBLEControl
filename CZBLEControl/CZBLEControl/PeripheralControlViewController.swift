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
    var centralManager: CBCentralManager?
    var serviceArray = NSMutableArray()

    //MARK - viewController lifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        peripheralObj?.delegate = self
        peripheralObj?.discoverServices(nil)
        centralManager?.delegate = self
        
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
            serviceArray.addObject(service)
            tableView.reloadData()
        }
    }
    
    //MARK - centralManager delegate
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
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
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return serviceArray.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("serviceCell") as? ServiceTableViewCell
        let service = serviceArray[indexPath.row] as? CBService
        cell?.primaryServiceLabel.text = (service?.isPrimary)! ? "Primary service: YES" : "Primary service: NO"
        cell?.uuidLabel.text = service?.UUID.UUIDString
        return cell!
    }
    
    @IBAction func connectSelfPeripheral(sender: AnyObject) {
        centralManager?.connectPeripheral(peripheralObj!, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        serviceArray.removeAllObjects()
    }

    

}
