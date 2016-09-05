//
//  RWNCViewModel.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 7/4/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol RWNCDelegate: class {
    func updateTableViewUI(indexPath: NSIndexPath)
    func replaceNotifyImage(image: UIImage?)
}

enum RWNCIdentifier {
    case read
    case write
    case writeWithNoResponse
    case notify
    case none
}

class RWNCViewModel: NSObject, CBPeripheralDelegate, UIPopoverPresentationControllerDelegate, UIViewControllerTransitioningDelegate, popoverDelegate {
    
    var identifier: RWNCIdentifier = .none
    
    var centralManager: CBCentralManager?
    
    var peripheralObj: CBPeripheral?
    var characterObj: CBCharacteristic?
    
    var uuidString = "UUID unavailable"
    
    weak var delegate: RWNCDelegate?
    
    //tableView array
    var valueArray = [(String, String)]()
    var descriptorArray = [String]()
    var writeValueArray = [(String, String)]()
    
    func setUIElement(actionBarItem: UIBarButtonItem, fallBackAction: () -> Void) {
        
        if peripheralObj != nil && characterObj != nil {
            
            peripheralObj?.delegate = self
            
            switch identifier {
            case .read:
                actionBarItem.title = "read"
                peripheralObj?.readValueForCharacteristic(characterObj!)
                
            case .write, .writeWithNoResponse:
                actionBarItem.title = "write"
                
            case .notify:
                peripheralObj?.setNotifyValue(true, forCharacteristic: characterObj!)
                actionBarItem.title = nil
                actionBarItem.image = UIImage(named: "unnotifyItem")
                
            default:
                fallBackAction()
            }
            
            if let descriptorArray = characterObj?.descriptors {
                for descriptor: CBDescriptor in descriptorArray {
                    peripheralObj?.readValueForDescriptor(descriptor)
                }
            }
        } else {
            fallBackAction()
        }
    }
    
    func disconnectPeripheral() {
        if characterObj?.isNotifying == true {
            peripheralObj?.setNotifyValue(false, forCharacteristic: characterObj!)
        }
    }
    
    func sectionNum() -> Int {
        if identifier == .write {
            return 3
        } else {
            return 2
        }
    }
    
    func rowNum(section: Int) -> Int {
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
    
    func cellText(cell: UITableViewCell, indexPath: NSIndexPath) {
        if identifier == .write {
            switch indexPath.section {
            case 0:
                cell.textLabel?.text = descriptorArray[indexPath.row]
                
            case 1:
                cell.textLabel?.text = writeValueArray[indexPath.row].0
                
                //Show date label text
                cell.detailTextLabel?.text = writeValueArray[indexPath.row].1
                
            case 2:
                cell.textLabel?.text = valueArray[indexPath.row].0
                
                //Show date label text
                cell.detailTextLabel?.text = valueArray[indexPath.row].1
                
            default:
                break
            }
        } else {
            switch indexPath.section {
            case 0:
                cell.textLabel?.text = descriptorArray[indexPath.row]
                
            case 1:
                cell.textLabel?.text = valueArray[indexPath.row].0
                
                //Show date label text
                cell.detailTextLabel?.text = valueArray[indexPath.row].1
                
            default:
                break
            }
        }
    }
    
    func deleteObjectAtIndexPath(indexPath: NSIndexPath) {
        if identifier == .write {
            switch indexPath.section {
            case 1:
                writeValueArray.removeAtIndex(indexPath.row)
                
            case 2:
                valueArray.removeAtIndex(indexPath.row)
                
            default:
                break
            }
        } else {
            switch indexPath.section {
            case 1:
                valueArray.removeAtIndex(indexPath.row)
                
            default:
                break
            }
        }
    }
    
    private func dateFormatTransfer() -> String {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/yy hh:mm:ss:SSS"
        return dateFormatter.stringFromDate(NSDate())
    }
    
    func sectionTitle(section: Int) -> String {
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
    
    func actionButtonProcess(sender: UIBarButtonItem, target: RWNCTableViewController) {
        guard let character = characterObj else {
            return
        }
        switch identifier {
        case .read:
            peripheralObj?.readValueForCharacteristic(character)
            
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
            
            target.presentViewController(popVC, animated: true, completion: nil)
            
        case .notify:
            if characterObj?.isNotifying == true {
                CustomAlertController.showChooseAlertControllerWithBlock("Close notify", message: "Are you sure to close notify?", target: target, actionHandler: { (action) in
                    self.peripheralObj?.setNotifyValue(false, forCharacteristic: character)
                })
            } else {
                peripheralObj?.setNotifyValue(true, forCharacteristic: character)
            }
            
        default:
            break
        }
    }
    
    func dataExisted() -> Bool {
        if identifier == .write {
            return writeValueArray.count != 0 || valueArray.count != 0
        } else {
            return valueArray.count != 0
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
                writeValueArray.append((input, dateFormatTransfer()))
                let indexPath = NSIndexPath(forRow: writeValueArray.count - 1, inSection: 1)
                
                delegate?.updateTableViewUI(indexPath)
                
            } else {
                valueArray.append((input, dateFormatTransfer()))
                let indexPath = NSIndexPath(forRow: valueArray.count - 1, inSection: 1)
                
                delegate?.updateTableViewUI(indexPath)
                
            }
        }
    }
    
    //MARK: - CBPeripheral delegate
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        if error != nil {
            print(error?.localizedDescription)
        } else {
            if let dataValue = characteristic.value {
                let dataString = String(data: dataValue, encoding: NSUTF8StringEncoding) ?? "No data respond"
                valueArray.append((dataString, dateFormatTransfer()))
                
                //Insert new cell row
                let sectionNum = identifier == .write ? 2 : 1
                let indexPath = NSIndexPath(forRow: valueArray.count - 1, inSection: sectionNum)
                delegate?.updateTableViewUI(indexPath)
            }
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateNotificationStateForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        delegate?.replaceNotifyImage(characteristic.isNotifying ? UIImage(named: "unnotifyItem") : UIImage(named: "notifyItem"))
    }
    
    func peripheral(peripheral: CBPeripheral, didWriteValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        if error != nil {
            print(error?.localizedDescription)
        } else {
            peripheral.readValueForCharacteristic(characteristic)
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForDescriptor descriptor: CBDescriptor, error: NSError?) {
        
        if error != nil {
            print(error?.localizedDescription)
        } else {
            if let descriptorString = descriptor.value?.description {
                descriptorArray.append(descriptorString)
                let indexPath = NSIndexPath(forRow: descriptorArray.count - 1, inSection: 0)
                delegate?.updateTableViewUI(indexPath)
            }
        }
        
    }

}
