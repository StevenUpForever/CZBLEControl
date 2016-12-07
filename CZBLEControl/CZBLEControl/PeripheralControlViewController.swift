//
//  PeripheralControlViewController.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 16/4/3.
//  Copyright © 2016年 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth

class PeripheralControlViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, peripheralTableViewDelegate {
    
    //IBOutlets
    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var connectBarItem: UIBarButtonItem!
    
    let viewModel = PeripheralViewModel()
    
    var selectedIndexPath: IndexPath?

    //MARK: - viewController lifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        uuidLabel.text = viewModel.uuidString
        viewModel.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.centralManager?.delegate = self
        viewModel.setPeripheralDelegate()
        
        viewModel.loadUI {[unowned self] (connected) in
            if connected {
                self.connectedUI()
            } else {
                self.disconnectedUI()
            }
        }
        
    }
    
    //MARK - centralManager delegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            break
        case .poweredOff:
            CustomAlertController.showCancelAlertControllerWithBlock(NSLocalizedString("BLE turned off", comment: ""), message: NSLocalizedString("Turn on your Bluetooth, going back", comment: ""), target: self, actionHandler: { (action) in
                _ = self.navigationController?.popToRootViewController(animated: true)
            })
        default:
            CustomAlertController.showCancelAlertController(NSLocalizedString("Unknown Error", comment: ""), message: NSLocalizedString("Unknown error, please try again", comment: ""), target: self)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        
        connectedUI()
        
        viewModel.scanCharacteristics(peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        CustomAlertController.showCancelAlertController(NSLocalizedString("Connect error", comment: ""), message: NSLocalizedString("Cannot connect device, please try again", comment: ""), target: self)
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        CustomAlertController.showCancelAlertController(NSLocalizedString("Peripheral disconnected", comment: ""), message: NSLocalizedString("Please reconnect your device", comment: ""), target: self)
        
        disconnectedUI()
    }
    
    //MARK: - tableView datasource & delegate
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.serviceArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.serviceArray[section].characterArray.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.serviceArray[section].uuidString
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "serviceCell") as! ServiceTableViewCell
        let character = viewModel.serviceArray[(indexPath as NSIndexPath).section].characterArray[(indexPath as NSIndexPath).row]
        cell.loadCellUI(character)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        openHiddenSubViewAtIndexPath(indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return selectedIndexPath == indexPath ? 180.0 : 95.0
    }
    
    //MARK: - Selectors
    
    @IBAction func dropDownProcess(_ sender: AnyObject) {
        let buttonPosition = sender.convert(CGPoint.zero, to: tableView)
        if let indexPath = tableView.indexPathForRow(at: buttonPosition) {
            openHiddenSubViewAtIndexPath(indexPath)
        }
    }
    
    fileprivate func openHiddenSubViewAtIndexPath(_ indexPath: IndexPath) {
        selectedIndexPath = selectedIndexPath == indexPath ? nil : indexPath
        tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    @IBAction func connectSelfPeripheral(_ sender: AnyObject) {
        viewModel.reConnectPeripheral()
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let notNilSelectedIndexPath = selectedIndexPath else {
            return
        }
        if let cell = tableView.cellForRow(at: notNilSelectedIndexPath) as? ServiceTableViewCell {
            
            //Prepare for destination viewController
            if let RWNCVC = segue.destination as? RWNCTableViewController {
                
                viewModel.segueAction(RWNCVC, cellViewModel: cell.viewModel, segue: segue)
                
            }
        }
    }
    
    //MARK: - custom peripheral delegate
    
    func updateTableViewSectionUI(_ indexSet: IndexSet) {
        tableView.insertSections(indexSet, with: .left)
    }
    
    func updateTableViewRowUI(_ indexPaths: [IndexPath]) {
        tableView.insertRows(at: indexPaths, with: UITableViewRowAnimation.left)
    }
    
    //MARK: - private methods
    
    func connectedUI() {
        statusLabel.text = NSLocalizedString("Connected", comment: "")
        statusLabel.textColor = UIColor.black
        connectBarItem.isEnabled = false
    }
    
    func disconnectedUI() {
        statusLabel.text = NSLocalizedString("Disconnected\nReconnect by top right button or back to choose another device", comment: "")
        statusLabel.textColor = UIColor.red
        connectBarItem.isEnabled = true
    }
    
    
}
