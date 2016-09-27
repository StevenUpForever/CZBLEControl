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
    @IBOutlet weak var rssiNumberLabel: UILabel!
    
    let viewModel = BLECellViewModel()
    
    let RSSISubView = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Add colored view to show the changes about RSSI number
        RSSIView.layer.borderColor = UIColor.darkGray.cgColor
        RSSIView.layer.borderWidth = 1.0
        self.RSSIView.insertSubview(RSSISubView, belowSubview: rssiNumberLabel)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        RSSIView.layer.cornerRadius = RSSIView.frame.size.width/2.0;
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //Load data to viewMode and UI data from viewModel
    
    func loadData(_ peripheralObj: PeripheralInfo) {
        
        viewModel.loadDataFromPeripheralObj(peripheralObj)
        
        self.nameLabel.text = viewModel.nameString
        self.UUIDLabel.text = viewModel.uuidString
        self.rssiNumberLabel.text = viewModel.RSSIString
        
        viewModel.changeRSSIValue(RSSIView, RSSISubView: RSSISubView)
        
        self.RSSIView.layoutIfNeeded()
    }

}
