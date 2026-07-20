//
//  RootView.swift
//  ミライ目標
//
//  Created by 石飛真大 on 2026/06/29.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        Group {
            if authViewModel.isLoading {
                ProgressView()
            } else if authViewModel.awaitingEmailConfirmation {
                EmailConfirmationView()
            } else if authViewModel.isPasswordRecovery {
                PasswordChangeView()
            } else if authViewModel.session != nil {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}
