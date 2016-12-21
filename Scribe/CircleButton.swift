//
//  CircleButton.swift
//  Scribe
//
//  Created by Geemakun Storey on 2016-12-19.
//  Copyright © 2016 geemakunstorey@storeyofgee.com. All rights reserved.
//

import UIKit
@IBDesignable
class CircleButton: UIButton {

    @IBInspectable var cornerRadius: CGFloat = 30.0 {
        didSet{
        setUpView()
        }
    }
    override func prepareForInterfaceBuilder() {
        setUpView()
    }
    func setUpView() {
        layer.cornerRadius = cornerRadius
    }
    
}
