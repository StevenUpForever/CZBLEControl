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
    var adData: [String : AnyObject]
    
    init(peripheral: CBPeripheral, RSSI: NSNumber, adData: [String : AnyObject]) {
        self.peripheral = peripheral
        self.RSSI = RSSI
        self.adData = adData
        super.init()
    }

}
