//
//  Models.swift
//  ミライ目標
//
//  Created by 石飛真大 on 2026/06/29.
//

import Foundation

// MARK: - Enums

enum GoalSortType: String, Codable {
    case nearestDueDate = "nearest_due_date"
    case progressLow = "progress_low"
    case progressHigh = "progress_high"
    case createdNew = "created_new"
    case createdOld = "created_old"
    
    var displayName: String {
        switch self {
        case .nearestDueDate:
            return "期限が近い順"
        case .progressLow:
            return "進捗が低い順"
        case .progressHigh:
            return "進捗が高い順"
        case .createdNew:
            return "作成日が新しい順"
        case .createdOld:
            return "作成日が古い順"
        }
    }
}

enum GoalStatus: String, Codable {
    case inProgress = "in_progress"
    case completed = "completed"
}

// MARK: - Models

struct AppSettings: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    var desiredSelf: String
    var goalSortType: GoalSortType
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case desiredSelf = "desired_self"
        case goalSortType = "goal_sort_type"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        userId = try container.decode(UUID.self, forKey: .userId)
        desiredSelf = try container.decode(String.self, forKey: .desiredSelf)
        goalSortType = try container.decode(GoalSortType.self, forKey: .goalSortType)
        
        // ISO8601形式の日付をデコード
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let createdAtString = try? container.decode(String.self, forKey: .createdAt),
           let date = iso8601Formatter.date(from: createdAtString) {
            createdAt = date
        } else {
            createdAt = try container.decode(Date.self, forKey: .createdAt)
        }
        
        if let updatedAtString = try? container.decode(String.self, forKey: .updatedAt),
           let date = iso8601Formatter.date(from: updatedAtString) {
            updatedAt = date
        } else {
            updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        }
    }
}

struct Goal: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    var title: String
    var reason: String
    var status: GoalStatus
    var dueDate: Date?
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case title
        case reason
        case status
        case dueDate = "due_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // 通常のイニシャライザ（Previewやテスト用）
    init(id: UUID, userId: UUID, title: String, reason: String, status: GoalStatus, dueDate: Date? = nil, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.userId = userId
        self.title = title
        self.reason = reason
        self.status = status
        self.dueDate = dueDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        userId = try container.decode(UUID.self, forKey: .userId)
        title = try container.decode(String.self, forKey: .title)
        reason = try container.decode(String.self, forKey: .reason)
        status = try container.decode(GoalStatus.self, forKey: .status)
        
        // due_dateのカスタムデコーディング（yyyy-MM-dd形式）
        if let dueDateString = try container.decodeIfPresent(String.self, forKey: .dueDate) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            dueDate = formatter.date(from: dueDateString)
        } else {
            dueDate = nil
        }
        
        // ISO8601形式の日付をデコード
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let createdAtString = try? container.decode(String.self, forKey: .createdAt),
           let date = iso8601Formatter.date(from: createdAtString) {
            createdAt = date
        } else {
            createdAt = try container.decode(Date.self, forKey: .createdAt)
        }
        
        if let updatedAtString = try? container.decode(String.self, forKey: .updatedAt),
           let date = iso8601Formatter.date(from: updatedAtString) {
            updatedAt = date
        } else {
            updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        }
    }
}

struct Milestone: Identifiable, Codable {
    let id: UUID
    let userId: UUID
    let goalId: UUID
    var title: String
    var completed: Bool
    var dueDate: Date?
    let createdAt: Date
    var updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case goalId = "goal_id"
        case title
        case completed
        case dueDate = "due_date"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    // 通常のイニシャライザ（Previewやテスト用）
    init(id: UUID, userId: UUID, goalId: UUID, title: String, completed: Bool, dueDate: Date?, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.userId = userId
        self.goalId = goalId
        self.title = title
        self.completed = completed
        self.dueDate = dueDate
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        userId = try container.decode(UUID.self, forKey: .userId)
        goalId = try container.decode(UUID.self, forKey: .goalId)
        title = try container.decode(String.self, forKey: .title)
        completed = try container.decode(Bool.self, forKey: .completed)
        
        // due_dateのカスタムデコーディング（yyyy-MM-dd形式）
        if let dueDateString = try container.decodeIfPresent(String.self, forKey: .dueDate) {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            dueDate = formatter.date(from: dueDateString)
        } else {
            dueDate = nil
        }
        
        // ISO8601形式の日付をデコード
        let iso8601Formatter = ISO8601DateFormatter()
        iso8601Formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let createdAtString = try? container.decode(String.self, forKey: .createdAt),
           let date = iso8601Formatter.date(from: createdAtString) {
            createdAt = date
        } else {
            createdAt = try container.decode(Date.self, forKey: .createdAt)
        }
        
        if let updatedAtString = try? container.decode(String.self, forKey: .updatedAt),
           let date = iso8601Formatter.date(from: updatedAtString) {
            updatedAt = date
        } else {
            updatedAt = try container.decode(Date.self, forKey: .updatedAt)
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(userId, forKey: .userId)
        try container.encode(goalId, forKey: .goalId)
        try container.encode(title, forKey: .title)
        try container.encode(completed, forKey: .completed)
        
        // due_dateのカスタムエンコーディング（yyyy-MM-dd形式）
        if let dueDate = dueDate {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            try container.encode(formatter.string(from: dueDate), forKey: .dueDate)
        } else {
            try container.encodeNil(forKey: .dueDate)
        }
        
        try container.encode(createdAt, forKey: .createdAt)
        try container.encode(updatedAt, forKey: .updatedAt)
    }
}

// MARK: - Helper Extensions

extension Goal {
    func progress(milestones: [Milestone]) -> Double {
        let goalMilestones = milestones.filter { $0.goalId == self.id }
        guard !goalMilestones.isEmpty else { return 0.0 }
        let completedCount = goalMilestones.filter { $0.completed }.count
        return Double(completedCount) / Double(goalMilestones.count) * 100
    }
}
