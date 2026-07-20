//
//  EmailConfirmationView.swift
//  ミライ目標
//
//  Created by 石飛真大 on 2026/06/29.
//

import SwiftUI

struct EmailConfirmationView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image(systemName: "envelope.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(.accentColor)
            
            Text("確認メールを送信しました")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("メールに記載されたリンクをクリックして、アカウントを有効化してください。")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Spacer()
            
            Button {
                authViewModel.awaitingEmailConfirmation = false
            } label: {
                Text("ログイン画面に戻る")
                    .foregroundColor(.accentColor)
            }
            .padding(.bottom, 40)
        }
    }
}

#Preview {
    EmailConfirmationView()
        .environmentObject(AuthViewModel())
}
