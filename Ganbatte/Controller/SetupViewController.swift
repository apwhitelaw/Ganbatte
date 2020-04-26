//
//  SetupViewController.swift
//  Ganbatte
//
//  Created by Austin Whitelaw on 4/6/20.
//  Copyright © 2020 Austin Whitelaw. All rights reserved.
//

import UIKit
import SnapKit

class SetupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    //var previousCollectionView = SubjectItemCollectionView()
    let typeOrderTableView = UITableView()
    let levelsTableView = UITableView()
    var levelsCollectionView: UICollectionView?
    
    var subjectArray: [SubjectItem2]  = []
    var editedSubjectArray: [SubjectItem2]  = []
    var typeOrder: [Int] = [0, 1, 2]
    var availableLevels: [Int] = []
    var selectedLevels: [Int] = []
    var selected: [Bool] = []
    var total = 0
    
    var totalReviewsLabel = UILabel()
    let beginButton = UIButton()
    
    init(reviewsArray: [SubjectItem2]) {
        subjectArray = reviewsArray
        editedSubjectArray = reviewsArray
        total = editedSubjectArray.count
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for subject in subjectArray {
            let level = subject.data.level
            if !availableLevels.contains(level) {
                availableLevels.append(level)
            }
        }
        availableLevels.sort { (a, b) -> Bool in
            if b < a { return true }
            else { return false }
        }
        
        for _ in 0..<availableLevels.count {
            selected.append(true)
        }
        
        
        selectedLevels = availableLevels
        view.backgroundColor = .wkGreen
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: -30, left: 0, bottom: 20, right: 0)
        layout.minimumInteritemSpacing = 5
        layout.scrollDirection = .horizontal
        
        var a: [SubjectItem2] = []
        var b: [SubjectItem2] = []
        for x in 1...100 {
            a.append(allKanjiArray[x])
            b.append(allKanjiArray[x])
        }
        
        let previousCollectionView = PreviousCollectionView(frame: CGRect.zero, collectionViewLayout: layout, correctArray: a, incorrectArray: b)
//        for x in 0...100 {
//            previousCollectionView.correctArray.append(allKanjiArray[x])
//        }
//        for x in 0...100 {
//            previousCollectionView.incorrectArray.append(allKanjiArray[x])
//        }
        view.addSubview(previousCollectionView)
        previousCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.topMargin).offset(20)
            make.centerX.equalTo(view)
            make.width.equalToSuperview().offset(-10) //.multipliedBy(0.7)
            make.height.equalTo(200)

        }
        
        view.addSubview(typeOrderTableView)
        typeOrderTableView.snp.makeConstraints { (make) in
            make.height.equalTo(150)
            //make.leading.equalTo(view.snp.width).multipliedBy(0.5)
            make.centerX.equalTo(view)
            make.top.equalTo(previousCollectionView.snp.bottom).offset(10)
            make.width.equalTo(view.frame.width * 0.55)
        }
        typeOrderTableView.layoutMargins = UIEdgeInsets.zero
        typeOrderTableView.separatorInset = UIEdgeInsets.zero
        typeOrderTableView.layer.cornerRadius = 10
        typeOrderTableView.dataSource = self
        typeOrderTableView.delegate = self
        typeOrderTableView.isEditing = true
        typeOrderTableView.isScrollEnabled = false
        
