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
import AVFoundation

class ReviewViewController: UIViewController, UIViewControllerTransitioningDelegate, CAAnimationDelegate {
    
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
    
    let rpv = ReviewProgressView()
    let showView = UIView()
    let gradientLayer = CAGradientLayer()
    let swipeGradient = CAGradientLayer()
    
    var readingAudio: AVAudioPlayer?
    let playReadingButton: UIButton = UIButton(type: .roundedRect)
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Hide navigation bar
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Unhide navigation bar
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
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
        
        //let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.wkGreen.cgColor, UIColor.black.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.25)
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        //self.view.layer.addSublayer(gradientLayer)
        
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
        
        showView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
        showView.alpha = 0.5
        view.addSubview(showView)
        showView.snp.makeConstraints { (make) in
            make.top.bottom.leading.equalTo(incorrectButton)
            make.trailing.equalTo(correctButton)
        }
        
        swipeGradient.frame = self.view.bounds
        swipeGradient.startPoint = CGPoint(x: 0.0, y: 0.5)
        swipeGradient.endPoint = CGPoint(x: 1.0, y: 0.5)
        swipeGradient.locations = [1.0, 1.0]
        //view.layer.insertSublayer(swipeGradient, at: 0)
        view.layer.addSublayer(swipeGradient)
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(revealGradient(sender:)))
        swipeLeft.direction = .left
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(revealGradient(sender:)))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeLeft)
        view.addGestureRecognizer(swipeRight)
        
        view.addSubview(playReadingButton)
        playReadingButton.setTitle("Play", for: .normal)
        playReadingButton.addTarget(self, action: #selector(playAudio), for: .touchUpInside)
        playReadingButton.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-10)
            make.bottom.equalTo(correctButton.snp.top).offset(-10)
        }
    }
    
    @objc func playAudio() {
        if let audio = currentReviewItem1.data.pronunciationAudios {
            for sound in audio {
                if sound.contentType == "audio/mpeg" {
                    if let url = URL(string: sound.url) {
                        do {
                            let data = try Data(contentsOf: url)
                            readingAudio = try AVAudioPlayer(data: data)
                            break
                        }
                        catch {
                            print(error.localizedDescription)
                            presentAlert(target: self, title: "Could not play audio.", message: "The audio failed to play.", defaultAction: "OK", alternateAction: "Cancel")
                        }
                    }
                }
            }
        }
        readingAudio?.prepareToPlay()
        readingAudio?.play()
    }
    
    @objc func revealGradient(sender: Any) {
        if let swipe = sender as? UISwipeGestureRecognizer {
            if swipe.direction == .left {
                swipeGradient.colors = [UIColor.clear.cgColor, UIColor.green.cgColor]
            } else {
                swipeGradient.colors = [UIColor.red.cgColor, UIColor.clear.cgColor]
            }
        }
    }
    
