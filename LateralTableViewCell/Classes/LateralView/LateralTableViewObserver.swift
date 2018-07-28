//
//  LateralTableViewObsever.swift
//  LateralTableViewCell
//
//  Created by 李鹏跃 on 2018/7/9.
//

import UIKit

class LateralTableViewObserver: NSObject {
    var isRemovedObserver: Bool = false
    private var tableViewClassStr: String = ""
    weak var tableView: UITableView? {
        didSet {
            if let tableView = tableView {
                tableViewClassStr = "\(type(of: tableView))"
                tableView.addObserver(self,
                                      forKeyPath: "contentOffset",
                                      options: .new,
                                      context: nil)
                isRemovedObserver = false
            }
        }
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            if let tableView = object as? UITableView{
                tableView.closeAllCell()
            }
        }
    }
    deinit {
        if !isRemovedObserver {
            print("\n🌶: 没有在"
                + tableViewClassStr
                + " 的deinit方法中调用\n"
                + "< self.removeObserve() >\n")
        }
        
    }
}
