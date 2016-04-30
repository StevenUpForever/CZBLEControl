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
    
    class func showCancelAlertController(title: String, message: String, target: AnyObject) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert);
        let cancelAction = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        target.presentViewController(alertController, animated: true, completion: nil)
    }
    
    class func showCancelAlertControllerWithBlock(title: String, message: String, target: AnyObject, actionHandler: (action: UIAlertAction) -> Void) {
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: { (action) in
            actionHandler(action: action)
        }))
        target.presentViewController(alertController, animated: true, completion: nil)
        
    }

}
