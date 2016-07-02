//
//  CharacterInfo.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 7/2/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import Foundation
import CoreBluetooth

class CharacterInfo {
    var serviceObj: CBService
    var uuidString: String
    
    var characterArray = [CBCharacteristic]()
    init(service: CBService) {
        serviceObj = service
        uuidString = serviceObj.UUID.UUIDString
    }
}
