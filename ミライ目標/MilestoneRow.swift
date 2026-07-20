//
//  MilestoneRow.swift
//  ミライ目標
//
//  Created by 石飛真大 on 2026/06/29.
//

import SwiftUI

struct MilestoneRow: View {
    let milestone: Milestone
    let showGoalName: Bool
    let goals: [Goal]
    let onToggle: () -> Void
    
    private var goalName: String? {
        guard showGoalName else { return nil }
        return goals.first(where: { $0.id == milestone.goalId })?.title
    }
    
    private var isOverdue: Bool {
        guard let dueDate = milestone.dueDate, !milestone.completed else { return false }
        return dueDate < Date()
    }
    
    // 日付フォーマッター
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Button {
                onToggle()
            } label: {
                Image(systemName: milestone.completed ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(milestone.completed ? .green : .gray)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(milestone.title)
                    .font(.body)
                    .foregroundColor(milestone.completed ? .secondary : .primary)
                    .strikethrough(milestone.completed)
                
                if let goalName = goalName {
                    Text(goalName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                if let dueDate = milestone.dueDate {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.caption2)
                        Text(dueDate, formatter: Self.dateFormatter)
                            .font(.caption)
                    }
                    .foregroundColor(isOverdue ? .red : .secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(10)
    }
}

#Preview {
    VStack(spacing: 12) {
        MilestoneRow(
            milestone: Milestone(
                id: UUID(),
                userId: UUID(),
                goalId: UUID(),
                title: "毎日運動する",
                completed: false,
                dueDate: Date().addingTimeInterval(86400 * 7),
                createdAt: Date(),
                updatedAt: Date()
            ),
            showGoalName: true,
            goals: [
                Goal(
                    id: UUID(),
                    userId: UUID(),
                    title: "健康になる",
                    reason: "長生きしたい",
                    status: .inProgress,
                    createdAt: Date(),
                    updatedAt: Date()
                )
            ],
            onToggle: {}
        )
        
        MilestoneRow(
            milestone: Milestone(
                id: UUID(),
                userId: UUID(),
                goalId: UUID(),
                title: "本を読む",
                completed: true,
                dueDate: nil,
                createdAt: Date(),
                updatedAt: Date()
            ),
            showGoalName: false,
            goals: [],
            onToggle: {}
        )
    }
    .padding()
}
