//
//  Assignment.swift
//  Ganbatte
//
//  Created by Austin Whitelaw on 4/1/20.
//  Copyright © 2020 Austin Whitelaw. All rights reserved.
//

import Foundation

struct Assignment: Codable {
    var id: Int
    var object: String
    var url: String
    var dataUpdatedAt: String
    var data: AssignmentData
    
    init() {
        self.id = 0
        self.object = ""
        self.url = ""
        self.dataUpdatedAt = ""
        self.data = AssignmentData()
    }
}

struct AssignmentData: Codable {
    var createdAt: String
    var subjectId: Int
    var subjectType: String
    var srsStage: Int
    var srsStageName: String
    var unlockedAt: String?
    var startedAt: String?
    var passedAt: String?
    var burnedAt: String?
    var availableAt: String?
    var passed: Bool
    var resurrectedAt: String?
    
    init() {
        self.createdAt = ""
        self.subjectId = 0
        self.subjectType = ""
        self.srsStage = 0
        self.srsStageName = ""
        self.unlockedAt = ""
        self.startedAt = ""
        self.passedAt = ""
        self.burnedAt = ""
        self.availableAt = ""
        self.passed = false
        self.resurrectedAt = ""
    }
}
