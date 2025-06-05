`git-wtree`プラグインは、git worktreeをより便利に使うための以下の機能を提供します：

## 🚀 主要機能

### 1. **worktree作成 (`add`)**
```bash
git wtree add feature/new-feature
git wtree add hotfix/bug-123 ../hotfix-123
```
- ブランチ名から自動的にディレクトリ名を生成
- ブランチが存在しない場合は新規作成
- カスタムパスも指定可能

### 2. **一覧表示 (`list`, `ls`)**
```bash
git wtree ls
```
- メインとworktreeを色分けして表示
- 各worktreeのHEADコミットとブランチ名を表示
- 見やすいフォーマットで整理

### 3. **worktreeへの移動ガイド (`go`)**
```bash
git wtree go new-feature
```
- worktree名またはブランチ名で検索
- 移動用のcdコマンドを表示
- 存在しない場合は利用可能なworktree一覧を表示

### 4. **worktree削除 (`remove`, `rm`)**
```bash
git wtree rm old-feature
```
- 名前やブランチ名で対象を特定
- 安全にworktreeを削除

### 5. **ステータス確認 (`status`)**
```bash
git wtree status
```
- 全worktreeの状態を一覧表示
- 未コミットの変更数を表示
- ディレクトリが存在しないworktreeも検出

### 6. **クリーンアップ (`clean`)**
```bash
git wtree clean
```
- 削除されたディレクトリのworktreeを整理
- `git worktree prune`を実行

## 🎨 便利な特徴

### カラー表示
- 🟢 メインworktree
- 🔵 通常のworktree  
- 🟡 警告（変更あり）
- 🔴 エラー（ディレクトリ欠落）

### 環境変数サポート
```bash
export GIT_WTREE_BASE="~/projects/worktrees"
```
デフォルトのworktree作成場所を設定可能

### ブランチ名の自動整形
`feature/user-auth` → `../user-auth`のように、スラッシュを含むブランチ名から適切なディレクトリ名を生成

### エラーハンドリング
- gitリポジトリ外での実行を検出
- 存在しないworktreeへのアクセスを防止
- 分かりやすいエラーメッセージ

## 💡 使用シナリオ

1. **機能開発**: メインブランチを残したまま新機能を別ディレクトリで開発
2. **緊急修正**: 現在の作業を中断せずにhotfixを別worktreeで対応
3. **レビュー**: 他の人のブランチを別worktreeで確認
4. **並行作業**: 複数の機能を同時に別々のディレクトリで開発

このプラグインにより、ブランチの切り替えなしに複数の作業を効率的に進められます！
