# ミライ目標

なりたい自分になるための目標管理アプリ

## 概要

単なる目標管理ではなく、ホーム画面の目立つ場所に「なりたい自分」を表示し、ユーザーが目標の目的を忘れないようにするアプリです。

## 技術スタック

- iOS
- Swift
- SwiftUI
- Supabase Auth
- Supabase PostgreSQL
- Supabase Swift SDK

## セットアップ手順

### 1. Supabase プロジェクトの作成

1. [Supabase](https://supabase.com) でプロジェクトを作成
2. プロジェクトのURLとPublishable Keyを取得

### 2. データベースのセットアップ

Supabase のSQL Editorで以下のSQLを実行してください：

```sql
-- app_settings テーブル
create table app_settings (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  desired_self text not null default '',
  goal_sort_type text not null default 'nearest_due_date',
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  constraint app_settings_goal_sort_type_check
    check (goal_sort_type in (
      'nearest_due_date',
      'progress_low',
      'progress_high',
      'created_new',
      'created_old'
    )),
  constraint app_settings_user_id_unique unique (user_id)
);

-- goals テーブル
create table goals (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  title text not null,
  reason text not null,
  status text not null default 'in_progress',
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  constraint goals_status_check
    check (status in ('in_progress', 'completed')),
  constraint goals_id_user_id_unique unique (id, user_id)
);

-- milestones テーブル
create table milestones (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users(id) on delete cascade,
  goal_id uuid not null,
  title text not null,
  completed boolean not null default false,
  due_date date null,
  created_at timestamp with time zone not null default now(),
  updated_at timestamp with time zone not null default now(),
  constraint milestones_goal_user_fk
    foreign key (goal_id, user_id)
    references goals(id, user_id)
    on delete cascade
);

-- RLS を有効化
alter table app_settings enable row level security;
alter table goals enable row level security;
alter table milestones enable row level security;

-- app_settings のポリシー
create policy "Users can select own app_settings"
  on app_settings for select
  using (auth.uid() = user_id);

create policy "Users can insert own app_settings"
  on app_settings for insert
  with check (auth.uid() = user_id);

create policy "Users can update own app_settings"
  on app_settings for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can delete own app_settings"
  on app_settings for delete
  using (auth.uid() = user_id);

-- goals のポリシー
create policy "Users can select own goals"
  on goals for select
  using (auth.uid() = user_id);

create policy "Users can insert own goals"
  on goals for insert
  with check (auth.uid() = user_id);

create policy "Users can update own goals"
  on goals for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can delete own goals"
  on goals for delete
  using (auth.uid() = user_id);

-- milestones のポリシー
create policy "Users can select own milestones"
  on milestones for select
  using (auth.uid() = user_id);

create policy "Users can insert own milestones"
  on milestones for insert
  with check (auth.uid() = user_id);

create policy "Users can update own milestones"
  on milestones for update
  using (auth.uid() = user_id)
  with check (auth.uid() = user_id);

create policy "Users can delete own milestones"
  on milestones for delete
  using (auth.uid() = user_id);
```

### 3. メール認証の設定

Supabase ダッシュボードで以下を設定：

1. Authentication > Settings に移動
2. Email Auth を有効化
3. Email Confirmations を有効化
4. Redirect URLs に以下を追加:
   - `miraimokuhyo://auth/callback`

### 4. Xcode プロジェクトの設定

#### Swift Package Manager で Supabase SDK を追加

1. Xcode でプロジェクトを開く
2. File > Add Package Dependencies...
3. 以下のURLを入力: `https://github.com/supabase/supabase-swift`
4. 必要なパッケージ（Supabase）を選択してプロジェクトに追加

#### Info.plist の設定

Info.plist に以下を追加してDeep Linkを有効化：

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

#### Supabase 認証情報の設定

`SupabaseManager.swift` を開いて、以下を置き換えてください：

```swift
let supabaseURL = URL(string: "YOUR_SUPABASE_URL")!
let supabaseKey = "YOUR_SUPABASE_PUBLISHABLE_KEY"
```

以下のように実際の値に置き換えます：

```swift
let supabaseURL = URL(string: "https://your-project-ref.supabase.co")!
let supabaseKey = "your-publishable-anon-key-here"
```

⚠️ **重要**: 絶対に `service_role` キーを使用しないでください。必ず `anon/publishable` キーを使用してください。

### 5. ビルドと実行

1. シミュレータまたは実機を選択
2. Command + R でビルド＆実行

## 機能一覧

### 認証
- ✅ メールアドレス・パスワードでの新規登録
- ✅ メール認証必須
- ✅ ログイン/ログアウト
- ✅ Deep Link対応

### ホーム画面
- ✅ 今日の日付表示
- ✅ なりたい自分カード
- ✅ 次のマイルストーン（最大3件）
- ✅ 進行中の目標（最大3件）
- ✅ 新しい目標を追加ボタン

### 目標管理
- ✅ 目標の作成・編集・削除
- ✅ 1ユーザーあたり最大10件の目標
- ✅ 目標の並び替え（5種類）
- ✅ 進捗率の自動計算

### マイルストーン管理
- ✅ マイルストーンの作成・削除
- ✅ 完了状態の切り替え
- ✅ 1目標あたり最大30件のマイルストーン
- ✅ 期限の設定

### 設定
- ✅ なりたい自分の編集
- ✅ アプリ情報の表示
- ✅ ログアウト

## セキュリティ

### 含めて良いもの
- ✅ SUPABASE_URL
- ✅ SUPABASE_PUBLISHABLE_KEY

### 絶対に含めてはいけないもの
- ❌ service_role key
- ❌ secret key
- ❌ DB password
- ❌ 管理者用API key

### ログに出してはいけないもの
- ❌ なりたい自分
- ❌ 目標名
- ❌ 理由
- ❌ マイルストーン名
- ❌ メールアドレス
- ❌ アクセストークン
- ❌ リフレッシュトークン

## App Store公開前のチェックリスト

- [ ] プライバシーポリシーの作成
- [ ] 利用規約の作成
- [ ] スクリーンショットの準備
- [ ] アプリアイコンの設定
- [ ] バージョン番号の確認
- [ ] セキュリティ監査
- [ ] テスト（実機・シミュレータ）

## トラブルシューティング

### ビルドエラー

**エラー: Supabase パッケージが見つからない**
- Swift Package Manager で Supabase SDK を追加してください

**エラー: URL Scheme が機能しない**
- Info.plist に正しく設定されているか確認してください
- Supabase の Redirect URLs に `miraimokuhyo://auth/callback` が追加されているか確認してください

### 認証エラー

**メール認証メールが届かない**
- Supabase ダッシュボードで Email Auth が有効になっているか確認
- 迷惑メールフォルダを確認

**ログインできない**
- メール認証が完了しているか確認
- パスワードが正しいか確認

### データの問題

**目標やマイルストーンが表示されない**
- RLS ポリシーが正しく設定されているか確認
- Supabase ダッシュボードでデータが正しく保存されているか確認

## ライセンス

このプロジェクトは個人開発用です。

## お問い合わせ

不具合や要望があれば、プロジェクトの Issues に報告してください。
