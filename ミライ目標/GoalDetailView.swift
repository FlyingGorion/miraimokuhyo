//
//  GoalDetailView.swift
//  ミライ目標
//
//  Created by 石飛真大 on 2026/06/29.
//

import SwiftUI
import Auth

struct GoalDetailView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var goalViewModel: GoalViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss
    
    let goal: Goal
    @State private var showDeleteConfirmation = false
    @State private var showEditGoal = false
    @State private var showAddMilestone = false
    
    private var userId: UUID {
        authViewModel.session?.user.id ?? UUID()
    }
    
    private var goalMilestones: [Milestone] {
        goalViewModel.milestones.filter { $0.goalId == goal.id }
    }
    
    private var incompleteMilestones: [Milestone] {
        goalMilestones
            .filter { !$0.completed }
            .sorted { ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) }
    }
    
    private var completedMilestones: [Milestone] {
        goalMilestones.filter { $0.completed }
    }
    
    private var progress: Double {
        goal.progress(milestones: goalViewModel.milestones)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // ヘッダーカード
                GoalDetailHeaderCard(
                    goal: goal,
                    progress: progress,
                    milestones: goalMilestones,
                    onEdit: { showEditGoal = true }
                )
                .padding(.horizontal)
                .padding(.top, 8)
                
                // なぜこの目標を達成したいのか
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "heart")
                            .font(.title3)
                            .foregroundColor(.purple)
                        Text("なぜこの目標を達成したいのか")
                            .font(.headline)
                    }
                    
                    Text(goal.reason)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                // マイルストーン一覧
                VStack(alignment: .leading, spacing: 16) {
                    HStack(spacing: 8) {
                        Image(systemName: "flag")
                            .font(.title3)
                            .foregroundColor(.purple)
                        Text("マイルストーン")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button {
                            showAddMilestone = true
                        } label: {
                            Text("追加")
                                .font(.headline)
                                .foregroundColor(.purple)
                            Image(systemName: "plus.circle.fill")
                                .font(.title3)
                                .foregroundColor(.purple)
                        }
                    }
                    .padding(.horizontal)
                    
                    if goalMilestones.isEmpty {
                        VStack(spacing: 12) {
                            Text("まだマイルストーンがありません")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Button {
                                showAddMilestone = true
                            } label: {
                                HStack {
                                    Image(systemName: "plus.circle.fill")
                                    Text("マイルストーンを追加")
                                }
                                .foregroundColor(.purple)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 32)
                    } else {
                        VStack(spacing: 0) {
                            // すべてのマイルストーンを順番に表示
                            ForEach(Array(goalMilestones.sorted { 
                                ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) 
                            }.enumerated()), id: \.element.id) { index, milestone in
                                GoalDetailMilestoneRow(
                                    milestone: milestone,
                                    index: index + 1,
                                    onToggle: {
                                        Task {
                                            await goalViewModel.toggleMilestone(milestone: milestone)
                                        }
                                    }
                                )
                                
                                if index < goalMilestones.count - 1 {
                                    Divider()
                                        .padding(.leading, 56)
                                }
                            }
                        }
                        .background(Color(uiColor: .secondarySystemBackground))
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                }
                
                // 削除ボタン
                Button(role: .destructive) {
                    showDeleteConfirmation = true
                } label: {
                    Text("目標を削除")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .foregroundColor(.red)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.top, 18)
            }
            .padding(.vertical)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("目標の詳細")
        .navigationBarTitleDisplayMode(.inline)
        .confirmationDialog("この目標を削除しますか?\n関連するマイルストーンも削除されます。", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("削除", role: .destructive) {
                Task {
                    await goalViewModel.deleteGoal(goalId: goal.id)
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showEditGoal) {
            GoalEditView(goal: goal)
        }
        .sheet(isPresented: $showAddMilestone) {
            MilestoneCreateView(goalId: goal.id)
        }
    }
}

// ヘッダーカード
struct GoalDetailHeaderCard: View {
    let goal: Goal
    let progress: Double
    let milestones: [Milestone]
    let onEdit: () -> Void
    
    private var completedMilestones: Int {
        milestones.filter { $0.completed }.count
    }
    
