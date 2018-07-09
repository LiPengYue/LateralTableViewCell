//
//  UIColorArc4random.swift
//  LateralTableViewCell_Example
//
//  Created by 李鹏跃 on 2018/7/9.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

extension UIColor {
    //返回随机颜色
    class var randomColor: UIColor {
        get {
            let red = CGFloat(arc4random()%80)/255.0
            let green = CGFloat(arc4random()%106)/255.0
            let blue = CGFloat(arc4random()%100)/255.0
//            let alpha = CGFloat(arc4random()%3)/10 + 0.4
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
    }
}
