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
    func updateTableViewSectionUI(_ indexSet: IndexSet)
    func updateTableViewRowUI(_ indexPaths: [IndexPath])
}

class PeripheralViewModel: NSObject, CBPeripheralDelegate {
    
    var peripheralObj: CBPeripheral?
    var centralManager: CBCentralManager?
    
    var uuidString = NSLocalizedString("UUID Unavailable", comment: "")
    
    weak var delegate: peripheralTableViewDelegate?
    
    //Public delegate for centralManager and peripheral
    
    func loadBLEObjects(_ peripheral: CBPeripheral, central: CBCentralManager) {
        
        centralManager = central
        
        peripheralObj = peripheral
        setPeripheralDelegate()
        peripheralObj?.discoverServices(nil)
        
        uuidString = peripheralObj!.identifier.uuidString
    }
    
    func setPeripheralDelegate() {
        peripheralObj?.delegate = self
    }
    
    func loadUI(_ callBack: (_ connected: Bool) -> Void) {
        if let peripheral = peripheralObj {
            switch peripheral.state {
            case .connected:
                callBack(true)
                
            default:
                callBack(false)
                
            }
        } else {
            callBack(false)
        }
    }
    
    func reConnectPeripheral() {
        serviceArray.removeAll()
        if let peripheral = peripheralObj {
            if let central = centralManager {
                central.connect(peripheral, options: [CBCentralManagerScanOptionAllowDuplicatesKey: false])
            }
        }
    }
    
    func scanCharacteristics(_ peripheral: CBPeripheral) {
        peripheralObj = peripheral
        peripheralObj?.discoverServices(nil)
    }
    
    func segueAction(_ RWNCVC: RWNCTableViewController, cellViewModel: PeripheralCellViewModel, segue: UIStoryboardSegue) {
        
        if let identifyStr = segue.identifier {
            RWNCVC.viewModel.identifier = swichIdentifier(identifyStr)
        }
        RWNCVC.viewModel.centralManager = centralManager
        RWNCVC.viewModel.peripheralObj = peripheralObj
        RWNCVC.viewModel.characterObj = cellViewModel.characterObj
        RWNCVC.viewModel.uuidString = cellViewModel.uuidString
        
    }
    
    fileprivate func swichIdentifier(_ identifier: String) -> RWNCIdentifier {
        switch identifier {
        case "read":
            return .read
            
        case "write":
            return .write
            
        case "writeWithoutResponse":
            return .writeWithNoResponse
            
        case "notify":
            return .notify
            
        default:
            return .none
        }
    }
    
//    MARK: - peripheral delegate
    
    var serviceArray = [CharacterInfo]()
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        if let peripheralServiceArray = peripheral.services {
            for service: CBService in peripheralServiceArray {
                serviceArray.append(CharacterInfo(service: service))
                peripheral.discoverCharacteristics(nil, for: service)
                
                delegate?.updateTableViewSectionUI(IndexSet(integer: serviceArray.count - 1))
            }
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        for i in 0 ..< serviceArray.count {
            if serviceArray[i].serviceObj.isEqual(service) {
                guard let detailArray = service.characteristics else {
                    return
                }
                var indexpaths = [IndexPath]()
                for detail in detailArray {
                    serviceArray[i].characterArray.append(detail)
                    indexpaths.append(IndexPath(row: serviceArray[i].characterArray.count - 1, section: i))
                }
                delegate?.updateTableViewRowUI(indexpaths)
            }
        }
    }

}
