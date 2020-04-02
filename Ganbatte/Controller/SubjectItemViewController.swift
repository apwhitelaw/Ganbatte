//
//  SubjectItemViewController.swift
//  Ganbatte
//
//  Created by Austin Whitelaw on 8/16/19.
//  Copyright © 2019 Austin Whitelaw. All rights reserved.
//

import Foundation
import UIKit
import BubbleTransition

class SubjectItemViewController: UIViewController {
    
    var viewArray: [UIView] = []
    let scroll = UIScrollView()
    var interactiveTransition: BubbleInteractiveTransition?
    var subjectItem1: SubjectItem2
    let meaning: Bool?
    var barColor: UIColor = .wkPink
    
    init(subjectItem1: SubjectItem2) {
        self.subjectItem1 = subjectItem1
        self.meaning = nil
        self.interactiveTransition = nil
        super.init(nibName: nil, bundle: nil)
    }
    init(subjectItem1: SubjectItem2, meaning: Bool) {
        self.subjectItem1 = subjectItem1
        self.meaning = meaning
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        view.backgroundColor = .wkGreen
        
        view.addSubview(scroll)
        scroll.snp.makeConstraints { (make) in
            make.top.bottom.leading.trailing.equalTo(view)
        }
        scroll.contentSize = CGSize(width: view.frame.width, height: 2000)
        scroll.isScrollEnabled = true
        var scrollSize: CGFloat = 0
        
        let characterLabel = UILabel()
        let meaningLabel = UILabel()
        let readingLabel = UILabel()
        
        characterLabel.font = UIFont(name: "HiraginoSans-W3", size: 72)
        characterLabel.text = subjectItem1.data.characters
        characterLabel.textAlignment = .center
        scroll.addSubview(characterLabel)
        scrollSize += characterLabel.text?.height(withConstrainedWidth: characterLabel.frame.width, font: characterLabel.font) ?? 0
        characterLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(scroll)
            make.width.equalTo(scroll).multipliedBy(0.9)
        }
        viewArray.append(characterLabel)
        
        var meaningText = ""
        var readingText = ""
        var meaningMnemonicText = ""
        var readingMnemonicText = ""
        var meaningHintText = ""
        var readingHintText = ""
        
        switch(subjectItem1.object) {
        case "radical": barColor = .wkBlue
        case "kanji": barColor = .wkPink
        case "vocabulary": barColor = .wkPurple
        default: barColor = .white
        }
        
        for meaning in subjectItem1.data.meanings {
            let text = meaning.meaning
            if meaningText == "" { meaningText = text }
            else { meaningText = meaningText + ", \(text)" }
        }
        
        if let itemReadings = subjectItem1.data.readings {
            for reading in itemReadings {
                if reading.acceptedAnswer == true {
                    let text = reading.reading
                    if readingText == "" { readingText = text }
                    else { readingText = readingText + ", \(text)" }
                }
            }
        }
        
        meaningMnemonicText = subjectItem1.data.meaningMnemonic
        if let readingMnemonic = subjectItem1.data.readingMnemonic {
            readingMnemonicText = readingMnemonic
        }
        if let meaningHint = subjectItem1.data.meaningHint {
            meaningHintText = meaningHint
        }
        if let readingHint = subjectItem1.data.readingHint {
            readingHintText = readingHint
        }
        
        let meaningSeparator = BarSeparatorView(title: "Meaning:")
        meaningSeparator.backgroundColor = barColor
        scroll.addSubview(meaningSeparator)
        scrollSize += 30
        meaningSeparator.snp.makeConstraints { (make) in
            make.centerX.equalTo(scroll)
            make.width.equalTo(scroll).multipliedBy(0.95)
            make.height.equalTo(30)
        }
        viewArray.append(meaningSeparator)
        
