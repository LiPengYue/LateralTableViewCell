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
    
    // MARK: - init
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupFunc()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - properties
    open var lateralViewEdgeInsets = UIEdgeInsets.zero {
        didSet {
            updataLateralViewConstraint()
        }
    }
    weak open var delegate: LateralViewDelegate? { didSet { lateralView.delegate = delegate } }
    open var isOpen = false { didSet { lateralView.isOpen = isOpen } }
    /// 是否可以同时展开多个cell
    open var isUnfoldingAtTheSameTime: Bool = false
    private weak var tableView: UITableView?
    // MARK: - func
    // MARK: handle views
    private func setupFunc() {
        contentView.addSubview(lateralView)
        lateralView.translatesAutoresizingMaskIntoConstraints = false
        layoutLateralView()
    }
    
    // MARK:functions
    private func getTableView(view: UIView)->(UITableView?) {
        if let view = view as? UITableView {
            return view
        }
        if let view = view.superview {
            return getTableView(view: view)
        }
        return nil
    }
    
    // MARK:life cycles
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        tableView = getTableView(view: self)
    }
    private func layoutLateralView() {
        lateralView.translatesAutoresizingMaskIntoConstraints = false
        let left = lateralViewEdgeInsets.left
        let top = lateralViewEdgeInsets.top
        let right = lateralViewEdgeInsets.right
        let bottom = lateralViewEdgeInsets.bottom
        
        leftConstraint = lateralView.leftConstraint(toItem: contentView, offset: left)
        rightConstraint = lateralView.rightConstraint(toItem: contentView, offset: right)
        bottomConstraint = lateralView.bottomConstraint(toItem: contentView, offset: bottom)
        topConstraint = lateralView.topConstraint(toItem: contentView, offset: top)
        
        contentView.addConstraint(leftConstraint!)
        contentView.addConstraint(rightConstraint!)
        contentView.addConstraint(bottomConstraint!)
        contentView.addConstraint(topConstraint!)
        //        contentView.addConstraint(heightConstraint!)
        contentView.updateConstraints()
    }
    private func updataLateralViewConstraint() {
        let left = lateralViewEdgeInsets.left
        let top = lateralViewEdgeInsets.top
        let right = lateralViewEdgeInsets.right
        let bottom = lateralViewEdgeInsets.bottom
        
        contentView.removeConstraint(leftConstraint!)
        contentView.removeConstraint(rightConstraint!)
        contentView.removeConstraint(bottomConstraint!)
        contentView.removeConstraint(topConstraint!)
        
        leftConstraint = lateralView.leftConstraint(toItem: contentView, offset: left)
        rightConstraint = lateralView.rightConstraint(toItem: contentView, offset: right)
        bottomConstraint = lateralView.bottomConstraint(toItem: contentView, offset: bottom)
        topConstraint = lateralView.topConstraint(toItem: contentView, offset: top)
        heightConstraint = lateralView.heightConstraint(toItem: contentView, offset: 100)
        contentView.addConstraint(leftConstraint!)
        contentView.addConstraint(rightConstraint!)
        contentView.addConstraint(bottomConstraint!)
        contentView.addConstraint(topConstraint!)
//        contentView.addConstraint(heightConstraint!)
        contentView.updateConstraints()
    }
    private var leftConstraint: NSLayoutConstraint?
    private var rightConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    private var topConstraint: NSLayoutConstraint?
    private var heightConstraint: NSLayoutConstraint?
    // MARK: lazy loads
    public lazy var lateralView: LateralView = {
        
        let lateralView = LateralView()
        lateralView.delegate = self.delegate
        lateralView.lateralViewWillChangeOpenStatusFunc {[weak self] (view, isOpen) in
            if(isOpen && !(self?.isUnfoldingAtTheSameTime ?? false)) {
                self?.tableView?.OpenLateralViewIndexPath = self?.tableView?.indexPath(for: self!)
            }
        }
        return lateralView
    }()
}




extension UIView {
    func leftConstraint(toItem: UIView,offset: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let left = NSLayoutConstraint.init(item: self,
                                           attribute: .left,
                                           relatedBy: .equal,
                                           toItem: toItem,
                                           attribute: .left,
                                           multiplier: 1,
                                           constant: offset)
        return left
    }
    func rightConstraint(toItem: UIView,offset: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let right = NSLayoutConstraint.init(item: self,
                                            attribute: .right,
                                            relatedBy: .equal,
                                            toItem: toItem,
                                            attribute: .right,
                                            multiplier: 1,
                                            constant: offset)
        return right
    }
    
    func bottomConstraint(toItem: UIView,offset: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let bottom = NSLayoutConstraint.init(item: self,
                                             attribute: .bottom,
                                             relatedBy: .equal,
                                             toItem: toItem,
                                             attribute: .bottom,
                                             multiplier: 1,
                                             constant: offset)
        return bottom
    }
    
    func topConstraint(toItem: UIView,offset: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let top = NSLayoutConstraint.init(item: self,
                                          attribute: .top,
                                          relatedBy: .equal,
                                          toItem: toItem,
                                          attribute: .top,
                                          multiplier: 1,
                                          constant: offset)
        return top
    }
    func heightConstraint(toItem: UIView,offset: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint.init(item: self,
                                          attribute: .height,
                                          relatedBy: .equal,
                                          toItem: nil,
                                          attribute: .notAnAttribute,
                                          multiplier: 1,
                                          constant: offset)
        return height
    }
    func widthConstraint(offset: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let width = NSLayoutConstraint.init(item: self,
                                          attribute: .width,
                                          relatedBy: .equal,
                                          toItem: nil,
                                          attribute: .notAnAttribute,
                                          multiplier: 1,
                                          constant: offset)
        return width
    }
    func widthConstraint(toItem: UIView,offset: CGFloat) -> NSLayoutConstraint {
        translatesAutoresizingMaskIntoConstraints = false
        let width = NSLayoutConstraint.init(item: self,
                                            attribute: .width,
                                            relatedBy: .equal,
                                            toItem: toItem,
                                            attribute: .width,
                                            multiplier: 1,
                                            constant: offset)
        return width
    }
}


