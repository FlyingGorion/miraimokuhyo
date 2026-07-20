//
//  GoalsView.swift
//  ミライ目標
//
//  Created by 石飛真大 on 2026/06/29.
//

import SwiftUI
import Auth

struct GoalsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var goalViewModel: GoalViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var showGoalCreate = false
    @State private var selectedTab: GoalTab = .inProgress
    
    private var userId: UUID {
        authViewModel.session?.user.id ?? UUID()
    }
    
    private var filteredGoals: [Goal] {
        let sortType = settingsViewModel.appSettings?.goalSortType ?? .nearestDueDate
        let sorted = goalViewModel.sortedGoals(by: sortType)
        
        switch selectedTab {
        case .inProgress:
            return sorted.filter { $0.status == .inProgress }
        case .completed:
            return sorted.filter { $0.status == .completed }
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(uiColor: .systemGroupedBackground)
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // タブ切り替え
                    HStack(spacing: 0) {
                        ForEach(GoalTab.allCases, id: \.self) { tab in
                            Button {
                                withAnimation {
                                    selectedTab = tab
                                }
                            } label: {
                                VStack(spacing: 8) {
                                    Text(tab.title)
                                        .font(.body)
                                        .fontWeight(selectedTab == tab ? .semibold : .regular)
                                        .foregroundColor(selectedTab == tab ? .blue : .secondary)
                                    
                                    Rectangle()
                                        .fill(selectedTab == tab ? Color.blue : Color.clear)
                                        .frame(height: 2)
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .background(Color(uiColor: .systemBackground))
                    
                    ScrollView {
                        VStack(spacing: 16) {
                            // メッセージカード
                            if selectedTab == .inProgress {
                                HStack(spacing: 12) {
                                    Image(systemName: "star")
                                        .font(.title2)
                                        .foregroundColor(.blue)
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("すべての目標は「なりたい自分」につながっています。")
                                            .font(.body)
                                            .foregroundColor(.primary)
                                        Text("小さな一歩の積み重ねが、未来のあなたをつくります。")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding()
                                .background(Color.blue.opacity(0.08))
                                .cornerRadius(12)
                                .padding(.horizontal)
                                .padding(.top, 16)
                            }
                            
                            // 目標リスト
                            if filteredGoals.isEmpty {
                                VStack(spacing: 16) {
                                    Text("まだ目標がありません")
                                        .font(.body)
                                        .foregroundColor(.secondary)
                                    Text("なりたい自分に近づくための目標を作成しましょう")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                        .multilineTextAlignment(.center)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 64)
                            } else {
                                ForEach(filteredGoals) { goal in
                                    NavigationLink(destination: GoalDetailView(goal: goal)) {
                                        DetailedGoalCard(goal: goal, milestones: goalViewModel.milestones)
                                    }
                                    .buttonStyle(.plain)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top, 8)
                        .padding(.bottom, 8)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showGoalCreate = true
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "plus")
                            Text("新しい目標を追加")
                        }
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.blue, lineWidth: 1.5)
                        )
                        .foregroundColor(.blue)
                    }
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
}

// タブの定義
enum GoalTab: CaseIterable {
    case inProgress
    case completed
    
    var title: String {
        switch self {
        case .inProgress:
            return "進行中"
        case .completed:
            return "達成済み"
        }
    }
}

// 詳細な目標カード
struct DetailedGoalCard: View {
    let goal: Goal
    let milestones: [Milestone]
    
    private var progress: Double {
        goal.progress(milestones: milestones)
    }
    
    private var goalMilestones: [Milestone] {
        milestones.filter { $0.goalId == goal.id }
    }
    
    private var completedMilestones: Int {
        goalMilestones.filter { $0.completed }.count
    }
    
    private var nextMilestone: Milestone? {
        goalMilestones
            .filter { !$0.completed }
            .sorted { ($0.dueDate ?? Date.distantFuture) < ($1.dueDate ?? Date.distantFuture) }
            .first
    }
    
    private var nextDeadline: Date? {
        goalMilestones
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
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                // 円形プログレス
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 8)
                        .frame(width: 90, height: 90)
                    
                    Circle()
                        .trim(from: 0, to: progress / 100)
                        .stroke(progressColor, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                        .frame(width: 90, height: 90)
                        .rotationEffect(.degrees(-90))
                    
                    Text("\(Int(progress))%")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(progressColor)
                }
                
                // 情報
                VStack(alignment: .leading, spacing: 8) {
                    Text(goal.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Text("理由：\(goal.reason)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                    
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
                    
                    // プログレスバー
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 6)
                                .cornerRadius(3)
                            
                            Rectangle()
                                .fill(progressColor)
                                .frame(width: geometry.size.width * (progress / 100), height: 6)
                                .cornerRadius(3)
                        }
                    }
                    .frame(height: 6)
                    
                    if let next = nextMilestone {
                        Text("次の一歩：\(next.title)")
                            .font(.caption)
                            .foregroundColor(.blue)
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                // 矢印
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
                    .padding(.top, 8)
            }
        }
        .padding()
        .background(Color(uiColor: .secondarySystemBackground))
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    GoalsView()
        .environmentObject(AuthViewModel())
        .environmentObject(GoalViewModel())
        .environmentObject(SettingsViewModel())
}
