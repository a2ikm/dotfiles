# ユーザー設定

## エージェントの進め方

- 方針が明確な作業（原因調査・修正・調査続行・ドキュメント整形など、進め方が定まっているもの）は、各ステップで確認を待たず自律的に進める。承認の問い合わせで作業を細切れに止めない。解決できない問題や仕様上の非自明な判断が生じたときのみ相談する。
  - 確認を待たず進めてよい: worktree 作成・ブランチ命名・PR description 修正・調査続行・自分の issue/PR へのコメント下書き・CI 修正ループ。
  - 必ず確認する: 破壊的操作・PR の Ready 化やレビュー依頼（通知が飛ぶ）・本番/共有環境への操作・外部への投稿の実行（下書きの提示までは自律で進めてよい）。
- 人間に判断を委ねそうになったら、まずその判断の根拠を自分で評価する。特に「これは実際に不具合・リスクになりうるか」は、コードや仕様を調べて自分で結論を出し、対応の要否まで判断する。「どちらにしますか」「どこで扱いますか」と問う前に、根拠を評価すれば自分で決められないかを検討する。人間に問うのは、調べても結論が出せない場合か、価値判断・優先度・意思決定など人間固有の判断が必要な場合に限る。
  - リスクの根拠を得るために、静的解析の実行・テストコードの追加・Draft PR を作って CI を回す、といった手段は自律的に判断して実施してよい。
- 報告は簡潔にする。末尾に「まとめると〜」のような要約は書かない。要約だけで伝わる内容なら、その要約だけを提示する。
- 同じ形の作業を複数の issue / PR / サービスへ横展開（fan-out）するときは、いきなり全対象を並行で走らせない。まず 1 件で出力フォーマットを具体例（golden）まで確定させ、指示文を `.memo/` に書き出してから、残りは指示文への `@参照` と対象 URL だけで着手する。修正が要るときは各チャットではなく指示文 1 本を直す。

## 文章スタイル

- 文章で体言止めを使わないこと。文末は動詞や助動詞で終わるようにする。
- GitHub（PR description・PR コメント・レビューコメント・issue 本文やコメント）に URL を書くときは、生の URL を直接置かず `[hotfix](https://github.com/owner/repo/pull/123)` のように Markdown のリンク記法で書く。GitHub の autolink は生の URL を次の半角スペースが来るまで URL とみなすため、URL をカッコで囲んでも閉じカッコや後続の文字まで URL に取り込まれてしまう。
  ```
  # NG: 「）を一般化し、」まで URL に含まれてしまう
  この不具合（切り戻し hotfix: https://github.com/owner/repo/pull/123）を一般化し、

  # OK
  この不具合（切り戻し [hotfix](https://github.com/owner/repo/pull/123)）を一般化し、
  ```

## Git

- ブランチ名に `/` を含めないこと。区切り文字には `-` を使用する。
- 自分がブランチ上で加えた変更をファイル単位で取り消すとき、復元元は**現ブランチの履歴上のコミット（merge-base かその祖先）に限る**。`git checkout develop -- <file>` や `git checkout origin/develop -- <file>` のように**ブランチ tip を復元元にしない**。分岐後に develop 側が進んでいると、tip 版が無関係な変更を引き込み、意図しない差分が PR に混入する（実際に別機能の変更を混入させた事故あり）。
  - 変更前の状態へ戻すなら `git checkout "$(git merge-base origin/develop HEAD)" -- <file>` などアンカーを明示する。可能なら `git checkout <ref> -- <file>` より **Edit で対象行を直接消す**方を優先する（何を消すか目視できる）。
  - commit / push の前と PR 作成の前に、PR として develop に入る差分を必ず確認する: `git diff "$(git merge-base origin/develop HEAD)"...HEAD --stat`。出た全ファイルが意図したものか目視する。`git diff --cached HEAD` だけで済ませない（それは直前コミットとの差分でしかなく、PR スコープを表さない）。
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
- `git push` したら、変更内容に合わせて PR description も更新する。description の更新には `gh pr edit` を使い、`--body` に直接文字列を渡さず、一時ファイルに本文を書き出してから `--body-file` で渡すようにする。
- `gh` でコメント・issue・PR の本文を `--body-file` で投稿・上書きした後は、必ず投稿結果を取得して本文が正しく反映されているか確認する。ファイルパスの文字列がそのまま本文として投稿されてしまう事故が起きるため、新規投稿だけでなく上書きの場合も確認する。
  ```bash
  # 例: issue コメントを投稿した後に本文を取得して確認する
  gh issue comment <issue-number> --body-file "$tmp"
  gh issue view <issue-number> --json comments --jq '.comments[-1].body'

  # 例: PR description を更新した後に本文を取得して確認する
  gh api repos/{owner}/{repo}/pulls/<pr-number> --jq '.body'
  ```
  取得した本文がファイルパス（例: `/var/folders/.../tmp.XXXX`）になっていた場合は投稿し直す。
- Pull Request の description には「何をしたか」だけでなく、実装の過程で行った設計上のトレードオフ検討を記載する。「別の案 X を検討したが、理由 Y のため採用しなかった」という判断があった場合は、その代替案と不採用の理由を必ず書く。description が「〜をした」という結果の記述だけだと、そうした検討をしたのかどうかがレビュアーに読み取れないため。
- レビューで指摘された項目をその PR で対応せず別作業（別 PR・別 issue）に回すときは、指摘を受けた PR の description に「この PR に含めないもの」として、何を・どこで対応するかを明記する。別作業に回した事実が description に無いと、次のレビューで同じ指摘を繰り返し受けるため。

## Google Workspace

- Google ドキュメント・スプレッドシートなどを取得する際は、`gws` コマンドを使う。事前に以下でトークンを設定する。
  ```bash
  export GOOGLE_WORKSPACE_CLI_TOKEN="$(gcloud auth print-access-token)"
  gws docs documents get --params '{"documentId": "<document-id>"}'
  ```
- タブを持つドキュメントは `"includeTabsContent": true` を付ける。本文テキストだけ取り出すには jq で `[.. | .textRun? // empty | .content] | join("")` のように抽出する。
