# 正典レジストリ

言語/FW ごとの正典 URL。1行の追加で言語を増やす。
版は URL に埋める。pin できる版付き URL（`@vX.Y.Z`、`/docs/16/`、`/oas/v3.1.0.html` 等）を出せば版の記載は要らない。URL が latest で版を持てないなら、自分が使う版を手元で確認して読む。
別途の注記は、規範が後継へ置き換わる supersession と、公式に見えて正典でない取り違えの罠だけ。二次情報すなわちブログ・Stack Overflow・wiki は正典でなく派生として扱う。

## Go

- 言語仕様（normative）: https://go.dev/ref/spec — 節に固定アンカーがある
- 標準ライブラリ（normative）: https://pkg.go.dev/std — パッケージ単位
- サードパーティ（normative）: `https://pkg.go.dev/<module path>` — 各プロジェクトで確認。`@vX.Y.Z` で URL に版を固定
- ツール/コマンド: https://pkg.go.dev/cmd/go 、https://go.dev/doc
- ガイド（semi-normative、仕様でなく作法）: https://go.dev/doc/effective_go
- 変更履歴: https://go.dev/doc/devel/release

## Linux

- man pages（normative。syscall=2 / libc=3 / 設定ファイル=5）: https://man7.org/linux/man-pages/ （上流 https://www.kernel.org/doc/man-pages/ ）。同名でも glibc 由来と kernel man-pages 由来で内容が分かれる点に注意
- カーネル文書（normative）: https://docs.kernel.org/ （sysfs/procfs の ABI は Documentation/ABI/ と `proc(5)`）
- POSIX（normative）: https://pubs.opengroup.org/onlinepubs/9699919799/ （POSIX.1-2017, The Open Group）
- systemd（normative。公式 man）: https://www.freedesktop.org/software/systemd/man/latest/

## RFC / IETF

- RFC 本文（normative。発行元が権威）: https://www.rfc-editor.org/rfc/rfcNNNN （例 https://www.rfc-editor.org/rfc/rfc9110 ）
- 状態と系譜: https://datatracker.ietf.org/doc/html/rfcNNNN （Status＝Proposed Standard / Internet Standard 等、Obsoletes / Obsoleted by / Updates）
- 正誤: https://www.rfc-editor.org/errata/
- supersession: URL は RFC 番号で本文を固定する（不変）が、現行規範かは「Obsoleted by」を辿る。例: HTTP/1.1 は RFC 2616 → 7230-7235 → 9110-9112
- 取り違え注意: MDN の HTTP 解説は導線に良いが、規範は RFC 本文

## AWS

- サービス文書 / API リファレンス（normative）: https://docs.aws.amazon.com/
- CLI リファレンス（normative）: https://docs.aws.amazon.com/cli/latest/reference/
- SDK: 各言語の公式リファレンス（Python は boto3 https://boto3.amazonaws.com/v1/documentation/api/latest/ 、Go は aws-sdk-go-v2 を pkg.go.dev で）
- 注意: リージョン・サービス提供状況・operation の API version で挙動が変わる
- 取り違え注意: AWS Blogs は公式寄りだが reference ではない

## PostgreSQL

- 公式マニュアル（normative）: https://www.postgresql.org/docs/16/ — メジャー版を URL に入れて pin。`/docs/current/` は移動する latest

## OpenAPI

- 仕様（normative）: https://spec.openapis.org/oas/v3.1.0.html — 版が URL に入る。`/oas/latest.html` は移動する
- ソース: https://github.com/OAI/OpenAPI-Specification
- ガイド（semi-normative）: https://learn.openapis.org/ （OpenAPI Initiative）
- 注意: 3.0 系と 3.1 系で差がある
- 取り違え注意: Swagger（swagger.io）は SmartBear のツール文書であり OpenAPI 仕様そのものではない

## TypeSpec

- 公式文書（normative）: https://typespec.io/docs — 言語・標準ライブラリ・エミッタの参照
- ソース: https://github.com/microsoft/typespec

## TypeScript

- Handbook（normative。実質の正典）: https://www.typescriptlang.org/docs/handbook/intro.html
- リリースノート（版ごとの挙動）: https://www.typescriptlang.org/docs/handbook/release-notes/
- tsconfig リファレンス: https://www.typescriptlang.org/tsconfig/
- 取り違え注意: 旧 Language Specification は非メンテなので参照しない

## React

- 公式（normative）: https://react.dev — API 参照は https://react.dev/reference/react
- 取り違え注意: 旧 https://reactjs.org は非現行。react.dev が現行

## Vite

- 公式（normative）: https://vite.dev — 設定は https://vite.dev/config/
- 取り違え注意: 旧ドメイン vitejs.dev でなく現行 vite.dev

## Vitest

- 公式（normative）: https://vitest.dev — API は https://vitest.dev/api/

## Docker

- 公式（normative）: https://docs.docker.com — Dockerfile と Compose の各リファレンス節がある

## Claude Code

- 公式ドキュメント（normative）: https://code.claude.com/docs/en/ — settings-reference / hooks / slash-commands / MCP / SDK / remote-control / routines などの節。各ページは `.../en/<topic>` で `.md` を付けると raw
- 取り違え注意: 正典は code.claude.com/docs。docs.anthropic.com や docs.claude.com/en/docs/claude-code は誤り/旧。「Claude Code（CLI）」と「Claude API / Agent SDK」は別物なので混同しない

## Node.js

- API リファレンス（normative）: https://nodejs.org/api/ （現行 latest）。版は URL に入る https://nodejs.org/docs/latest-vXX.x/api/ で pin。使う版に合わせる（`node --version` / package.json の `engines.node` / .nvmrc）
- 取り違え注意: Node の正典はランタイム API（fs / http / stream 等）。JS 言語仕様そのものは ECMAScript（https://tc39.es/ecma262/）や MDN で、Node ではない。`@types/node`（DefinitelyTyped）は community 型で正典でない

## テンプレート（言語を増やすとき）

## <言語/FW>

- 正典 URL（normative）: <URL。pin できるなら版付きで>
- ガイド（semi-normative）: <URL>
- 取り違え注意（あれば）: <公式に見えて正典でないもの / supersession / 解釈の罠>
