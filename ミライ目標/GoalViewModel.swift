//
//  GoalViewModel.swift
//  ミライ目標
//
//  Created by 石飛真大 on 2026/06/29.
//

import Foundation
import SwiftUI
import Combine
import Supabase
import PostgREST

@MainActor
class GoalViewModel: ObservableObject {
    @Published var goals: [Goal] = []
    @Published var milestones: [Milestone] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseManager.shared.client
    private let maxGoalsPerUser = 10
    private let maxMilestonesPerGoal = 30
    
    func fetchGoals(userId: UUID) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // キャンセルチェック
            try Task.checkCancellation()
            
            let fetchedGoals: [Goal] = try await supabase.database
                .from("goals")
                .select()
                .eq("user_id", value: userId.uuidString)
                .execute()
                .value
            
            // キャンセルチェック
            try Task.checkCancellation()
            
            goals = fetchedGoals
            
            print("✅ [GOAL] FetchGoals succeeded - Count: \(goals.count)")
        } catch is CancellationError {
            // キャンセルエラーは無視（通常の動作）
            print("ℹ️ [GOAL] FetchGoals cancelled (normal behavior)")
        } catch {
            // コンソールに詳細なエラーログを出力
            print("❌ [GOAL] FetchGoals failed")
            print("   UserID: \(userId)")
            print("   Error: \(error)")
            print("   LocalizedDescription: \(error.localizedDescription)")
            
            errorMessage = "通信に失敗しました。時間をおいて再度お試しください。"
        }
    }
    
    func fetchMilestones(userId: UUID) async {
        do {
            // キャンセルチェック
            try Task.checkCancellation()
            
            let fetchedMilestones: [Milestone] = try await supabase.database
                .from("milestones")
                .select()
                .eq("user_id", value: userId.uuidString)
                .execute()
                .value
            
            // キャンセルチェック
            try Task.checkCancellation()
            
            milestones = fetchedMilestones
            
            print("✅ [MILESTONE] FetchMilestones succeeded - Count: \(milestones.count)")
        } catch is CancellationError {
            // キャンセルエラーは無視（通常の動作）
            print("ℹ️ [MILESTONE] FetchMilestones cancelled (normal behavior)")
        } catch {
            // コンソールに詳細なエラーログを出力
            print("❌ [MILESTONE] FetchMilestones failed")
            print("   UserID: \(userId)")
            print("   Error: \(error)")
            print("   LocalizedDescription: \(error.localizedDescription)")
            
            errorMessage = "通信に失敗しました。時間をおいて再度お試しください。"
        }
    }
    
    func createGoal(userId: UUID, title: String, reason: String, dueDate: Date?, milestoneName: String?, milestoneDueDate: Date?) async -> Goal? {
        // 目標数チェック
        if goals.count >= maxGoalsPerUser {
            errorMessage = "作成できる目標は10件までです。"
            return nil
        }
        
        do {
            if let dueDate = dueDate {
                struct NewGoalWithDate: Encodable {
                    let user_id: String
                    let title: String
                    let reason: String
                    let status: String
                    let due_date: String
                }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                let newGoal = NewGoalWithDate(
                    user_id: userId.uuidString,
                    title: title,
                    reason: reason,
                    status: "in_progress",
                    due_date: formatter.string(from: dueDate)
                )
                
                let createdGoal: Goal = try await supabase.database
                    .from("goals")
                    .insert(newGoal)
                    .select()
                    .single()
                    .execute()
                    .value
                
                goals.append(createdGoal)
                
                // マイルストーンがあれば作成
                if let milestoneName = milestoneName, !milestoneName.isEmpty {
                    await createMilestone(userId: userId, goalId: createdGoal.id, title: milestoneName, dueDate: milestoneDueDate)
                }
                
                return createdGoal
            } else {
                struct NewGoal: Encodable {
                    let user_id: String
                    let title: String
                    let reason: String
                    let status: String
                }
                
                let newGoal = NewGoal(
                    user_id: userId.uuidString,
                    title: title,
                    reason: reason,
                    status: "in_progress"
                )
                
                let createdGoal: Goal = try await supabase.database
                    .from("goals")
                    .insert(newGoal)
                    .select()
                    .single()
                    .execute()
                    .value
                
                goals.append(createdGoal)
                
                // マイルストーンがあれば作成
                if let milestoneName = milestoneName, !milestoneName.isEmpty {
                    await createMilestone(userId: userId, goalId: createdGoal.id, title: milestoneName, dueDate: milestoneDueDate)
                }
                
                return createdGoal
            }
        } catch {
            // コンソールに詳細なエラーログを出力
            print("❌ [GOAL] CreateGoal failed")
            print("   UserID: \(userId)")
            print("   Error: \(error)")
            print("   LocalizedDescription: \(error.localizedDescription)")
            
            errorMessage = "保存に失敗しました。"
            return nil
        }
    }
    
    func updateGoal(goal: Goal) async {
        do {
            if let dueDate = goal.dueDate {
                struct GoalUpdateWithDate: Encodable {
                    let title: String
                    let reason: String
                    let status: String
                    let due_date: String
                    let updated_at: String
                }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                let updates = GoalUpdateWithDate(
                    title: goal.title,
                    reason: goal.reason,
                    status: goal.status.rawValue,
                    due_date: formatter.string(from: dueDate),
                    updated_at: ISO8601DateFormatter().string(from: Date())
                )
                
                try await supabase.database
                    .from("goals")
                    .update(updates)
                    .eq("id", value: goal.id.uuidString)
                    .execute()
            } else {
                struct GoalUpdate: Encodable {
                    let title: String
                    let reason: String
                    let status: String
                    let due_date: String?
                    let updated_at: String
                }
                
                let updates = GoalUpdate(
                    title: goal.title,
                    reason: goal.reason,
                    status: goal.status.rawValue,
                    due_date: nil,
                    updated_at: ISO8601DateFormatter().string(from: Date())
                )
                
                try await supabase.database
                    .from("goals")
                    .update(updates)
                    .eq("id", value: goal.id.uuidString)
                    .execute()
            }
            
            if let index = goals.firstIndex(where: { $0.id == goal.id }) {
                goals[index] = goal
            }
        } catch {
            // コンソールに詳細なエラーログを出力
            print("❌ [GOAL] UpdateGoal failed")
            print("   GoalID: \(goal.id)")
            print("   Error: \(error)")
            print("   LocalizedDescription: \(error.localizedDescription)")
            
            errorMessage = "保存に失敗しました。"
        }
    }
    
    func deleteGoal(goalId: UUID) async {
        do {
            try await supabase.database
                .from("goals")
                .delete()
                .eq("id", value: goalId.uuidString)
                .execute()
            
            goals.removeAll { $0.id == goalId }
            milestones.removeAll { $0.goalId == goalId }
        } catch {
            // コンソールに詳細なエラーログを出力
            print("❌ [GOAL] DeleteGoal failed")
            print("   GoalID: \(goalId)")
            print("   Error: \(error)")
            print("   LocalizedDescription: \(error.localizedDescription)")
            
            errorMessage = "削除に失敗しました。"
        }
    }
    
    func createMilestone(userId: UUID, goalId: UUID, title: String, dueDate: Date?) async {
        // マイルストーン数チェック
        let goalMilestones = milestones.filter { $0.goalId == goalId }
        if goalMilestones.count >= maxMilestonesPerGoal {
            errorMessage = "作成できるマイルストーンは1つの目標につき30件までです。"
            return
        }
        
        do {
            if let dueDate = dueDate {
                struct NewMilestoneWithDate: Encodable {
                    let user_id: String
                    let goal_id: String
                    let title: String
                    let completed: Bool
                    let due_date: String
                }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                let newMilestone = NewMilestoneWithDate(
                    user_id: userId.uuidString,
                    goal_id: goalId.uuidString,
                    title: title,
                    completed: false,
                    due_date: formatter.string(from: dueDate)
                )
                
                let createdMilestone: Milestone = try await supabase.database
                    .from("milestones")
                    .insert(newMilestone)
                    .select()
                    .single()
                    .execute()
                    .value
                
                milestones.append(createdMilestone)
            } else {
                struct NewMilestone: Encodable {
                    let user_id: String
                    let goal_id: String
                    let title: String
                    let completed: Bool
                }
                
                let newMilestone = NewMilestone(
                    user_id: userId.uuidString,
                    goal_id: goalId.uuidString,
                    title: title,
                    completed: false
                )
                
                let createdMilestone: Milestone = try await supabase.database
                    .from("milestones")
                    .insert(newMilestone)
                    .select()
                    .single()
                    .execute()
                    .value
                
                milestones.append(createdMilestone)
            }
        } catch {
            // コンソールに詳細なエラーログを出力
            print("❌ [MILESTONE] CreateMilestone failed")
            print("   UserID: \(userId)")
            print("   GoalID: \(goalId)")
            print("   Error: \(error)")
            print("   LocalizedDescription: \(error.localizedDescription)")
            
            errorMessage = "保存に失敗しました。"
        }
    }
    
    func updateMilestone(milestoneId: UUID, title: String, dueDate: Date?) async {
        do {
            if let dueDate = dueDate {
                struct MilestoneUpdateWithDate: Encodable {
                    let title: String
                    let due_date: String
                    let updated_at: String
                }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd"
                
                let updates = MilestoneUpdateWithDate(
                    title: title,
                    due_date: formatter.string(from: dueDate),
                    updated_at: ISO8601DateFormatter().string(from: Date())
                )
                
                try await supabase.database
                    .from("milestones")
                    .update(updates)
                    .eq("id", value: milestoneId.uuidString)
                    .execute()
            } else {
                struct MilestoneUpdate: Encodable {
                    let title: String
                    let due_date: String?
                    let updated_at: String
                }
                
                let updates = MilestoneUpdate(
                    title: title,
                    due_date: nil,
                    updated_at: ISO8601DateFormatter().string(from: Date())
                )
                
                try await supabase.database
                    .from("milestones")
                    .update(updates)
                    .eq("id", value: milestoneId.uuidString)
                    .execute()
            }
            
            // ローカルデータも更新
            if let index = milestones.firstIndex(where: { $0.id == milestoneId }) {
                milestones[index].title = title
                milestones[index].dueDate = dueDate
            }
            
            print("✅ [MILESTONE] UpdateMilestone succeeded")
        } catch {
            // コンソールに詳細なエラーログを出力
            print("❌ [MILESTONE] UpdateMilestone failed")
            print("   MilestoneID: \(milestoneId)")
            print("   Error: \(error)")
            print("   LocalizedDescription: \(error.localizedDescription)")
            
            errorMessage = "更新に失敗しました。"
        }
    }
    
    func toggleMilestone(milestone: Milestone) async {
        var updated = milestone
        updated.completed.toggle()
        
        do {
            struct MilestoneUpdate: Encodable {
                let completed: Bool
                let updated_at: String
            }
            
            let updates = MilestoneUpdate(
                completed: updated.completed,
                updated_at: ISO8601DateFormatter().string(from: Date())
            )
            
            try await supabase.database
                .from("milestones")
                .update(updates)
                .eq("id", value: milestone.id.uuidString)
                .execute()
            
            if let index = milestones.firstIndex(where: { $0.id == milestone.id }) {
                milestones[index] = updated
            }
            
            // マイルストーン更新後、目標のステータスをチェック
            await checkAndUpdateGoalStatus(goalId: milestone.goalId)
            
            print("✅ [MILESTONE] ToggleMilestone succeeded")
        } catch {
            // コンソールに詳細なエラーログを出力
            print("❌ [MILESTONE] ToggleMilestone failed")
            print("   MilestoneID: \(milestone.id)")
            print("   Error: \(error)")
            print("   LocalizedDescription: \(error.localizedDescription)")
            
            errorMessage = "更新に失敗しました。"
        }
    }
    
    // 目標のステータスを自動更新
    private func checkAndUpdateGoalStatus(goalId: UUID) async {
        guard let goal = goals.first(where: { $0.id == goalId }) else { return }
        
        let goalMilestones = milestones.filter { $0.goalId == goalId }
        
        // マイルストーンが存在し、すべて完了している場合
        if !goalMilestones.isEmpty {
            let allCompleted = goalMilestones.allSatisfy { $0.completed }
            
            if allCompleted && goal.status != .completed {
                // 目標を達成済みに更新
                var updatedGoal = goal
                updatedGoal.status = .completed
                await updateGoal(goal: updatedGoal)
            } else if !allCompleted && goal.status == .completed {
                // マイルストーンが未完了に戻された場合、進行中に戻す
                var updatedGoal = goal
                updatedGoal.status = .inProgress
                await updateGoal(goal: updatedGoal)
            }
        }
    }
    
    func deleteMilestone(milestoneId: UUID) async {
        do {
            try await supabase.database
                .from("milestones")
                .delete()
                .eq("id", value: milestoneId.uuidString)
                .execute()
            
            milestones.removeAll { $0.id == milestoneId }
            
            print("✅ [MILESTONE] DeleteMilestone succeeded")
        } catch {
            // コンソールに詳細なエラーログを出力
            print("❌ [MILESTONE] DeleteMilestone failed")
            print("   MilestoneID: \(milestoneId)")
            print("   Error: \(error)")
            print("   LocalizedDescription: \(error.localizedDescription)")
            
            errorMessage = "削除に失敗しました。"
        }
    }
    
    func sortedGoals(by sortType: GoalSortType) -> [Goal] {
        switch sortType {
        case .nearestDueDate:
            return goals.sorted { goal1, goal2 in
                let milestones1 = milestones.filter { $0.goalId == goal1.id && !$0.completed }
                let milestones2 = milestones.filter { $0.goalId == goal2.id && !$0.completed }
                
                let date1 = milestones1.compactMap { $0.dueDate }.min()
                let date2 = milestones2.compactMap { $0.dueDate }.min()
                
                if let date1 = date1, let date2 = date2 {
                    return date1 < date2
                } else if date1 != nil {
                    return true
                } else if date2 != nil {
                    return false
                } else {
                    return goal1.createdAt > goal2.createdAt
                }
            }
        case .progressLow:
            return goals.sorted { (goal1: Goal, goal2: Goal) -> Bool in
                return goal1.progress(milestones: milestones) < goal2.progress(milestones: milestones)
            }
        case .progressHigh:
            return goals.sorted { (goal1: Goal, goal2: Goal) -> Bool in
                return goal1.progress(milestones: milestones) > goal2.progress(milestones: milestones)
            }
        case .createdNew:
            return goals.sorted { $0.createdAt > $1.createdAt }
        case .createdOld:
            return goals.sorted { $0.createdAt < $1.createdAt }
        }
    }
}
