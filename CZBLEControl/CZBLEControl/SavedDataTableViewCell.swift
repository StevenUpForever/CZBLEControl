//
//  SavedDataTableViewCell.swift
//  CZBLEControl
//
//  Created by Steven Jia on 9/8/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit
import GoogleAPIClient
import SwiftyDropbox

class SavedDataTableViewCell: UITableViewCell {
    
    var dataSourceObj: AnyObject!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func loadData(sourceObj: AnyObject) {
        
        dataSourceObj = sourceObj
        
        if sourceObj is GTLDriveFile {
            textLabel?.text = sourceObj.name
        } else if sourceObj is Files.Metadata {
            textLabel?.text = sourceObj.name
        }
    }

}
