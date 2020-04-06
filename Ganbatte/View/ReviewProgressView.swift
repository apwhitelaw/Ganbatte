//
//  ReviewProgressView.swift
//  Ganbatte
//
//  Created by Austin Whitelaw on 4/5/20.
//  Copyright © 2020 Austin Whitelaw. All rights reserved.
//

import UIKit
import SnapKit

class ReviewProgressView: UIView {
    
    let completedLabel: UILabel = {
        let l = UILabel()
        l.text = "0"
        return l
    }()
    let remainingLabel: UILabel = {
        let l = UILabel()
        l.text = "0"
        return l
    }()
    let currentSetLabel: UILabel = {
        let l = UILabel()
        l.text = "0"
        return l
    }()
    
    var total = 0
    var remaining = 0 {
        didSet {
            remainingLabel.text = String(remaining)
        }
    }
    var completed = 0 {
        didSet {
            completedLabel.text = String(completed)
        }
    }
    var currentSet = 0 {
        didSet {
            currentSetLabel.text = String(currentSet)
        }
    }
    
    
    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        self.backgroundColor = .white
        
        
        let remainingIconView = UIImageView()
        if let remainingIcon = UIImage(named: "inbox.png") {
            remainingIconView.image = remainingIcon
        }
        let completedIconView = UIImageView()
        if let completedIcon = UIImage(named: "complete.png") {
            completedIconView.image = completedIcon
        }
        let currentSetIconView = UIImageView()
        if let currentSetIcon = UIImage(named: "clock.png") {
            currentSetIconView.image = currentSetIcon
        }
        
        addSubview(remainingLabel)
        addSubview(remainingIconView)
        addSubview(completedLabel)
        addSubview(completedIconView)
        addSubview(currentSetLabel)
        addSubview(currentSetIconView)
        remainingLabel.snp.makeConstraints { (make) in
            //make.centerY.equalTo(self.snp.centerY)
            make.top.equalTo(self.snp.bottom).offset(10)
            make.height.equalTo(20)
            make.trailing.equalTo(self.snp.trailing).offset(-10)
        }
        remainingIconView.snp.makeConstraints { (make) in
            //make.centerY.equalTo(self.snp.centerY)
            make.top.equalTo(self.snp.bottom).offset(10)
            make.height.width.equalTo(20)
            make.trailing.equalTo(remainingLabel.snp.leading).offset(-10)
        }
        completedLabel.snp.makeConstraints { (make) in
            //make.centerY.equalTo(self.snp.centerY)
            make.top.equalTo(self.snp.bottom).offset(10)
            make.height.equalTo(20)
            make.trailing.equalTo(remainingIconView.snp.leading).offset(-10)
        }
        completedIconView.snp.makeConstraints { (make) in
            //make.centerY.equalTo(self.snp.centerY)
            make.top.equalTo(self.snp.bottom).offset(10)
            make.height.width.equalTo(20)
            make.trailing.equalTo(completedLabel.snp.leading).offset(-10)
        }
        currentSetLabel.snp.makeConstraints { (make) in
            make.top.equalTo(self.snp.bottom).offset(10)
            make.height.equalTo(20)
            make.trailing.equalTo(completedIconView.snp.leading).offset(-10)
        }
        currentSetIconView.snp.makeConstraints { (make) in
             make.top.equalTo(self.snp.bottom).offset(10)
             make.height.width.equalTo(20)
             make.trailing.equalTo(currentSetLabel.snp.leading).offset(-10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