//        view.addSubview(levelsTableView)
//        levelsTableView.snp.makeConstraints { (make) in
//            make.height.top.equalTo(typeOrderTableView)
//            make.leading.equalTo(typeOrderTableView.snp.trailing).offset(10)
//            make.trailing.equalTo(view).offset(-10)
//            //make.width.greaterThanOrEqualTo(view.frame.width * 0.1)
//            //make.width.lessThanOrEqualTo(view.frame.width * 0.3)
//        }
//        levelsTableView.layoutMargins = UIEdgeInsets.zero
//        levelsTableView.separatorInset = UIEdgeInsets.zero
//        levelsTableView.layer.cornerRadius = 10
//        levelsTableView.dataSource = self
//        levelsTableView.delegate = self
//        levelsTableView.isEditing = false
//        levelsTableView.isScrollEnabled = true
        
        levelsCollectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())
        if let cv = levelsCollectionView {
            view.addSubview(cv)
            cv.snp.makeConstraints { (make) in
                make.width.equalTo(view.snp.width).multipliedBy(0.75)
                make.height.equalTo(150)
                make.top.equalTo(typeOrderTableView.snp.bottom).offset(30)
                make.centerX.equalTo(view)
            }
            cv.backgroundColor = .white
            cv.layer.cornerRadius = 10
            cv.dataSource = self
            cv.delegate = self
            cv.register(LevelCell.self, forCellWithReuseIdentifier: "cell")
            
            view.addSubview(totalReviewsLabel)
            totalReviewsLabel.text = "100"
            totalReviewsLabel.snp.makeConstraints { (make) in
                make.centerX.equalTo(view)
                make.top.equalTo(cv.snp.bottom).offset(10)
            }
        }
        updateLabels()
        
        beginButton.setTitle("Begin Reviews", for: .normal)
        beginButton.addTarget(self, action: #selector(beginReviews), for: .touchUpInside)
        beginButton.backgroundColor = .wkBlue
        view.addSubview(beginButton)
        beginButton.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-50)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.4)
            make.height.equalTo(50)
        }
    }
    
    @objc func beginReviews() {
        let vc = ReviewViewController(reviewsArray1: editedSubjectArray)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func removeLevel(_ level: Int) {
//        for (index, subject) in editedSubjectArray.enumerated() {
//            if subject.data.level == level {
//                print(index, editedSubjectArray.count)
//                editedSubjectArray.remove(at: index)
//            }
//        }
        editedSubjectArray.removeAll { $0.data.level == level }
        updateLabels()
    }
    func addLevel(_ level: Int) {
        for subject in subjectArray {
            if subject.data.level == level {
                editedSubjectArray.append(subject)
            }
        }
        updateLabels()
    }
    
    func updateLabels() {
        total = editedSubjectArray.count
        totalReviewsLabel.text = "\(total)"
        if total > 0 {
            beginButton.isUserInteractionEnabled = true
            beginButton.backgroundColor = .wkBlue
        } else {
            beginButton.isUserInteractionEnabled = false
            beginButton.backgroundColor = .lightGray
        }
    }
    
    func setColors(cell: UICollectionViewCell, indexPath: IndexPath) {
        if selected[indexPath.row] {
            cell.backgroundColor = UIColor(red: 200/255, green: 200/255, blue: 200/255, alpha: 1.0)
        } else {
            cell.backgroundColor = UIColor(red: 140/255, green: 140/255, blue: 140/255, alpha: 1.0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            if selected[indexPath.row] {
                selected[indexPath.row] = false
                removeLevel(availableLevels[indexPath.row])
            } else {
                selected[indexPath.row] = true
                addLevel(availableLevels[indexPath.row])
            }
            if let cell = collectionView.cellForItem(at: indexPath) {
                setColors(cell: cell, indexPath: indexPath)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? LevelCell {
            cell.backgroundColor = .lightGray
            cell.label.text = "\(availableLevels[indexPath.row])"
            setColors(cell: cell, indexPath: indexPath)
            cell.addSubview(cell.label)
            cell.label.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
            }
            cell.layer.cornerRadius = 5
            return cell
        }
        let cell = UICollectionViewCell()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 30, height: 30)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return availableLevels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        
        if tableView == typeOrderTableView {
            var text = ""
            switch(indexPath.row) {
            case 0:
                text = "Radical"
                cell.backgroundColor = .wkBlue
            case 1:
                text = "Kanji"
                cell.backgroundColor = .wkPink
            case 2:
                text = "Vocabulary"
                cell.backgroundColor = .wkPurple
            default:
                text = "None"
                cell.backgroundColor = .wkGreen
            }
            cell.textLabel?.text = text
        }
        
        if tableView == levelsTableView {
            cell.textLabel?.text = String(availableLevels[indexPath.row])
            if let levelText = cell.textLabel?.text {
                if let level = Int(levelText) {
                    if selected[indexPath.row] == true {
                        cell.accessoryType = .checkmark
                    } else {
                        cell.accessoryType = .none
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == levelsTableView {
            if let cell = tableView.cellForRow(at: indexPath) {
                cell.setSelected(false, animated: true)
                if let levelText = cell.textLabel?.text {
                    if let level = Int(levelText) {
                        if cell.accessoryType == .checkmark {
                            removeLevel(level)
                            cell.accessoryType = .none
                            selected[indexPath.row] = false
                        } else {
                            addLevel(level)
                            cell.accessoryType = .checkmark
                            selected[indexPath.row] = true
                        }
                        totalReviewsLabel.text = "\(editedSubjectArray.count)"
                    }
                }
            }
        }
        
        print(selectedLevels)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView == typeOrderTableView{
            return 50
        } else {
            return 30
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == typeOrderTableView {
            return 3
        }
        if tableView == levelsTableView {
            return availableLevels.count
        }
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let item = typeOrder[sourceIndexPath.row]
        typeOrder.remove(at: sourceIndexPath.row)
        typeOrder.insert(item, at: destinationIndexPath.row)
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }

}

class LevelCell: UICollectionViewCell {
    var label = UILabel()
    var level: Int = 0
}
