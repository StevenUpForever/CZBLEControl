//
//  CustomAlertController.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 16/4/3.
//  Copyright © 2016年 ChengzhiJia. All rights reserved.
//

import UIKit

class CustomAlertController: UIAlertController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    class func showCancelAlertController(_ title: String?, message: String?, target: UIViewController) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert);
        let cancelAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        target.present(alertController, animated: true, completion: nil)
    }
    
    class func showCancelAlertControllerWithBlock(_ title: String, message: String, target: UIViewController, actionHandler: @escaping (_ action: UIAlertAction) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { (action) in
            actionHandler(action)
        }))
        target.present(alertController, animated: true, completion: nil)
    }
    
    class func showChooseAlertControllerWithBlock(_ title: String?, message: String?, target: UIViewController, actionHandler: @escaping (_ action: UIAlertAction) -> Void) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (action) in
            actionHandler(action)
        }))
        target.present(alertController, animated: true, completion: nil)
    }

}
