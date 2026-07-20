//
//  GoalCard.swift
//  ミライ目標
//
//  Created by 石飛真大 on 2026/06/29.
//

import SwiftUI

struct GoalCard: View {
    let goal: Goal
    let milestones: [Milestone]
    
    private var progress: Double {
        goal.progress(milestones: milestones)
    }
    
    private var nextDueDate: Date? {
        milestones
            .filter { $0.goalId == goal.id && !$0.completed }
            .compactMap { $0.dueDate }
            .min()
    }
    
    // 日付フォーマッター
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(goal.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            Text(goal.reason)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(2)
            
            ProgressBar(progress: progress)
            
            if let dueDate = nextDueDate {
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                    Text("次の期限: \(dueDate, formatter: Self.dateFormatter)")
                        .font(.caption)
                }
                .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    GoalCard(
        goal: Goal(
            id: UUID(),
            userId: UUID(),
            title: "健康的な生活を送る",
            reason: "長く元気でいたいから",
            status: .inProgress,
            createdAt: Date(),
            updatedAt: Date()
        ),
        milestones: [
            Milestone(
                id: UUID(),
                userId: UUID(),
                goalId: UUID(),
                title: "毎日運動する",
                completed: true,
                dueDate: Date(),
                createdAt: Date(),
                updatedAt: Date()
            )
        ]
    )
    .padding()
}
