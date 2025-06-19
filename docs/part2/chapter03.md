# 第3章 値と変数の基本

## はじめに

プログラミングでは、データを扱うために「変数」という概念を使います。変数は、データを入れておく「箱」のようなものです。この章では、Scalaにおける値と変数の基本を学びます。

## 値（val）と変数（var）

Scalaには、データを保存する方法が2つあります：

1. **val**（値）: 一度設定したら変更できない
2. **var**（変数）: 後から変更できる

### val - 変更できない値

```scala
// ValExample.scala
@main def valExample(): Unit =
  val name = "太郎"
  val age = 20
  
  println(s"名前: ${name}")
  println(s"年齢: ${age}")
  
  // val は変更できません
  // name = "次郎"  // これはエラーになります！
```

valの特徴：
- 一度値を設定したら変更できません
- より安全なプログラムが書けます
- Scalaではvalの使用が推奨されています

### var - 変更可能な変数

```scala
// VarExample.scala
@main def varExample(): Unit =
  var count = 0
  println(s"最初のcount: ${count}")
  
  count = 5
  println(s"変更後のcount: ${count}")
  
  count = count + 1
  println(s"1増やした後のcount: ${count}")
```

実行結果：
```
最初のcount: 0
変更後のcount: 5
1増やした後のcount: 6
```

## なぜvalを使うのか？

### valの利点

```scala
// WhyVal.scala
@main def whyVal(): Unit =
  // 商品の価格計算
  val basePrice = 1000
  val taxRate = 0.1
  val discount = 100
  
  // 計算過程が明確
  val priceAfterDiscount = basePrice - discount
  val tax = priceAfterDiscount * taxRate
  val finalPrice = priceAfterDiscount + tax
  
  println(s"定価: ${basePrice}円")
  println(s"割引: ${discount}円")
  println(s"割引後: ${priceAfterDiscount}円")
  println(s"税額: ${tax}円")
  println(s"最終価格: ${finalPrice}円")
```

valを使うメリット：
1. **バグが少ない**: 値が途中で変わらないので、予期しない動作を防げます
2. **読みやすい**: コードを読む人が値の変化を追う必要がありません
3. **並行処理に強い**: 複数の処理が同時に動いても安全です

### varが必要な場面

```scala
// WhenToUseVar.scala
@main def whenToUseVar(): Unit =
  // カウンターのような値を増やしていく処理
  var total = 0
  
  println("数値を足していきます")
  
  total = total + 10
  println(s"10を足して: ${total}")
  
  total = total + 20
  println(s"20を足して: ${total}")
  
  total = total + 30
  println(s"30を足して: ${total}")
  
  println(s"合計: ${total}")
```

## 変数の命名規則

### 基本的なルール

```scala
// NamingRules.scala
@main def namingRules(): Unit =
  // 良い変数名の例
  val firstName = "太郎"       // キャメルケース（推奨）
  val lastName = "山田"
  val userAge = 25
  val isStudent = true
  
  // 数字から始まる変数名はエラー
  // val 1stName = "太郎"  // エラー！
  
  // アンダースコアは使える
  val user_name = "花子"
  val MAX_SIZE = 100
  
  // 日本語も使える（非推奨）
  val 名前 = "太郎"
  println(s"名前: ${名前}")
```

### 命名のベストプラクティス

```scala
// GoodNaming.scala
@main def goodNaming(): Unit =
  // 意味のある名前を使う
  val totalPrice = 1500      // 良い: 何の値か分かる
  val tp = 1500              // 悪い: 意味が不明
  
  // 適切な長さ
  val age = 20                                        // 良い
  val userAgeInYearsAsInteger = 20                  // 悪い: 長すぎる
  
  // 一貫性のある命名
  val userName = "太郎"       // キャメルケース
  val userEmail = "taro@example.com"
  val userPhone = "090-1234-5678"
```

## 型の明示的な指定

### 型推論

Scalaは賢いので、多くの場合、型を自動的に判断してくれます：

```scala
// TypeInference.scala
@main def typeInference(): Unit =
  val number = 42           // Scalaが自動的にIntと判断
  val decimal = 3.14        // Doubleと判断
  val text = "Hello"        // Stringと判断
  val flag = true           // Booleanと判断
  
  println(s"number is ${number.getClass.getSimpleName}")
  println(s"decimal is ${decimal.getClass.getSimpleName}")
  println(s"text is ${text.getClass.getSimpleName}")
  println(s"flag is ${flag.getClass.getSimpleName}")
```

### 型を明示的に書く

時には型を明示的に書いた方が良い場合があります：

```scala
// ExplicitTypes.scala
@main def explicitTypes(): Unit =
  // 型を明示的に指定
  val count: Int = 10
  val price: Double = 99.99
  val name: String = "商品A"
  val available: Boolean = true
  
  // 型を指定することで意図を明確にできる
  val age: Int = 25          // 年齢は整数
  val weight: Double = 65.5  // 体重は小数を含む
  
  // 型が合わない場合はエラー
  // val wrong: Int = 3.14   // エラー！DoubleをIntに入れられない
```

## 定数の扱い

### 大文字の定数

慣習として、変更されない定数は大文字で書きます：

