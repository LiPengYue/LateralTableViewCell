//
//  LateralTableViewCell.swift
//  LateralView
//
//  Created by 李鹏跃 on 2018/3/12.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

import UIKit

open class LateralTableViewCell: UITableViewCell {
    private struct context {
        static let context = UnsafeMutableRawPointer(bitPattern: 100800)
        static let isOpenLateralView = UnsafeMutableRawPointer(bitPattern: 100801)
    }
    
   public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupFunc()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupFunc() {
        contentView.addSubview(lateralView)
        /**
         NSLayoutConstraint(item: 视图,
         attribute: 约束属性,
         relatedBy: 约束关系,
         toItem: 参照视图,
         attribute: 参照属性,
         multiplier: 乘积,
         constant: 约束数值)
        */
        
//        contentView.translatesAutoresizingMaskIntoConstraints = false
//        self.translatesAutoresizingMaskIntoConstraints = false
//        lateralView.translatesAutoresizingMaskIntoConstraints = false
//        let left = NSLayoutConstraint(item: lateralView,
//                           attribute: .left,
//                           relatedBy: .equal,
//                           toItem: contentView,
//                           attribute: .left,
//                           multiplier: 1,
//                           constant: 0)
//        let right = NSLayoutConstraint(item: lateralView,
//                           attribute: .left,
//                           relatedBy: .equal,
//                           toItem: contentView,
//                           attribute: .left,
//                           multiplier: 1,
//                           constant: 0)
//        let bottom = NSLayoutConstraint(item: lateralView,
//                                       attribute: .left,
//                                       relatedBy: .equal,
//                                       toItem: contentView,
//                                       attribute: .left,
//                                       multiplier: 1,
//                                       constant: 0)
//        let top = NSLayoutConstraint(item: lateralView,
//                                       attribute: .left,
//                                       relatedBy: .equal,
//                                       toItem: contentView,
//                                       attribute: .left,
//                                       multiplier: 1,
//                                       constant: 0)
//        
//        contentView.addConstraint(top)
//        contentView.addConstraint(bottom)
//        contentView.addConstraint(left)
//        contentView.addConstraint(right)
    }
    open override func layoutSubviews() {
        super.layoutSubviews()
        lateralView.frame = contentView.bounds
    }
    //MARK: - property
    private weak var tableView: UITableView?
    open lazy var lateralView: LateralView = {
        let lateralView = LateralView()
        lateralView.delegate = self.delegate
        lateralView.lateralViewWillChangeOpenStatusFunc {[weak self] (view, isOpen) in
            if(isOpen && !(self?.isUnfoldingAtTheSameTime ?? false)) {
                self?.tableView?.OpenLateralViewIndexPath = self?.tableView?.indexPath(for: self!)
            }
        }
        return lateralView
    }()
    
    weak open var delegate: LateralViewDelegate? {
        didSet {
            lateralView.delegate = delegate
        }
    }
    
    open var isOpen = false {
        didSet {
            lateralView.isOpen = isOpen
        }
    }
    
    ///
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        tableView = getTableView(view: self)
    }
    
    ///是否可以同时展开多个cell
    open var isUnfoldingAtTheSameTime: Bool = false
    
    private func getTableView(view: UIView)->(UITableView?) {
        if let view = view as? UITableView {
            return view
        }
        if let view = view.superview {
            return getTableView(view: view)
        }
        return nil
    }
}




extension UITableView {
    private struct OpenLateralViewIndexPathUnsafeRawPointer {
        static let IsOpen = UnsafeRawPointer.init(bitPattern:"OpenLateralViewIndexPathUnsafeRawPointer".hashValue)
        static let IsOpenPrivate = UnsafeRawPointer.init(bitPattern:"OpenLateralViewIndexPathUnsafeRawPointerPrivate".hashValue)
    }
    var OpenLateralViewIndexPathPrivate: IndexPath? {
        get{
            return (objc_getAssociatedObject(self, UITableView.OpenLateralViewIndexPathUnsafeRawPointer.IsOpenPrivate!) as? IndexPath)
        }
        set(newValue){
            objc_setAssociatedObject(self, UITableView.OpenLateralViewIndexPathUnsafeRawPointer.IsOpenPrivate!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }    }
    
    open func closeAllCell() {
        self.OpenLateralViewIndexPath = nil
    }
    open var OpenLateralViewIndexPath: IndexPath? {
        get{
            return OpenLateralViewIndexPathPrivate
        }
        set(newValue){
            if let oldValue = OpenLateralViewIndexPathPrivate {
                if newValue != (OpenLateralViewIndexPathPrivate) {
                    if let cell = self.cellForRow(at: oldValue) as? LateralTableViewCell{
                        cell.isOpen = false
                    }
                }
            }
            OpenLateralViewIndexPathPrivate = newValue
        }
    }
}


