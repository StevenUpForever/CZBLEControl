//
//  ClassExtension.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 16/4/29.
//  Copyright © 2016年 ChengzhiJia. All rights reserved.
//

import UIKit

extension UIColor {
    class func customRed() -> UIColor {
        return UIColor(red: 213.0/255, green: 0.0/255, blue: 0.0/255, alpha: 1.0)
    }
    
    class func customOrange() -> UIColor {
        return UIColor(red: 255.0/255, green: 87.0/255, blue: 34.0/255, alpha: 1.0)
    }
    
    class func customBlue() -> UIColor {
        return UIColor(red: 3.0/255, green: 169.0/255, blue: 244.0/255, alpha: 1.0)
    }
    
    class func customGreen() -> UIColor {
        return UIColor(red: 76.0/255, green: 175.0/255, blue: 80.0/255, alpha: 1.0)
    }
    
    class func titleBlue() -> UIColor {
        return UIColor(red: 169.0/255, green: 245.0/255, blue: 242.0/255, alpha: 1.0)
    }
    
    class func gradientBlue() -> UIColor {
        return UIColor(red: 206.0/255, green: 246.0/255, blue: 236.0/255, alpha: 1.0)
    }
    
}

extension UITextField {
    func showAlertBorder() {
        self.layer.borderColor = UIColor.redColor().CGColor
        self.layer.borderWidth = 1.5
    }
    
    func resetBorder() {
        self.layer.borderColor = UIColor.clearColor().CGColor
        self.layer.borderWidth = 0.0
    }
    
}
