# ユーザー設定

## 文章スタイル

- 文章で体言止めを使わないこと。文末は動詞や助動詞で終わるようにする。

## Git

- ブランチ名に `/` を含めないこと。区切り文字には `-` を使用する。
- `gh pr create` で pull request を作成する際、`--body` に直接文字列を渡さず、一時ファイルに本文を書き出してから `--body-file` で渡すようにする。
  ```bash
  # 一時ファイルに本文を書き出す
  tmp=$(mktemp)
  cat <<'EOF' > "$tmp"
  ## Summary
  - 変更内容の説明
  EOF

  # --body-file で渡す
  gh pr create --title "タイトル" --body-file "$tmp"

  # 一時ファイルを削除する
  rm "$tmp"
  ```
