//
//  SupabaseManager.swift
//  ミライ目標
//
//  Created by 石飛真大 on 2026/06/29.
//

import Foundation
import Supabase
import Auth

class SupabaseManager {
    static let shared = SupabaseManager()
    
    let client: SupabaseClient
    
    private init() {
        // Info.plist 経由で Secrets.xcconfig の値を読み込む
        guard let urlString = Bundle.main.infoDictionary?["SUPABASE_URL"] as? String,
              let supabaseURL = URL(string: urlString),
              let supabaseKey = Bundle.main.infoDictionary?["SUPABASE_ANON_KEY"] as? String,
              !supabaseKey.isEmpty,
              !urlString.isEmpty else {
            fatalError("Supabase の設定が見つかりません。Secrets.xcconfig を作成してください。詳しくは Secrets.xcconfig.example を参照してください。")
        }
        
        client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: supabaseKey
        )
    }
}
