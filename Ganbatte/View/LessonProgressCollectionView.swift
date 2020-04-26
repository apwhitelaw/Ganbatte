//
//  LessonProgressCollectionView.swift
//  Ganbatte
//
//  Created by Austin Whitelaw on 4/8/20.
//  Copyright © 2020 Austin Whitelaw. All rights reserved.
//

//import UIKit
//
//private let reuseIdentifier = "Cell"
//private let headerIdentifier = "headerView"
//
//class LevelProgressCollectionView: UICollectionView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
//
//    var radicalArray: [SubjectItem2] = []
//    var kanjiArray: [SubjectItem2] = []
//    var vocabArray: [SubjectItem2] = []
//
//    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
//        super.init(frame: frame, collectionViewLayout: layout)
//        self.backgroundColor =  UIColor(red: 242/255, green: 242/255, blue: 247/255, alpha: 1.0) //.wkGreen
//
//        self.dataSource = self
//        self.delegate = self
//        // Register cell classes
//        self.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
//        self.register(SectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
//    }
//
//    required init?(coder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
//}
