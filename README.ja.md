> **注意**: このリポジトリは100% vibe codingで作られています。私は使っていますが、広く使われることを想定していません。私の知人などに共有するのが楽なのでオープンにしているだけです。issueに対しては、気まぐれに対応するだけなので利用する場合は気をつけてください。

# git-wtree

複数のworktreeを簡単かつ直感的に管理できる便利なgit worktreeラッパーです。

## 🚀 機能

`git-wtree`は、git worktreeの体験を向上させる以下の機能を提供します：

### 1. **worktreeの作成 (`add`)**
```bash
git wtree add feature/new-feature
git wtree add hotfix/bug-123 ../hotfix-123
```
- ブランチ名からディレクトリ名を自動生成
- 存在しない場合は新しいブランチを作成
- カスタムパスの指定をサポート

### 2. **worktreeの一覧表示 (`list`, `ls`)**
```bash
git wtree list
git wtree ls
```
- メインとworktreeの色分け表示
- 各worktreeのHEADコミットとブランチ名を表示
- クリーンで整理されたフォーマット

### 3. **worktreeへの移動 (`go`)**
```bash
git wtree go new-feature
```
- worktree名またはブランチ名で検索
- 移動用のcdコマンドを表示
- 対象が見つからない場合は利用可能なworktreeを表示

### 4. **worktreeの削除 (`remove`, `rm`)**
```bash
git wtree remove old-feature
git wtree rm old-feature
```
- 名前またはブランチで対象を特定
- worktreeを安全に削除

### 5. **ステータスの確認 (`status`)**
```bash
git wtree status
```
- すべてのworktreeのステータスを一覧表示
- コミットされていない変更の数を表示
- 欠落しているディレクトリを検出

### 6. **クリーンアップ (`clean`)**
```bash
git wtree clean
```
- 削除されたディレクトリのworktreeを削除
- `git worktree prune`を実行

## 🎨 特徴

### カラー表示
- 🟢 メインworktree
- 🔵 通常のworktree
- 🟡 警告（コミットされていない変更）
- 🔴 エラー（ディレクトリが見つからない）

### 環境変数のサポート
```bash
export GIT_WTREE_BASE="~/projects/worktrees"
```
デフォルトのworktree作成場所を設定

### 自動ブランチ名フォーマット
`feature/user-auth`のようなブランチ名を`../user-auth`のような適切なディレクトリ名に変換

### エラーハンドリング
- gitリポジトリ外での実行を検出
- 存在しないworktreeへのアクセスを防止
- 明確なエラーメッセージ

## 💡 ユースケース

1. **機能開発**: メインブランチを離れることなく、別々のディレクトリで新機能を開発
2. **ホットフィックス**: 現在の作業を中断することなく、別のworktreeで緊急の修正を処理
3. **コードレビュー**: 他の人のブランチを別のworktreeでチェックアウト
4. **並行作業**: 複数の機能を異なるディレクトリで同時に開発

## 📦 インストール

```bash
cargo install git-wtree
```

## 🔧 設定

デフォルトのworktreeベースディレクトリを設定：
```bash
export GIT_WTREE_BASE=".worktree"  # デフォルト
```

## 📝 使い方

```bash
# 新しいworktreeを作成
git wtree add feature/awesome-feature

# すべてのworktreeを一覧表示
git wtree ls

# worktreeに移動
git wtree go awesome-feature

# すべてのworktreeのステータスを確認
git wtree status

# worktreeを削除
git wtree rm old-feature

# 欠落しているworktreeをクリーンアップ
git wtree clean
```

このプラグインにより、ブランチの切り替えを繰り返すことなく、複数の作業ストリームを効率的に管理できます！