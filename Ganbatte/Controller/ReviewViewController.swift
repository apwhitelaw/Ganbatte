//
//  AssignmentViewController.swift
//  Ganbatte
//
//  Created by Austin Whitelaw on 8/13/19.
//  Copyright © 2019 Austin Whitelaw. All rights reserved.
//

import Foundation
import UIKit
import SnapKit
import LTMorphingLabel
import BubbleTransition
import Alamofire
import Koloda

class ReviewViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    let lessons: Bool
    let postUrl: String
    
    let infoView = UIView()
    let itemView = UIView()
    
    var total = 0
    
    var reviewsArray1: [SubjectItem2] = []
    var currentReviewSet1: [SubjectItem2] = [] // max 10
    var currentReviewItem1: SubjectItem2
    var correctArray1: [SubjectItem2] = []
    var incorrectArray1: [SubjectItem2] = []
    
    let meaningReadingLabel: UILabel = UILabel()  // originally these were LTMorphingLabel
    let characterLabel: UILabel = UILabel()       // but the text wrap was not working
    let answerLabel: UILabel = UILabel()
    var answerShown: Bool = false
    var meaningText: String = ""
    var readingText: String = ""
    
    let meaningCompletedLabel = UILabel()
    let readingCompletedLabel = UILabel()
    let progressLabel = UILabel()
    
    let incorrectButton: UIButton = UIButton()
    let correctButton: UIButton = UIButton()
    let skipButton: UIButton = UIButton()
    let wrapUpButton: UIButton = UIButton()

    let transition = BubbleTransition()
    let interactiveTransition = BubbleInteractiveTransition()
    let showInfoButton = UIButton()
    
    var meaning: Bool = true // false == reading, true == meaning
    
    init(reviewsArray1: [SubjectItem2]) {
        self.reviewsArray1 = reviewsArray1
        self.currentReviewItem1 = reviewsArray1[0]
        self.lessons = false
        self.postUrl = "https://api.wanikani.com/v2/reviews/"
        super.init(nibName: nil, bundle: nil)
    }
    
    init(lessonsArray1: [SubjectItem2]) {
        self.currentReviewSet1 = lessonsArray1
        self.currentReviewItem1 = lessonsArray1[0]
        self.lessons = true
        self.postUrl = "https://api.wanikani.com/v2/assignments/"
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initialSetup()
        setupReview1()
    }
    
    func initialSetup() {
        correctArray1     = []
        incorrectArray1   = []
        
        setupInfoView()
        setupItemView()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(showAnswer))
        view.addGestureRecognizer(tap)
        
        view.addSubview(answerLabel)
        answerLabel.alpha = 0
        answerLabel.text = "Answer Label"
        answerLabel.textAlignment = .center
        answerLabel.numberOfLines = 4
        answerLabel.snp.makeConstraints { (make) in
            make.center.equalTo(view)
            make.width.equalTo(view).offset(-10)
        }

        incorrectButton.addTarget(self, action: #selector(incorrectAnswer), for: .touchUpInside)
        incorrectButton.setTitle("Incorrect", for: .normal)
        incorrectButton.backgroundColor = .red
        view.addSubview(incorrectButton)
        incorrectButton.snp.makeConstraints { (make) in
            make.height.equalTo(100)
            make.width.equalTo(view.frame.width / 2)
            make.leading.equalTo(view)
            make.bottom.equalTo(view)
        }

        correctButton.addTarget(self, action: #selector(correctAnswer), for: .touchUpInside)
        correctButton.setTitle("Correct", for: .normal)
        correctButton.backgroundColor = .green
        view.addSubview(correctButton)
        correctButton.snp.makeConstraints { (make) in
            make.height.equalTo(100)
            make.leading.equalTo(incorrectButton.snp.trailing)
            make.trailing.equalTo(view)
            make.bottom.equalTo(view)
        }
        
        correctButton.isUserInteractionEnabled = false
        incorrectButton.isUserInteractionEnabled = false

        showInfoButton.addTarget(self, action: #selector(presentBubble), for: .touchUpInside)
        showInfoButton.setTitle("Show Info", for: .normal)
        view.addSubview(showInfoButton)
        showInfoButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY).offset(200)
        }

//        skipButton.addTarget(self, action: #selector(setupReview), for: .touchUpInside)
//        skipButton.setTitle("Skip", for: .normal)
//        view.addSubview(skipButton)
//        skipButton.snp.makeConstraints { (make) in
//            make.centerX.equalTo(view.snp.centerX)
//            make.centerY.equalTo(view.snp.centerY).offset(250)
//        }
        
        wrapUpButton.addTarget(self, action: #selector(wrapUp), for: .touchUpInside)
        wrapUpButton.setTitle("Wrap Up", for: .normal)
        view.addSubview(wrapUpButton)
        wrapUpButton.snp.makeConstraints { (make) in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY).offset(250)
        }
    }
    
    func setupInfoView() {
        infoView.backgroundColor = .white
        view.addSubview(infoView)
        infoView.snp.makeConstraints { (make) in
            make.top.equalTo(view.snp.topMargin)
            make.leading.trailing.equalTo(view)
            make.height.equalTo(70)
        }
        
        meaningCompletedLabel.text = "M: 0"
        readingCompletedLabel.text = "R: 0"
        meaningCompletedLabel.textColor = .black
        readingCompletedLabel.textColor = .black
        meaningCompletedLabel.numberOfLines = 2
        readingCompletedLabel.numberOfLines = 2
        readingCompletedLabel.textAlignment = .right
        infoView.addSubview(meaningCompletedLabel)
        infoView.addSubview(readingCompletedLabel)
        meaningCompletedLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(infoView)
            make.leading.equalTo(infoView).offset(5)
        }
        readingCompletedLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(infoView)
            make.trailing.equalTo(infoView).offset(-5)
        }
        
        if lessons == false {
            total = reviewsArray1.count
            progressLabel.text =
            """
            Reviews Remaining: \(reviewsArray1.count) / \(total)
            Current Review Set: 0 / 10
            """
        } else if lessons == true {
            total = currentReviewSet1.count
            progressLabel.text = "Lessons Remaining: \(currentReviewSet1.count) / \(total)"
            
            readingCompletedLabel.isHidden = true
            meaningCompletedLabel.isHidden = true
        }
        progressLabel.numberOfLines = 2
        progressLabel.textAlignment = .center
        infoView.addSubview(progressLabel)
        progressLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(infoView)
            make.centerY.equalTo(infoView).offset(0)
        }
        
    }
    
    func setupItemView() {
        view.addSubview(itemView)
        
        itemView.snp.makeConstraints { (make) in
            make.centerX.equalTo(view.snp.centerX)
            make.centerY.equalTo(view.snp.centerY).offset(-50)
        }
        
        characterLabel.font = UIFont(name: "HiraginoSans-W3", size: 72)
        characterLabel.numberOfLines = 0
        characterLabel.textAlignment = .center
        itemView.addSubview(characterLabel)
        characterLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(itemView.snp.centerX)
            make.centerY.equalTo(itemView.snp.centerY)
            make.width.equalTo(view).offset(-20)
        }
        
        meaningReadingLabel.text = "Meaning"
        meaningReadingLabel.font = meaningReadingLabel.font.withSize(24)
        itemView.addSubview(meaningReadingLabel)
        meaningReadingLabel.snp.makeConstraints { (make) in
            make.centerX.equalTo(itemView.snp.centerX)
            make.bottom.equalTo(characterLabel.snp.top).offset(-10)
        }
    }
    
    
    func resetItems() {
        meaning = randomBool()
        meaningCompletedLabel.textColor = .black
        readingCompletedLabel.textColor = .black
        meaningCompletedLabel.text = "M: 0"
        readingCompletedLabel.text = "R: 0"
        itemView.frame.origin.y += 100
        itemView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        answerLabel.alpha = 0
        answerShown = false
        meaningText = ""
        readingText = ""
    }
    
    
    
    @objc func setupReview1() {
        resetItems()
        if (currentReviewSet1.count < 10) && (reviewsArray1.count > 0) {
            reviewsArray1.shuffle()
            currentReviewItem1 = reviewsArray1[0]
        } else if currentReviewSet1.count > 0 {
            currentReviewSet1.shuffle()
            currentReviewItem1 = currentReviewSet1[0]
        } else {
            let vc = CompletionViewController(correctArray: correctArray1, incorrectArray: incorrectArray1)
            vc.modalPresentationStyle = .fullScreen
            present(vc, animated: true)
        }
        
        characterLabel.text = currentReviewItem1.data.characters
        
        switch(currentReviewItem1.object) {
        case "radical": view.backgroundColor = .wkBlue
        case "kanji": view.backgroundColor = .wkPink
        case "vocabulary": view.backgroundColor = .wkPurple
        default: view.backgroundColor = .wkGreen
        }
        
        for meaning in currentReviewItem1.data.meanings {
            let text = meaning.meaning
            if meaningText == "" { meaningText = text }
            else { meaningText = meaningText + ", \(text)" }
        }
        
        if let itemReadings = currentReviewItem1.data.readings {
            for reading in itemReadings {
                if reading.acceptedAnswer == true {
                    let text = reading.reading
                    if readingText == "" { readingText = text }
                    else { readingText = readingText + ", \(text)" }
                }
            }
        } else {
            currentReviewItem1.readingCompleted = true
        }
        
        if currentReviewItem1.meaningCompleted == true {
            meaning = false
        }
        if currentReviewItem1.readingCompleted == true {
            meaning = true
        }
        
        if meaning == true {
            meaningReadingLabel.text = "Meaning"
            answerLabel.font = UIFont.systemFont(ofSize: 17)
            answerLabel.text = meaningText
        } else if meaning == false {
            meaningReadingLabel.text = "Reading"
            answerLabel.font = UIFont(name: "HiraginoSans-W3", size: 24)
            answerLabel.text = readingText
        }
        
        if currentReviewItem1.meaningCompleted == true {
            meaningCompletedLabel.textColor = .green
        }
        if currentReviewItem1.readingCompleted == true {
            readingCompletedLabel.textColor = .green
        }
        if currentReviewItem1.incorrectMeaning > 0 {
            meaningCompletedLabel.textColor = .red
            meaningCompletedLabel.text = "M: \(currentReviewItem1.incorrectMeaning)"
        }
        if currentReviewItem1.incorrectReading > 0 {
            readingCompletedLabel.textColor = .red
            readingCompletedLabel.text = "R: \(currentReviewItem1.incorrectReading)"
        }
        
        updateLabels()
    }
    
    @objc func showAnswer() {
        if answerShown == false {
            UIView.animate(withDuration: 1.0) {
                self.itemView.frame.origin.y -= 100
                self.itemView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                self.answerLabel.alpha = 1.0
            }
            
            correctButton.isUserInteractionEnabled = true
            incorrectButton.isUserInteractionEnabled = true
            answerShown = true
        }
    }
    
    @objc func correctAnswer() {
        correctButton.isUserInteractionEnabled = false
        incorrectButton.isUserInteractionEnabled = false
        
        if currentReviewSet1.count > 0 {
            var contains = false
            for item in currentReviewSet1 {
                if item.id == currentReviewItem1.id {
                    contains = true
                }
            }
            if !contains {
                print("removing \(reviewsArray1[0].id)...")
                reviewsArray1.remove(at: 0)
                print("inserting \(currentReviewItem1.id)")
                currentReviewSet1.insert(currentReviewItem1, at: 0)
                for item in currentReviewSet1 {
                    print(item.id, terminator:" ")
                }
            }
        } else {
            print("removing \(reviewsArray1[0].id)...")
            reviewsArray1.remove(at: 0)
            print("inserting \(currentReviewItem1.id)")
            currentReviewSet1.insert(currentReviewItem1, at: 0)
            for item in currentReviewSet1 {
                print(item.id, terminator:" ")
            }
        }
        
        if meaning == true {
            currentReviewItem1.meaningCompleted = true
        } else if meaning == false {
            currentReviewItem1.readingCompleted = true
        }
        if(currentReviewItem1.meaningCompleted == true) && (currentReviewItem1.readingCompleted == true) {
            //performSelector(inBackground: #selector(postItem), with: nil)
            postItem() // above causes app to show item just completed
        } else {
            setupReview1()
        }
        
    }
    
    @objc func incorrectAnswer() {
        correctButton.isUserInteractionEnabled = false
        incorrectButton.isUserInteractionEnabled = false
        
        var contains = false
        for item in currentReviewSet1 {
            if item.id == currentReviewItem1.id {
                contains = true
            }
        }
        
        if !contains {
            print("removing \(reviewsArray1[0])...")
            reviewsArray1.remove(at: 0)
            print("inserting \(currentReviewItem1.id)")
            currentReviewSet1.insert(currentReviewItem1, at: 0)
            for item in currentReviewSet1 {
                print(item.id, terminator:" ")
            }
        }
        
        if meaning == true {
            currentReviewItem1.incorrectMeaning += 1
        } else if meaning == false {
            currentReviewItem1.incorrectReading += 1
        }
        
        setupReview1()
    }
    
    @objc func postItem() {
        let params = [
            "review": [
                "subject_id": currentReviewItem1.id,
                "incorrect_meaning_answers": currentReviewItem1.incorrectMeaning,
                "incorrect_reading_answers": currentReviewItem1.incorrectReading
            ]
        ]
        if lessons == false {
            AF.request(postUrl, method: .post, parameters: params, headers: WKConstants.headers).responseJSON { (response) in
                print(response)
                for (index, item) in self.currentReviewSet1.enumerated() {
                    if item.id == self.currentReviewItem1.id {
                        self.currentReviewSet1.remove(at: index)
                        print("removing item at \(index)...")
                        if (item.incorrectMeaning == 0) && (item.incorrectReading == 0) {
                            self.correctArray1.append(item)
                        } else {
                            self.incorrectArray1.append(item)
                        }
                    }
                }
                self.setupReview1()
            }
        } else if lessons == true {
             //named postUrl but in this case it is actually PUT
            AF.request("\(postUrl)\(currentReviewItem1.assignment.id)/start", method: .put, headers: WKConstants.headers).responseJSON { (response) in
                print(response)
                for (index, item) in self.currentReviewSet1.enumerated() {
                    if item.id == self.currentReviewItem1.id {
                        self.currentReviewSet1.remove(at: index)
                        print("removing item at \(index)...")
                        if (item.incorrectMeaning == 0) && (item.incorrectReading == 0) {
                            self.correctArray1.append(item)
                        } else {
                            self.incorrectArray1.append(item)
                        }
                    }
                }
                self.setupReview1()
            }
        }
    }
    
    @objc func wrapUp() {		
        reviewsArray1 = []
        setupReview1()
    }
    
    func updateLabels() {
        if lessons == false {
            progressLabel.text =
            """
            Reviews Remaining: \(reviewsArray1.count) / \(total)
            Current Review Set: \(currentReviewSet1.count) / 10
            """
        } else if lessons == true {
            progressLabel.text = "Lessons Remaining: \(currentReviewSet1.count) / \(total)"
        }
    }
    
    func randomBool() -> Bool {
        return arc4random_uniform(2) == 0
    }
    
    
    @objc func presentBubble() {
//        let controller = SubjectItemViewController(subjectItem: currentReviewItem, meaning: meaning)
//        controller.transitioningDelegate = self
//        controller.modalPresentationStyle = .custom
//        controller.interactiveTransition = interactiveTransition
//        interactiveTransition.attach(to: controller)
//        present(controller, animated: true, completion: nil)
    }
    
    // MARK: UIViewControllerTransitioningDelegate
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .present
        transition.startingPoint = showInfoButton.center
        transition.bubbleColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        transition.duration = 0.25
        return transition
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.transitionMode = .dismiss
        transition.startingPoint = showInfoButton.center
        transition.bubbleColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        transition.duration = 0.25
        return transition
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition
    }
    
}
