---
name: daily-flipbook
description: 今日のClaude Codeセッションログから振り返り本（FlipBook）を自動生成して開く
---

# Daily FlipBook Generator

今日のClaude Codeセッションログを読み取り、1日の振り返りをページめくりできる「本」として生成するスキル。

## トリガー

- `/daily-flipbook` で起動
- 「今日の振り返り本作って」「日記本生成して」等

## 処理フロー

### Step 1: セッションログの収集

今日のClaude Codeセッションログを両方のパスから収集する:

```bash
# パス1: デフォルト
~/.claude/projects/

# パス2: CLAUDE_CONFIG_DIR指定
~/claude-data/projects/
```

**必ず両方のパスを検索すること。片方だけで「見つからない」は禁止。**

ログファイルはJSONL形式。以下のコマンドで今日のセッションを見つける:

```bash
# 今日更新されたJSONLファイルを検索
find ~/.claude/projects/ -name "*.jsonl" -newer /tmp/today_marker -not -path "*/subagents/*" 2>/dev/null
find ~/claude-data/projects/ -name "*.jsonl" -newer /tmp/today_marker -not -path "*/subagents/*" 2>/dev/null
```

日付マーカーの作成:
```bash
touch -t $(date +%Y%m%d)0000 /tmp/today_marker
```

### Step 2: ログの解析

各JSONLファイルから以下を抽出:

1. **ユーザーのメッセージ** (`type: "user"`) → 何を依頼したか
2. **アシスタントの応答** (`type: "assistant"`) → 何を実行したか
3. **ツール使用** (`tool_use`) → Write, Edit, Bash等の実行内容

これらを時系列で整理し、以下の構造にまとめる:

```
- セッション1: [プロジェクト名]
  - やったこと: [概要]
  - 成果物: [ファイル、コミット等]
  - 学び: [気づき、発見]

- セッション2: ...
```

### Step 3: 本の構成を決定

収集した情報から本の構成を自動生成:

| ページ | 内容 |
|--------|------|
| 表紙 | 日付 + タイトル（「YYYY年MM月DD日の記録」） |
| はじめに | 今日のサマリー（セッション数、主な成果） |
| 各章 | セッションごとの詳細（やったこと、コード、学び） |
| 最終ページ | 今日の振り返り + 明日へのアクション |

**構成ルール:**
- 1セッションにつき1見開き（2ページ）
- 最大6章（12ページ）まで。それ以上は重要度で選別
- コードブロック、引用、ティップスボックスを適宜使用

### Step 4: FlipBook HTMLを生成

テンプレート（`index.html`）をベースに、`pages` 配列を差し替えたHTMLを生成する。

出力先: `/tmp/claude/daily-flipbook/YYYY-MM-DD.html`

使用可能なCSSクラス:
- `.page-title` — 大見出し
- `.chapter-label` — 章番号
- `.page-body` — 本文
- `.code-block` — コード（`.comment`, `.keyword`, `.string`, `.property` でハイライト）
- `.quote` — 引用ブロック
- `.tip-box` — ティップス（`.tip-title` + `<ul>`）
- `.comparison` — 2カラム比較（`.col.good` / `.col.bad`）
- `.divider` — 装飾区切り線
- `.dropcap` — ドロップキャップ（`<p class="dropcap">`）

### Step 5: ブラウザで開く

```bash
open /tmp/claude/daily-flipbook/YYYY-MM-DD.html
```

## 出力例

表紙:
```
2026年4月5日の記録
── Today I Learned ──
```

章の例:
```
第一章: FlipBook UIを作った

「本のページめくるUI作れる？」から始まって、
CSS 3D transformsとWeb Audio APIで
ドラッグでめくれる本のUIを作った。

途中で「マウスで本当にめくれるように」と
要件が追加されて、ドラッグ操作の実装に。
mousedown → mousemove → mouseup で
角度を計算して、50度超えたら完了、
それ以下ならバネで戻す。
```

## 注意事項

- セッションログが見つからない場合は「今日はまだセッションがありません」と伝える
- 個人情報（APIキー、パスワード等）がログに含まれている場合は除外する
- 生成したHTMLにも個人情報を含めない
- ログの解析にはBashツール（jq）を使用する