    private var nextMilestone: Milestone? {
        milestones
            .filter { !$0.completed }
            .sorted { ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) }
            .first
    }
    
    private var nextDeadline: Date? {
        milestones
            .filter { !$0.completed }
            .compactMap { $0.dueDate }
            .min()
    }
    
    private var progressColor: Color {
        if progress >= 75 {
            return .green
        } else if progress >= 50 {
            return .blue
        } else if progress >= 25 {
            return .orange
        } else {
            return .purple
        }
    }
    
    // 日付フォーマッター
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            GeometryReader { geometry in
                VStack {
                    Image("goal_detail_background")
                        .resizable()
                        .frame(maxWidth: .infinity)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                }
                .frame(width: geometry.size.width, height: geometry.size.height)
            }
            
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .top, spacing: 16) {
                    // 円形プログレス
                    ZStack {
                        Circle()
                            .fill(Color.white)
                            .frame(width: 100, height: 100)
                        
                        Circle()
                            .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                            .frame(width: 90, height: 90)
                        
                        Circle()
                            .trim(from: 0, to: progress / 100)
                            .stroke(progressColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                            .frame(width: 90, height: 90)
                            .rotationEffect(.degrees(-90))
                        
                        VStack(spacing: 2) {
                            Text("\(Int(progress))%")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(progressColor)
                            Text("進捗")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // 目標情報
                    VStack(alignment: .leading, spacing: 8) {
                        // ステータスバッジ
                        Text(goal.status == .completed ? "達成済み" : "進行中")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(goal.status == .completed ? .green : .purple)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 4)
                            .background(
                                (goal.status == .completed ? Color.green : Color.purple).opacity(0.15)
                            )
                            .cornerRadius(12)
                        
                        Text(goal.title)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.primary)
                        
                        Text("理由：\(goal.reason)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .lineLimit(2)
                        
                        if let next = nextMilestone {
                            HStack(spacing: 4) {
                                Text("次の一歩：\(next.title)")
                                    .font(.caption)
                                    .foregroundColor(.blue)
                                    .lineLimit(1)
                            }
                        }
                    }
                    
                    Spacer()
                }
                
                // 下部情報
                HStack(spacing: 24) {
                    // マイルストーン数
                    HStack(spacing: 6) {
                        Image(systemName: "flag")
                            .font(.caption)
                        Text("マイルストーン：\(completedMilestones)/\(milestones.count)")
                            .font(.caption)
                    }
                    .foregroundColor(.secondary)
                    
                    // 目標の期限
                    if let goalDueDate = goal.dueDate {
                        HStack(spacing: 6) {
                            Image(systemName: "calendar.badge.clock")
                                .font(.caption)
                            Text("目標期限：\(goalDueDate, formatter: Self.dateFormatter)")
                                .font(.caption)
                        }
                        .foregroundColor(.orange)
                    }
                    Spacer()
                }
            }
            .padding()
            
            // 編集ボタン
            Button {
                onEdit()
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "pencil")
                        .font(.caption)
                    Text("編集")
                        .font(.caption)
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white)
                .cornerRadius(16)
            }
            .padding()
        }
        .frame(height: 280)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// マイルストーン行
struct GoalDetailMilestoneRow: View {
    let milestone: Milestone
    let index: Int
    let onToggle: () -> Void
    @State private var showEditMilestone = false
    
    private var statusText: String {
        if milestone.completed {
            return "完了"
        } else {
            return "進行中"
        }
    }
    
    private var statusColor: Color {
        if milestone.completed {
            return .green
        } else {
            return .purple
        }
    }
    
    // 日付フォーマッター
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    var body: some View {
        Button {
            showEditMilestone = true
        } label: {
            HStack(spacing: 12) {
                // 番号またはチェックマーク
                Button {
                    onToggle()
                } label: {
                    ZStack {
                        Circle()
                            .fill(milestone.completed ? Color.purple : Color.purple.opacity(0.1))
                            .frame(width: 32, height: 32)
                        
                        if milestone.completed {
                            Image(systemName: "checkmark")
                                .font(.caption)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                        } else {
                            Text("\(index)")
                                .font(.caption)
                                .fontWeight(.semibold)
                                .foregroundColor(.purple)
                        }
                    }
                }
                .buttonStyle(.plain)
                
                // タイトル
                Text(milestone.title)
                    .font(.body)
                    .foregroundColor(.primary)
                    .strikethrough(milestone.completed)
                
                Spacer()
                
                // 期限とステータス
                VStack(alignment: .trailing, spacing: 4) {
                    if let dueDate = milestone.dueDate {
                        Text("目標日：\(dueDate, formatter: Self.dateFormatter)")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    
                    Text(statusText)
                        .font(.caption)
                        .foregroundColor(statusColor)
                }
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color.clear)
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showEditMilestone) {
            MilestoneEditView(milestone: milestone)
        }
    }
}

// マイルストーン編集ビュー
struct MilestoneEditView: View {
    @EnvironmentObject var goalViewModel: GoalViewModel
    @Environment(\.dismiss) var dismiss
    
    let milestone: Milestone
    @State private var title: String
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    
    init(milestone: Milestone) {
        self.milestone = milestone
        _title = State(initialValue: milestone.title)
        _hasDueDate = State(initialValue: milestone.dueDate != nil)
        _dueDate = State(initialValue: milestone.dueDate ?? Date())
    }
    
    private var canSave: Bool {
        !title.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("マイルストーン") {
                    TextField("マイルストーン名", text: $title)
                }
                
                Section {
                    Toggle("期限を設定", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("期限", selection: $dueDate, displayedComponents: .date)
                    }
                }
            }
            .navigationTitle("マイルストーンを編集")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("保存") {
                        Task {
                            await goalViewModel.updateMilestone(
                                milestoneId: milestone.id,
                                title: title,
                                dueDate: hasDueDate ? dueDate : nil
                            )
                            dismiss()
                        }
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        GoalDetailView(goal: Goal(
            id: UUID(),
            userId: UUID(),
            title: "サンプル目標",
            reason: "成長するため",
            status: .inProgress,
            createdAt: Date(),
            updatedAt: Date()
        ))
        .environmentObject(AuthViewModel())
        .environmentObject(GoalViewModel())
        .environmentObject(SettingsViewModel())
    }
}
