//
//  CustomView.swift
//  CZBLEControl
//
//  Created by Chengzhi Jia on 7/1/16.
//  Copyright © 2016 ChengzhiJia. All rights reserved.
//

import UIKit

@IBDesignable class CustomView: UIView {

    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.CGColor
        }
    }
    
    @IBInspectable var isRound: Bool = false {
        didSet {
            if isRound {
                layer.cornerRadius = frame.width/2.0
            }
        }
    }

}
