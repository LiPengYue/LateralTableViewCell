//
//  KRChekHomeWorkTableView.swift
//  KoalaReadingTeacher
//
//  Created by 李鹏跃 on 2018/7/6.
//  Copyright © 2018年 Beijing Enjoy Reading Education&Technology Co,. Ltd. All rights reserved.
//

import UIKit
import LateralTableViewCell
class PYTableView: UITableView,
    UITableViewDelegate,
    UITableViewDataSource
{
    let bookCellID = "PYTableViewCell"
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    //设置
    private func setup() {
        delegate = self
        dataSource = self
        estimatedRowHeight = 140
        isAutoCloseAllCellWithScrollTableView = true
        register(PYTableViewCell.self, forCellReuseIdentifier: bookCellID)
    }
    deinit {
        removeObserve()
        print("✅deinit: \(type(of: self))")
    }
}


//MARK: - delegate && dataSource
extension PYTableView {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 11
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: bookCellID, for: indexPath) as? PYTableViewCell{
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 160
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        closeAllCell()
//    }
  
}

