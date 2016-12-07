//
//  BLECellViewModel.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 7/2/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth

class BLECellViewModel: NSObject {
    
    var nameString: String = NSLocalizedString("Name Unavailable", comment: "")
    var uuidString: String = NSLocalizedString("UUID Unavailable", comment: "")
    
    fileprivate var RSSINum = 0
    var RSSIString: String = "0"
    
    var peripheral: CBPeripheral?
    
    func loadDataFromPeripheralObj(_ peripheralObj: PeripheralInfo) {
        if let name = peripheralObj.peripheral.name {
            nameString = name
        }
        uuidString = peripheralObj.peripheral.identifier.uuidString
        
        RSSINum = peripheralObj.RSSI.intValue
        RSSIString = "\(RSSINum)"
        
        peripheral = peripheralObj.peripheral
    }
    
    //Change RSSI number shown
    
    func changeRSSIValue(_ RSSIView: UIView, RSSISubView: UIView) {
        
        let width = RSSIView.frame.size.width
        let height = RSSIView.frame.size.height
        
        let num = (RSSINum + 100) * 2
        
        if num >= 0 && num <= 25 {
            RSSISubView.frame = CGRect(x: 0, y: height*3/4, width: width, height: height/4)
            RSSISubView.backgroundColor = UIColor.customRed()
        } else if num > 25 && num <= 50 {
            RSSISubView.frame = CGRect(x: 0, y: height/2, width: width, height: height/2)
            RSSISubView.backgroundColor = UIColor.customOrange()
        } else if num > 50 && num <= 75 {
            RSSISubView.frame = CGRect(x: 0, y: height/4, width: width, height: height*3/4)
            RSSISubView.backgroundColor = UIColor.customBlue()
        } else if num > 75 {
            RSSISubView.frame = RSSIView.bounds
            RSSISubView.backgroundColor = UIColor.customGreen()
        }
    }

}
