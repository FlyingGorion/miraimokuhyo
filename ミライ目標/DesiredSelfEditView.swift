//
//  DesiredSelfEditView.swift
//  ミライ目標
//
//  Created by 石飛真大 on 2026/06/29.
//

import SwiftUI
import Auth

struct DesiredSelfEditView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @Environment(\.dismiss) var dismiss
    
    @State private var desiredSelf: String
    
    init() {
        _desiredSelf = State(initialValue: "")
    }
    
    private var userId: UUID {
        authViewModel.session?.user.id ?? UUID()
    }
    
    private var canSave: Bool {
        !desiredSelf.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextEditor(text: $desiredSelf)
                        .frame(minHeight: 100)
                        .onChange(of: desiredSelf) {
                            desiredSelf = String(desiredSelf.prefix(70))
                        }
                } header: {
                    Text("なりたい自分")
                } footer: {
                    Text("あなたが目指す理想の姿を入力してください")
                }
            }
            .navigationTitle("なりたい自分を編集")
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
                            await settingsViewModel.updateDesiredSelf(userId: userId, desiredSelf: desiredSelf)
                            dismiss()
                        }
                    }
                    .disabled(!canSave)
                }
            }
            .onAppear {
                desiredSelf = settingsViewModel.appSettings?.desiredSelf ?? ""
            }
        }
    }
}

#Preview {
    DesiredSelfEditView()
        .environmentObject(AuthViewModel())
        .environmentObject(SettingsViewModel())
}
