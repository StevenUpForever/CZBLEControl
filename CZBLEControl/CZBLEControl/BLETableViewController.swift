//
//  BLETableViewController.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 16/4/3.
//  Copyright © 2016年 ChengzhiJia. All rights reserved.
//

import UIKit
import CoreBluetooth
import Crashlytics

class BLETableViewController: UITableViewController, CBCentralManagerDelegate {
    
    let viewModel = BLETableViewModel()
    
    let refresh = UIRefreshControl()
    
    //MARK: - viewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        refresh.addTarget(self, action: #selector(BLETableViewController.tableViewRefresh(_:)), for: .valueChanged)
        view.addSubview(refresh)
        
        self.navigationItem.titleView = UIImageView(image: UIImage(named: "titleView"))
        
    }
    
    //Begin/Stop scan peripheral in lifeCycle when the view is appearing or dissappearing
    
    override func viewWillAppear(_ animated: Bool) {
        viewModel.centralManager.delegate = self
        viewModel.scanPeripheralInLifeCycle(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        viewModel.scanPeripheralInLifeCycle(false)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.peripheralArray.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "BLECell", for: indexPath) as! BLETableViewCell
        cell.loadData(viewModel.peripheralArray[(indexPath as NSIndexPath).row])
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.connectPeripheralWithSelectedRow(indexPath) { [weak self] (poweredOn) in
            if let strongSelf = self {
                if !poweredOn {
                    CustomAlertController.showCancelAlertController(NSLocalizedString("Please check your device and open Bluetooth", comment: ""), message: nil, target: strongSelf)
                } else {
                    let cell = tableView.cellForRow(at: indexPath) as! BLETableViewCell
                    if !cell.indicator.isAnimating {
                        cell.indicator.startAnimating()
                    }
                    strongSelf.viewModel.connectToPeripheral(cell.viewModel)
                }
            }
        }
    }
    
    //When deselect the cell, stop the animation of indicator on the deselected cell
    
    override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        endIndicatorLoading(indexPath)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 73.0
    }
    
    //MARK: - CBCentralManager delegate
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            viewModel.scanPeripheral()
        case .unsupported:
            CustomAlertController.showCancelAlertController(NSLocalizedString("BLE Unsupported", comment: ""), message: NSLocalizedString("Your device doesn't support BLE", comment: ""), target: self)
        case .poweredOff:
            CustomAlertController.showCancelAlertController("BLE turned off", message: "Please turn on your Bluetooth", target: self)
            viewModel.clearAllPeripherals({[unowned self] (indexPaths) in
                self.tableView.deleteRows(at: indexPaths, with: .right)
            })
        case .unknown:
            CustomAlertController.showCancelAlertController(NSLocalizedString("BLE Device error", comment: ""), message: NSLocalizedString("Unknown error, please try again", comment: ""), target: self)
        case .unauthorized:
            CustomAlertController.showCancelAlertController(NSLocalizedString("BLE unauthorized", comment: ""), message: NSLocalizedString("Your device is unauthorized to use Bluetooth", comment: ""), target: self)
        default:
            CustomAlertController.showCancelAlertController(NSLocalizedString("BLE Device error", comment: ""), message: NSLocalizedString("Unknown error, please try again", comment: ""), target: self)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        
        viewModel.discoverPeripheral(peripheral, RSSI: RSSI, adData: advertisementData as [String : AnyObject]) {[weak self] (newRow, indexPath) in
            if let strongSelf = self {
                if newRow {
                    if let cell = strongSelf.tableView.cellForRow(at: indexPath) as? BLETableViewCell {
                        cell.loadData(strongSelf.viewModel.peripheralArray[(indexPath as NSIndexPath).row])
                    }
                } else {
                    strongSelf.tableView.insertRows(at: [indexPath], with: .left)
                }
            }
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        endIndicatorLoading(viewModel.replaceSelectedPeripheral() as IndexPath)
        performSegue(withIdentifier: "peripheralControl", sender: self)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        endIndicatorLoading(viewModel.replaceSelectedPeripheral() as IndexPath)
        CustomAlertController.showCancelAlertController(NSLocalizedString("Connect error", comment: ""), message: NSLocalizedString("Cannot connect device, please try again", comment: ""), target: self)
    }

    //MARK: - Other selectors
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        viewModel.pushToPeripheralController(segue)
    }
    
    func endIndicatorLoading(_ indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? BLETableViewCell {
            if cell.indicator.isAnimating {
                cell.indicator.stopAnimating()
            }
        }
    }
    
    //MARK: - Selectors
    
    func tableViewRefresh(_ refreshControl: UIRefreshControl) {
        viewModel.clearAllPeripherals {[unowned self] (indexPaths) in
            self.tableView.deleteRows(at: indexPaths, with: .right)
        }
        viewModel.scanPeripheral()
        refreshControl.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
