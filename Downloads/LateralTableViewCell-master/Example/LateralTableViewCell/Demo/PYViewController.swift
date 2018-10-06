//
//  PYViewController.swift
//  LateralTableViewCell_Example
//
//  Created by 李鹏跃 on 2018/7/18.
//  Copyright © 2018年 CocoaPods. All rights reserved.
//

import UIKit

class PYViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let tableView = PYTableView.init(frame: CGRect.zero, style: UITableViewStyle.plain)
        view.addSubview(tableView)
        view.addSubview(modalButton)
        modalButton.frame = CGRect.init(x: 0, y: 0, width: view.frame.width, height: 100)
        tableView.frame = CGRect.init(x: 0, y: 110, width: view.frame.width, height: view.frame.height - 110)
    }
    ///懒加载 modal button
    private lazy var modalButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.init(named: ""), for: UIControlState.normal)
        button.setTitle("popVC", for: UIControlState.normal)
        button.setTitleColor(UIColor.red, for: .normal)
        button.addTarget(self, action: #selector(clickButton), for: UIControlEvents.touchUpInside)
        return button
    }()
    @objc private func clickButton() {
        self.dismiss(animated: true, completion: nil)
    }
    
    deinit {
        print("✅deinit: \(type(of: self))")
    }
}
