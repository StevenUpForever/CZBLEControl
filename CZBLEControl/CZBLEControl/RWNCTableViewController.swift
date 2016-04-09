//
//  RWNCTableViewController.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 16/4/8.
//  Copyright © 2016年 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth

class RWNCTableViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    @IBOutlet weak var connectBarItem: UIBarButtonItem!
    @IBOutlet weak var actionBarItem: UIBarButtonItem!
    
    
    var centralManager = CBCentralManager()
    var peripheralObj: CBPeripheral?
    var characterObj: CBCharacteristic?
    
    var searchBar = UISearchBar()
    
    var prepareInfo: RWNCPrepareInfo?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.titleView = searchBar
        
        actionBarItem.title = prepareInfo?.barItemTitleStr
        actionBarItem.tag = (prepareInfo?.barItemTag)!
        if actionBarItem.tag == 3 {
            actionBarItem.image = UIImage(named: "notifyItem")
        } else if actionBarItem.tag == 4 {
            actionBarItem.enabled = false
        }
        peripheralObj = prepareInfo?.RWNCPeripheral
        characterObj = prepareInfo?.RWNCCharacter
        
        switch (peripheralObj?.state)! {
        case CBPeripheralState.Connected:
            connectBarItem.enabled = false
        case CBPeripheralState.Disconnected:
            CustomAlertController.showErrorAlertController("Peripheral not connected", message: "Peripheral is disconnected, please connect with refresh button", target: self)
            connectBarItem.enabled = true
        default:
            break
        }
        centralManager.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    
    //MARK - CBCentral delegate
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
        connectBarItem.enabled = false
        peripheralObj = peripheral
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        CustomAlertController.showErrorAlertController("Peripheral connect error", message: "Connect to device error, please try again", target: self)
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        CustomAlertController.showErrorAlertController("Peripheral disconnected", message: "Please reconnect your device", target: self)
        connectBarItem.enabled = true
    }
    
    //MARK - CBPeripheral delegate
    
    //MARK - IBActions and Selectors
    @IBAction func connectProcess(sender: AnyObject) {
    }
    
    @IBAction func actionProcess(sender: UIBarButtonItem) {
        print(sender.tag)
    }
    
    

}
