//
//  PopoverViewController.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 16/4/8.
//  Copyright © 2016年 ChengzhiJia. All rights reserved.
//

import UIKit

@objc protocol popoverDelegate {
    func popOverVCWriteValueProcess(input: String)
}

class PopoverViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var valueTextField: UITextField!
    
    weak var delegate: popoverDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        valueTextField.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - IBActions
    
    @IBAction func submitProcess(sender: AnyObject) {
        if valueTextField.text != nil && !valueTextField.text!.isEmpty {
            delegate?.popOverVCWriteValueProcess(valueTextField.text!)
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            valueTextField.layer.borderWidth = 2.0
            valueTextField.layer.borderColor = UIColor.redColor().CGColor
        }
    }
    
    //MARK: - textField delegate
    
    func textFieldDidBeginEditing(textField: UITextField) {
        valueTextField.layer.borderWidth = 0.0
        valueTextField.layer.borderColor = UIColor.clearColor().CGColor
    }
    

}
