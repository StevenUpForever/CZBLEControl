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
    
    let viewModel = BLECellViewModel()
    
    let RSSISubView = UIView()

    override func awakeFromNib() {
        super.awakeFromNib()
        
        //Add colored view to show the changes about RSSI number
        
        self.RSSIView.insertSubview(RSSISubView, belowSubview: rssiNumberLabel)
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
