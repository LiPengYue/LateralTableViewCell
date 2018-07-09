//
//  LateralTableViewObsever.swift
//  LateralTableViewCell
//
//  Created by 李鹏跃 on 2018/7/9.
//

import UIKit

class LateralTableViewObserver: NSObject {

    private var tableView: UITableView?
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "contentOffset" {
            if let tableView = object as? UITableView{
                tableView.closeAllCell()
            }
        }
    }
    
    deinit {
        tableView?.removeObserver(self, forKeyPath: "contentOffset")
    }
}
