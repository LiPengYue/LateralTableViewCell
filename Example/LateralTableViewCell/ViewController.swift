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
        let tableView = PYTableView(frame: view.bounds, style: UITableViewStyle.plain)
        view.addSubview(tableView)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

