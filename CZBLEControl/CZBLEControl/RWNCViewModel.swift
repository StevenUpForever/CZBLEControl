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

class RWNCViewModel: NSObject, UIPopoverPresentationControllerDelegate, UIViewControllerTransitioningDelegate, popoverDelegate {
    
    //BLE Objects
    
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
    
    //Data Save objects
    
    let googleDriveManager = GoogleDriveManager.sharedManager
    let dropboxManager = DropBoxManager.sharedManager
    
    //UI viewModel
    
    func setUIElement(actionBarItem: UIBarButtonItem, fallBackAction: () -> Void) {
        
        if peripheralObj != nil && characterObj != nil {
            
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
    
    //MARK: BLE viewModel
    
    func disconnectPeripheral() {
        if characterObj?.isNotifying == true {
            peripheralObj?.setNotifyValue(false, forCharacteristic: characterObj!)
        }
    }
    
    func appendDataToValueArray(characteristic: CBCharacteristic) -> NSIndexPath? {
        if let dataValue = characteristic.value {
            let dataString = String(data: dataValue, encoding: NSUTF8StringEncoding) ?? "No data respond"
            valueArray.append((dataString, dateFormatTransfer()))
            
            //Insert new cell row
            let sectionNum = identifier == .write ? 2 : 1
            return NSIndexPath(forRow: valueArray.count - 1, inSection: sectionNum)
        } else {
            return nil
        }
    }
    
    func appendDataToDescriptorArray(descriptor: CBDescriptor) -> NSIndexPath? {
        if let descriptorString = descriptor.value?.description {
            descriptorArray.append(descriptorString)
            return NSIndexPath(forRow: descriptorArray.count - 1, inSection: 0)
        } else {
            return nil
        }
    }

}
