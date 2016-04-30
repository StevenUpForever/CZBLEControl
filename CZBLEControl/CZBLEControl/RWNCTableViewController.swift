//
//  RWNCTableViewController.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 16/4/8.
//  Copyright © 2016年 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth

enum RWNCIdentifier {
    case read
    case writeWithNoResponse
    case notify
    case descriptor
    case none
}

class RWNCTableViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UIPopoverPresentationControllerDelegate, UIViewControllerTransitioningDelegate {
    
    //IBOutlets
    @IBOutlet weak var connectBarItem: UIBarButtonItem!
    @IBOutlet weak var actionBarItem: UIBarButtonItem!
    
    //Instance Objects
    var centralManager = CBCentralManager()
    var peripheralObj: CBPeripheral?
    var characterObj: CBCharacteristic?
    
    //tableView array
    var valueArray = [String]()
    
    var identifier: RWNCIdentifier = .none

    //MARK: - viewController lifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if peripheralObj != nil && characterObj != nil {
            switch identifier {
            case .read:
                
                actionBarItem.title = "read"
                peripheralObj?.readValueForCharacteristic(characterObj!)
                
            case .writeWithNoResponse:
                
                actionBarItem.title = "write"
                
            case .notify:
                
                peripheralObj?.setNotifyValue(true, forCharacteristic: characterObj!)
                actionBarItem.image = UIImage(named: "unnotifyItem")
                
            case .descriptor:
                
                actionBarItem.enabled = false
                if let descriptorArray = characterObj?.descriptors {
                    for descriptor: CBDescriptor in descriptorArray {
                        peripheralObj?.readValueForDescriptor(descriptor)
                    }
                }
                
            default:
                break
            }
        } else {
            CustomAlertController.showCancelAlertControllerWithBlock("Peripheral not found", message: "Peripheral or characteristic not found, going back", target: self, actionHandler: { (action) in
                self.navigationController?.popViewControllerAnimated(true)
            })
        }
        
        
        if actionBarItem.tag == 3 {
            actionBarItem.title = nil
            actionBarItem.image = UIImage(named: "notifyItem")
        } else if actionBarItem.tag == 4 {
            
        }
        peripheralObj?.delegate = self
        centralManager.delegate = self
        
        switch (peripheralObj?.state)! {
        case CBPeripheralState.Connected:
            connectBarItem.enabled = false
            switch actionBarItem.tag {
            case 0:
                
            
            case 4:
                self.title = "Descriptors"
                
            default:
                break
            }
            
        case CBPeripheralState.Disconnected:
            CustomAlertController.showCancelAlertController("Peripheral not connected", message: "Peripheral is disconnected, please connect with refresh button", target: self)
            connectBarItem.enabled = true
        default:
            break
        }
    }
    
    override func viewDidLayoutSubviews() {
        if identifier == .none {
            CustomAlertController.showCancelAlertControllerWithBlock("Segue error", message: "Not correct segue, going back", target: self, actionHandler: { (action) in
                self.navigationController?.popViewControllerAnimated(true)
            })
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        if characterObj?.isNotifying == true {
            peripheralObj?.setNotifyValue(false, forCharacteristic: characterObj!)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return actionBarItem.tag == 1 ? 2 : 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch actionBarItem.tag {
        case 1:
            return section == 0 ? responseArray.count : valueArray.count
        case 2:
            return responseArray.count
        case 3:
            return valueArray.count
        case 4:
            return descriptorArray.count
        default:
            return valueArray.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        switch actionBarItem.tag {
        case 1:
            if indexPath.section == 0 {
                cell.textLabel?.text = responseArray[indexPath.row]
            } else {
                cell.textLabel?.text = valueArray[indexPath.row]
            }
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy hh:mm:ss:SSS"
            cell.detailTextLabel?.text = actionBarItem.tag == 4 ? nil : dateFormatter.stringFromDate(NSDate())
        case 2:
            cell.textLabel?.text = responseArray[indexPath.row]
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy hh:mm:ss:SSS"
            cell.detailTextLabel?.text = actionBarItem.tag == 4 ? nil : dateFormatter.stringFromDate(NSDate())
        case 4:
            if let obj = descriptorArray[indexPath.row] {
                cell.textLabel?.text = obj.description
            } else {
                cell.textLabel?.text = "Data not found"
            }
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy hh:mm:ss:SSS"
            cell.detailTextLabel?.text = actionBarItem.tag == 4 ? nil : dateFormatter.stringFromDate(NSDate())
        default:
            cell.textLabel?.text = valueArray[indexPath.row]

            let dateFormatter = NSDateFormatter()
            dateFormatter.dateFormat = "MM/dd/yy hh:mm:ss:SSS"
            cell.detailTextLabel?.text = actionBarItem.tag == 4 ? nil : dateFormatter.stringFromDate(NSDate())
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if tableView.numberOfSections == 2 {
            return section == 0 ? "Write value" : "Response value"
        } else {
            return actionBarItem.tag == 2 ? "Write value" : "Read value"
        }
    }
    
    //MARK - CBCentral delegate
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
        peripheralObj = peripheral
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        CustomAlertController.showCancelAlertController("Peripheral connect error", message: "Connect to device error, please try again", target: self)
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        CustomAlertController.showCancelAlertController("Peripheral disconnected", message: "Please reconnect your device", target: self)
        connectBarItem.enabled = true
    }
    
    //MARK - CBPeripheral delegate
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        switch actionBarItem.tag {
        case 1:
            let dataStr: String = characteristic.value == nil || String(data: characteristic.value!, encoding: NSUTF8StringEncoding) == nil ? "No data respond" : String(data: characteristic.value!, encoding: NSUTF8StringEncoding)!
            valueArray.append(dataStr)
            let indexPath = NSIndexPath(forRow: valueArray.count - 1, inSection: 1)
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        default:
            let dataStr: String = characteristic.value == nil || String(data: characteristic.value!, encoding: NSUTF8StringEncoding) == nil ? "No data respond" : String(data: characteristic.value!, encoding: NSUTF8StringEncoding)!
            valueArray.append(dataStr)
            let indexPath = NSIndexPath(forRow: valueArray.count - 1, inSection: 0)
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        }
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        actionBarItem.image = characteristic.isNotifying ? UIImage(named: "unnotifyItem") : UIImage(named: "notifyItem")
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("write")
        
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForDescriptor descriptor: CBDescriptor, error: NSError?) {
       descriptorArray.append(descriptor.value)
        let indexPath = NSIndexPath(forRow: valueArray.count - 1, inSection: 0)
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForDescriptor descriptor: CBDescriptor, error: NSError?) {
        
    }
    
    //MARK - IBActions and Selectors
    @IBAction func connectProcess(sender: AnyObject) {
        centralManager.connectPeripheral(peripheralObj!, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    
    @IBAction func actionProcess(sender: UIBarButtonItem) {
        switch sender.tag {
        case 0:
            if peripheralObj != nil && characterObj != nil {
                peripheralObj?.readValueForCharacteristic(characterObj!)
            }
        case 1, 2:
            let popVC = PopoverViewController()
            popVC.delegate = self
            popVC.modalPresentationStyle = UIModalPresentationStyle.Popover
            popVC.preferredContentSize = CGSizeMake(300, 125)
            popVC.transitioningDelegate = self
            let popController = popVC.popoverPresentationController
            popController?.permittedArrowDirections = .Any
            popController?.barButtonItem = sender
            popController?.delegate = self
            self.presentViewController(popVC, animated: true, completion: nil)
        case 3:
            if characterObj!.isNotifying {
                let alertController = UIAlertController(title: "Close notify", message: "Are you sure to close notify?", preferredStyle: .Alert)
                let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                let sure = UIAlertAction(title: "Close notify", style: .Destructive, handler: { (action) in
                    self.peripheralObj?.setNotifyValue(false, forCharacteristic: self.characterObj!)
                })
                alertController.addAction(cancel)
                alertController.addAction(sure)
                self.presentViewController(alertController, animated: true, completion: nil)
            } else {
                peripheralObj?.setNotifyValue(true, forCharacteristic: characterObj!)
            }
        default:
            break
        }
    }
    
    //MARK - popoverPresentViewControlller delegate
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    func writeValueProcess(input: String) {
        if actionBarItem.tag == 1 || actionBarItem.tag == 2 {
            if let data = input.dataUsingEncoding(NSUTF8StringEncoding) {
                peripheralObj?.writeValue(data, forCharacteristic: characterObj!, type: .WithResponse)
                responseArray.append(input)
                let indexPath = NSIndexPath(forRow: responseArray.count - 1, inSection: 0)
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            }
        }else {
            if let data = input.dataUsingEncoding(NSUTF8StringEncoding) {
                peripheralObj?.writeValue(data, forCharacteristic: characterObj!, type: .WithoutResponse)
            }
        }
    }
    
}
