//
//  CustomView.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 7/1/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit

@IBDesignable class CustomView: UIView {

    @IBInspectable var borderColor: UIColor = UIColor.clearColor() {
        didSet {
            self.layer.borderColor = borderColor.CGColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var roundCornerRadius: Bool = false {
        didSet {
            self.layer.cornerRadius = roundCornerRadius ? self.frame.width/2.0 : 0.0
        }
    }

}
