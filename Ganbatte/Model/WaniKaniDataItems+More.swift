//
//  WaniKaniDataItems+More.swift
//  Ganbatte
//
//  Created by Austin Whitelaw on 8/22/19.
//  Copyright © 2019 Austin Whitelaw. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

struct WKConstants {
    static let headers: HTTPHeaders = [
        "Wanikani-Revision": "20170710",
        "Authorization": "Bearer ac5f60fc-ec37-4cef-981a-a3fcb75ff2e1"
    ]
}

struct AppSettings {
    static var lessonSize = 5
}

enum SubjectItemType: String {
    case radical
    case kanji
    case vocabulary
}

class CharacterImage {
    let url: String
    let contentType: String
    let metadata: AnyObject
    
    init(url: String, contentType: String, metadata: AnyObject) {
        self.url = url
        self.contentType = contentType
        self.metadata = metadata
    }
}

class PronounciationAudio {
    let url: String
    let	contentType: String
    let metadata: [String: Any]
    
    init(url: String, contentType: String, metadata: [String: Any]) {
        self.url = url
        self.contentType = contentType
        self.metadata = metadata
    }
}

struct AllSubjects: Codable {
    var object: String
    var url: String
    var pages: Pages
    var totalCount: Int
    var dataUpdatedAt: String
    var data: [SubjectItem2]
}

struct AllAssignments: Codable {
    var object: String
    var url: String
    var pages: Pages
    var totalCount: Int
    var dataUpdatedAt: String
    var data: [Assignment]
}

struct Pages: Codable {
    var perPage: Int
    var nextUrl: String?
    var prevUrl: String?
}

extension UIColor {
    static var wkBlue: UIColor {return UIColor(red: 0/255, green: 162/255, blue: 244/255, alpha: 1.0)}
    static var wkPink: UIColor {return UIColor(red: 247/255, green: 0, blue: 164/255, alpha: 1.0)}
    static var wkPurple: UIColor {return UIColor(red: 168/255, green: 0, blue: 253/255, alpha: 1.0)}
    static var wkGreen: UIColor {return UIColor(red: 147/255, green: 232/255, blue: 164/255, alpha: 1.0)}
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

func presentAlert(target: UIViewController, title: String, message: String, defaultAction: String, alternateAction: String) {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    alert.addAction(UIAlertAction(title: defaultAction, style: .default, handler: nil))
    alert.addAction(UIAlertAction(title: alternateAction, style: .cancel, handler: nil))
    target.present(alert, animated: true)
}
