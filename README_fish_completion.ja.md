# git-wtree Fish Shell補完

このディレクトリには、`git-wtree`コマンドのfish shell補完サポートが含まれています。

## インストール

1. 補完ファイルをfishの補完ディレクトリにコピーします：
   ```bash
   cp completions/git-wtree.fish ~/.config/fish/completions/
   ```

2. fishシェルをリロードするか、新しいセッションを開始します。

## 機能

この補完は以下の機能を提供します：

- **サブコマンド補完**: エイリアスを含むすべての利用可能なサブコマンドを補完
  - `add` - 新しいworktreeを作成
  - `list` / `ls` - すべてのworktreeを一覧表示
  - `go` - worktreeへのナビゲーションガイドを表示
  - `remove` / `rm` - worktreeを削除
  - `status` - すべてのworktreeのステータスを表示
  - `clean` - 存在しないworktreeをクリーンアップ

- **コンテキスト対応補完**:
  - `git-wtree add`の後のブランチ名
  - `git-wtree go`と`git-wtree remove`の後のworktree名
  - `add`のオプション第2引数でのパス補完

## テスト

この補完には、fishの組み込みテスト機能を使用した包括的なテストスイートが含まれています。

### テストの実行

1. 基本的なユニットテスト：
   ```bash
   cd tests
   fish test_completion.fish
   ```

2. 実際のシナリオテスト（一時的なgitリポジトリを作成）：
   ```bash
   cd tests
   fish test_real_scenario.fish
   ```

### テストカバレッジ

テストスイートは以下をカバーしています：
- サブコマンド補完
- エイリアスサポート（ls、rm）
- `add`コマンドのブランチ名補完
- `go`および`remove`コマンドのworktree名補完
- ターミナルコマンド（status、clean、list）後の補完なし
- パス補完の動作

## 開発

### ファイル構造

```
completions/
  git-wtree.fish    # メイン補完ファイル
tests/
  test_completion.fish      # ユニットテスト
  test_real_scenario.fish   # 統合テスト
  setup_test_repo.fish      # テストリポジトリ作成ヘルパー
docs/
  completion.md     # 補完戦略ドキュメント
```

### ヘルパー関数

補完は以下のヘルパー関数を使用しています：
- `__fish_git_wtree_using_command` - 特定のサブコマンドが使用されているかチェック
- `__fish_git_wtree_needs_command` - サブコマンドがまだ指定されていないかチェック
- `__fish_git_wtree_branches` - 利用可能なgitブランチをリスト
- `__fish_git_wtree_worktrees` - 既存のworktreeをリスト
- `__fish_git_wtree_add_needs_branch` - addコマンドがブランチ補完を必要としているかチェック
- `__fish_git_wtree_add_needs_path` - addコマンドがパス補完を必要としているかチェック