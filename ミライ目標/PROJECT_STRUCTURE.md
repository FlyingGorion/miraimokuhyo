# プロジェクト構成ファイル

このドキュメントでは、プロジェクトの各ファイルの役割を説明します。

## アプリエントリーポイント

### MiraiMokuhyoApp.swift (旧: _____App.swift)
- アプリのメインエントリーポイント
- `@main` 属性を持つ
- `AuthViewModel` を作成し、全体に提供

## ViewModels

### AuthViewModel.swift
- 認証関連の状態とロジックを管理
- 新規登録、ログイン、ログアウト機能
- セッション管理
- 初回ログイン時の app_settings 作成

### GoalViewModel.swift
- 目標とマイルストーンの状態とロジックを管理
- CRUD操作（作成、読み取り、更新、削除）
- 目標の並び替え機能
- 進捗計算

### SettingsViewModel.swift
- アプリ設定の状態とロジックを管理
- なりたい自分の編集
- 並び替え設定の更新

## Models

### Models.swift
- データモデルの定義
- `GoalSortType`, `GoalStatus` 列挙型
- `AppSettings`, `Goal`, `Milestone` 構造体
- Supabase のスネークケースとSwiftのキャメルケースの変換（CodingKeys）

## Views - 認証

### RootView.swift
- 認証状態に応じて表示を切り替えるルートビュー
- ログイン前/後の画面振り分け

### LoginView.swift
- ログイン画面
- メールアドレスとパスワードの入力
- 新規登録画面への遷移

### SignUpView.swift
- 新規登録画面
- メールアドレス、パスワード、確認パスワードの入力

### EmailConfirmationView.swift
- メール確認待ち画面
- 新規登録後に表示

## Views - メイン

### MainTabView.swift
- メインのタブビュー
- ホーム、目標、設定の3つのタブ
- ViewModelの作成と提供

### HomeView.swift
- ホーム画面
- なりたい自分カード、次のマイルストーン、進行中の目標を表示

### GoalsView.swift
- 目標一覧画面
- 全ての目標を表示
- 並び替え機能

### GoalCreateView.swift
- 目標作成画面
- 目標名、理由、マイルストーン（任意）の入力

### GoalDetailView.swift
- 目標詳細画面
- 目標情報、マイルストーン一覧、進捗率の表示
- 編集、削除機能

### GoalEditView.swift
- 目標編集画面
- 目標名と理由の編集

### MilestoneCreateView.swift
- マイルストーン作成画面
- マイルストーン名と期限（任意）の入力

### SettingsView.swift
- 設定画面
- なりたい自分の表示と編集
- アプリ情報
- ログアウト

### DesiredSelfEditView.swift
- なりたい自分の編集画面

## Components - UI部品

### DesiredSelfCard.swift
- なりたい自分を表示するカード
- ホーム画面で使用

### GoalCard.swift
- 目標情報を表示するカード
- 目標名、理由、進捗率、次の期限を表示

### ProgressBar.swift
- 進捗率を視覚的に表示するプログレスバー

### MilestoneRow.swift
- マイルストーンを表示する行
- チェックボックス、タイトル、期限を表示
- 完了状態の切り替え

## Utilities

### SupabaseManager.swift
- Supabase クライアントのシングルトン
- 認証情報の管理

⚠️ このファイルで Supabase URL と Publishable Key を設定する必要があります！

## その他

### ContentView.swift
- デフォルトで生成されたビュー（現在は未使用）

### README.md
- プロジェクトの説明
- セットアップ手順
- トラブルシューティング

## ファイル追加手順（Xcodeで）

すべてのファイルがXcodeプロジェクトに追加されていることを確認してください：

1. Xcode でプロジェクトナビゲータを開く
2. 各 `.swift` ファイルが表示されているか確認
3. 表示されていないファイルがあれば、File > Add Files to "ミライ目標"... から追加

## ビルドターゲットの確認

すべての `.swift` ファイルがビルドターゲットに含まれていることを確認：

1. 各ファイルを選択
2. File Inspector（右側のパネル）を開く
3. Target Membership で「ミライ目標」にチェックが入っているか確認
