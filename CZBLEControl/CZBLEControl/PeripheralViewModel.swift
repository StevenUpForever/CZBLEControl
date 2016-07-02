//
//  PeripheralViewModel.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 7/2/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth

protocol peripheralTableViewDelegate: class {
    func updateTableViewSectionUI(indexSet: NSIndexSet)
    func updateTableViewRowUI(indexPaths: [NSIndexPath])
}

class PeripheralViewModel: NSObject, CBPeripheralDelegate {
    
    var peripheralObj: CBPeripheral?
    var centralManager = CBCentralManager()
    
    var uuidString = "UUID unavailable"
    
    weak var delegate: peripheralTableViewDelegate?
    
    //Public delegate for centralManager and peripheral
    
    let managerDelegate = CentralManagerDelegate()
    
    func loadBLEObjects(peripheral: CBPeripheral) {
        
        peripheralObj = peripheral
        peripheralObj?.delegate = self
        peripheralObj?.discoverServices(nil)
        
        uuidString = peripheralObj!.identifier.UUIDString
        
        centralManager.delegate = managerDelegate
    }
    
    func loadUI(callBack: (connected: Bool) -> Void) {
        if let state = peripheralObj?.state {
            switch state {
            case .Connected:
                callBack(connected: true)
                
            default:
                callBack(connected: false)
                
            }
        }
    }
    
    func reConnectPeripheral() {
        serviceArray.removeAll()
        guard let peripheral = peripheralObj else {
            return
        }
        centralManager.connectPeripheral(peripheral, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
    }
    
//    MARK: - peripheral delegate
    
    var serviceArray = [CharacterInfo]()
    
    func peripheral(peripheral: CBPeripheral, didDiscoverServices error: NSError?) {
        
        if let peripheralServiceArray = peripheral.services {
            for service: CBService in peripheralServiceArray {
                serviceArray.append(CharacterInfo(service: service))
                peripheral.discoverCharacteristics(nil, forService: service)
                
                delegate?.updateTableViewSectionUI(NSIndexSet(index: serviceArray.count - 1))
            }
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        
        for i in 0 ..< serviceArray.count {
            if serviceArray[i].serviceObj.isEqual(service) {
                guard let detailArray = service.characteristics else {
                    return
                }
                var indexpaths = [NSIndexPath]()
                for detail in detailArray {
                    serviceArray[i].characterArray.append(detail)
                    indexpaths.append(NSIndexPath(forRow: serviceArray[i].characterArray.count - 1, inSection: i))
                }
                delegate?.updateTableViewRowUI(indexpaths)
            }
        }
    }

}
