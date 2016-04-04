//
//  PeripheralInfo.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 16/4/3.
//  Copyright © 2016年 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralInfo: NSObject {
    
    var peripheral: CBPeripheral
    var RSSI: NSNumber
    
    init(peripheral: CBPeripheral, RSSI: NSNumber) {
        self.peripheral = peripheral
        self.RSSI = RSSI
    }

}
