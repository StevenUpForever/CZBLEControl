//
//  PeripheralInfo.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 16/4/3.
//  Copyright © 2016年 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth

struct PeripheralInfo {
    var peripheral: CBPeripheral
    var RSSI: NSNumber
    var adData: [String : AnyObject]
}

struct CharacterInfo {
    var serviceObj: CBService
    var characterArray = [CBCharacteristic]()
}
