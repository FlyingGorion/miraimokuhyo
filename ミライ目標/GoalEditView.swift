//
//  GoalEditView.swift
//  ミライ目標
//
//  Created by 石飛真大 on 2026/06/29.
//

import SwiftUI

struct GoalEditView: View {
    @EnvironmentObject var goalViewModel: GoalViewModel
    @Environment(\.dismiss) var dismiss
    
    let goal: Goal
    @State private var title: String
    @State private var reason: String
    @State private var hasDueDate: Bool
    @State private var dueDate: Date
    
    init(goal: Goal) {
        self.goal = goal
        _title = State(initialValue: goal.title)
        _reason = State(initialValue: goal.reason)
        _hasDueDate = State(initialValue: goal.dueDate != nil)
        _dueDate = State(initialValue: goal.dueDate ?? Date())
    }
    
    private var canSave: Bool {
        !title.isEmpty && !reason.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("目標") {
                    TextField("目標名", text: $title)
                        .onChange(of: title) {
                            title = String(title.prefix(70))
                        }
                    
                    TextField("理由", text: $reason, axis: .vertical)
                        .lineLimit(3)
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
            }
            .navigationTitle("目標を編集")
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
                            var updatedGoal = goal
                            updatedGoal.title = title
                            updatedGoal.reason = reason
                            updatedGoal.dueDate = hasDueDate ? dueDate : nil
                            await goalViewModel.updateGoal(goal: updatedGoal)
                            dismiss()
                        }
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
}
