//
//  RWNCTableViewController.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 16/4/8.
//  Copyright © 2016年 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth
import MBProgressHUD

class RWNCTableViewController: UITableViewController, CBCentralManagerDelegate, RWNCDelegate {
    
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
        indicator.label.text = "Saving..."
        
        viewModel.setUIElement(actionBarItem) { 
            self.showfallBackAlertController()
        }
        
    }
    
    override func viewWillAppear(animated: Bool) {
        viewModel.centralManager?.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        if viewModel.identifier == .none {
            showfallBackAlertController()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        viewModel.disconnectPeripheral()
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return viewModel.sectionNum()
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.rowNum(section)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        viewModel.cellText(cell, indexPath: indexPath)
        return cell
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sectionTitle(section)
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section == 0 ? false : true
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            viewModel.deleteObjectAtIndexPath(indexPath)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Right)
        }
    }
    
    //MARK: - CBCentral delegate
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
        switch central.state {
        case CBCentralManagerState.PoweredOn:
            break
        case CBCentralManagerState.PoweredOff:
            CustomAlertController.showCancelAlertController("BLE turned off", message: "Please turn on your Bluetooth", target: self)
        default:
            CustomAlertController.showCancelAlertController("Unknown Error", message: "Unknown error, please try again", target: self)
        }
    }
    
    func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        let alertController = UIAlertController(title: "Peripheral disconnected", message: "Fallback or save your data", preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "back", style: .Default, handler: { (action) in
            if let nav = self.navigationController {
                nav.popViewControllerAnimated(true)
            }
        }))
        alertController.addAction(UIAlertAction(title: "Stay", style: .Cancel, handler: nil))
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    //MARK: - IBActions and Selectors
    
    @IBAction func actionProcess(sender: UIBarButtonItem) {
        viewModel.actionButtonProcess(sender, target: self)
    }
    
    weak var fileNameTextField: UITextField?
    weak var submitAction: UIAlertAction?
    var fileName: String?
    
    @IBAction func saveAction(sender: UIBarButtonItem) {
        showFileNameAlertController()
    }
    
    //MARK: - viewModel delegate
    
    func updateTableViewUI(indexPath: NSIndexPath) {
        tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Left)
    }
    
    func replaceNotifyImage(image: UIImage?) {
        actionBarItem.image = image
    }
    
    //MARK: - private methods
    
    private func showfallBackAlertController() {
        CustomAlertController.showCancelAlertControllerWithBlock("Peripheral not found", message: "Peripheral or characteristic not found, going back", target: self, actionHandler: { (action) in
            self.navigationController?.popViewControllerAnimated(true)
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
