//
//  ViewController.swift
//  Ganbatte
//
//  Created by Austin Whitelaw on 8/8/19.
//  Copyright © 2019 Austin Whitelaw. All rights reserved.
//

import UIKit
import SnapKit
import Alamofire

var allRadicalArray: [SubjectItem2] = []
var allKanjiArray: [SubjectItem2] = []
var allVocabArray: [SubjectItem2] = []

class ViewController: UIViewController {
    
    //let apiUrl: String = "https://api.wanikani.com/v2/assignments?available_before="
    let apiUrl: String = "https://api.wanikani.com/v2/summary"
    let idUrl: String = "https://api.wanikani.com/v2/subjects?ids=" // append id number
    
    let scroll = UIScrollView()
    
    
    var lessonView: UIView = UIView()
    var reviewView: UIView = UIView()
    let lessonsLabel: UILabel = {
        let l = UILabel()
        l.text = "Lessons: 0"
        return l
    }()
    let reviewsLabel: UILabel = {
        let l = UILabel()
        l.text = "Reviews: 0"
        return l
    }()
    
    var username = ""
    var level = 0
    
    var lastUpdated = Date()
    var lessonsAvailable: Int = 0
    var reviewsAvailable: Int = 0
    var lessonsArray: [SubjectItem] = []
    var reviewsArray: [SubjectItem] = []
    
    var allItemsArray: [SubjectItem2] = []
    
    var reviewIds: [Int] = []
    var lessonIds: [Int] = []
    var reviewsArray1: [SubjectItem2] = []
    var lessonsArray1: [SubjectItem2] = []
    
    let dispatchGroup = DispatchGroup()
    
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
        
