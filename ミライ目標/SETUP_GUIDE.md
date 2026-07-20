# セットアップガイド

## 必須の設定

アプリを動作させるために、以下の手順を**必ず**実行してください。

### 1. Supabase Swift SDKのインストール

1. Xcodeでプロジェクトを開く
2. メニューバーから `File` > `Add Package Dependencies...` を選択
3. 検索欄に以下のURLを入力:
   ```
   https://github.com/supabase/supabase-swift
   ```
4. `Add Package` ボタンをクリック
5. `Supabase` パッケージを選択してプロジェクトに追加

### 2. Supabaseプロジェクトの作成

1. [https://supabase.com](https://supabase.com) にアクセス
2. 新しいプロジェクトを作成
3. プロジェクトの設定から以下の情報を取得:
   - **Project URL** (例: `https://xxxxxxxxxxxxx.supabase.co`)
   - **anon/public key** (Publishable Key)

### 3. データベーステーブルの作成

Supabase ダッシュボードで:

1. 左メニューから `SQL Editor` を選択
2. `README.md` に記載されているSQLスクリプトをコピー
3. SQL Editorに貼り付けて実行

これで以下が作成されます:
- `app_settings` テーブル
- `goals` テーブル
- `milestones` テーブル
- RLS (Row Level Security) ポリシー

### 4. メール認証の設定

Supabase ダッシュボードで:

1. 左メニューから `Authentication` > `Settings` を選択
2. `Email Auth` を有効化
3. `Email Confirmations` を有効にする
4. `Redirect URLs` セクションで `Add URL` をクリック
5. 以下のURLを追加:
   ```
   miraimokuhyo://auth/callback
   ```

### 5. Info.plistの設定

Xcodeで:

1. プロジェクトナビゲータで `Info.plist` を探す（見つからない場合は、プロジェクトの設定から Info タブを開く）
2. 以下のキーを追加:

**方法1: Info.plistファイルを直接編集する場合**

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>miraimokuhyo</string>
        </array>
    </dict>
</array>
```

**方法2: Xcodeの設定画面から追加する場合**

1. プロジェクト設定を開く
2. `Info` タブを選択
3. `URL Types` セクションを展開
4. `+` ボタンをクリック
5. `URL Schemes` に `miraimokuhyo` と入力

### 6. SupabaseManager.swiftの設定

1. Xcodeで `SupabaseManager.swift` を開く
2. 以下の行を見つける:
   ```swift
   let supabaseURL = URL(string: "YOUR_SUPABASE_URL")!
   let supabaseKey = "YOUR_SUPABASE_PUBLISHABLE_KEY"
   ```
3. 手順2で取得した実際の値に置き換える:
   ```swift
   let supabaseURL = URL(string: "https://xxxxxxxxxxxxx.supabase.co")!
   let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh4eHh4eHh4eHh4eHgiLCJyb2xlIjoiYW5vbiIsImlhdCI6MTY3ODg4ODg4OCwiZXhwIjoxOTk0NDY0ODg4fQ.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
   ```

⚠️ **重要**: 必ず `anon` または `publishable` キーを使用してください。`service_role` キーは絶対に使用しないでください！

### 7. ファイルの確認

Xcodeのプロジェクトナビゲータで、以下のファイルがすべて含まれていることを確認:

**エントリーポイント**
- ✅ MiraiMokuhyoApp.swift (旧: _____App.swift)

**ViewModels**
- ✅ AuthViewModel.swift
- ✅ GoalViewModel.swift
- ✅ SettingsViewModel.swift

**Models**
- ✅ Models.swift
- ✅ SupabaseManager.swift

**Views - 認証**
- ✅ RootView.swift
- ✅ LoginView.swift
- ✅ SignUpView.swift
- ✅ EmailConfirmationView.swift

**Views - メイン**
- ✅ MainTabView.swift
- ✅ HomeView.swift
- ✅ GoalsView.swift
- ✅ GoalCreateView.swift
- ✅ GoalDetailView.swift
- ✅ GoalEditView.swift
- ✅ MilestoneCreateView.swift
- ✅ SettingsView.swift
- ✅ DesiredSelfEditView.swift

**Components**
- ✅ DesiredSelfCard.swift
- ✅ GoalCard.swift
- ✅ ProgressBar.swift
- ✅ MilestoneRow.swift

ファイルが見つからない場合:
1. ファイルが実際に存在するか確認
2. `File` > `Add Files to "ミライ目標"...` から追加
3. Target Membership で「ミライ目標」にチェックが入っているか確認

### 8. ビルドと実行

1. シミュレータまたは実機を選択
2. `Product` > `Build` (Command + B) でビルド
3. エラーがないことを確認
4. `Product` > `Run` (Command + R) で実行

## 動作確認

### 1. 新規登録
1. アプリを起動
2. 「アカウントを作成」をタップ
3. メールアドレスとパスワードを入力
4. 「登録する」をタップ
5. 確認メール送信画面が表示される

### 2. メール確認
1. 登録したメールアドレスの受信箱を確認
2. Supabaseからの確認メールを開く
3. 確認リンクをタップ
4. アプリに戻る（Deep Linkで自動的に戻る）

### 3. ログイン
1. 「ログイン画面に戻る」をタップ
2. メールアドレスとパスワードを入力
3. 「ログイン」をタップ
4. ホーム画面が表示される

### 4. 初期設定の確認
1. ホーム画面で「なりたい自分」が表示されることを確認
2. デフォルト値: 「常に自由であり続け、誠実さと好奇心のある人間になる」

### 5. 目標の作成
1. 「新しい目標を追加」ボタンをタップ
2. 目標名と理由を入力
3. （任意）マイルストーンを追加
4. 「保存」をタップ
5. 目標詳細画面に遷移

### 6. その他の機能
- ✅ マイルストーンの完了状態を切り替え
- ✅ 目標の編集と削除
- ✅ 目標画面で並び替え
- ✅ 設定画面で「なりたい自分」を編集
- ✅ ログアウト

## トラブルシューティング

### ビルドエラー: "Cannot find 'Supabase' in scope"

**原因**: Supabase Swift SDKがインストールされていない

**解決方法**:
1. `File` > `Add Package Dependencies...`
2. `https://github.com/supabase/supabase-swift` を追加

### ビルドエラー: "Type 'SupabaseClient' cannot be found"

**原因**: パッケージの依存関係が正しく解決されていない

**解決方法**:
1. `File` > `Packages` > `Reset Package Caches`
2. プロジェクトをクリーン（`Product` > `Clean Build Folder`）
3. 再ビルド

### 実行時エラー: "Invalid URL"

**原因**: SupabaseManager.swift で URL が正しく設定されていない

**解決方法**:
1. SupabaseManager.swift を開く
2. `YOUR_SUPABASE_URL` を実際のSupabase URLに置き換え
3. URLが `https://` で始まっていることを確認

### ログインできない

**原因1**: メール認証が完了していない

**解決方法**:
- 受信箱で確認メールを探す
- 迷惑メールフォルダも確認
- 確認リンクをクリック

**原因2**: パスワードが間違っている

**解決方法**:
- パスワードを確認
- 必要に応じてパスワードリセット（今後実装予定）

### Deep Linkが動作しない

**原因**: Info.plist の URL Scheme が設定されていない

**解決方法**:
1. Info.plist に URL Types を追加
2. URL Schemes に `miraimokuhyo` を設定
3. Supabase の Redirect URLs に `miraimokuhyo://auth/callback` を追加

### データが表示されない

**原因**: RLSポリシーが正しく設定されていない

**解決方法**:
1. Supabase ダッシュボードでテーブルを確認
2. RLS が有効になっているか確認
3. ポリシーが正しく設定されているか確認（README.md参照）

## サポート

問題が解決しない場合:

1. Xcodeのコンソールでエラーメッセージを確認
2. Supabase ダッシュボードの Logs を確認
3. README.md の詳細なトラブルシューティングセクションを参照

## 次のステップ

アプリが正常に動作したら:

1. ✅ 実機でテスト
2. ✅ アプリアイコンの設定
3. ✅ スプラッシュスクリーンの追加（任意）
4. ✅ プライバシーポリシーの作成
5. ✅ App Store申請の準備

おめでとうございます！ミライ目標アプリの実装が完了しました🎉
