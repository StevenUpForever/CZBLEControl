//
//  PopoverViewController.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 16/4/8.
//  Copyright © 2016年 ChengzhiJia. All rights reserved.
//

import UIKit

protocol popoverDelegate: class {
    func popOverVCWriteValueProcess(_ input: String)
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
    
    @IBAction func submitProcess(_ sender: AnyObject) {
        if valueTextField.text != nil && !valueTextField.text!.isEmpty {
            
            delegate?.popOverVCWriteValueProcess(valueTextField.text!)
            
            self.dismiss(animated: true, completion: nil)
        } else {
            valueTextField.layer.borderWidth = 2.0
            valueTextField.layer.borderColor = UIColor.red.cgColor
        }
    }
    
    //MARK: - textField delegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        valueTextField.layer.borderWidth = 0.0
        valueTextField.layer.borderColor = UIColor.clear.cgColor
    }
    

}
