//
//  TableView+LateralView.swift
//  LateralTableViewCell
//
//  Created by 李鹏跃 on 2018/7/9.
//

import UIKit

extension UITableView {
    /// 关闭所有开启的cell --- LateralTableViewCell
    open func closeAllCell() {
        self.OpenLateralViewIndexPath = nil
    }
    
    /// 滑动的时候是否自动关闭所有cell --- LateralTableViewCell
    open var isAutoCloseAllCellWithScrollTableView: Bool {
        get { return getIsCloseAllCellWithScroll() }
        set {
            setIsCloseAllCellWithScroll(isAutoCloseAllCellWithScrollTableView)
        }
    }
   
    
    private var observe: LateralTableViewObserver? {
        get { return getObserve() }
        set { setObserve(newValue) }
    }
    
    var OpenLateralViewIndexPathPrivate: IndexPath? {
        get{
            return (objc_getAssociatedObject(self, UITableView.OpenLateralViewIndexPathUnsafeRawPointer.IsOpenPrivate!) as? IndexPath)
        }
        set(newValue){
            objc_setAssociatedObject(self, UITableView.OpenLateralViewIndexPathUnsafeRawPointer.IsOpenPrivate!, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    var OpenLateralViewIndexPath: IndexPath? {
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
    
    private func getIsCloseAllCellWithScroll() -> Bool{
        let isAutoCloseUnpointer = UITableView.IsAutoCloseAllCellWithScrollTableViewUnsafeRawPointer.isAutoClose!
        let isClose = objc_getAssociatedObject(self, isAutoCloseUnpointer) as? Bool
        return isClose ?? true
    }
    
    private func setIsCloseAllCellWithScroll(_ isAutoClose: Bool) {
        let isAutoCloseUnpointer = UITableView.IsAutoCloseAllCellWithScrollTableViewUnsafeRawPointer.isAutoClose!
        objc_setAssociatedObject(self, isAutoCloseUnpointer, isAutoClose, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        let observe = isAutoClose ? LateralTableViewObserver() : nil
            self.observe = observe
    }
    
    private func setObserve(_ observe: LateralTableViewObserver?) {
        
        let isAutoCloseObserve = UITableView.IsAutoCloseObserve.isAutoCloseObserve!
        objc_setAssociatedObject(self,
                                 isAutoCloseObserve,
                                 observe, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        if let observe = observe  {
            addObserver(observe,
                        forKeyPath: "contentOffset",
                        options: .new,
                        context: nil)
        }
    }
    
    private func getObserve() -> LateralTableViewObserver? {
        let isAutoCloseObserve = UITableView.IsAutoCloseObserve.isAutoCloseObserve!
        return objc_getAssociatedObject(self, isAutoCloseObserve) as? LateralTableViewObserver
    }
    
}


private extension UITableView {
    struct IsAutoCloseAllCellWithScrollTableViewUnsafeRawPointer {
        static let isAutoClose = UnsafeRawPointer.init(bitPattern: "IsAutoCloseAllCellWithScrollTableViewUnsafeRawPointer".hashValue)
    }
    
    struct OpenLateralViewIndexPathUnsafeRawPointer {
        static let IsOpen = UnsafeRawPointer.init(bitPattern:"OpenLateralViewIndexPathUnsafeRawPointer".hashValue)
        static let IsOpenPrivate = UnsafeRawPointer.init(bitPattern:"OpenLateralViewIndexPathUnsafeRawPointerPrivate".hashValue)
    }
    
    struct IsAutoCloseObserve {
        static let isAutoCloseObserve = UnsafeRawPointer.init(bitPattern: "IsAutoCloseAllCellWithScrollTableViewObserve".hashValue)
    }

}
