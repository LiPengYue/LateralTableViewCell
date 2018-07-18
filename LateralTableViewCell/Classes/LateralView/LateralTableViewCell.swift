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
            isLayoutLaterView = true
            layoutLateralView()
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
    private var isLayoutLaterView: Bool = true
    open override func layoutSubviews() {
        super.layoutSubviews()
        if !isLayoutLaterView { return }
        layoutLateralView()
    }
    
    private func layoutLateralView() {
        
        let x = lateralViewEdgeInsets.left
        let w = contentView.frame.width
            - lateralViewEdgeInsets.left
            - lateralViewEdgeInsets.right
        
        let y = lateralViewEdgeInsets.top
        let h = contentView.frame.height
            - lateralViewEdgeInsets.top
            - lateralViewEdgeInsets.bottom
        
        lateralView.frame = CGRect.init(x: x, y: y, width: w, height: h)
    }
    
    
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







