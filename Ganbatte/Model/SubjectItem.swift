//
//  SubjectItem.swift
//  Ganbatte
//
//  Created by Austin Whitelaw on 8/11/19.
//  Copyright © 2019 Austin Whitelaw. All rights reserved.
//

import Foundation

protocol SubjectItem {
    
    var id: Int {get}
    var object: SubjectItemType {get}
    var url: String {get}
    var dataUpdatedAt: String {get}
    
    var assignmentId: Int {get set}
    var auxiliaryMeanings: [AnyObject] {get}
    var characters: String {get}
    var createdAt: String {get}
    var documentUrl: String {get}
    var hiddenAt: String {get}
    var lessonPosition: Int {get}
    var level: Int {get}
    var meaningMnemonic: String {get}
    var meanings: [[String: Any]] {get}
    var slug: String {get}
    
    var meaningCompleted: Bool {get set}
    var readingCompleted: Bool {get set}
    var incorrectMeaning: Int {get set}
    var incorrectReading: Int {get set}
    
    
}

class SubjectItem2: Codable {
    var assignment: Assignment
    var id: Int
    var object: String
    var url: String
    var dataUpdatedAt: String
    var data: SubjectData3
    
    var meaningCompleted: Bool
    var readingCompleted: Bool
    var incorrectMeaning: Int
    var incorrectReading: Int
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.assignment = try container.decodeIfPresent(Assignment.self, forKey: .assignment) ?? Assignment()
        self.id = try container.decodeIfPresent(Int.self, forKey: .id) ?? 0
        self.object = try container.decodeIfPresent(String.self, forKey: .object) ?? "none"
        self.url = try container.decodeIfPresent(String.self, forKey: .object) ?? ""
        self.dataUpdatedAt = try container.decodeIfPresent(String.self, forKey: .object) ?? ""
        self.data = try (container.decodeIfPresent(SubjectData3.self, forKey: .data) ?? nil)!
        self.meaningCompleted = try container.decodeIfPresent(Bool.self, forKey: .meaningCompleted) ?? false
        self.readingCompleted = try container.decodeIfPresent(Bool.self, forKey: .readingCompleted) ?? false
        self.incorrectMeaning = try container.decodeIfPresent(Int.self, forKey: .incorrectMeaning) ?? 0
        self.incorrectReading = try container.decodeIfPresent(Int.self, forKey: .incorrectReading) ?? 0
    }
}

class SubjectData3: Codable {
    var auxiliaryMeanings: [[String: String]]
    var characters: String?
    var createdAt: String
    var documentUrl: String
    var hiddenAt: String?
    var lessonPosition: Int
    var level: Int
    var meanings: [Meaning]
    var meaningMnemonic: String
    var slug: String
    var amalgamationSubjectIds: [Int]?
    var characterImages: [CharacterImagesData]?
    var componentSubjectIds: [Int]?
    var meaningHint: String?
    var readings: [Reading]?
    var readingMnemonic: String?
    var readingHint: String?
    var visuallySimilarSubjectIds: [Int]?
    var contextSentences: [ContextSentence]?
    var partsOfSpeech: [String]?
    var pronunciationAudios: [PronunciationAudio]?
}

struct Meaning: Codable {
    var meaning: String
    var primary: Bool
    var acceptedAnswer: Bool
}

struct Reading: Codable {
    var type: String?
    var primary: Bool
    var acceptedAnswer: Bool
    var reading: String
}

struct CharacterImagesData: Codable {
    var url: String
    var metadata: CharacterImageMetaData
    var contentType: String
}

struct CharacterImageMetaData: Codable {
    var styleName: String?
    var color: String?
    var dimensions: String?
    var inlineStyles: Bool?
}

struct ContextSentence: Codable {
    var en: String
    var ja: String
}

struct PronunciationAudio: Codable {
    var url: String
    var metadata: PronounciationAudioMetaData
    var content_type: String?
}

struct PronounciationAudioMetaData: Codable {
    var gender: String
    var sourceId: Int
    var pronounciation: String?
    var voiceActorId: Int
    var voiceActorName: String
    var voiceDescription: String
}
