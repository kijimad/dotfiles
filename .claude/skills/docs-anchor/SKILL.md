---
name: docs-anchor
description: Anchor a claim about a language or framework to its canonical official documentation — the librarian move behind correct knowledge mapping. Use when the user wants to verify how something actually works from primary sources, learn deeply rather than take a quick answer, or map knowledge correctly; triggers include 公式ドキュメントで確認, 本当はどう動くのか, 正しくマッピング, anchor to docs. Other skills reach for it when a fact needs an authoritative, versioned source.
---

正典に錨を打つ（anchor to canon）。役割は**司書であって託宣者ではない**。要約を手渡さず、正典すなわち公式ドキュメントの該当節へ導いて本人に読ませ、検証可能な形で知識をマッピングする。もっともらしいが誤った知識を作らせないための校正機構。

対象言語/FW の正典ルートは [`registry.md`](registry.md) を引く。無ければ live で公式を辿り、確定できた正典を registry へ1行足す。

## 手順

1. **幹を選ぶ。** anchor するのは、壊れると行動が狂う load-bearing な主張だけ。枝葉や自明な事実は対象にしない。
   - 完了: anchor 対象が「行動に効く主張」に絞られている。

2. **正典の該当節を確定する。** registry から正典ルートを引き、記憶でなく現物を辿る。URL とバージョンと節まで特定する。ブログ・Stack Overflow・LLM の記憶は正典ではない。使うなら派生と明示し、正典と混ぜない。
   - 完了: 各主張に URL と版と節が付く。版が確定できないものは「要再確認」と印す。

3. **ノードとエッジに錨を打つ。** 用語すなわちノードだけでなく関係すなわちエッジにも錨を打つ。誤りはエッジに宿る。「A は B を保証するのか、たまたまそうなるだけか」「X は vN で廃止されたか」「この API はスレッド安全か、どの条件でか」。
   - 完了: 要となるエッジが少なくとも1本、版付きで anchor されている。

4. **来歴を刻む。** 各ノードとエッジに、種別すなわち normative は docs が言う / inferred は自分が繋いだ、確信度、最終確認日を残す。normative と inferred を言い切りで混ぜない。

5. **本人に読ませ、生成で固める。** 正典の該当節を要約で代替せず本人に読ませる。読んだ後 `reverse-questions` か `grill-me` へ渡して理解を試す。読むだけで終えない。

## ノードの持ち方

```
主張        : 自分の言葉で1文（generation effect で定着する）
正典アンカー : URL + バージョン + 節（正しさを担保する）
種別        : normative / inferred
確信度・最終確認日
```

「自分の言葉」が定着を、「アンカー」が正しさを担う。片方欠けると、借り物の正しさか、自分のものだが誤りか、どちらかに倒れる。

## 他 skill へ渡す

この skill は入口すなわち司書に徹する。教える・試す・残すは既存へ委ねる。

- 「なぜこの形か」で説明する → `explain-design`
- 理解度を試す → `reverse-questions` / `grill-me`
- マッピングを来歴付きでグラフへ永続化する → `graphify`
- 学んだ幹を記憶に残す → `agent-memory`

## 深さの校正

新規・高リスク・非自明な主張は正典まで潜る。定型・低リスクな事実は素早く答え anchor を省く。すべてを潜るのは続かず、あらゆる質問で発火すると邪魔になる。
