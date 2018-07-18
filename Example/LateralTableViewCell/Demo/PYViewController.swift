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
        modalButton.snp.makeConstraints { (make) in
            make.left.top.right.equalTo(view)
            make.height.equalTo(200)
        }
        tableView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(view)
            make.top.equalTo(modalButton.snp.bottom)
        }
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