//    var last = UITouch()
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
//        swipeGradient.colors = [UIColor.clear.cgColor, UIColor.green.cgColor]
//        if let touch = touches.first {
//            last = touch
//        }
//    }
//
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        for touch in touches {
//            last = touch
//            let x = Float(touch.preciseLocation(in: view).x / view.frame.width)
//            print(x)
//            swipeGradient.locations = [NSNumber(value: -(x - 1.0)), 1.0]
//        }
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
////        let endPointAnimation = CABasicAnimation(keyPath: "endPoint")
////        endPointAnimation.toValue = CGPoint(x: 1.5, y: 0.5)
////        let colorsAnimation = CABasicAnimation(keyPath: "colors")
////        colorsAnimation.toValue = []
////        swipeGradient.add(endPointAnimation, forKey: nil)
////        swipeGradient.add(colorsAnimation, forKey: nil)
//        swipeGradient.locations = [1.0, 1.0]
//        swipeGradient.colors = []
//    }
    
    func setGradient(mainColor: UIColor) {
        gradientLayer.colors = [mainColor.cgColor, UIColor.black.cgColor]
    }
    
    func setupInfoView() {
//        infoView.backgroundColor = .white
//        view.addSubview(infoView)
//        infoView.snp.makeConstraints { (make) in
//            make.top.equalTo(view.snp.topMargin)
//            make.leading.trailing.equalTo(view)
//            make.height.equalTo(70)
//        }
//
//        meaningCompletedLabel.text = "M: 0"
//        readingCompletedLabel.text = "R: 0"
//        meaningCompletedLabel.textColor = .black
//        readingCompletedLabel.textColor = .black
//        meaningCompletedLabel.numberOfLines = 2
//        readingCompletedLabel.numberOfLines = 2
//        readingCompletedLabel.textAlignment = .right
//        infoView.addSubview(meaningCompletedLabel)
//        infoView.addSubview(readingCompletedLabel)
//        meaningCompletedLabel.snp.makeConstraints { (make) in
//            make.centerY.equalTo(infoView)
//            make.leading.equalTo(infoView).offset(5)
//        }
//        readingCompletedLabel.snp.makeConstraints { (make) in
//            make.centerY.equalTo(infoView)
//            make.trailing.equalTo(infoView).offset(-5)
//        }
//
//        if lessons == false {
//            total = reviewsArray1.count
//            progressLabel.text =
//            """
//            Reviews Remaining: \(reviewsArray1.count) / \(total)
//            Current Review Set: 0 / 10
//            """
//        } else if lessons == true {
//            total = currentReviewSet1.count
//            progressLabel.text = "Lessons Remaining: \(currentReviewSet1.count) / \(total)"
//
//            readingCompletedLabel.isHidden = true
//            meaningCompletedLabel.isHidden = true
//        }
//        progressLabel.numberOfLines = 2
//        progressLabel.textAlignment = .center
//        infoView.addSubview(progressLabel)
//        progressLabel.snp.makeConstraints { (make) in
//            make.centerX.equalTo(infoView)
//            make.centerY.equalTo(infoView).offset(0)
//        }
        
        view.addSubview(rpv)
        rpv.snp.makeConstraints { (make) in
            make.centerX.equalTo(view)
            make.top.equalTo(view.snp.topMargin).offset(0)
            make.height.equalTo(2)
            make.width.equalTo(view.snp.width)
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
        showView.alpha = 0.5
        readingAudio = AVAudioPlayer()
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
            navigationController?.pushViewController(vc, animated: true)
//            vc.modalPresentationStyle = .fullScreen
//            present(vc, animated: true)
        }
        
        characterLabel.text = currentReviewItem1.data.characters
        
//        switch(currentReviewItem1.object) {
//        case "radical": view.backgroundColor = .wkBlue
//        case "kanji": view.backgroundColor = .wkPink
//        case "vocabulary": view.backgroundColor = .wkPurple
//        default: view.backgroundColor = .wkGreen
//        }
        
        //let animation: CABasicAnimation = CABasicAnimation(keyPath: "colors")
        //animation.fromValue = gradientLayer.colors
        var newColors = [UIColor.wkGreen.cgColor, UIColor.black.cgColor]
        switch(currentReviewItem1.object) {
        case "radical": newColors[0] = UIColor.wkBlue.cgColor
        case "kanji": newColors[0] = UIColor.wkPink.cgColor
        case "vocabulary": newColors[0] = UIColor.wkPurple.cgColor
        default: newColors[0] = UIColor.wkGreen.cgColor
        }
        gradientLayer.colors = newColors
        //animation.toValue = newColors
        //animation.duration = 0.3
        //animation.isRemovedOnCompletion = true
        //animation.fillMode = CAMediaTimingFillMode.forwards
        //animation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        //animation.delegate = self
        //self.gradientLayer.add(animation, forKey: "animateGradientColorChange")
        
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
        
        if let audios = currentReviewItem1.data.pronunciationAudios {
            playReadingButton.isHidden = false
        } else {
            playReadingButton.isHidden = true
        }
        
        updateLabels()
    }
    
    @objc func showAnswer() {
        if answerShown == false {
            UIView.animate(withDuration: 1.0) {
                self.itemView.frame.origin.y -= 100
                self.itemView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
                self.answerLabel.alpha = 1.0
                self.showView.alpha = 0.0
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
            print("removing \(reviewsArray1[0].id)...")
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
        rpv.completed = correctArray1.count + incorrectArray1.count
        rpv.remaining = reviewsArray1.count
        rpv.currentSet = currentReviewSet1.count
        
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
        let controller = SubjectItemViewController(subjectItem1: currentReviewItem1, meaning: meaning)
        controller.transitioningDelegate = self
        controller.modalPresentationStyle = .custom
        controller.interactiveTransition = interactiveTransition
        interactiveTransition.attach(to: controller)
        present(controller, animated: true, completion: nil)
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
