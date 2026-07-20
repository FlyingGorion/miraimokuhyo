//
//  HomeView.swift
//  ミライ目標
//
//  Created by 石飛真大 on 2026/06/29.
//

import SwiftUI
import Auth

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var goalViewModel: GoalViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var showGoalCreate = false
    @Binding var selectedTab: Int
    
    private var userId: UUID {
        authViewModel.session?.user.id ?? UUID()
    }
    
    private var upcomingMilestones: [Milestone] {
        goalViewModel.milestones
            .filter { !$0.completed && $0.dueDate != nil }
            .sorted { ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) }
            .prefix(3)
            .map { $0 }
    }
    
    private var sortedGoals: [Goal] {
        let sortType = settingsViewModel.appSettings?.goalSortType ?? .nearestDueDate
        return goalViewModel.sortedGoals(by: sortType)
            .filter { $0.status == .inProgress }
            .prefix(3)
            .map { $0 }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // なりたい自分カード（大きな背景画像付き）
                        if let desiredSelf = settingsViewModel.appSettings?.desiredSelf {
                            HeroDesiredSelfCard(desiredSelf: desiredSelf)
                                .padding(.horizontal)
                        }
                        
                        // 進行中の目標
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Image(systemName: "chart.line.uptrend.xyaxis")
                                    .font(.title3)
                                Text("進行中の目標")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                Spacer()
                                Button {
                                    selectedTab = 1  // 目標タブに切り替え
                                } label: {
                                    Text("すべて見る")
                                        .font(.subheadline)
                                        .foregroundColor(.blue)
                                }
                            }
                            .padding(.horizontal)
                            
                            if !sortedGoals.isEmpty {
                                VStack(spacing: 16) {
                                    ForEach(sortedGoals) { goal in
                                        NavigationLink(destination: GoalDetailView(goal: goal)) {
                                            ProgressGoalCard(goal: goal, milestones: goalViewModel.milestones)
                                        }
                                        .buttonStyle(.plain)
                                        .padding(.horizontal)
                                    }
                                }
                            } else {
                                VStack(spacing: 12) {
                                    Text("まだ目標がありません")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                    Text("なりたい自分に近づくための目標を作成しましょう")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 32)
                            }
                        }
                        
                        // 次のマイルストーン
                        if !upcomingMilestones.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    Image(systemName: "target")
                                        .font(.title3)
                                    Text("次のマイルストーン")
                                        .font(.title3)
                                        .fontWeight(.semibold)
                                    Spacer()
                                    .font(.subheadline)
                                    .foregroundColor(.blue)
                                }
                                .padding(.horizontal)
                                
                                VStack(spacing: 12) {
                                    ForEach(upcomingMilestones) { milestone in
                                        if let goal = goalViewModel.goals.first(where: { $0.id == milestone.goalId }) {
                                            NavigationLink(destination: GoalDetailView(goal: goal)) {
                                                MilestoneCheckboxRow(
                                                    milestone: milestone,
                                                    goals: goalViewModel.goals
                                                ) {
                                                    Task {
                                                        await goalViewModel.toggleMilestone(milestone: milestone)
                                                    }
                                                }
                                            }
                                            .buttonStyle(.plain)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        // 新しい目標を追加ボタン
                        Button {
                            showGoalCreate = true
                        } label: {
                            HStack {
                                Image(systemName: "plus")
                                Text("新しい目標を追加")
                            }
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.blue, lineWidth: 2)
                            )
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                    }
                    .padding(.top, 8)
                }
            }
            .sheet(isPresented: $showGoalCreate) {
                GoalCreateView()
            }
            .task {
                await settingsViewModel.fetchSettings(userId: userId)
                await goalViewModel.fetchGoals(userId: userId)
                await goalViewModel.fetchMilestones(userId: userId)
            }
        }
    }
    
    private func dateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日（E）"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: Date())
    }
}

