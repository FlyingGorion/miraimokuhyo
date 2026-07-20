//
//  SettingsViewModel.swift
//  ミライ目標
//
//  Created by 石飛真大 on 2026/06/29.
//

import Foundation
import SwiftUI
import Combine
import Supabase
import PostgREST

@MainActor
class SettingsViewModel: ObservableObject {
    @Published var appSettings: AppSettings?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let supabase = SupabaseManager.shared.client
    
    func fetchSettings(userId: UUID) async {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // キャンセルチェック
            try Task.checkCancellation()
            
            let settings: [AppSettings] = try await supabase.database
                .from("app_settings")
                .select()
                .eq("user_id", value: userId.uuidString)
                .execute()
                .value
            
            // キャンセルチェック
            try Task.checkCancellation()
            
            appSettings = settings.first
            
            print("✅ [SETTINGS] FetchSettings succeeded - Found: \(settings.count) record(s)")
        } catch is CancellationError {
            // キャンセルエラーは無視（通常の動作）
            print("ℹ️ [SETTINGS] FetchSettings cancelled (normal behavior)")
        } catch {
            // コンソールに詳細なエラーログを出力
            print("❌ [SETTINGS] FetchSettings failed")
            print("   UserID: \(userId)")
            print("   Error: \(error)")
            print("   LocalizedDescription: \(error.localizedDescription)")
            
            errorMessage = "通信に失敗しました。時間をおいて再度お試しください。"
        }
    }
    
    func updateDesiredSelf(userId: UUID, desiredSelf: String) async {
        do {
            struct DesiredSelfUpdate: Encodable {
                let desired_self: String
                let updated_at: String
            }
            
            let updates = DesiredSelfUpdate(
                desired_self: desiredSelf,
                updated_at: ISO8601DateFormatter().string(from: Date())
            )
            
            try await supabase.database
                .from("app_settings")
                .update(updates)
                .eq("user_id", value: userId.uuidString)
                .execute()
            
            if var settings = appSettings {
                settings.desiredSelf = desiredSelf
                settings.updatedAt = Date()
                appSettings = settings
            }
        } catch {
            // コンソールに詳細なエラーログを出力
            print("❌ [SETTINGS] UpdateDesiredSelf failed")
            print("   UserID: \(userId)")
            print("   Error: \(error)")
            print("   LocalizedDescription: \(error.localizedDescription)")
            
            errorMessage = "保存に失敗しました。"
        }
    }
    
    func updateSortType(userId: UUID, sortType: GoalSortType) async {
        do {
            struct SortTypeUpdate: Encodable {
                let goal_sort_type: String
                let updated_at: String
            }
            
            let updates = SortTypeUpdate(
                goal_sort_type: sortType.rawValue,
                updated_at: ISO8601DateFormatter().string(from: Date())
            )
            
            try await supabase.database
                .from("app_settings")
                .update(updates)
                .eq("user_id", value: userId.uuidString)
                .execute()
            
            if var settings = appSettings {
                settings.goalSortType = sortType
                settings.updatedAt = Date()
                appSettings = settings
            }
        } catch {
            // コンソールに詳細なエラーログを出力
            print("❌ [SETTINGS] UpdateSortType failed")
            print("   UserID: \(userId)")
            print("   SortType: \(sortType.rawValue)")
            print("   Error: \(error)")
            print("   LocalizedDescription: \(error.localizedDescription)")
            
            errorMessage = "保存に失敗しました。"
        }
    }
}
