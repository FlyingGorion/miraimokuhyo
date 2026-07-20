//
//  AuthViewModel.swift
//  ミライ目標
//
//  Created by 石飛真大 on 2026/06/29.
//

import Foundation
import SwiftUI
import Combine
import Supabase
import Auth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var session: Session?
    @Published var isLoading = true
    @Published var errorMessage: String?
    @Published var awaitingEmailConfirmation = false
    @Published var isPasswordRecovery = false
    
    private let supabase = SupabaseManager.shared.client
    
    init() {
        Task {
            await checkSession()
        }
    }
    
    func checkSession() async {
        do {
            session = try await supabase.auth.session
            isLoading = false
        } catch {
            isLoading = false
        }
    }
    
    func signUp(email: String, password: String, redirectTo: URL? = nil) async {
        do {
            let response = try await supabase.auth.signUp(
                email: email,
                password: password,
                redirectTo: redirectTo
            )
            
            if response.user != nil {
                awaitingEmailConfirmation = true
            }
        } catch {
            // コンソールに詳細なエラーログを出力
            print("❌ [AUTH] SignUp failed")
            print("   Email: <hidden>") // メールアドレスは表示しない
            print("   Error: \(error)")
            print("   LocalizedDescription: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("   Domain: \(nsError.domain)")
                print("   Code: \(nsError.code)")
                print("   UserInfo: \(nsError.userInfo)")
            }
            
            // ユーザーには簡潔なメッセージを表示
            errorMessage = "新規登録に失敗しました。"
        }
    }
    
    func handleDeepLink(url: URL) async {
        do {
            let session = try await supabase.auth.session(from: url)
            
            // URLにtype=recoveryパラメータがあればパスワードリセットフロー
            if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
               let queryItems = components.queryItems,
               queryItems.contains(where: { $0.name == "type" && $0.value == "recovery" }) {
                self.isPasswordRecovery = true
                self.session = session
                print("✅ [AUTH] Deep link handled - password recovery")
            } else {
                self.session = session
                self.awaitingEmailConfirmation = false
                
                // 初回ログイン時にapp_settingsを作成
                await createAppSettingsIfNeeded()
                print("✅ [AUTH] Deep link handled successfully")
            }
        } catch {
            print("❌ [AUTH] Deep link handling failed")
            print("   URL: \(url)")
            print("   Error: \(error)")
            errorMessage = "メール認証の処理に失敗しました。"
        }
    }
    
    func signIn(email: String, password: String) async {
        do {
            let session = try await supabase.auth.signIn(
                email: email,
                password: password
            )
            
            self.session = session
            
            // 初回ログイン時にapp_settingsを作成
            await createAppSettingsIfNeeded()
        } catch {
            // コンソールに詳細なエラーログを出力
            print("❌ [AUTH] SignIn failed")
            print("   Email: <hidden>") // メールアドレスは表示しない
            print("   Error: \(error)")
            print("   LocalizedDescription: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("   Domain: \(nsError.domain)")
                print("   Code: \(nsError.code)")
                print("   UserInfo: \(nsError.userInfo)")
            }
            
            // ユーザーには簡潔なメッセージを表示
            errorMessage = "ログインに失敗しました。"
        }
    }
    
    func signOut() async {
        do {
            try await supabase.auth.signOut()
            session = nil
        } catch {
            // コンソールに詳細なエラーログを出力
            print("❌ [AUTH] SignOut failed")
            print("   Error: \(error)")
            print("   LocalizedDescription: \(error.localizedDescription)")
            
            // ユーザーには簡潔なメッセージを表示
            errorMessage = "ログアウトに失敗しました。"
        }
    }
    
    func updatePassword(newPassword: String) async -> Bool {
        do {
            try await supabase.auth.update(user: UserAttributes(password: newPassword))
            isPasswordRecovery = false
            
            print("✅ [AUTH] Password updated successfully")
            return true
        } catch {
            print("❌ [AUTH] UpdatePassword failed")
            print("   Error: \(error)")
            print("   LocalizedDescription: \(error.localizedDescription)")
            
            let errorString = "\(error)"
            if errorString.contains("same_password") || errorString.contains("different password") {
                errorMessage = "現在のパスワードと同じパスワードは使用できません。別のパスワードを入力してください。"
            } else {
                errorMessage = "パスワードの更新に失敗しました。"
            }
            return false
        }
    }
    
    func resetPassword(email: String) async -> Bool {
        do {
            try await supabase.auth.resetPasswordForEmail(
                email,
                redirectTo: URL(string: "miraimokuhyo://auth/callback?type=recovery")
            )
            print("✅ [AUTH] Password reset email sent successfully")
            return true
        } catch {
            // コンソールに詳細なエラーログを出力
            print("❌ [AUTH] ResetPassword failed")
            print("   Email: <hidden>") // メールアドレスは表示しない
            print("   Error: \(error)")
            print("   LocalizedDescription: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("   Domain: \(nsError.domain)")
                print("   Code: \(nsError.code)")
                print("   UserInfo: \(nsError.userInfo)")
            }
            
            // ユーザーには簡潔なメッセージを表示
            errorMessage = "パスワードリセットメールの送信に失敗しました。"
            return false
        }
    }
    
    private func createAppSettingsIfNeeded() async {
        guard let userId = session?.user.id else { return }
        
        do {
            // 既存のapp_settingsを確認
            let existing: [AppSettings] = try await supabase.database
                .from("app_settings")
                .select()
                .eq("user_id", value: userId.uuidString)
                .execute()
                .value
            
            if existing.isEmpty {
                struct NewAppSettings: Encodable {
                    let user_id: String
                    let desired_self: String
                    let goal_sort_type: String
                }
                
                // app_settingsを作成
                let newSettings = NewAppSettings(
                    user_id: userId.uuidString,
                    desired_self: "常に自由であり続け、誠実さと好奇心のある人間になる",
                    goal_sort_type: "nearest_due_date"
                )
                
                try await supabase.database
                    .from("app_settings")
                    .insert(newSettings)
                    .execute()
                
                print("✅ [AUTH] app_settings created successfully")
            }
        } catch {
            // エラーログを出力
            print("❌ [AUTH] CreateAppSettings failed")
            print("   UserID: \(userId)")
            print("   Error: \(error)")
            print("   LocalizedDescription: \(error.localizedDescription)")
            // エラーは黙って処理（次回起動時に再試行される）
        }
    }
}
