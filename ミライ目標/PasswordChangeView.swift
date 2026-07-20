//
//  PasswordChangeView.swift
//  ミライ目標
//
//  Created by 石飛真大 on 2026/07/05.
//

import SwiftUI

struct PasswordChangeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var showNewPassword = false
    @State private var showConfirmPassword = false
    @State private var isLoading = false
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        ZStack {
            // 背景画像（固定）
            GeometryReader { geometry in
                Image("login_signIn_background")
                    .resizable()
                    .scaledToFill()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .clipped()
            }
            .ignoresSafeArea()
            
            // コンテンツ（キーボードに応じて移動）
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: max(250 - keyboardHeight * 0.4, 100))
                
                // パスワード変更フォームカード
                VStack(spacing: 20) {
                    // タイトル
                    VStack(spacing: 8) {
                        Image(systemName: "lock.rotation")
                            .font(.system(size: 48))
                            .foregroundColor(Color(red: 0.5, green: 0.45, blue: 0.85))
                            .padding(.bottom, 8)
                        
                        Text("新しいパスワードを設定")
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color(red: 0.4, green: 0.35, blue: 0.7))
                        
                        Text("新しいパスワードを入力してください")
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    .padding(.top, 8)
                    
                    // 新しいパスワード
                    VStack(alignment: .leading, spacing: 8) {
                        Text("新しいパスワード")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red: 0.4, green: 0.35, blue: 0.7))
                        
                        HStack(spacing: 12) {
                            Image(systemName: "lock")
                                .foregroundColor(Color(red: 0.5, green: 0.45, blue: 0.75))
                                .frame(width: 24)
                            
                            if showNewPassword {
                                TextField("新しいパスワードを入力", text: $newPassword)
                                    .textContentType(.newPassword)
                                    .autocorrectionDisabled()
                            } else {
                                SecureField("新しいパスワードを入力", text: $newPassword)
                                    .textContentType(.newPassword)
                            }
                            
                            Button {
                                showNewPassword.toggle()
                            } label: {
                                Image(systemName: showNewPassword ? "eye.slash" : "eye")
                                    .foregroundColor(Color.gray)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    
                    // パスワード確認
                    VStack(alignment: .leading, spacing: 8) {
                        Text("パスワード確認")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(red: 0.4, green: 0.35, blue: 0.7))
                        
                        HStack(spacing: 12) {
                            Image(systemName: "lock.fill")
                                .foregroundColor(Color(red: 0.5, green: 0.45, blue: 0.75))
                                .frame(width: 24)
                            
                            if showConfirmPassword {
                                TextField("パスワードを再入力", text: $confirmPassword)
                                    .textContentType(.newPassword)
                                    .autocorrectionDisabled()
                            } else {
                                SecureField("パスワードを再入力", text: $confirmPassword)
                                    .textContentType(.newPassword)
                            }
                            
                            Button {
                                showConfirmPassword.toggle()
                            } label: {
                                Image(systemName: showConfirmPassword ? "eye.slash" : "eye")
                                    .foregroundColor(Color.gray)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.8))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    }
                    
                    // パスワード一致チェック
                    if !confirmPassword.isEmpty && newPassword != confirmPassword {
                        HStack(spacing: 4) {
                            Image(systemName: "exclamationmark.circle")
                                .foregroundColor(.red)
                            Text("パスワードが一致しません")
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                    
                    // エラーメッセージ
                    if let errorMessage = authViewModel.errorMessage {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                    }
                    
                    // 変更ボタン
                    Button {
                        Task {
                            isLoading = true
                            let success = await authViewModel.updatePassword(newPassword: newPassword)
                            isLoading = false
                            
                            if success {
                                // パスワード更新成功 → isPasswordRecoveryがfalseになりホーム画面へ遷移
                            }
                        }
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.8)
                                Text("変更中...")
                            } else {
                                Text("パスワードを変更")
                            }
                        }
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.5, green: 0.45, blue: 0.85),
                                    Color(red: 0.65, green: 0.55, blue: 0.9)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                    }
                    .disabled(newPassword.isEmpty || newPassword != confirmPassword || isLoading)
                    .opacity((newPassword.isEmpty || newPassword != confirmPassword || isLoading) ? 0.6 : 1.0)
                }
                .padding(24)
                .background(Color.white.opacity(0.95))
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.1), radius: 20, x: 0, y: 10)
                .padding(.horizontal, 24)
                
                Spacer()
            }
            .animation(.easeOut(duration: 0.3), value: keyboardHeight)
        }
        .onAppear {
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil,
                queue: .main
            ) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    keyboardHeight = keyboardFrame.height
                }
            }
            
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { _ in
                keyboardHeight = 0
            }
        }
        .onDisappear {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }
}

#Preview {
    PasswordChangeView()
        .environmentObject(AuthViewModel())
}
