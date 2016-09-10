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
        
        if let googleDriveSource = sourceObj as? GTLDriveFile {
            textLabel?.text = googleDriveSource.name
        } else if let dropboxSource = sourceObj as? Files.Metadata {
            textLabel?.text = dropboxSource.name
        }
    }

}
