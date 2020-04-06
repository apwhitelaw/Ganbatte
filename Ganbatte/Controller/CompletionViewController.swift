//
//  CompletionViewController.swift
//  Ganbatte
//
//  Created by Austin Whitelaw on 8/28/19.
//  Copyright © 2019 Austin Whitelaw. All rights reserved.
//

import UIKit
import SnapKit

private let reuseIdentifier = "Cell"
private let headerIdentifier = "headerView"

class CompletionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    var correctArray: [SubjectItem2] = []
    var incorrectArray: [SubjectItem2] = []
    
    init(correctArray: [SubjectItem2], incorrectArray: [SubjectItem2]) {
        self.correctArray = correctArray
        self.incorrectArray = incorrectArray
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: -30, left: 0, bottom: 20, right: 0)
        layout.minimumInteritemSpacing = 5
        //layout.sectionHeadersPinToVisibleBounds = true
        super.init(collectionViewLayout: layout)
    }
    
    init(reviewsArray: [SubjectItem2]) {
        for x in 0..<50 {
            let rand = Int(arc4random_uniform(300))
            correctArray.append(reviewsArray[rand])
        }
        for x in 50..<100 {
            let rand = Int(arc4random_uniform(300))
            incorrectArray.append(reviewsArray[rand])
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: -30, left: 0, bottom: 20, right: 0)
        layout.minimumInteritemSpacing = 5
        //layout.sectionHeadersPinToVisibleBounds = true
        super.init(collectionViewLayout: layout)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.setHidesBackButton(true, animated: false)
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(returnToHome))
        navigationItem.setRightBarButton(doneButton, animated: false)
        
        collectionView.backgroundColor =  UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0) //.wkGreen
        
        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        self.collectionView!.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
    }
    
    @objc func returnToHome() {
        navigationController?.popToRootViewController(animated: true)
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 3
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if section == 1 {
            return incorrectArray.count
        } else if section == 2 {
            return correctArray.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 100)
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier, for: indexPath as IndexPath) as! SectionHeaderView

            headerView.frame.size.height = 50
            headerView.frame.size.width = view.frame.width
            
            if indexPath.section == 0 {
                headerView.titleLabel.text = "Finished!"
            } else if indexPath.section == 1 {
                headerView.backgroundColor = .red
                headerView.titleLabel.text = "Incorrect"
            } else if indexPath.section == 2 {
                headerView.backgroundColor = .green
                headerView.titleLabel.text = "Correct"
            }

            return headerView
        } else { assert(false) }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.layer.cornerRadius = 5
        var cellItem: SubjectItem2
        if(indexPath.section == 1) {
            cellItem = incorrectArray[indexPath.row]
        } else {
            // if any issues, originally said: else if (indexPath.section == 2)
            cellItem = correctArray[indexPath.row]
        }
        switch(cellItem.object) {
        case "radical": cell.backgroundColor = .wkBlue
        case "kanji": cell.backgroundColor = .wkPink
        case "vocabulary": cell.backgroundColor = .wkPurple
        default: cell.backgroundColor = .white
        }
        let label = UILabel()
        if let text = cellItem.data.characters {
            label.text = text
        }
        cell.addSubview(label)
        label.snp.makeConstraints { (make) in
            make.center.equalTo(cell)
        }
    
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        var cellItem: SubjectItem2
        if(indexPath.section == 1) {
            cellItem = incorrectArray[indexPath.row]
        } else {
            // if any issues, originally said: else if (indexPath.section == 2)
            cellItem = correctArray[indexPath.row]
        }
        
        var width: CGFloat = 40
        if let text = cellItem.data.characters {
            let newWidth = text.width(withConstrainedHeight: 50, font: UIFont.systemFont(ofSize: 18))
            if newWidth > width {
                width = newWidth
            }
        }
        
        return CGSize(width: width, height: 40)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var newVC = UIViewController()
        if indexPath.section == 1 {
            newVC = SubjectItemViewController(subjectItem1: incorrectArray[indexPath.row])
        } else if indexPath.section == 2 {
            newVC = SubjectItemViewController(subjectItem1: correctArray[indexPath.row])
        }
        //newVC.modalPresentationStyle = .fullScreen
        present(newVC, animated: true) {

        }
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}

