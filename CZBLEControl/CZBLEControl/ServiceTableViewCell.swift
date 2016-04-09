//
//  ServiceTableViewCell.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 16/4/7.
//  Copyright © 2016年 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth

class ServiceTableViewCell: UITableViewCell {

    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var propertyLabel: UILabel!
    @IBOutlet weak var readButton: UIButton!
    @IBOutlet weak var writeButton: UIButton!
    @IBOutlet weak var notifyButton: UIButton!
    @IBOutlet weak var descriptorButton: UIButton!
    @IBOutlet weak var buttonCombineView: UIView!
    
    var cellCharacter: CBCharacteristic?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        readButton.enabled = false
        writeButton.enabled = false
        notifyButton.enabled = false
        
        let gradient = CAGradientLayer()
        gradient.frame = buttonCombineView.bounds
        gradient.colors = [UIColor.whiteColor().CGColor, UIColor.gradientBlue().CGColor, UIColor.titleBlue().CGColor, UIColor.gradientBlue().CGColor, UIColor.whiteColor().CGColor]
        buttonCombineView.layer.insertSublayer(gradient, atIndex: 0)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadData(character: CBCharacteristic) {
        cellCharacter = character
        uuidLabel.text = character.UUID.UUIDString
        propertyLabel.text = getPropertitesName(character.properties)
    }
    
    func getPropertitesName(property: CBCharacteristicProperties) -> String {
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
            notifyButton.enabled = true
        }
        if property.rawValue & CBCharacteristicProperties.NotifyEncryptionRequired.rawValue > 0 {
            propertyStr += " NotifyEncryptionRequired"
        }
        if property.rawValue & CBCharacteristicProperties.Read.rawValue > 0 {
            propertyStr += " Read"
            readButton.enabled = true
        }
        if property.rawValue & CBCharacteristicProperties.Write.rawValue > 0 {
            propertyStr += " Write"
            writeButton.enabled = true
        }
        if property.rawValue & CBCharacteristicProperties.WriteWithoutResponse.rawValue > 0 {
            propertyStr += " WriteWithoutResponse"
            writeButton.enabled = true
        }
        return propertyStr
    }

}
