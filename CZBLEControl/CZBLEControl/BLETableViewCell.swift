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
        
        self.RSSIView.insertSubview(RSSISubView, belowSubview: rssiNumberLabel)
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func loadData() {
        
        self.nameLabel.text = viewModel.nameString
        self.UUIDLabel.text = viewModel.uuidString
        self.rssiNumberLabel.text = viewModel.RSSIString
        
        viewModel.changeRSSIValue(RSSIView, RSSISubView: RSSISubView)
        
        self.RSSIView.layoutIfNeeded()
    }

}
