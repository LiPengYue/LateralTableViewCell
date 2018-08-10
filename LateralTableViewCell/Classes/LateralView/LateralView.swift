//
//  LateralView.swift
//  demo
//
//  Created by 李鹏跃 on 2018/3/9.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

import UIKit
// read me
/**
 1. 层级结构（superView -> subView）
 self.addSubView(buttons)
 self.addSubView(scrollView)
 scrollView.addSubView(continerView)
 2. 侧滑后button点击问题的解决方法：
 其实scrollView是挡住了buttons
 自定义scrollView：`LateralScrollView`
 重写了`func point(inside point: CGPoint, with event: UIEvent?) -> Bool` 方法
 判断点击范围是否在button的范围内，如果在，则响应事件穿透到下一层view，否则响应事件
 3. 打开cell后的复用问题的解决：
 给tableView添加分类`TableView+LateralView`
 添加了当前打开的index属性作为标记
 4. 滑动tableView的时候关闭所有cell的解决
 在tableView添加的分类中添加`observe：LateralTableViewObserver`属性
 并监听offset变化，如果改变，则关闭所有cell
 5. 未解决问题：允许多个cell打开的情况下，滑动tableView依然关闭所有cell，没有碰到类似需求，如果有用到可以呼叫我进行优化
 6. tableView 自适应行高问题的解决
 用系统约束布局，scrollView，以及continerView,
 在布局continerView的时候，因为其属于scrollView的subView，所以需要注意，设置left，width，top，bottom 等于scrollView，并设置scrollView的contentSize，才能正常显示并可以滑动
 */

///获取 button
@objc public protocol LateralViewDelegate {
    ///返回button数组， 从右往左一次排列
    func lateralViewAddButton(view:LateralView) ->([UIButton])
    ///button 的宽度
    func lateralViewButtonWidth(button: UIButton,index:NSInteger) -> (CGFloat)
    
    ///最左边的一个button的左间距为多少
    func lateralViewLastButtonLeftMargin(view: LateralView) -> (CGFloat)
    ///距离左边的间距
    func lateralViewButtonRightMargin(button: UIButton,index:NSInteger) -> (CGFloat)
    ///距离上下的间距 默认为0
    func lateralViewButtonTopBottomMargin(button: UIButton,index:NSInteger) -> (CGFloat)
    
    ///展开的时候调用
    @objc optional func lateralViewWillChangeOpenStatusFunc(view:LateralView,isOpen:Bool)
}

/// 自定义 侧滑
open class LateralView: UIView,UIScrollViewDelegate {
    // MARK: - init
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - properties
    /// 在这上面进行布局
    open var continerView: UIView { return continerView_private }
    
    /// buttonArray
    open var buttonArray: [UIButton] {
        if (buttonArrayPrivate.count <= 0) {
            let buttonArrayTemp = delegate?.lateralViewAddButton(view: self)
            buttonArrayPrivate = buttonArrayTemp ?? []
        }
        return buttonArrayPrivate
    }
    
    /// 是否可以左滑
    open var isLeftSlide: Bool = true {
        didSet {
            scrollView.isScrollEnabled = isLeftSlide
        }
    }
    
    ///delegate 里面有设置button的方法
    weak open var delegate: LateralViewDelegate?
    
    ///是否为打开状态，可控制开启或关闭，有动画
    open var isOpen: Bool = false {
        didSet {
            delegate?.lateralViewWillChangeOpenStatusFunc?(view: self, isOpen: isOpen)
            lateralViewWillChangeOpenStatusBlock?(self,isOpen)
            close()
        }
    }
    
    /// color 容器视图的color
    open var continerViewColor: UIColor = UIColor.white {
        didSet {
            continerView.backgroundColor = continerViewColor
        }
    }
    /// 背景色 改变的是 button 下层视图 的 背景色
    open var backGroundColor: UIColor = UIColor.white {
        didSet {
            self.backgroundColor = backGroundColor
        }
    }
    
    ///返回button 宽度总和 （算button之间的间距）
    open var buttonTotalWidth: CGFloat { return buttonTotalWidthPrivate }
    
