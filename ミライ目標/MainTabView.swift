//
//  MainTabView.swift
//  ミライ目標
//
//  Created by 石飛真大 on 2026/06/29.
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var goalViewModel = GoalViewModel()
    @StateObject private var settingsViewModel = SettingsViewModel()
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tabItem {
                    Label("ホーム", systemImage: "house.fill")
                }
                .tag(0)
            
            GoalsView()
                .tabItem {
                    Label("目標", systemImage: "list.bullet")
                }
                .tag(1)
            
            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape.fill")
                }
                .tag(2)
        }
        .environmentObject(goalViewModel)
        .environmentObject(settingsViewModel)
    }
}

#Preview {
    MainTabView()
        .environmentObject(AuthViewModel())
}