        meaningLabel.numberOfLines = 0
        meaningLabel.lineBreakMode = .byWordWrapping
        meaningLabel.textAlignment = .center
        meaningLabel.isHidden = false
        meaningLabel.text = meaningText
        scroll.addSubview(meaningLabel)
        scrollSize += meaningLabel.text?.height(withConstrainedWidth: meaningLabel.frame.width, font: .systemFont(ofSize: 18)) ?? 0
        meaningLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(scroll)
            //make.top.equalTo(meaningSeparator.snp.bottom).offset(20)
            make.width.equalTo(scroll).multipliedBy(0.90)
        }
        viewArray.append(meaningLabel)
        
        if readingText != "" {
            let readingSeparator = BarSeparatorView(title: "Reading:")
            readingSeparator.backgroundColor = barColor
            scroll.addSubview(readingSeparator)
            scrollSize += 30
            readingSeparator.snp.makeConstraints { (make) in
                make.centerX.equalTo(scroll)
                make.width.equalTo(scroll).multipliedBy(0.95)
                make.height.equalTo(30)
                //make.top.equalTo(meaningLabel.snp.bottom).offset(20)
            }
            viewArray.append(readingSeparator)
            
            readingLabel.isHidden = false
            readingLabel.text = readingText
            readingLabel.textAlignment = .center
            scroll.addSubview(readingLabel)
            scrollSize += readingLabel.text?.height(withConstrainedWidth: readingLabel.frame.width, font: .systemFont(ofSize: 18)) ?? 0
            readingLabel.snp.makeConstraints { (make) in
                make.centerX.equalTo(scroll)
                make.width.equalTo(scroll).multipliedBy(0.90)
            }
            viewArray.append(readingLabel)
        }
        
        if meaningMnemonicText != "" {
            let meaningMnemonicSeparator = BarSeparatorView(title: "Meaning Mnemonic:")
            meaningMnemonicSeparator.backgroundColor = barColor
            scroll.addSubview(meaningMnemonicSeparator)
            scrollSize += 30
            meaningMnemonicSeparator.snp.makeConstraints { (make) in
                make.centerX.equalTo(scroll)
                make.width.equalTo(scroll).multipliedBy(0.95)
                make.height.equalTo(30)
            }
            viewArray.append(meaningMnemonicSeparator)
            
            let meaningMnemonicView = SizeableTextView(text: insertTextHighlighting(text: meaningMnemonicText))
            scroll.addSubview(meaningMnemonicView)
            let height = meaningMnemonicView.labelHeight
            scrollSize += height
            meaningMnemonicView.snp.makeConstraints { (make) in
                make.centerX.equalTo(scroll)
                make.width.equalTo(scroll).multipliedBy(0.90)
                make.height.equalTo(height) //(height * 1.2)
            }
            viewArray.append(meaningMnemonicView)
        }
        
        if meaningHintText != "" {
            let meaningHintSeparator = BarSeparatorView(title: "Meaning Hint:")
            meaningHintSeparator.backgroundColor = barColor
            scroll.addSubview(meaningHintSeparator)
            scrollSize += 30
            meaningHintSeparator.snp.makeConstraints { (make) in
                make.centerX.equalTo(scroll)
                make.width.equalTo(scroll).multipliedBy(0.95)
                make.height.equalTo(30)
            }
            viewArray.append(meaningHintSeparator)
            
            let meaningHintView = SizeableTextView(text: insertTextHighlighting(text:meaningHintText))
            scroll.addSubview(meaningHintView)
            let height = meaningHintView.labelHeight
            scrollSize += height
            meaningHintView.snp.makeConstraints { (make) in
                make.centerX.equalTo(scroll)
                make.width.equalTo(scroll).multipliedBy(0.90)
                make.height.equalTo(height * 1.2)
            }
            viewArray.append(meaningHintView)
        }
        
        if readingMnemonicText != "" {
            let readingMnemonicSeparator = BarSeparatorView(title: "Reading Mnemonic:")
            readingMnemonicSeparator.backgroundColor = barColor
            scroll.addSubview(readingMnemonicSeparator)
            scrollSize += 30
            readingMnemonicSeparator.snp.makeConstraints { (make) in
                make.centerX.equalTo(scroll)
                make.width.equalTo(scroll).multipliedBy(0.95)
                make.height.equalTo(30)
            }
            viewArray.append(readingMnemonicSeparator)
            
            let readingMnemonicView = SizeableTextView(text: insertTextHighlighting(text:readingMnemonicText))
            scroll.addSubview(readingMnemonicView)
            let height = readingMnemonicView.labelHeight
            scrollSize += height
            readingMnemonicView.snp.makeConstraints { (make) in
                make.centerX.equalTo(scroll)
                make.width.equalTo(scroll).multipliedBy(0.90)
                make.height.equalTo(height * 1.2)
            }
            viewArray.append(readingMnemonicView)
        }
        
        if readingHintText != "" {
            let readingHintSeparator = BarSeparatorView(title: "Reading Hint:")
            readingHintSeparator.backgroundColor = barColor
            scroll.addSubview(readingHintSeparator)
            scrollSize += 30
            readingHintSeparator.snp.makeConstraints { (make) in
                make.centerX.equalTo(scroll)
                make.width.equalTo(scroll).multipliedBy(0.95)
                make.height.equalTo(30)
            }
            viewArray.append(readingHintSeparator)
            
            let readingHintView = SizeableTextView(text: insertTextHighlighting(text:readingHintText))
            scroll.addSubview(readingHintView)
            let height = readingHintView.labelHeight
            scrollSize += height
            readingHintView.snp.makeConstraints { (make) in
                make.centerX.equalTo(scroll)
                make.width.equalTo(scroll).multipliedBy(0.90)
                make.height.equalTo(height * 1.2)
            }
            viewArray.append(readingHintView)
        }
        
        for (index, view) in viewArray.enumerated() {
            view.snp.makeConstraints { (make) in
                if index == 0 { make.top.equalTo(scroll).offset(50) }
                else { make.top.equalTo(viewArray[index-1].snp.bottom).offset(20) }
            }
            scrollSize += 30
        }
        
        scroll.contentSize = CGSize(width: scroll.frame.width, height: scrollSize)

        if meaning == true {
            readingLabel.isHidden = true
        } else if meaning == false {
            meaningLabel.isHidden = true
        }
        if meaning != nil {
            let newButton = UIButton()
            newButton.addTarget(self, action: #selector(dismissModalView), for: .touchUpInside)
            newButton.setTitle("Dismiss", for: .normal)
            newButton.setTitleColor(.red, for: .normal)
            view.addSubview(newButton)
            newButton.snp.makeConstraints { (make) in
                make.centerX.equalTo(view.snp.centerX)
                make.centerY.equalTo(view.snp.centerY).offset(100)
            }
        }
    }
    
    func insertTextHighlighting(text: String) -> NSMutableAttributedString {
        
        var editableText: NSString = text as NSString
        let newAttributedString = NSMutableAttributedString(string: text)
        var x = NSRange()
        var y = NSRange()
        var z = NSRange()
        var ja = NSRange()
        var read  = NSRange()
        var mean = NSRange()
        x = editableText.range(of: "<radical>")
        y = editableText.range(of: "<kanji>")
        z = editableText.range(of: "<vocabulary>")
        ja = editableText.range(of: "<ja>")
        read = editableText.range(of: "<reading>")
        mean = editableText.range(of: "<meaning>")
        while x.length != 0 || y.length != 0 || z.length != 0 || ja.length != 0 {
            if x.length != 0 {
                x = editableText.range(of: "<radical>")
                var x2 = editableText.range(of: "</radical>")
                
                newAttributedString.addAttribute(.backgroundColor, value: UIColor.wkBlue, range: NSRange(location: x.location, length: x2.location - x.location))
                x2 = NSRange(location: x2.location - x.length, length: x2.length)
                newAttributedString.deleteCharacters(in: x)
                editableText = editableText.replacingCharacters(in: x, with: "") as NSString
                newAttributedString.deleteCharacters(in: x2)
                editableText = editableText.replacingCharacters(in: x2, with: "") as NSString
                
            }
            
            if y.length != 0 {
                y = editableText.range(of: "<kanji>")
                var y2 = editableText.range(of: "</kanji>")
                
                newAttributedString.addAttribute(.backgroundColor, value: UIColor.wkPink, range: NSRange(location: y.location, length: y2.location - y.location))
                y2 = NSRange(location: y2.location - y.length, length: y2.length)
                newAttributedString.deleteCharacters(in: y)
                editableText = editableText.replacingCharacters(in: y, with: "") as NSString
                newAttributedString.deleteCharacters(in: y2)
                editableText = editableText.replacingCharacters(in: y2, with: "") as NSString
                
            }
            
            if z.length != 0 {
                z = editableText.range(of: "<vocabulary>")
                var z2 = editableText.range(of: "</vocabulary>")
                
                newAttributedString.addAttribute(.backgroundColor, value: UIColor.wkPurple, range: NSRange(location: z.location, length: z2.location - z.location))
                z2 = NSRange(location: z2.location - z.length, length: z2.length)
                newAttributedString.deleteCharacters(in: z)
                editableText = editableText.replacingCharacters(in: z, with: "") as NSString
                newAttributedString.deleteCharacters(in: z2)
                editableText = editableText.replacingCharacters(in: z2, with: "") as NSString
                
            }
            
            if ja.length != 0 {
                ja = editableText.range(of: "<ja>")
                var ja2 = editableText.range(of: "</ja>")
                
                newAttributedString.addAttribute(.backgroundColor, value: UIColor.lightGray, range: NSRange(location: ja.location, length: ja2.location - ja.location))
                ja2 = NSRange(location: ja2.location - ja.length, length: ja2.length)
                newAttributedString.deleteCharacters(in: ja)
                editableText = editableText.replacingCharacters(in: ja, with: "") as NSString
                newAttributedString.deleteCharacters(in: ja2)
                editableText = editableText.replacingCharacters(in: ja2, with: "") as NSString
                
            }
            
            if read.length != 0 {
                read = editableText.range(of: "<reading>")
                var read2 = editableText.range(of: "</reading>")
                
                newAttributedString.addAttribute(.backgroundColor, value: UIColor.lightGray, range: NSRange(location: read.location, length: read2.location - read.location))
                read2 = NSRange(location: read2.location - read.length, length: read2.length)
                newAttributedString.deleteCharacters(in: read)
                editableText = editableText.replacingCharacters(in: read, with: "") as NSString
                newAttributedString.deleteCharacters(in: read2)
                editableText = editableText.replacingCharacters(in: read2, with: "") as NSString
                
            }
            
            if mean.length != 0 {
                mean = editableText.range(of: "<meaning>")
                var mean2 = editableText.range(of: "</meaning>")
                
                newAttributedString.addAttribute(.backgroundColor, value: UIColor.lightGray, range: NSRange(location: mean.location, length: mean2.location - mean.location))
                mean2 = NSRange(location: mean2.location - mean.length, length: mean2.length)
                newAttributedString.deleteCharacters(in: mean)
                editableText = editableText.replacingCharacters(in: read, with: "") as NSString
                newAttributedString.deleteCharacters(in: mean2)
                editableText = editableText.replacingCharacters(in: mean2, with: "") as NSString

            }
            
            x = editableText.range(of: "<radical>")
            y = editableText.range(of: "<kanji>")
            z = editableText.range(of: "<vocabulary>")
            ja = editableText.range(of: "<ja>")
            read = editableText.range(of: "<reading>")
            mean = editableText.range(of: "<meaning>")
        }
        
        return newAttributedString
    }
    
    @objc func dismissModalView() {
        self.dismiss(animated: true, completion: nil)
        interactiveTransition?.finish()
    }
    
}

