//
//  ViewController.swift
//  LateralTableViewCell
//
//  Created by LiPengYue on 07/09/2018.
//  Copyright (c) 2018 LiPengYue. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(modalButton)
        modalButton.frame = CGRect.init(x: 0, y: 0, width: view.frame.width, height: 200);
    }
    ///懒加载 modal button
    private lazy var modalButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage.init(named: ""), for: UIControlState.normal)
        button.setTitle("跳转VC", for: UIControlState.normal)
        button.setTitleColor(UIColor.red, for: .normal)
        button.addTarget(self, action: #selector(clickButton), for: UIControlEvents.touchUpInside)
        return button
    }()
    @objc private func clickButton() {
        self.present(PYViewController(), animated: true, completion: nil)
    }
}

