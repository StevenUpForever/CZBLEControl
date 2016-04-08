//
//  CharacterInfo.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 16/4/7.
//  Copyright © 2016年 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth

class CharacterInfo: NSObject {
    var serviceObj: CBService
    var characterArray = [CBCharacteristic]()
    
    init(service: CBService) {
        serviceObj = service
        //super.init()
    }
}
