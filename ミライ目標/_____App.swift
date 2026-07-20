//
//  MiraiMokuhyoApp.swift
//  ミライ目標
//
//  Created by 石飛真大 on 2026/06/29.
//

import SwiftUI

@main
struct MiraiMokuhyoApp: App {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(authViewModel)
                .onOpenURL { url in
                    Task {
                        await authViewModel.handleDeepLink(url: url)
                    }
                }
        }
    }
}