    //MARK: private property
    private var continerView_private: UIView = UIView()
    private var isFirstLayout = true
    private var buttonArrayPrivate: [UIButton] = [UIButton]()
    private var buttonWDic = [UIButton:CGFloat]()
    private var lateralViewWillChangeOpenStatusBlock: ((_ view:LateralView,_ isOpen:Bool)->())?
    private var buttonTotalWidthPrivate: CGFloat = 0
    private var tap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapFunc))
        return tap
    }()
    private var scrollViewHeightConstraint: NSLayoutConstraint?
    
    // MARK: - func
    /// 当isOpen状态改变的时候会调用这个方法
    open func lateralViewWillChangeOpenStatusFunc(block: ((_ view:LateralView,_ isOpen:Bool)->())?) {
        lateralViewWillChangeOpenStatusBlock = block
    }
    
    open func relayoutButtons() {
        layoutButton()
    }
    
    // MARK: lazy loads     ///不会 调用代理方法 里的打开状态改变
    private func close() {
        let offsetX_Max: CGFloat = self.buttonTotalWidthPrivate
        let offsetX_Min: CGFloat = 0
        let offsetX: CGFloat = isOpen ? offsetX_Max : offsetX_Min
        let offset = CGPoint.init(x: offsetX, y: 0)
        scrollView.setEventWith(point: CGPoint.zero, andIsOpen: isOpen)
        UIView.animate(withDuration: 0.1) {
            self.scrollView.contentOffset = offset
        }
    }
    private func layoutButton() {
        buttonTotalWidthPrivate = 0
        let _ = buttonArray.map{ $0.removeFromSuperview() }
        
        for index in 0 ..< buttonArray.count {
            
            let button = buttonArray[index]
            insertSubview(button, belowSubview: scrollView)
            let rightMargin = delegate?.lateralViewButtonRightMargin(button: button, index: index) ?? 0
            let buttonTopMargin = delegate?.lateralViewButtonTopBottomMargin(button: button, index: index) ?? 0
            let buttonW = delegate?.lateralViewButtonWidth(button: button, index: index) ?? 0
            buttonTotalWidthPrivate += (rightMargin + buttonW)
            buttonWDic[button] = buttonW
            
            var x: CGFloat = self.frame.width
            if (index >= 1) {
                let buttonFront = buttonArray[index - 1]
                x = buttonFront.frame.origin.x
            }
            
            x -= (buttonW + rightMargin)
            let h = self.frame.height - buttonTopMargin * 2.0
            button.frame = CGRect.init(x: x, y: buttonTopMargin, width: buttonW, height: h)
            
        }
        let leftMargin = (delegate?.lateralViewLastButtonLeftMargin(view: self)) ?? 0
        buttonTotalWidthPrivate += leftMargin
        
    }
    
    // MARK: handle views
    ///设置
    private func setup() {
        
        isFirstLayout = true
        scrollView.removeFromSuperview()
        addSubview(scrollView)
        scrollView.addSubview(continerView)
        
        addConstraint_scrollView()
        addConstraint_continerView()
        
        scrollView.panGestureRecognizer.addObserver(self,
                                                    forKeyPath: "state",
                                                    options: .new,
                                                    context: nil)
        let buttonArrayTemp = delegate?.lateralViewAddButton(view: self)
        buttonArrayPrivate = buttonArrayTemp ?? []
    }
    
    private func addConstraint_scrollView() {
        // layout scrollView
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        let sLeft = scrollView.leftConstraint(toItem: self, offset: 0)
        let sRight = scrollView.rightConstraint(toItem: self, offset: 0)
        let sTop = scrollView.topConstraint(toItem: self, offset: 0)
        let sBottom = scrollView.bottomConstraint(toItem: self, offset: 0)
        self.addConstraints([sLeft,sRight,sTop,sBottom])
        
    }
    
    private func addConstraint_continerView() {
        // layout continerView
        continerView.translatesAutoresizingMaskIntoConstraints = false
        let cLeft = continerView.leftConstraint(toItem: scrollView, offset: 0)
        let cTop = continerView.topConstraint(toItem: self, offset: 0)
        let cBottom = continerView.bottomConstraint(toItem: self, offset: 0)
        let cwidth = continerView.widthConstraint(toItem: self, offset: 0)
        self.addConstraints([cLeft,cBottom,cTop,cwidth])
    }
    
    // MARK: handle event
    @objc private func tapFunc(tap: UITapGestureRecognizer) {
        isOpen = true
    }
    //MARK: observer func
    override open func observeValue(forKeyPath keyPath: String?,
                                    of object: Any?,
                                    change: [NSKeyValueChangeKey : Any]?,
                                    context: UnsafeMutableRawPointer?) {
        if keyPath?.elementsEqual("state") ?? false {
            if let state = change?[NSKeyValueChangeKey.newKey] as? Int {
                
                switch  UIGestureRecognizerState.init(rawValue: state)! {
                case .ended: fallthrough
                case .cancelled: fallthrough
                case .failed:
                    isOpen = scrollView.contentOffset.x >= 1
                    return
                default:break
                }
            }
        }else {
            super.observeValue(forKeyPath: keyPath,
                               of: object,
                               change: change,
                               context: context)
        }
    }
    
    // MARK:life cycles
    override open func addSubview(_ view: UIView) {
        if (view == scrollView) {
            super.addSubview(view)
            return
        }
        continerView.addSubview(view)
    }
    
    override open func layoutSubviews() {
        
        let heightConstraintTemp = scrollView.heightConstraint(toItem: self, offset: self.frame.height)
        
        if (isFirstLayout) {
            isFirstLayout = false
            self.addConstraint(heightConstraintTemp)
            continerView.backgroundColor = continerViewColor
            self.updateConstraints()
            layoutButton()
        }else{
            self.removeConstraint(scrollViewHeightConstraint!)
            self.addConstraint(heightConstraintTemp)
            self.updateConstraints()
        }
        scrollViewHeightConstraint = heightConstraintTemp
        scrollView.contentSize = CGSize.init(width: frame.size.width + buttonTotalWidthPrivate, height: 0)
    }
    
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let x = bounds.width - buttonTotalWidthPrivate
        scrollView.setEventWith(point: CGPoint.init(x: x, y: point.y), andIsOpen: self.scrollView.contentOffset.x >= buttonTotalWidthPrivate)
        if (isOpen && point.x <= x) {
            isOpen = false
        }
        return super.hitTest(point, with: event)
    }
    
    deinit {
        scrollView.panGestureRecognizer.removeObserver(self, forKeyPath: "state")
    }
    
    
    // MARK: lazy loads
    /// scrollView
    private lazy var scrollView: LateralScrollView = {
        let scrollView = LateralScrollView()
        scrollView.delegate = self
        scrollView.addGestureRecognizer(self.tap)
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.backgroundColor = UIColor.clear
        
        return scrollView
    }()
    
}

//MARK: - scrollView delegate
extension LateralView {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.x < 0) {
            scrollView.contentOffset.x = 0
        }
        if (!scrollView.isTracking && scrollView.contentOffset.x >= 1 && !isOpen) {
            isOpen = true
        }
    }
}
