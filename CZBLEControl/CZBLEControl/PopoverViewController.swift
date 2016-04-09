//
//  PopoverViewController.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 16/4/8.
//  Copyright © 2016年 ChengzhiJia. All rights reserved.
//

import UIKit

@objc protocol detailsControlDelegate {
    optional func writeValueProcess(input: String)
}

class PopoverViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var valueTextField: UITextField!
    
    weak var delegate: detailsControlDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        valueTextField.delegate = self
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func submitProcess(sender: AnyObject) {
        if valueTextField.text != nil && valueTextField.text?.characters.count != 0 {
            delegate?.writeValueProcess!(valueTextField.text!)
            self.dismissViewControllerAnimated(true, completion: nil)
        } else {
            valueTextField.layer.borderWidth = 2.0
            valueTextField.layer.borderColor = UIColor.redColor().CGColor
        }
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        valueTextField.layer.borderWidth = 0.0
        valueTextField.layer.borderColor = UIColor.clearColor().CGColor
    }
    

}
