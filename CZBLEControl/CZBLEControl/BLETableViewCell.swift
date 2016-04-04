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
    @IBOutlet weak var RSSIView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var peripheralInfo: PeripheralInfo!
    let RSSISubView = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()
        self.RSSIView.addSubview(RSSISubView)
        self.RSSIView.layer.borderWidth = 2.0
        self.RSSIView.layer.borderColor = UIColor.darkGrayColor().CGColor
        // Initialization code
    }
    
    override func layoutSubviews() {
        self.RSSIView.layer.cornerRadius = self.RSSIView.frame.size.width/2.0
    }
    
    

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func loadData(info: PeripheralInfo?) {
        self.RSSIView.layer.cornerRadius = self.RSSIView.frame.size.width/2.0
        self.nameLabel.text = info?.peripheral.name == nil ? "Name Unavailable" : info?.peripheral.name
        self.UUIDLabel.text = info?.peripheral.identifier.UUIDString
        self.changeRSSIValue(((info?.RSSI.integerValue)! + 100)*2)
        self.peripheralInfo = info
        self.RSSIView.layoutIfNeeded()
    }
    
    private func changeRSSIValue(num: Int?) {
        let width = self.RSSIView.frame.size.width
        let height = self.RSSIView.frame.size.height
        if num == nil || (num >= 0 && num <= 25) {
            RSSISubView.frame = CGRectMake(0, height*3/4, width, height/4)
            RSSISubView.backgroundColor = UIColor.redColor()
        } else if num > 25 && num <= 50 {
            RSSISubView.frame = CGRectMake(0, height/2, width, height/2)
            RSSISubView.backgroundColor = UIColor.yellowColor()
        } else if num > 50 && num <= 75 {
            RSSISubView.frame = CGRectMake(0, height/4, width, height*3/4)
            RSSISubView.backgroundColor = UIColor.blueColor()
        } else if num > 75 {
            RSSISubView.frame = RSSIView.frame
            RSSISubView.backgroundColor = UIColor.greenColor()
        }
    }

}
