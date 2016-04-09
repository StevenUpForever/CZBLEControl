//
//  RWNCPrepareInfo.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 16/4/8.
//  Copyright © 2016年 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth

enum RWNCIdentifier: String {
    case read = "read"
    case write = "write"
    case writeWithNoResponse = "writeWithNoResponse"
    case notify = "notify"
    case descriptor = "descriptor"
}

class RWNCPrepareInfo: NSObject {
    
    var RWNCPeripheral: CBPeripheral?
    var RWNCCharacter: CBCharacteristic?
    var barItemTitleStr: String?
    var barItemTag: Int?
    
    init(identifier: RWNCIdentifier, peripheral: CBPeripheral?, character: CBCharacteristic?) {
        RWNCPeripheral = peripheral
        RWNCCharacter = character
        
        switch identifier {
        case .read:
            barItemTitleStr = "read"
            barItemTag = 0
        case .write:
            barItemTitleStr = "write"
            barItemTag = 1
        case .writeWithNoResponse:
            barItemTitleStr = "write"
            barItemTag = 2
        case .notify:
            barItemTitleStr = ""
            barItemTag = 3
        case .descriptor:
            barItemTitleStr = ""
            barItemTag = 4
        }
    }

}
