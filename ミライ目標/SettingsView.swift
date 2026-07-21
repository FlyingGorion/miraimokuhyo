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
    @State private var showDeleteAccountConfirmation = false
    @State private var isDeletingAccount = false
    
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
                
                Section {
                    Button(role: .destructive) {
                        showDeleteAccountConfirmation = true
                    } label: {
                        HStack {
                            Spacer()
                            if isDeletingAccount {
                                ProgressView()
                                    .padding(.trailing, 8)
                            }
                            Text("アカウントを削除")
                            Spacer()
                        }
                    }
                    .disabled(isDeletingAccount)
                } footer: {
                    Text("アカウントを削除すると、すべてのデータが完全に削除され、元に戻すことはできません。")
                        .font(.caption)
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
            .confirmationDialog("アカウントを削除しますか？", isPresented: $showDeleteAccountConfirmation, titleVisibility: .visible) {
                Button("アカウントを削除", role: .destructive) {
                    isDeletingAccount = true
                    Task {
                        await authViewModel.deleteAccount()
                        isDeletingAccount = false
                    }
                }
                Button("キャンセル", role: .cancel) {
                    // 何もしない
                }
            } message: {
                Text("すべての目標・マイルストーン・設定データが完全に削除されます。この操作は取り消せません。")
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
