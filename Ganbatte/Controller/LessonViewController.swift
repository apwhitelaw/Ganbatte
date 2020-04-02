//
//  LessonViewController.swift
//  Ganbatte
//
//  Created by Austin Whitelaw on 8/14/19.
//  Copyright © 2019 Austin Whitelaw. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import EZSwipeController
import Alamofire

class LessonViewController: EZSwipeController, EZSwipeControllerDataSource {
    
    var lessonsArray: [SubjectItem] = []
    var vcArray: [UIViewController] = []
    var quizArray: [SubjectItem] = []
    var index = 0
    var lessonsArray1: [SubjectItem2] = []
    var quizArray1: [SubjectItem2] = []
    
    init(lessonsArray1: [SubjectItem2]) {
        self.lessonsArray1 = lessonsArray1
        for x in 0..<AppSettings.lessonSize {
            vcArray.append(SubjectItemViewController(subjectItem1:self.lessonsArray1[x]))
            quizArray1.append(self.lessonsArray1[x])
        }
        super.init()
        
        //getAssignmentIds()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    func getAssignmentIds() {
        AF.request(
            "https://api.wanikani.com/v2/assignments?immediately_available_for_lessons", headers: WKConstants.headers).responseJSON{ (response) in
            if let jsonDict = response.value as? [String: Any] {
                if let data = jsonDict["data"] as? [[String: Any]] {
                    //print(data)
                    for item in data {
                        let assignmentId = item["id"] as? Int ?? 0
                        if let data2 = item["data"] as? [String: Any] {
                            let subjectId = data2["subject_id"] as? Int ?? 0
                            for x in 0..<5 {
                                if subjectId == self.lessonsArray[x].id {
                                    self.lessonsArray[x].assignmentId = assignmentId
                                }
                            }
                        }
                    }
                }
            }
        }
        
        //let quizVC = ReviewViewController(lessonsArray: quizArray)
        //vcArray.append(quizVC)
    }
    
    override func setupView() {
        datasource = self
        navigationBarShouldNotExist = true
    }
    
    func viewControllerData() -> [UIViewController] {
        return vcArray
    }
    
}

