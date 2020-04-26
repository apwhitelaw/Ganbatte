//
//  ComponentView.swift
//  Ganbatte
//
//  Created by Austin Whitelaw on 4/3/20.
//  Copyright © 2020 Austin Whitelaw. All rights reserved.
//

import UIKit
import SnapKit

class ComponentView: UIView {
    
    var height: CGFloat = 0
    var components: [Int] = []
    var radicals : Bool = false
    
    init(components: [Int], radicals: Bool) {
        super.init(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        self.components = components
        self.radicals = radicals
    }
    
    func setupViews() {
        
        var objects: [SubjectItem2] = []
        for id in components {
            if radicals {
                if let radical = allRadicalArray.first(where: { $0.id == id }) {
                    objects.append(radical)
                }
            } else {
                if let kanji = allKanjiArray.first(where: { $0.id == id }) {
                    objects.append(kanji)
                }
            }
        }
                
        var buttonArray: [UIButton] = []
        var labelArray: [UILabel] = []
        for object in objects{
            let itemDisplay = UIButton()
            itemDisplay.backgroundColor = radicals ? .wkBlue : .wkPink
            itemDisplay.layer.cornerRadius = 5
            if let chars = object.data.characters {
                itemDisplay.setTitle(chars, for: .normal)
            } else {
                // IMPLEMENT CHARACTER IMAGES
            }
            buttonArray.append(itemDisplay)
            
            let meaningLabel = UILabel()
            var meaningText = ""
            for meaning in object.data.meanings {
                if meaning.primary {
                    meaningText = meaning.meaning
                }
            }
            meaningLabel.text = meaningText
            labelArray.append(meaningLabel)
        }
        
        if objects.count > 2 {
            height = 100
        } else {
            height = 50
        }
        
        let itemWidth = (self.bounds.width - 20) / 3
        print(itemWidth)
        for (index,button) in buttonArray.enumerated() {
            button.snp.makeConstraints { (make) in
                addSubview(button)
                addSubview(labelArray[index])
                let offset = index > 2 ? CGFloat((index + 1) / 2) * itemWidth : CGFloat(index + 1) * itemWidth
                make.leading.equalTo(self).offset(offset)
                if buttonArray.count > 2 {
                    if index < 3 {
                        make.centerY.equalTo(self).multipliedBy(0.25)
                    } else {
                        make.centerY.equalTo(self).multipliedBy(0.75)
                    }
                } else {
                    make.centerY.equalTo(self)
                }
            }
            
            labelArray[index].snp.makeConstraints { (make) in
                make.leading.equalTo(button.snp.trailing)
                make.centerY.equalTo(button)
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
