//
//  CharacterInfo.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 7/2/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import Foundation
import CoreBluetooth

struct CharacterInfo {
    var serviceObj: CBService
    var characterArray = [CBCharacteristic]()
}