        setupViews()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        DispatchQueue.global(qos: .userInteractive).async {
            if allRadicalArray.count == 0 {
                self.loadSubjects()
            }
            self.sendRequests()
        }
    }
    
    func loadSubjects() {
        
         // TODO: IF LOAD FAILS, RUN DOWNLOAD AND SAVE
        
    //if FileManager().fileExists(atPath: getDocumentsDirectory().appendingPathComponent("radical").absoluteString) {
        if true {
            print("Loading Subject Data...")
            allRadicalArray = loadSubjectsFromFile(subjectType: SubjectItem2.self, fileName: "radical")
            allKanjiArray = loadSubjectsFromFile(subjectType: SubjectItem2.self, fileName: "kanji")
            allVocabArray = loadSubjectsFromFile(subjectType: SubjectItem2.self, fileName: "vocab")
        } else {
            print("Downloading All Subjects And Saving...")
            getAllSubjectsAndSave()
        }
        
    }
    
    func getAllSubjectsAndSave() {
        //let group = DispatchGroup()
        
        var radArr: [SubjectItem2] = []
        let radicalUrl = "https://api.wanikani.com/v2/subjects?types=radical"
            requestSubjects(currentApiUrl: radicalUrl, subjectType: SubjectItem2.self) { (result) in
            for item in result.data {
                radArr.append(item)
            }
        }
        
        var kanjiArr: [SubjectItem2] = []
        var kanjiUrl = "https://api.wanikani.com/v2/subjects?types=kanji"
        repeat {
            dispatchGroup.enter()
            requestSubjects(currentApiUrl: kanjiUrl, subjectType: SubjectItem2.self) { (result) in
                if let nextUrl = result.pages.nextUrl {
                    kanjiUrl = nextUrl
                } else {
                    kanjiUrl = ""
                }
                print(kanjiUrl)
                for item in result.data {
                    kanjiArr.append(item)
                }
                self.dispatchGroup.leave()
            }
            dispatchGroup.wait()
        } while(kanjiUrl != "")
        
        var vocArr: [SubjectItem2] = []
        var vocabUrl = "https://api.wanikani.com/v2/subjects?types=vocabulary"
        repeat {
            dispatchGroup.enter()
            requestSubjects(currentApiUrl: vocabUrl, subjectType: SubjectItem2.self) { (result) in
                if let nextUrl = result.pages.nextUrl {
                    vocabUrl = nextUrl
                } else {
                    vocabUrl = ""
                }
                print(vocabUrl)
                for item in result.data {
                    vocArr.append(item)
                }
                self.dispatchGroup.leave()
            }
            dispatchGroup.wait()
        } while (vocabUrl != "")
        
        let assignmentsArray = getAllAssignments()
        dispatchGroup.enter()
        for assignment in assignmentsArray {
            if let item = radArr.first(where: {$0.id == assignment.data.subjectId}) {
                item.assignment = assignment
                continue
            }
            if let item = kanjiArr.first(where: {$0.id == assignment.data.subjectId}) {
                item.assignment = assignment
                continue
            }
            if let item = vocArr.first(where: {$0.id == assignment.data.subjectId}) {
                item.assignment = assignment
                continue
            }
        }
        dispatchGroup.leave()
        dispatchGroup.wait()
        
        saveSubjects(dataToSave: radArr, fileName: "radical")
        saveSubjects(dataToSave: kanjiArr, fileName: "kanji")
        saveSubjects(dataToSave: vocArr, fileName: "vocab")
    }
    
    func getAllAssignments() -> [Assignment] {
        print("Getting assignments...")
        //let group = DispatchGroup()
        var assignmentsUrl = "https://api.wanikani.com/v2/assignments"
        var assignmentsArray: [Assignment] = []
        repeat {
            dispatchGroup.enter()
            requestAssignments(currentApiUrl: assignmentsUrl) { (assignments) in
                if let nextUrl = assignments.pages.nextUrl {
                    assignmentsUrl = nextUrl
                } else {
                    assignmentsUrl = ""
                }
                print(assignmentsUrl)
                assignmentsArray = assignmentsArray + assignments.data
                self.dispatchGroup.leave()
            }
            dispatchGroup.wait()
        } while (assignmentsUrl != "")
        
        return assignmentsArray
    }
    
    func saveSubjects<T: Codable>(dataToSave: T, fileName: String) {
        let fullPath = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            let encoded = try JSONEncoder().encode(dataToSave)
            print("Saving subjects...")
            try encoded.write(to: fullPath)
            
        } catch {
            print(error)
        }
        //print(FileManager().fileExists(atPath: fullPath as! String))
    }
    
    func loadSubjectsFromFile<T: Codable>(subjectType: T.Type, fileName: String) -> [T] {
        let fullPath = getDocumentsDirectory().appendingPathComponent(fileName)
        do {
            let data = try Data(contentsOf: fullPath)
            let decoded = try JSONDecoder().decode([T].self, from: data)
            print(decoded.count)
            return decoded
            
        } catch {
            print(error)
        }
        
        return []
    }
    
    func deleteFile(atURL: URL) {
        do {
            //let fileURLS = try FileManager().contentsOfDirectory(at: getDocumentsDirectory(), includingPropertiesForKeys: nil, options: [])
            try FileManager().removeItem(at: atURL)
        } catch {
            print(error)
        }
    }
    
    func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func requestSubjects<T: Codable>(currentApiUrl: String, subjectType: T.Type, resultHandler: @escaping (AllSubjects) -> ()) {
        AF.request(currentApiUrl, headers: WKConstants.headers).responseJSON { response in
            if let jsonDict = response.value as? [String: Any] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions.prettyPrinted)
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let allSubjectsData = try decoder.decode(AllSubjects.self, from: jsonData)
                        resultHandler(allSubjectsData)
                    } catch {
                        print(error)
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func requestAssignments(currentApiUrl: String, resultHandler: @escaping (AllAssignments) -> ()) {
        AF.request(currentApiUrl, headers: WKConstants.headers).responseJSON { response in
            if let jsonDict = response.value as? [String: Any] {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: jsonDict, options: JSONSerialization.WritingOptions.prettyPrinted)
                    let decoder = JSONDecoder()
                    decoder.keyDecodingStrategy = .convertFromSnakeCase
                    do {
                        let allSubjectsData = try decoder.decode(AllAssignments.self, from: jsonData)
                        resultHandler(allSubjectsData)
                    } catch {
                        print(error)
                    }
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func setupViews() {
        
        view.addSubview(scroll)
        scroll.snp.makeConstraints { (make) in
            make.width.equalTo(view)
            make.height.equalTo(view)
            make.center.equalTo(view)
        }
        scroll.isScrollEnabled = true
        scroll.contentSize = CGSize(width: view.frame.width, height: 1000)
        
        view.backgroundColor = .wkBlue
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [UIColor.wkGreen.cgColor, UIColor.black.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.25)
        self.view.layer.insertSublayer(gradientLayer, at: 0)
        
        let settingsButton = UIButton()
        //settingsButton.setTitle("Settings", for: .normal)
        settingsButton.setImage(UIImage(named: "settings.png"), for: .normal)
        settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)
        scroll.addSubview(settingsButton)
        settingsButton.snp.makeConstraints { (make) in
            make.width.equalTo(30)
            make.height.equalTo(30)
            make.top.equalTo(scroll).offset(5)
            make.trailing.equalTo(view.snp.trailing).offset(-25)
            //make.centerX.equalTo(scroll)
        }
        
        let iconView = UIImageView(image: UIImage(named: "Logo.png"))
        scroll.addSubview(iconView)
        iconView.snp.makeConstraints { (make) in
            make.width.height.equalTo(100)
            make.top.equalTo(scroll).offset(50)
            make.leading.equalTo(scroll).offset(25)
        }
        
        let infoView = UserInfoView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        scroll.addSubview(infoView)
        infoView.snp.makeConstraints { (make) in
            make.height.equalTo(100)
            make.width.greaterThanOrEqualTo(50)
            make.top.equalTo(iconView)
            make.leading.greaterThanOrEqualTo(iconView.snp.trailing).offset(25)
            make.trailing.equalTo(view.snp.trailing).offset(-25)
        }
        
        lessonView.backgroundColor = lessonsArray1.count > 0 ? .white : UIColor(red: 191.25/255, green: 191.25/255, blue: 191.25/255, alpha: 1.0)
        lessonView.isUserInteractionEnabled = true
        let lessonTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(beginLessons))
        lessonView.addGestureRecognizer(lessonTapRecognizer)
        
        reviewView.backgroundColor = lessonsArray1.count > 0 ? .white : UIColor(red: 191.25/255, green: 191.25/255, blue: 191.25/255, alpha: 1.0)
        reviewView.isUserInteractionEnabled = true
        let reviewTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(beginReviews))
        reviewView.addGestureRecognizer(reviewTapRecognizer)
        
        scroll.addSubview(lessonView)
        scroll.addSubview(reviewView)
        
        lessonView.addSubview(lessonsLabel)
        reviewView.addSubview(reviewsLabel)
        let arrow1 = UILabel()
        arrow1.text = ">"
        let arrow2 = UILabel()
        arrow2.text = ">"
        lessonView.addSubview(arrow1)
        reviewView.addSubview(arrow2)
        
        lessonView.snp.makeConstraints { (make) in
            make.width.equalTo(view)
            make.height.equalTo(50)
            make.centerX.equalTo(scroll)
            make.centerY.equalTo(250)
        }
        
        lessonsLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(lessonView)
            make.leading.equalTo(lessonView).offset(20)
        }
        
        reviewView.snp.makeConstraints { (make) in
            make.width.equalTo(view)
            make.height.equalTo(50)
            make.centerX.equalTo(scroll)
            make.centerY.equalTo(350)
        }
        
        reviewsLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(reviewView)
            make.leading.equalTo(reviewView).offset(20)
        }
        
        arrow1.snp.makeConstraints { (make) in
            make.centerY.equalTo(lessonView)
            make.trailing.equalTo(lessonView).offset(-20)
        }
        
        arrow2.snp.makeConstraints { (make) in
            make.centerY.equalTo(reviewView)
            make.trailing.equalTo(reviewView).offset(-20)
        }
    }
    
    @objc func openSettings() {
        let vc = SettingsTableViewController() //SettingsViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func beginLessons() {
        let vc = LessonViewController(lessonsArray1: lessonsArray1)
        vc.modalPresentationStyle = .fullScreen
        //let navVC = UINavigationController(rootViewController: vc)
        present(vc, animated: true) {
            
        }
    }
    
    @objc func beginReviews() {
        let vc = ReviewViewController(reviewsArray1: reviewsArray1)
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true) {
//
//        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func updateLabels() {
        lessonsLabel.text = "Lessons: \(lessonsArray1.count)"
        reviewsLabel.text = "Reviews: \(reviewsArray1.count)"
        
        lessonView.backgroundColor = lessonsArray1.count > 0 ? .white : UIColor(red: 127.5/255, green: 127.5/255, blue: 127.5/255, alpha: 1.0)
        reviewView.backgroundColor = lessonsArray1.count > 0 ? .white : UIColor(red: 127.5/255, green: 127.5/255, blue: 127.5/255, alpha: 1.0)
    }
    
    func sendRequests() {
        
        var request: URLRequest
        do {
            request = try URLRequest(url: URL(string: "\(apiUrl)")!, method: .get, headers: WKConstants.headers)
            request.cachePolicy = .reloadIgnoringLocalCacheData
            
            AF.request(request).responseJSON { response in
                if let jsonDict = response.value as? [String: Any] {
                    print(jsonDict["data_updated_at"])
                    if let data = jsonDict["data"] as? [String: Any] {
                        if let lessons = data["lessons"] as? [[String: Any]] {
                            self.setupLessons(lessons: lessons)
                        }
                        
                        if let reviews = data["reviews"] as? [[String: Any]] {
                            self.setupReviews(reviews: reviews)
                        }
                    }
                }
            }
        } catch {
            print(error)
        }
        
        AF.request("https://api.wanikani.com/v2/user", headers: WKConstants.headers).responseJSON { (response) in
            if let jsonDict = response.value as? [String: Any] {
                if let data = jsonDict["data"] as? [String: Any] {
                    if let username = data["username"] as? String {
                        self.username = username
                    }
                    if let level = data["level"] as? Int {
                        self.level = level
                    }
                }
            }
        }
    }
    
    func setupLessons(lessons: [[String: Any]]) {
        lessonsArray1 = []
        let lessonSet = lessons[0]
        if let currentLessons = lessonSet["subject_ids"] as? [Int] {
            
            var ids = ""
            for lesson in currentLessons {
                if ids == ""{ ids = "\(lesson)" }
                else { ids = ids + ",\(lesson)" }
            }
            createArrayFromIds1(ids: currentLessons, lessons: true)
        }
    }
    
    func setupReviews(reviews: [[String: Any]]) {
        reviewsArray1 = []
        let reviewSet = reviews[0] // 0 = most recent hour, 1 = upcoming hour, etc.
        if let currentReviews = reviewSet["subject_ids"] as? [Int] {
            
            var ids = ""
            for review in currentReviews {
                if ids == ""{ ids = "\(review)" }
                else { ids = ids + ",\(review)" }
            }
            createArrayFromIds1(ids: currentReviews, lessons: false)
        }
    }
    
    func createArrayFromIds1(ids: [Int], lessons: Bool) {
        
        for id in ids {
            if let item = allRadicalArray.first(where: {$0.id == id}) {
                print(item, lessons)
                if lessons == true {
                    lessonsArray1.append(item)
                } else {
                    reviewsArray1.append(item)
                }
                continue
            }
            if let item = allKanjiArray.first(where: {$0.id == id}) {
                print(item, lessons)
                if lessons == true {
                    lessonsArray1.append(item)
                } else {
                    reviewsArray1.append(item)
                }
                continue
            }
            if let item = allVocabArray.first(where: {$0.id == id}) {
                print(item, lessons)
                if lessons == true {
                    lessonsArray1.append(item)
                } else {
                    reviewsArray1.append(item)
                }
                continue
            }
        }
        
        updateLabels()
        // sort lessons: remove/edit sortLessons() function?
    }
    
    func sortLessons() {
        
        for _ in 0...lessonsArray.count {
            for (index,item) in lessonsArray.enumerated() {
                if index != (lessonsArray.count - 1) {
                    let nextItem = lessonsArray[index+1]
                    if item.level > nextItem.level {
                        let temp = nextItem
                        lessonsArray[index+1] = item
                        lessonsArray[index] = temp
                    }
                }
            }
        }
        
        for _ in 0...lessonsArray.count {
            for (index,item) in lessonsArray.enumerated() {
                if index != (lessonsArray.count - 1) {
                    let nextItem = lessonsArray[index+1]
                    if item.level == nextItem.level {
                        if item.lessonPosition > nextItem.lessonPosition {
                            let temp = nextItem
                            lessonsArray[index+1] = item
                            lessonsArray[index] = temp
                        }
                    }
                }
            }
        }
    }
    
    
}

