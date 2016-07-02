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
    
    func addGradientToView(view: UIView) {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.whiteColor().CGColor, UIColor.gradientBlue().CGColor, UIColor.titleBlue().CGColor, UIColor.gradientBlue().CGColor, UIColor.whiteColor().CGColor]
        view.layer.insertSublayer(gradient, atIndex: 0)
    }
    
    func loadCharacter(character: CBCharacteristic, enable: (notify: Bool, read: Bool, write: Bool, writeNoResponse: Bool) -> Void) {
        characterObj = character
        uuidString = character.UUID.UUIDString
        
        let property = character.properties
        propertyString = getPropertitesName(property)
        
        enable(notify: property.rawValue & CBCharacteristicProperties.Notify.rawValue > 0, read: property.rawValue & CBCharacteristicProperties.Read.rawValue > 0, write: property.rawValue & CBCharacteristicProperties.Write.rawValue > 0, writeNoResponse: property.rawValue & CBCharacteristicProperties.WriteWithoutResponse.rawValue > 0)
        
    }
    
    private func getPropertitesName(property: CBCharacteristicProperties) -> String {
        
        var propertyStr = "Propertites:"
        
        if property.rawValue & CBCharacteristicProperties.Broadcast.rawValue > 0 {
            propertyStr += " Broadcast"
        }
        if property.rawValue & CBCharacteristicProperties.AuthenticatedSignedWrites.rawValue > 0 {
            propertyStr += " AuthenticatedSignedWrites"
        }
        if property.rawValue & CBCharacteristicProperties.ExtendedProperties.rawValue > 0 {
            propertyStr += " ExtendedProperties"
        }
        if property.rawValue & CBCharacteristicProperties.Indicate.rawValue > 0 {
            propertyStr += " Indicate"
        }
        if property.rawValue & CBCharacteristicProperties.IndicateEncryptionRequired.rawValue > 0 {
            propertyStr += " IndicateEncryptionRequired"
        }
        if property.rawValue & CBCharacteristicProperties.Notify.rawValue > 0 {
            propertyStr += " Notify"
        }
        if property.rawValue & CBCharacteristicProperties.NotifyEncryptionRequired.rawValue > 0 {
            propertyStr += " NotifyEncryptionRequired"
        }
        if property.rawValue & CBCharacteristicProperties.Read.rawValue > 0 {
            propertyStr += " Read"
        }
        if property.rawValue & CBCharacteristicProperties.Write.rawValue > 0 {
            propertyStr += " Write"
        }
        if property.rawValue & CBCharacteristicProperties.WriteWithoutResponse.rawValue > 0 {
            propertyStr += " WriteWithoutResponse"
        }
        return propertyStr
    }

}