// 大きな背景画像付きのなりたい自分カード
struct HeroDesiredSelfCard: View {
    let desiredSelf: String
    
    var body: some View {
        ZStack(alignment: .bottomLeading) {
            
            // 背景画像
            GeometryReader { geometry in
                Image("MyIdealSelf_background")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
                
            }
            .frame(height: 240)
            .cornerRadius(20)
            
            // コンテンツ
            VStack(alignment: .leading, spacing: 12) {
                Text("なりたい自分")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Color.purple)
                    .cornerRadius(8)
                
                GeometryReader { geometry in
                    Text(desiredSelf)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                        .lineSpacing(6)
                        .frame(width: geometry.size.width * 0.8)
                }
            }
            .padding(20)
        }
        .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: 4)
    }
}

// チェックボックス付きマイルストーン行
struct MilestoneCheckboxRow: View {
    let milestone: Milestone
    let goals: [Goal]
    let onToggle: () -> Void
    
    private var goalName: String? {
        goals.first(where: { $0.id == milestone.goalId })?.title
    }
    
    // 日付フォーマッター
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    var body: some View {
        HStack(spacing: 16) {
            // チェックボックス
            Button {
                onToggle()
            } label: {
                Image(systemName: milestone.completed ? "checkmark.square.fill" : "square")
                    .font(.title2)
                    .foregroundColor(milestone.completed ? .green : .gray)
            }
            
            // テキスト
            VStack(alignment: .leading, spacing: 6) {
                Text(milestone.title)
                    .font(.body)
                    .foregroundColor(milestone.completed ? .secondary : .primary)
                    .strikethrough(milestone.completed)
                
                // 目標名と期限
                HStack(spacing: 8) {
                    if let goalName = goalName {
                        HStack(spacing: 4) {
                            Image(systemName: "target")
                                .font(.caption2)
                            Text(goalName)
                                .font(.caption2)
                        }
                        .foregroundColor(.secondary)
                    }
                    
                    if let dueDate = milestone.dueDate {
                        HStack(spacing: 4) {
                            Image(systemName: "calendar")
                                .font(.caption2)
                            Text(dueDate, formatter: Self.dateFormatter)
                                .font(.caption2)
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
            
            Spacer()
            
            // 矢印アイコン
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.gray.opacity(0.5))
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
}

// 進捗率付き目標カード
struct ProgressGoalCard: View {
    let goal: Goal
    let milestones: [Milestone]
    
    private var progress: Double {
        goal.progress(milestones: milestones)
    }
    
    private var nextMilestone: Milestone? {
        milestones
            .filter { $0.goalId == goal.id && !$0.completed }
            .sorted { ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) }
            .first
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
        HStack(spacing: 16) {
            // 円形プログレス
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                    .frame(width: 70, height: 70)
                
                Circle()
                    .trim(from: 0, to: progress / 100)
                    .stroke(progressColor, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(-90))
                
                Text("\(Int(progress))%")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(progressColor)
            }
            
            // テキスト情報
            VStack(alignment: .leading, spacing: 6) {
                Text(goal.title)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text("理由：\(goal.reason)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                
                // 目標の期限を表示
                if let goalDueDate = goal.dueDate {
                    HStack(spacing: 4) {
                        Image(systemName: "calendar.badge.clock")
                            .font(.caption2)
                        Text("目標期限：\(goalDueDate, formatter: Self.dateFormatter)")
                            .font(.caption2)
                    }
                    .foregroundColor(.orange)
                }
                
                if let next = nextMilestone {
                    Text("次の一歩：\(next.title)")
                        .font(.caption)
                        .foregroundColor(.blue)
                        .lineLimit(1)
                } else {
                    Text("次の一歩：なし")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // 矢印
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(12)
    }
}

#Preview {
    @Previewable @State var selectedTab = 0
    HomeView(selectedTab: $selectedTab)
        .environmentObject(AuthViewModel())
        .environmentObject(GoalViewModel())
        .environmentObject(SettingsViewModel())
}
