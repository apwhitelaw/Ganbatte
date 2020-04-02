//
//  SizeableTextView.swift
//  Ganbatte
//
//  Created by Austin Whitelaw on 1/20/20.
//  Copyright © 2020 Austin Whitelaw. All rights reserved.
//

import UIKit

class SizeableTextView: UIView {
    
    let label: UILabel = UILabel()
    var labelHeight: CGFloat = 0.0
    
    init(text: NSMutableAttributedString) {
        super.init(frame: CGRect.zero)
        backgroundColor = .white
        label.numberOfLines = 0
        //label.text = text
        label.attributedText = text
        addSubview(label)
        label.snp.makeConstraints { (make) in
            make.center.equalTo(self)
            make.width.equalTo(self).multipliedBy(0.95)
        }
        labelHeight = label.text?.height(withConstrainedWidth: (UIScreen.main.bounds.width * 0.9), font: .systemFont(ofSize: 18)) ?? 0
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
