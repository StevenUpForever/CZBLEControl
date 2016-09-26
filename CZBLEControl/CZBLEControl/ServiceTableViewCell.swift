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
        
        readButton.isEnabled = false
        writeButton.isEnabled = false
        notifyButton.isEnabled = false
        writeNoResponseButton.isEnabled = false
        
        viewModel.addGradientToView(buttonCombineView)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func loadCellUI(_ character: CBCharacteristic) {
        
        viewModel.loadCharacter(character) { (notify, read, write, writeNoResponse) in
            self.notifyButton.isEnabled = notify
            self.readButton.isEnabled = read
            self.writeButton.isEnabled = write
            self.writeNoResponseButton.isEnabled = writeNoResponse
        }
        
        uuidLabel.text = viewModel.uuidString
        propertyLabel.text = viewModel.propertyString
    }

}
