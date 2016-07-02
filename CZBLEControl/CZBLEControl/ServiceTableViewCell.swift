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
    @IBOutlet weak var buttonCombineView: UIView!
    @IBOutlet weak var writeNoResponseButton: UIButton!
    
    let viewModel = PeripheralCellViewModel()
    
    var cellCharacter: CBCharacteristic?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        var ss: UIViewController?
        if let aa = ss as? PeripheralControlViewController {
            
        }
        
        readButton.enabled = false
        writeButton.enabled = false
        notifyButton.enabled = false
        writeNoResponseButton.enabled = false
        
        viewModel.addGradientToView(buttonCombineView)
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func loadCellUI(character: CBCharacteristic) {
        
        viewModel.loadCharacter(character) { (notify, read, write, writeNoResponse) in
            self.notifyButton.enabled = notify
            self.readButton.enabled = read
            self.writeButton.enabled = write
            self.writeNoResponseButton.enabled = writeNoResponse
        }
        
        uuidLabel.text = viewModel.uuidString
        propertyLabel.text = viewModel.propertyString
    }

}
