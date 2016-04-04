//
//  BLETableViewController.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 16/4/3.
//  Copyright © 2016年 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLETableViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    private let centralManager = CBCentralManager()
    private let peripheralArray = NSMutableArray()
    
    //MARK = viewController lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager.delegate = self;
    }
    
    //MARK - CBCentralManager delegate
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case CBCentralManagerState.PoweredOn:
            centralManager.scanForPeripheralsWithServices(nil, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
        case CBCentralManagerState.Unsupported:
            CustomAlertController.showErrorAlertController("Not support", message: "Your device doesn't support BLE", target: self)
        case CBCentralManagerState.PoweredOff:
            CustomAlertController.showErrorAlertController("BLE turned off", message: "Please turn on your Bluetooth", target: self)
        default:
            CustomAlertController.showErrorAlertController("Unknown Error", message: "Unknown error, please try again", target: self)
        }
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
        if self.peripheralArray.containsObject(peripheral) == false {
            self.peripheralArray.addObject(peripheral)
            self.tableView.reloadData()
        }
    }
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
//        DeviceConnectTableViewCell *cell = [self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow];
//        cell.stateView.image = [UIImage imageNamed:@"tick55"];
//        [cell.indicator stopAnimating];
//        NSLog(@"%@", peripheral.services);
//        //713D0007-503E-4C75-BA94-3148F18D941E
//        CBMutableCharacteristic *character = [[CBMutableCharacteristic alloc]initWithType:[CBUUID UUIDWithString:@"00002a05-0000-1000-8000-00805f9b34fb"] properties:CBCharacteristicPropertyWrite value:nil permissions:CBAttributePermissionsWriteable | CBAttributePermissionsReadable];
//        [peripheral writeValue:[@"0" dataUsingEncoding:NSUTF8StringEncoding] forCharacteristic:character type:CBCharacteristicWriteWithResponse];
        //[self performSegueWithIdentifier:@"gotoControl" sender:self];
        //[peripheral discoverServices:@[[CBUUID UUIDWithString:@"713D0000-503E-4C75-BA94-3148F18D941E"]]];
        
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

    /*
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
