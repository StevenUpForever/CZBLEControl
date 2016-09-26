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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationVC = segue.destination as? SavedDataTableViewController {
            switch segue.identifier! {
            case "GoogleDrive":
                destinationVC.dataSource = .googleDrive
            case "Dropbox":
                destinationVC.dataSource = .dropbox
            default:
                destinationVC.dataSource = .localDrive
            }
        }
    }

}
