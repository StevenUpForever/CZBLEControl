//
//  SavedDataSourceTableViewController.swift
//  CZBLEControl
//
//  Created by Steven Jia on 9/8/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit

class SavedDataSourceTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationVC = segue.destinationViewController as? SavedDataTableViewController {
            switch segue.identifier! {
            case "GoogleDrive":
                destinationVC.dataSource = .GoogleDrive
            case "Dropbox":
                destinationVC.dataSource = .Dropbox
            default:
                destinationVC.dataSource = .localDrive
            }
        }
    }

}
