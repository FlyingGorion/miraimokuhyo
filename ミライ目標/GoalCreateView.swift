//
//  GoalCreateView.swift
//  ミライ目標
//
//  Created by 石飛真大 on 2026/06/29.
//

import SwiftUI
import Auth

struct GoalCreateView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var goalViewModel: GoalViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var reason = ""
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    @State private var milestones: [MilestoneInput] = []
    @State private var showAddMilestone = false
    
    private var userId: UUID {
        authViewModel.session?.user.id ?? UUID()
    }
    
    private var canSave: Bool {
        !title.isEmpty && !reason.isEmpty
    }
    
    // 日付フォーマッター
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    
    var body: some View {
        NavigationStack {
            Form {
                Section("目標") {
                    TextField("目標名", text: $title)
                        .onChange(of: title) {
                            title = String(title.prefix(70))
                        }
                    
                    TextField("理由", text: $reason, axis: .vertical)
                        .onChange(of: reason) { oldValue, newValue in
                            // 改行数をチェック
                            let lines = newValue.components(separatedBy: "\n")
                            
                            // 3行を超える場合は制限
                            if lines.count > 3 {
                                reason = oldValue
                                return
                            }
                            
                            // 各行が適切な長さかチェック（1行あたり約40文字程度を想定）
                            // これにより画面幅に収まるようにする
                            for line in lines {
                                if line.count > 50 {
                                    // 1行が長すぎる場合は制限
                                    reason = oldValue
                                    return
                                }
                            }
                        }
                }
                
                Section {
                    Toggle("期限を設定", isOn: $hasDueDate)
                    
                    if hasDueDate {
                        DatePicker("期限", selection: $dueDate, displayedComponents: .date)
                    }
                } header: {
                    Text("目標の期限 (任意)")
                }
                
                Section {
                    ForEach(milestones.indices, id: \.self) { index in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text(milestones[index].title)
                                    .font(.body)
                                Spacer()
                                Button {
                                    milestones.remove(at: index)
                                } label: {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                }
                            }
                            
                            if let dueDate = milestones[index].dueDate {
                                Text("期限: \(dueDate, formatter: Self.dateFormatter)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                    
                    Button {
                        showAddMilestone = true
                    } label: {
                        Label("マイルストーンを追加", systemImage: "plus.circle")
                    }
                } header: {
                    Text("マイルストーン (任意)")
                }
            }
            .navigationTitle("新しい目標")
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
                            // 目標を作成
                            if let createdGoal = await goalViewModel.createGoal(
                                userId: userId,
                                title: title,
                                reason: reason,
                                dueDate: hasDueDate ? dueDate : nil,
                                milestoneName: nil,
                                milestoneDueDate: nil
                            ) {
                                // マイルストーンを作成
                                for milestone in milestones {
                                    await goalViewModel.createMilestone(
                                        userId: userId,
                                        goalId: createdGoal.id,
                                        title: milestone.title,
                                        dueDate: milestone.dueDate
                                    )
                                }
                                
                                // 元の画面に戻る
                                dismiss()
                            }
                        }
                    }
                    .disabled(!canSave)
                }
            }
            .sheet(isPresented: $showAddMilestone) {
                MilestoneInputSheet { milestone in
                    milestones.append(milestone)
                }
            }
        }
        .alert("エラー", isPresented: .constant(goalViewModel.errorMessage != nil)) {
            Button("OK") {
                goalViewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = goalViewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}

// マイルストーン入力用の構造体
struct MilestoneInput: Identifiable {
    let id = UUID()
    var title: String
    var dueDate: Date?
}

// マイルストーン追加用のシート
struct MilestoneInputSheet: View {
    @Environment(\.dismiss) var dismiss
    let onAdd: (MilestoneInput) -> Void
    
    @State private var title = ""
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    
    private var canAdd: Bool {
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
            .navigationTitle("マイルストーンを追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("追加") {
                        let milestone = MilestoneInput(
                            title: title,
                            dueDate: hasDueDate ? dueDate : nil
                        )
                        onAdd(milestone)
                        dismiss()
                    }
                    .disabled(!canAdd)
                }
            }
        }
    }
}

#Preview {
    GoalCreateView()
        .environmentObject(AuthViewModel())
        .environmentObject(GoalViewModel())
}
