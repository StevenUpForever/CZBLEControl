//
//  PeripheralCellViewModel.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 7/2/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralCellViewModel: NSObject {
    
    var characterObj: CBCharacteristic?
    var uuidString = "UUID unavailable"
    var propertyString = "Propertites:"
    
    func addGradientToView(_ view: UIView) {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.white.cgColor, UIColor.gradientBlue().cgColor, UIColor.titleBlue().cgColor, UIColor.gradientBlue().cgColor, UIColor.white.cgColor]
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    func loadCharacter(_ character: CBCharacteristic, enable: (_ notify: Bool, _ read: Bool, _ write: Bool, _ writeNoResponse: Bool) -> Void) {
        characterObj = character
        uuidString = character.uuid.uuidString
        
        let property = character.properties
        propertyString = getPropertitesName(property)
        
        enable(property.rawValue & CBCharacteristicProperties.notify.rawValue > 0, property.rawValue & CBCharacteristicProperties.read.rawValue > 0, property.rawValue & CBCharacteristicProperties.write.rawValue > 0, property.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue > 0)
        
    }
    
    fileprivate func getPropertitesName(_ property: CBCharacteristicProperties) -> String {
        
        var propertyStr = "Propertites:"
        
        if property.rawValue & CBCharacteristicProperties.broadcast.rawValue > 0 {
            propertyStr += " Broadcast"
        }
        if property.rawValue & CBCharacteristicProperties.authenticatedSignedWrites.rawValue > 0 {
            propertyStr += " AuthenticatedSignedWrites"
        }
        if property.rawValue & CBCharacteristicProperties.extendedProperties.rawValue > 0 {
            propertyStr += " ExtendedProperties"
        }
        if property.rawValue & CBCharacteristicProperties.indicate.rawValue > 0 {
            propertyStr += " Indicate"
        }
        if property.rawValue & CBCharacteristicProperties.indicateEncryptionRequired.rawValue > 0 {
            propertyStr += " IndicateEncryptionRequired"
        }
        if property.rawValue & CBCharacteristicProperties.notify.rawValue > 0 {
            propertyStr += " Notify"
        }
        if property.rawValue & CBCharacteristicProperties.notifyEncryptionRequired.rawValue > 0 {
            propertyStr += " NotifyEncryptionRequired"
        }
        if property.rawValue & CBCharacteristicProperties.read.rawValue > 0 {
            propertyStr += " Read"
        }
        if property.rawValue & CBCharacteristicProperties.write.rawValue > 0 {
            propertyStr += " Write"
        }
        if property.rawValue & CBCharacteristicProperties.writeWithoutResponse.rawValue > 0 {
            propertyStr += " WriteWithoutResponse"
        }
        return propertyStr
    }

}
