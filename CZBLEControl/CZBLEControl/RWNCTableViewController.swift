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
    case write
    case writeWithNoResponse
    case notify
    case none
}

class RWNCTableViewController: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate, UIPopoverPresentationControllerDelegate, UIViewControllerTransitioningDelegate, popoverDelegate {
    
    //IBOutlets
    @IBOutlet weak var connectBarItem: UIBarButtonItem!
    @IBOutlet weak var actionBarItem: UIBarButtonItem!
    
    //Instance Objects
    var centralManager = CBCentralManager()
    var peripheralObj: CBPeripheral?
    var characterObj: CBCharacteristic?
    
    //tableView array
    var valueArray = [String]()
    var descriptorArray = [String]()
    var writeValueArray = [String]()
    
    var identifier: RWNCIdentifier = .none

    //MARK: - viewController lifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if peripheralObj != nil && characterObj != nil {
            switch identifier {
            case .read:
                actionBarItem.title = "read"
                peripheralObj?.readValueForCharacteristic(characterObj!)
                
            case .write, .writeWithNoResponse:
                actionBarItem.title = "write"
                
            case .notify:
                peripheralObj?.setNotifyValue(true, forCharacteristic: characterObj!)
                actionBarItem.image = UIImage(named: "unnotifyItem")
                
            default:
                showPopAlertController()
            }
            
            switch peripheralObj!.state {
            case .Connected:
                connectBarItem.enabled = false
            case .Disconnected:
                connectBarItem.enabled = true
                 CustomAlertController.showCancelAlertController("Peripheral not connected", message: "Peripheral is disconnected, please connect with refresh button", target: self)
            default:
                break
            }
            
            if let descriptorArray = characterObj?.descriptors {
                for descriptor: CBDescriptor in descriptorArray {
                    peripheralObj?.readValueForDescriptor(descriptor)
                }
            }
            
        } else {
            showPopAlertController()
        }
        
        peripheralObj?.delegate = self
        centralManager.delegate = self
        
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
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if identifier == .write {
            return 3
        } else {
            return 2
        }
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if identifier == .write {
            switch section {
            case 0:
                return descriptorArray.count
            case 1:
                return writeValueArray.count
            default:
                return valueArray.count
            }
        } else {
             return section == 0 ? descriptorArray.count : valueArray.count
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        
        if identifier == .write {
            
            switch indexPath.section {
            case 0:
                cell.textLabel?.text = descriptorArray[indexPath.row]
                
            case 1:
                cell.textLabel?.text = writeValueArray[indexPath.row]
                
                //Show date label text
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MM/dd/yy hh:mm:ss:SSS"
                cell.detailTextLabel?.text = dateFormatter.stringFromDate(NSDate())
                
            case 2:
                cell.textLabel?.text = valueArray[indexPath.row]
                
                //Show date label text
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MM/dd/yy hh:mm:ss:SSS"
                cell.detailTextLabel?.text = dateFormatter.stringFromDate(NSDate())
                
            default:
                break
            }
            
        } else {
            
            switch indexPath.section {
            case 0:
                cell.textLabel?.text = descriptorArray[indexPath.row]
                
            case 1:
                cell.textLabel?.text = valueArray[indexPath.row]
                
                //Show date label text
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "MM/dd/yy hh:mm:ss:SSS"
                cell.detailTextLabel?.text = dateFormatter.stringFromDate(NSDate())
                
            default:
                break
            }
            
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if identifier == .write {
            switch section {
            case 0:
                return "Descriptors"
            case 1:
                return "Write Value"
            default:
                return "Return Value"
            }
            
        } else {
            if section == 0 {
                return "Descriptors"
            } else {
                switch identifier {
                case .read:
                    return "Read Value"
                case .writeWithNoResponse:
                    return "Write Value, no response"
                case .notify:
                    return "Return Value"
                default:
                    return "Invalid data type"
                }
            }
        }
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
        peripheralObj = peripheral
    }
    
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        CustomAlertController.showCancelAlertController("Peripheral connect error", message: "Connect to device error, please try again", target: self)
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        CustomAlertController.showCancelAlertController("Peripheral disconnected", message: "Please reconnect your device", target: self)
        connectBarItem.enabled = true
    }
    
    //MARK: - CBPeripheral delegate
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if let dataValue = characteristic.value {
            let dataString = String(data: dataValue, encoding: NSUTF8StringEncoding) ?? "No data respond"
            valueArray.append(dataString)
            
            //Insert new cell row
            let sectionNum = identifier == .write ? 2 : 1
            let indexPath = NSIndexPath(forRow: valueArray.count - 1, inSection: sectionNum)
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        }
        
        if error != nil {
            print(error?.description)
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        actionBarItem.image = characteristic.isNotifying ? UIImage(named: "unnotifyItem") : UIImage(named: "notifyItem")
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        print("write")
        if error != nil {
            print(error?.description)
        } else {
            peripheral.readValueForCharacteristic(characteristic)
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForDescriptor descriptor: CBDescriptor, error: NSError?) {
        if let descriptorString = descriptor.value?.description {
            descriptorArray.append(descriptorString)
            let indexPath = NSIndexPath(forRow: descriptorArray.count - 1, inSection: 0)
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
        }
    }
    
    //MARK: - IBActions and Selectors
    
    @IBAction func connectProcess(sender: AnyObject) {
        centralManager.connectPeripheral(peripheralObj!, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    
    @IBAction func actionProcess(sender: UIBarButtonItem) {
        
        switch identifier {
        case .read:
            peripheralObj?.readValueForCharacteristic(characterObj!)
            
        case .write, .writeWithNoResponse:
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
            
        case .notify:
            if characterObj?.isNotifying == true {
                CustomAlertController.showChooseAlertControllerWithBlock("Close notify", message: "Are you sure to close notify?", target: self, actionHandler: { (action) in
                    self.peripheralObj?.setNotifyValue(false, forCharacteristic: self.characterObj!)
                })
            } else {
               peripheralObj?.setNotifyValue(true, forCharacteristic: characterObj!)
            }
            
        default:
            showPopAlertController()
            
        }
        
    }
    
    //MARK: - popoverPresentViewControlller delegate
    
    func adaptivePresentationStyleForPresentationController(controller: UIPresentationController) -> UIModalPresentationStyle {
        return .None
    }
    
    //MARK: - PopoverVC delegate
    
    func popOverVCWriteValueProcess(input: String) {
        
        if let data = input.dataUsingEncoding(NSUTF8StringEncoding) {
            peripheralObj?.writeValue(data, forCharacteristic: characterObj!, type: .WithoutResponse)
            
            if identifier == .write {
                writeValueArray.append(input)
                let indexPath = NSIndexPath(forRow: writeValueArray.count - 1, inSection: 1)
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            } else {
                valueArray.append(input)
                let indexPath = NSIndexPath(forRow: valueArray.count - 1, inSection: 1)
                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
            }
        }
        
    }
    
    //MARK: - private methods
    
    private func showPopAlertController() {
        CustomAlertController.showCancelAlertControllerWithBlock("Peripheral not found", message: "Peripheral or characteristic not found, going back", target: self, actionHandler: { (action) in
            self.navigationController?.popViewControllerAnimated(true)
        })
    }
    
}
