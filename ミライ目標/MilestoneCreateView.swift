//
//  MilestoneCreateView.swift
//  ミライ目標
//
//  Created by 石飛真大 on 2026/06/29.
//

import SwiftUI
import Auth

struct MilestoneCreateView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var goalViewModel: GoalViewModel
    @Environment(\.dismiss) var dismiss
    
    let goalId: UUID
    @State private var title = ""
    @State private var hasDueDate = false
    @State private var dueDate = Date()
    
    private var userId: UUID {
        authViewModel.session?.user.id ?? UUID()
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
            .navigationTitle("マイルストーンを追加")
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
                            await goalViewModel.createMilestone(
                                userId: userId,
                                goalId: goalId,
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