```scala
// Constants.scala
@main def constants(): Unit =
  // 定数は大文字とアンダースコアで命名
  val MAX_USERS = 1000
  val MIN_AGE = 18
  val DEFAULT_TIMEOUT = 30
  val PI = 3.14159
  
  println(s"最大ユーザー数: ${MAX_USERS}")
  println(s"最小年齢: ${MIN_AGE}")
  println(s"デフォルトタイムアウト: ${DEFAULT_TIMEOUT}秒")
  
  // 計算で使用
  val radius = 10
  val circumference = 2 * PI * radius
  println(s"半径${radius}の円周: ${circumference}")
```

## スコープ（変数の有効範囲）

### ブロックスコープ

```scala
// Scope.scala
@main def scopeExample(): Unit =
  val outer = "外側の変数"
  
  // 新しいブロック
  {
    val inner = "内側の変数"
    println(outer)  // 外側の変数は見える
    println(inner)  // 内側の変数も見える
  }
  
  println(outer)  // 外側の変数は見える
  // println(inner)  // エラー！内側の変数は見えない
  
  // if文のスコープ
  val score = 85
  if score >= 80 then
    val grade = "A"
    println(s"成績: ${grade}")
  // println(grade)  // エラー！if文の外では見えない
```

### シャドーイング（変数の隠蔽）

```scala
// Shadowing.scala
@main def shadowingExample(): Unit =
  val x = 10
  println(s"外側のx: ${x}")
  
  {
    val x = 20  // 内側で同じ名前の変数を定義
    println(s"内側のx: ${x}")
  }
  
  println(s"外側のxは変わらない: ${x}")
```

## 実践的な例：買い物リスト

```scala
// ShoppingList.scala
@main def shoppingList(): Unit =
  // 商品情報
  val item1Name = "りんご"
  val item1Price = 150
  val item1Quantity = 3
  
  val item2Name = "牛乳"
  val item2Price = 200
  val item2Quantity = 2
  
  val item3Name = "パン"
  val item3Price = 120
  val item3Quantity = 1
  
  // 小計の計算
  val subtotal1 = item1Price * item1Quantity
  val subtotal2 = item2Price * item2Quantity
  val subtotal3 = item3Price * item3Quantity
  
  // 合計
  val total = subtotal1 + subtotal2 + subtotal3
  
  // レシート出力
  println("=== レシート ===")
  println(s"${item1Name} ${item1Price}円 × ${item1Quantity} = ${subtotal1}円")
  println(s"${item2Name} ${item2Price}円 × ${item2Quantity} = ${subtotal2}円")
  println(s"${item3Name} ${item3Price}円 × ${item3Quantity} = ${subtotal3}円")
  println("----------------")
  println(s"合計: ${total}円")
  
  // ポイント計算（varを使う例）
  var points = 0
  points = total / 100  // 100円につき1ポイント
  println(s"獲得ポイント: ${points}ポイント")
```

## よくあるエラーと対処法

### エラー例1：valへの再代入

```scala
val x = 10
x = 20  // エラー！
```

エラーメッセージ：
```
error: reassignment to val
```

**対処法**: 値を変更したい場合はvarを使う

### エラー例2：初期化されていない変数

```scala
val x: Int  // エラー！初期値がない
```

エラーメッセージ：
```
error: only classes can have declared but undefined members
```

**対処法**: 変数は宣言時に初期値を設定する

### エラー例3：型の不一致

```scala
val age: Int = "20"  // エラー！文字列をIntに入れられない
```

エラーメッセージ：
```
error: type mismatch
  found   : String("20")
  required: Int
```

**対処法**: 正しい型の値を代入するか、型変換を行う

## 練習問題

### 問題1：個人情報の管理

以下の情報を適切な変数に格納して表示するプログラムを作成してください：
- 名前：あなたの名前
- 年齢：あなたの年齢
- 身長：170.5（cm）
- 学生かどうか：true/false

### 問題2：銀行口座シミュレーション

銀行口座の残高管理プログラムを作成してください：
- 初期残高：10000円
- 入金：5000円
- 出金：3000円
- 最終残高を表示

### 問題3：温度変換

以下の要件でプログラムを作成してください：
- 摂氏温度を変数に格納（例：25度）
- 華氏温度に変換（華氏 = 摂氏 × 9/5 + 32）
- 両方の温度を表示

### 問題4：エラーを修正

以下のプログラムのエラーを修正してください：

```scala
@main def broken(): Unit =
  val userName = "太郎"
  val userAge = 20
  
  userName = "次郎"
  
  val message = "こんにちは、" + userName + "さん"
  val NextYear = userAge + 1
  
  println(message)
  println("来年は" + nextyear + "歳ですね")
```

## まとめ

この章では以下のことを学びました：

1. **valとvar**
   - val：変更できない値（推奨）
   - var：変更可能な変数（必要な時だけ使用）

2. **変数の命名規則**
   - キャメルケースを使用（firstName）
   - 意味のある名前をつける
   - 定数は大文字とアンダースコア（MAX_SIZE）

3. **型推論と型指定**
   - Scalaは型を自動的に判断
   - 必要に応じて明示的に型を指定

4. **スコープ**
   - 変数はブロック内でのみ有効
   - 内側のブロックから外側の変数は見える

5. **プログラミングのベストプラクティス**
   - できるだけvalを使う
   - 変数名は分かりやすく
   - 適切なスコープで変数を定義

次の章では、様々な種類のデータ（文字列、真偽値など）について詳しく学んでいきます！