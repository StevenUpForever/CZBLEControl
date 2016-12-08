//
//  RWNCTableViewController.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 16/4/8.
//  Copyright © 2016年 ChengzhiJia. All rights reserved.
//

import UIKit
import MBProgressHUD

class RWNCTableViewController: UITableViewController, RWNCDelegate {
    
    let viewModel = RWNCViewModel()
    var indicator: MBProgressHUD!
    
    //IBOutlets
    @IBOutlet weak var actionBarItem: UIBarButtonItem!

    //MARK: - viewController lifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.delegate = self
        
        navigationItem.title = viewModel.uuidString
        indicator = MBProgressHUD(view: tableView)
        tableView.addSubview(indicator)
        indicator.label.text = NSLocalizedString("Saving...", comment: "")
        
        viewModel.setUIElement(actionBarItem) { 
            self.showfallBackAlertController()
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.centralManager?.delegate = self
        viewModel.peripheralObj?.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        if viewModel.identifier == .none {
            showfallBackAlertController()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.disconnectPeripheral()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sectionNum()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rowNum(section)
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        viewModel.cellText(cell, indexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sectionTitle(section)
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return (indexPath as NSIndexPath).section == 0 ? false : true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            viewModel.deleteObjectAtIndexPath(indexPath)
            tableView.deleteRows(at: [indexPath], with: .right)
        }
    }
    
    //MARK: - IBActions and Selectors
    
    @IBAction func actionProcess(_ sender: UIBarButtonItem) {
        viewModel.actionButtonProcess(sender, target: self)
    }
    
    weak var fileNameTextField: UITextField?
    weak var submitAction: UIAlertAction?
    var fileName: String?
    
    @IBAction func saveAction(_ sender: UIBarButtonItem) {
        if viewModel.dataExisted() {
            showFileNameAlertController()
        } else {
            CustomAlertController.showCancelAlertController(NSLocalizedString("No data to save", comment: ""), message: nil, target: self)
        }
    }
    
    //MARK: - viewModel delegate
    
    func updateTableViewUI(_ indexPath: IndexPath) {
        tableView.insertRows(at: [indexPath], with: .left)
    }
    
    func replaceNotifyImage(_ image: UIImage?) {
        actionBarItem.image = image
    }
    
    //MARK: - private methods
    
    fileprivate func showfallBackAlertController() {
        CustomAlertController.showCancelAlertControllerWithBlock(NSLocalizedString("Peripheral not found", comment: ""), message: NSLocalizedString("Peripheral or characteristic not found, going back", comment: ""), target: self, actionHandler: { (action) in
            _ = self.navigationController?.popViewController(animated: true)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
