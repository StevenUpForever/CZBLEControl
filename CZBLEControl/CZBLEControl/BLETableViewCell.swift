//
//  BLETableViewCell.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 16/4/3.
//  Copyright © 2016年 ChengzhiJia. All rights reserved.
//

import UIKit

class BLETableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var UUIDLabel: UILabel!
    @IBOutlet weak var RSSIView: CustomView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var rssiNumberLabel: UILabel!
    
    var peripheralInfo: PeripheralInfo?
    
    let RSSISubView = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.RSSIView.insertSubview(RSSISubView, belowSubview: rssiNumberLabel)
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func loadData(info: PeripheralInfo?) {
        
        self.peripheralInfo = info
        
        self.RSSIView.layer.cornerRadius = self.RSSIView.frame.size.width/2.0
        self.nameLabel.text = info?.peripheral.name == nil ? "Name Unavailable" : info?.peripheral.name
        self.UUIDLabel.text = info?.peripheral.identifier.UUIDString
        
        let RSSINum = info?.RSSI.integerValue ?? 0
        self.rssiNumberLabel.text = "\(RSSINum)"
        self.changeRSSIValue((RSSINum + 100)*2)
        
        self.RSSIView.layoutIfNeeded()
    }
    
    //Change RSSI number shown
    private func changeRSSIValue(num: Int?) {
        
        let width = self.RSSIView.frame.size.width
        let height = self.RSSIView.frame.size.height
        
        if num >= 0 && num <= 25 {
            self.RSSISubView.frame = CGRectMake(0, height*3/4, width, height/4)
            self.RSSISubView.backgroundColor = UIColor.customRed()
        } else if num > 25 && num <= 50 {
            self.RSSISubView.frame = CGRectMake(0, height/2, width, height/2)
            self.RSSISubView.backgroundColor = UIColor.customOrange()
        } else if num > 50 && num <= 75 {
            self.RSSISubView.frame = CGRectMake(0, height/4, width, height*3/4)
            self.RSSISubView.backgroundColor = UIColor.customBlue()
        } else if num > 75 {
            self.RSSISubView.frame = self.RSSIView.bounds
            self.RSSISubView.backgroundColor = UIColor.customGreen()
        }
    }

}
