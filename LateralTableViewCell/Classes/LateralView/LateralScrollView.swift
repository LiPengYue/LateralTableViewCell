//
//  LateralScrollView.swift
//  LateralView
//
//  Created by 李鹏跃 on 2018/3/12.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

import UIKit

open class LateralScrollView: UIScrollView {
    private var isOpen = false
    private var point = CGPoint()
    func setEventWith(point Point: CGPoint, andIsOpen isOpen: Bool) {
        self.isOpen = isOpen
        self.point = Point
    }
    var isRelevantEvent = false
    override open func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if isOpen && point.x >= self.point.x || isRelevantEvent{
            return false
        }else{
            return super.point(inside: point, with: event)
        }
    }
    
}
