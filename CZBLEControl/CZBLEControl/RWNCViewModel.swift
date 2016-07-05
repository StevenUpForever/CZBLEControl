//
//  RWNCViewModel.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 7/4/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
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

class RWNCViewModel: NSObject {
    
    var identifier: RWNCIdentifier = .none
    
    var peripheralObj: CBPeripheral?
    var characterObj: CBCharacteristic?
    
    var uuidString = "UUID unavailable"
    

}
