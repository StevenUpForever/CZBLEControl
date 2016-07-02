//
//  PeripheralDelegate.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 7/2/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralDelegate: NSObject, CBPeripheralDelegate {
    
    //MARK: - peripheral delegate
    
        func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
    
            //If find new service, insert it into peripheral array
            if let peripheralServiceArray = peripheral.services {
                for service: CBService in peripheralServiceArray {
                    serviceArray.append(CharacterInfo(service: service))
                    peripheral.discoverCharacteristics(nil, forService: service)
                    let indexSet = NSIndexSet(index: serviceArray.count - 1)
                    tableView.insertSections(indexSet, withRowAnimation: .Left)
                }
            }
    
        }
    
        func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
    
            if let characterArray = service.characteristics {
                for character: CBCharacteristic in characterArray {
                    for info in serviceArray {
    
                        if info.serviceObj == service {
                            info.characterArray.append(character)
    
                            if let sectionNum = serviceArray.indexOf(info) {
                                let indexPath = NSIndexPath(forRow: info.characterArray.count - 1, inSection: sectionNum)
                                tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Left)
                            }
    
                        }
                    }
                }
            }
            
        }

}
