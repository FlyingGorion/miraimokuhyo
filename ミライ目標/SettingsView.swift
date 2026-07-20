//
//  SettingsView.swift
//  ミライ目標
//
//  Created by 石飛真大 on 2026/06/29.
//

import SwiftUI
import Auth

struct SettingsView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    @State private var showEditDesiredSelf = false
    @State private var showLogoutConfirmation = false
    
    private var userId: UUID {
        authViewModel.session?.user.id ?? UUID()
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("なりたい自分")
                            .font(.headline)
                        
                        Text(settingsViewModel.appSettings?.desiredSelf ?? "")
                            .font(.body)
                            .foregroundColor(.secondary)
                        
                        Button {
                            showEditDesiredSelf = true
                        } label: {
                            Text("編集する")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                    .padding(.vertical, 8)
                }
                
                Section("データ") {
                    HStack {
                        Text("データはアカウントに保存されています")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                }
                
                Section("アプリ情報") {
                    HStack {
                        Text("バージョン")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        showLogoutConfirmation = true
                    } label: {
                        Text("ログアウト")
                            .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("設定")
            .sheet(isPresented: $showEditDesiredSelf) {
                DesiredSelfEditView()
            }
            .confirmationDialog("ログアウトしますか？", isPresented: $showLogoutConfirmation, titleVisibility: .visible) {
                Button("ログアウト", role: .destructive) {
                    Task {
                        await authViewModel.signOut()
                    }
                }
                Button("キャンセル", role: .cancel) {
                    // 何もしない
                }
            } message: {
                Text("ログアウトすると、再度ログインが必要になります。")
            }
            .task {
                await settingsViewModel.fetchSettings(userId: userId)
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AuthViewModel())
        .environmentObject(SettingsViewModel())
}
