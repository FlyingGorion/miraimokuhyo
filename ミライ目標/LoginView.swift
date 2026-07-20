//
//  LoginView.swift
//  ミライ目標
//
//  Created by 石飛真大 on 2026/06/29.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var email = ""
    @State private var password = ""
    @State private var showSignUp = false
    @State private var showPassword = false
    @State private var showPasswordReset = false
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        NavigationStack {
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
                        .frame(height: max(300 - keyboardHeight * 0.4, 120))
                    
                    // ログインフォームカード
                    VStack(spacing: 20) {
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
                                            .textContentType(.password)
                                            .autocorrectionDisabled()
                                    } else {
                                        SecureField("パスワードを入力", text: $password)
                                            .textContentType(.password)
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
                            
                            // エラーメッセージ
                            if let errorMessage = authViewModel.errorMessage {
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                            }
                            
                            // ログインボタン
                            Button {
                                Task {
                                    await authViewModel.signIn(email: email, password: password)
                                }
                            } label: {
                                Text("ログイン")
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
                            .disabled(email.isEmpty || password.isEmpty)
                            .opacity((email.isEmpty || password.isEmpty) ? 0.6 : 1.0)
                            
                            // パスワードを忘れた
                            Button {
                                showPasswordReset = true
                            } label: {
                                Text("パスワードをお忘れの方はこちら")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(red: 0.5, green: 0.45, blue: 0.75))
                            }
                            
                            // 区切り線
                            HStack {
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                                Text("または")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                            }
                            .padding(.vertical, 8)
                            
                            // 新規登録ボタン
                            Button {
                                showSignUp = true
                            } label: {
                                Text("新規登録はこちら")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(red: 0.5, green: 0.45, blue: 0.75))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(Color.white)
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(Color(red: 0.5, green: 0.45, blue: 0.75), lineWidth: 1.5)
                                    )
                            }
                        }
                        .padding(28)
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
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
            .sheet(isPresented: $showPasswordReset) {
                PasswordResetView()
            }
        }
    }
}

// パスワードリセット画面
struct PasswordResetView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) var dismiss
    @State private var email = ""
    @State private var isEmailSent = false
    @State private var isLoading = false
    @State private var errorMessage: String?
    @State private var keyboardHeight: CGFloat = 0
    
    var body: some View {
        NavigationStack {
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
                    // 上部スペース
                    Spacer()
                        .frame(height: max(280 - keyboardHeight * 0.4, 100))
                    
                    // パスワードリセットフォームカード
                    VStack(spacing: 20) {
                        // タイトル
                        VStack(spacing: 8) {
                            Image(systemName: "lock.rotation")
                                .font(.system(size: 48))
                                .foregroundColor(Color(red: 0.5, green: 0.45, blue: 0.85))
                                .padding(.bottom, 8)
                            
                            Text("パスワードをリセット")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundColor(Color(red: 0.4, green: 0.35, blue: 0.7))
                            
                            Text("登録されているメールアドレスを入力してください。\nパスワードリセットのリンクをお送りします。")
                                .font(.system(size: 14))
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, 8)
                        
                        if !isEmailSent {
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
                                        .disabled(isLoading)
                                }
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                                )
                            }
                            
                            // エラーメッセージ
                            if let errorMessage = errorMessage {
                                Text(errorMessage)
                                    .font(.caption)
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                            }
                            
                            // 送信ボタン
                            Button {
                                Task {
                                    isLoading = true
                                    errorMessage = nil
                                    
                                    let success = await authViewModel.resetPassword(email: email)
                                    
                                    isLoading = false
                                    
                                    if success {
                                        withAnimation {
                                            isEmailSent = true
                                        }
                                    } else {
                                        errorMessage = authViewModel.errorMessage
                                        // エラーメッセージをクリア（次回表示用）
                                        authViewModel.errorMessage = nil
                                    }
                                }
                            } label: {
                                HStack {
                                    if isLoading {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                            .scaleEffect(0.8)
                                        Text("送信中...")
                                    } else {
                                        Text("送信")
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
                            .disabled(email.isEmpty || isLoading)
                            .opacity((email.isEmpty || isLoading) ? 0.6 : 1.0)
                        } else {
                            // 送信完了メッセージ
                            VStack(spacing: 16) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(.green)
                                
                                Text("メールを送信しました")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Color(red: 0.4, green: 0.35, blue: 0.7))
                                
                                Text("メールボックスを確認して、リンクからパスワードをリセットしてください。")
                                    .font(.system(size: 14))
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                            }
                            .padding(.vertical, 24)
                        }
                        
                        // 閉じるボタン
                        Button {
                            dismiss()
                        } label: {
                            Text(isEmailSent ? "閉じる" : "キャンセル")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(Color(red: 0.5, green: 0.45, blue: 0.75))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.white)
                                .cornerRadius(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color(red: 0.5, green: 0.45, blue: 0.75), lineWidth: 1.5)
                                )
                        }
                    }
                    .padding(28)
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
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundColor(.primary)
                    }
                }
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthViewModel())
}
