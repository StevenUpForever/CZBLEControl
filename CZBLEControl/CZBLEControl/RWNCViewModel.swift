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
    func updateTableViewUI(_ indexPath: IndexPath)
    func replaceNotifyImage(_ image: UIImage?)
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
    
    var uuidString = NSLocalizedString("UUID unavailable", comment: "")
    
    weak var delegate: RWNCDelegate?
    
    //tableView array
    
    var valueArray = [(String, String)]()
    var descriptorArray = [String]()
    var writeValueArray = [(String, String)]()
    
    //Data Save objects
    
    let googleDriveManager = GoogleDriveManager.sharedManager
    let dropboxManager = DropBoxManager.sharedManager
    let coreDataProcessor = CoreDataManager.sharedInstance
    
    var tempInfo: tempUploadInfo?
    
    struct tempUploadInfo {
        var tempFileName: String
        var tempTarget: UIViewController
        var completionHandler: statusMessageHandler
    }
    
    //UI viewModel
    
    func setUIElement(_ actionBarItem: UIBarButtonItem, fallBackAction: () -> Void) {
        
        if peripheralObj != nil && characterObj != nil {
            
            switch identifier {
            case .read:
                actionBarItem.title = NSLocalizedString("read", comment: "")
                peripheralObj?.readValue(for: characterObj!)
                
            case .write, .writeWithNoResponse:
                actionBarItem.title = NSLocalizedString("write", comment: "")
                
            case .notify:
                peripheralObj?.setNotifyValue(true, for: characterObj!)
                actionBarItem.title = nil
                actionBarItem.image = UIImage(named: "unnotifyItem")
                
            default:
                fallBackAction()
            }
            
            if let descriptorArray = characterObj?.descriptors {
                for descriptor: CBDescriptor in descriptorArray {
                    peripheralObj?.readValue(for: descriptor)
                }
            }
        } else {
            fallBackAction()
        }
    }
    
    func actionButtonProcess(_ sender: UIBarButtonItem, target: RWNCTableViewController) {
        guard let character = characterObj else {
            return
        }
        switch identifier {
        case .read:
            peripheralObj?.readValue(for: character)
            
        case .write, .writeWithNoResponse:
            let popVC = PopoverViewController()
            popVC.delegate = self
            popVC.modalPresentationStyle = UIModalPresentationStyle.popover
            popVC.preferredContentSize = CGSize(width: 300, height: 125)
            popVC.transitioningDelegate = self
            let popController = popVC.popoverPresentationController
            popController?.permittedArrowDirections = .any
            popController?.barButtonItem = sender
            popController?.delegate = self
            
            target.present(popVC, animated: true, completion: nil)
            
        case .notify:
            if characterObj?.isNotifying == true {
                CustomAlertController.showChooseAlertControllerWithBlock(NSLocalizedString("Close notify", comment: ""), message: NSLocalizedString("Are you sure to close notify?", comment: ""), target: target, actionHandler: { (action) in
                    self.peripheralObj?.setNotifyValue(false, for: character)
                })
            } else {
                peripheralObj?.setNotifyValue(true, for: character)
            }
            
        default:
            break
        }
    }
    
    //MARK: - popoverPresentViewControlller delegate
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    //MARK: - PopoverVC delegate
    
    func popOverVCWriteValueProcess(_ input: String) {
        if let data = input.data(using: String.Encoding.utf8) {
            peripheralObj?.writeValue(data, for: characterObj!, type: .withoutResponse)
            
            if identifier == .write {
                writeValueArray.append((input, dateFormatTransfer()))
                let indexPath = IndexPath(row: writeValueArray.count - 1, section: 1)
                
                delegate?.updateTableViewUI(indexPath)
                
            } else {
                valueArray.append((input, dateFormatTransfer()))
                let indexPath = IndexPath(row: valueArray.count - 1, section: 1)
                
                delegate?.updateTableViewUI(indexPath)
                
            }
        }
    }
    
    //MARK: BLE viewModel
    
    func disconnectPeripheral() {
        if characterObj?.isNotifying == true {
            peripheralObj?.setNotifyValue(false, for: characterObj!)
        }
    }
    
    func appendDataToValueArray(_ characteristic: CBCharacteristic) -> IndexPath? {
        if let dataValue = characteristic.value {
            let dataString = String(data: dataValue, encoding: String.Encoding.utf8) ?? NSLocalizedString("No data respond", comment: "")
            valueArray.append((dataString, dateFormatTransfer()))
            
            //Insert new cell row
            let sectionNum = identifier == .write ? 2 : 1
            return IndexPath(row: valueArray.count - 1, section: sectionNum)
        } else {
            return nil
        }
    }
    
    func appendDataToDescriptorArray(_ descriptor: CBDescriptor) -> IndexPath? {
        if let descriptorString = (descriptor.value as AnyObject).description {
            descriptorArray.append(descriptorString)
            return IndexPath(row: descriptorArray.count - 1, section: 0)
        } else {
            return nil
        }
    }

}
