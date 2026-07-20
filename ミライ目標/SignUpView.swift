//
//  SignUpView.swift
//  ミライ目標
//
//  Created by 石飛真大 on 2026/06/29.
//

import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
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
                // 上部スペース（ロゴが背景に含まれているため）
                Spacer()
                    .frame(height: max(250 - keyboardHeight * 0.4, 100))
                
                // 新規登録フォームカード
                VStack(spacing: 18) {
                        // タイトル
                        VStack(spacing: 8) {
                            Text("アカウント作成")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color(red: 0.4, green: 0.35, blue: 0.7))
                            
                            Text("登録後、確認メールを送信します")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 8)
                        
                        // メールアドレス
                        VStack(alignment: .leading, spacing: 8) {
                            Text("メールアドレス")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(red: 0.4, green: 0.35, blue: 0.7))
                            
                            HStack(spacing: 12) {
                                Image(systemName: "envelope")
                                    .foregroundColor(Color(red: 0.5, green: 0.45, blue: 0.75))
                                    .frame(width: 24)
                                
                                TextField("メールアドレスを入力", text: $email)
                                    .textInputAutocapitalization(.never)
                                    .textContentType(.emailAddress)
                                    .keyboardType(.emailAddress)
                                    .autocorrectionDisabled()
                            }
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(12)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                            )
                        }
                        
                        // パスワード
                        VStack(alignment: .leading, spacing: 8) {
                            Text("パスワード")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(red: 0.4, green: 0.35, blue: 0.7))
                            
                            HStack(spacing: 12) {
                                Image(systemName: "lock")
                                    .foregroundColor(Color(red: 0.5, green: 0.45, blue: 0.75))
                                    .frame(width: 24)
                                
                                if showPassword {
                                    TextField("パスワードを入力", text: $password)
                                        .textContentType(.newPassword)
                                        .autocorrectionDisabled()
                                } else {
                                    SecureField("パスワードを入力", text: $password)
                                        .textContentType(.newPassword)
                                }
                                
                                Button {
                                    showPassword.toggle()
                                } label: {
                                    Image(systemName: showPassword ? "eye.slash" : "eye")
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
                        if !confirmPassword.isEmpty && password != confirmPassword {
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
                        
                        // 登録ボタン
                        Button {
                            Task {
                                await authViewModel.signUp(
                                    email: email,
                                    password: password,
                                    redirectTo: URL(string: "miraimokuhyo://auth/callback")!
                                )
                            }
                        } label: {
                            Text("登録する")
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
                        .disabled(email.isEmpty || password.isEmpty || password != confirmPassword)
                        .opacity((email.isEmpty || password.isEmpty || password != confirmPassword) ? 0.6 : 1.0)
                        
                        // ログインへ戻る
                        Button {
                            dismiss()
                        } label: {
                            HStack(spacing: 4) {
                                Image(systemName: "arrow.left")
                                    .font(.caption)
                                Text("ログイン画面に戻る")
                                    .font(.system(size: 14))
                            }
                            .foregroundColor(Color(red: 0.5, green: 0.45, blue: 0.75))
                        }
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
            // キーボード表示の監視
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillShowNotification,
                object: nil,
                queue: .main
            ) { notification in
                if let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
                    keyboardHeight = keyboardFrame.height
                }
            }
            
            // キーボード非表示の監視
            NotificationCenter.default.addObserver(
                forName: UIResponder.keyboardWillHideNotification,
                object: nil,
                queue: .main
            ) { _ in
                keyboardHeight = 0
            }
        }
        .onDisappear {
            // 監視を解除
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
        .onTapGesture {
            // 画面タップでキーボードを閉じる
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        SignUpView()
            .environmentObject(AuthViewModel())
    }
}
