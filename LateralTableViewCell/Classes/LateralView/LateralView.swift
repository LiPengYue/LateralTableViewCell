//
//  LateralView.swift
//  demo
//
//  Created by 李鹏跃 on 2018/3/9.
//  Copyright © 2018年 李鹏跃. All rights reserved.
//

import UIKit

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
    
    override init(frame: CGRect) {
        super.init(frame:frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //MARK: - 关于配置
    ///设置
    private func setup() {
        scrollView.panGestureRecognizer.addObserver(self, forKeyPath: "state", options: NSKeyValueObservingOptions.new, context: nil)
        isFirstLayout = true
        scrollView.removeFromSuperview()
        addSubview(scrollView)
        scrollView.addSubview(continerView)
        buttonArrayPrivate = (delegate?.lateralViewAddButton(view: self)) ?? []
        layoutButton()
    }
    
    //MARK: - property
    private var isFirstLayout = true
    private var buttonArrayPrivate: [UIButton] = [UIButton]()
    private var buttonWDic = [UIButton:CGFloat]()
    private var lateralViewWillChangeOpenStatusBlock: ((_ view:LateralView,_ isOpen:Bool)->())?
    private var buttonTotalWidthPrivate: CGFloat = 0
    private var tap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(tapFunc))
        return tap
    }()
    @objc private func tapFunc(tap: UITapGestureRecognizer) {
       isOpen = true
    }
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
    
    /// 在这上面进行布局
    open lazy var continerView: UIView = {
        let view = UIView()
        return view
    }()

    /// buttonArray
    open var buttonArray: [UIButton] {
        get{
            return buttonArrayPrivate
        }
    }
   
    /// 是否可以左滑
    open var isLeftSlide: Bool = true {
        didSet {
            scrollView.isScrollEnabled = isLeftSlide
        }
    }
    
    ///delegate 里面有设置button的方法
    weak open var delegate: LateralViewDelegate? {
        didSet {
            buttonArrayPrivate = (delegate?.lateralViewAddButton(view: self)) ?? []
        }
    }

    /// 当isOpen状态改变的时候会调用这个方法
    open func lateralViewWillChangeOpenStatusFunc(block: ((_ view:LateralView,_ isOpen:Bool)->())?) {
        lateralViewWillChangeOpenStatusBlock = block
    }

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
    
    //MARK: - public func
    ///返回button 宽度总和 （算button之间的间距）
    open func buttonTotalWidth() -> CGFloat{
        return buttonTotalWidthPrivate
    }
    
    //MARK: - observer func
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
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
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    override open func addSubview(_ view: UIView) {
        if (view == scrollView) {
            super.addSubview(view)
            return
        }
        continerView.addSubview(view)
    }
    
    override open func layoutSubviews() {
        if (isFirstLayout) {
            isFirstLayout = false
            scrollView.frame = bounds
            continerView.frame = bounds
            continerView.backgroundColor = continerViewColor
            layoutButton()
            scrollView.contentSize = CGSize.init(width: frame.size.width + buttonTotalWidthPrivate, height: 0)
        }
    }
    
    override open func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let x = bounds.width - buttonTotalWidth()
        scrollView.setEventWith(point: CGPoint.init(x: x, y: point.y), andIsOpen: self.scrollView.contentOffset.x >= buttonTotalWidth())
        if (isOpen && point.x <= x) {
            isOpen = false
        }
        return super.hitTest(point, with: event)
    }
    
    //MARK: - private function
    ///不会 调用代理方法 里的打开状态改变
    private func close() {
        let offsetX_Max: CGFloat = self.buttonTotalWidth()
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
        for index in 0 ..< buttonArrayPrivate.count {
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

    deinit {
        scrollView.panGestureRecognizer.removeObserver(self, forKeyPath: "state")
    }

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
