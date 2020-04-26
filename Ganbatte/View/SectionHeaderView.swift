//
//  SectionHeaderView.swift
//  Ganbatte
//
//  Created by Austin Whitelaw on 1/20/20.
//  Copyright © 2020 Austin Whitelaw. All rights reserved.
//

import UIKit

class SectionHeaderView: UICollectionReusableView {
    
    let titleLabel = UILabel()
    let percentageLabel = UILabel()
    
    init(title: String) {
        super.init(frame: CGRect.zero)
        self.addSubview(titleLabel)
        titleLabel.text = title
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(self)
            make.leading.equalTo(self).offset(10)
        }
        
        setupResultHeader()
    }
    
    func setupResultHeader() {
        titleLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(self).offset(5)
            make.leading.equalTo(self).offset(5)
        }
        
        self.addSubview(percentageLabel)
        percentageLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(titleLabel.snp.trailing).offset(10)
            make.centerY.equalTo(titleLabel)
        }
    }
    
    convenience override init(frame: CGRect) {
        self.init(title: "Temporary String")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