extension Date {
    static func ISOStringFromDate(date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        
        return dateFormatter.string(from: date).appending("Z")
    }
    
    static func dateFromISOString(string: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        
        return dateFormatter.date(from: string)
    }
}

extension ViewController {
    class UserInfoView: UIView {
        let titleLabel = UILabel()
        let usernameLevelLabel = UILabel()
        let otherInfoLabel = UILabel()
        
        override init(frame: CGRect) {
            super.init(frame: frame)
            self.backgroundColor = .wkPink
            
            titleLabel.text = "Anki for WaniKani"
            addSubview(titleLabel)
            usernameLevelLabel.text = "ResistantLaw • Level 29"
            addSubview(usernameLevelLabel)
            otherInfoLabel.text = "Started: 389 days ago"
            addSubview(otherInfoLabel)
            
            titleLabel.snp.makeConstraints { (make) in
                make.centerX.equalTo(self)
                make.top.greaterThanOrEqualTo(self).offset(10)
                make.bottom.equalTo(usernameLevelLabel).offset(-30)
            }
            usernameLevelLabel.snp.makeConstraints { (make) in
                make.center.equalTo(self)
            }
            otherInfoLabel.snp.makeConstraints { (make) in
                make.centerX.equalTo(self)
                make.top.equalTo(usernameLevelLabel).offset(30)
                make.bottom.greaterThanOrEqualTo(-10)
            }
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
