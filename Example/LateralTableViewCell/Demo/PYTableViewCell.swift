//
//  KRChekHomeWorkBookTableViewCell.swift
//  KoalaReadingTeacher
//
//  Created by 李鹏跃 on 2018/7/6.
//  Copyright © 2018年 Beijing Enjoy Reading Education&Technology Co,. Ltd. All rights reserved.
//

import UIKit
import LateralTableViewCell

/// 书籍阅读
class PYTableViewCell: LateralTableViewCell,LateralViewDelegate {
    
    // MARK: - init
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
  
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - properties
    
    // MARK: - func
    private func setup() {
        delegate = self
        contentView.backgroundColor = UIColor.white
        lateralView.backgroundColor = #colorLiteral(red: 0.8704799107, green: 0.9112444196, blue: 1, alpha: 1)
        
        continerView.addSubview(titleLabel)
        continerView.addSubview(iconImageView)
        continerView.addSubview(subTitle)
        
        iconImageView.snp.makeConstraints { (make) in
            make.left.top.equalTo(continerView).offset(10)
            make.height.width.equalTo(140)
            make.bottom.equalTo(continerView.snp.bottom).offset(-10)
        }
        titleLabel.snp.makeConstraints { (make) in
           make.top.equalTo(iconImageView)
            make.left.equalTo(iconImageView.snp.right).offset(10)
            make.right.equalTo(continerView).offset(10)
        }
        subTitle.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.right.equalTo(titleLabel)
        }

        lateralViewEdgeInsets = UIEdgeInsets.init(top: 10, left: 10, bottom: -10, right: -10)
    }
    ///懒加载
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 0
        label.text = "森林里的蜗牛"
        label.textColor = #colorLiteral(red: 0.9607843161, green: 0.7058823705, blue: 0.200000003, alpha: 1)
        label.textAlignment = .left
        return label
    }()
    private lazy var subTitle: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
        label.text = "只吃叶子和斑鸠"
        label.textColor = #colorLiteral(red: 0.2588235438, green: 0.7568627596, blue: 0.9686274529, alpha: 1)
        label.textAlignment = .left
        return label
    }()
    ///懒加载 imageView icon
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.init(named: "icon")
        imageView.isUserInteractionEnabled = true
        imageView.contentMode = .scaleAspectFit
        
        return imageView
    }()
}


// MARK: - delegate
extension PYTableViewCell {
    func lateralViewAddButton(view: LateralView) -> ([UIButton]) {
        let buttonCount = Int(arc4random() % 3) + 1
        var buttonArray = [UIButton]()
        for _ in 0 ..< buttonCount {
            let button = UIButton()
            button.addTarget(self, action: #selector(clickButton), for: UIControlEvents.touchUpInside)
            
            button.layer.cornerRadius = 20
            button.layer.masksToBounds = true
            button.backgroundColor = UIColor.randomColor
            //            button.alpha = 0.5
            button.setTitle("😄哈", for: UIControlState.selected)
            button.setTitle("点我", for: UIControlState.normal)
            buttonArray.append(button)
        }
        return buttonArray
    }
    
    @objc private func clickButton(button: UIButton) {
        self.lateralView.continerView.backgroundColor = button.backgroundColor ?? UIColor.white
        self.isOpen = false
    }
    
    func lateralViewButtonWidth(button: UIButton, index: NSInteger) -> (CGFloat) {
        return 50
    }
    
    func lateralViewLastButtonLeftMargin(view: LateralView) -> (CGFloat) {
        return 10
    }
    
    func lateralViewButtonRightMargin(button: UIButton, index: NSInteger) -> (CGFloat) {
        return 10
    }
    
    func lateralViewButtonTopBottomMargin(button: UIButton, index: NSInteger) -> (CGFloat) {
        return 10
    }
}

