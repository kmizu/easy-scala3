# 第2章 数値で遊んでみよう

## はじめに

前の章では、初めてのプログラムを作りました。今度は、コンピュータの得意技「計算」を学びましょう！

電卓を使ったことはありますよね？Scalaは、とても賢い電卓のように使えます。しかも、計算結果を覚えておいたり、複雑な計算を簡単にしたりできるんです。

この章で学ぶこと：
- 🔢 基本的な計算（足し算、引き算、掛け算、割り算）
- 📦 計算結果を保存する方法
- 🎯 もっと便利な計算方法
- 💡 プログラムで計算を活用する方法

## 基本的な計算

### 四則演算って何？

「四則演算」は、算数で習った4つの計算のことです：
- **足し算**（たす）: +
- **引き算**（ひく）: -
- **掛け算**（かける）: ×（プログラムでは * を使います）
- **割り算**（わる）: ÷（プログラムでは / を使います）

### REPLで計算してみよう

まずはREPLを起動しましょう。ターミナルで：

```bash
scala
```

`scala>` が表示されたら、計算できる準備完了です！

#### 足し算（加算）- プラス記号を使おう

```scala
scala> 10 + 20
val res0: Int = 30
```

**何が起きたの？**
1. `10 + 20` と入力した
2. Scalaが計算して `30` という答えを出した
3. その答えを `res0` という名前で覚えてくれた
4. `Int` は「整数」という意味（Integer の略）

もう少し試してみましょう：

```scala
scala> 123 + 456
val res1: Int = 579

scala> 1 + 2 + 3 + 4 + 5  // 何個でも足せます！
val res2: Int = 15
```

💡 **ポイント**：スペースは入れても入れなくても大丈夫です
- `10+20` でもOK
- `10 + 20` でもOK（見やすいのでオススメ）

#### 引き算（減算）- マイナス記号を使おう

```scala
scala> 100 - 30
val res2: Int = 70
```

普通の引き算ですね。では、小さい数から大きい数を引くとどうなるでしょう？

```scala
scala> 50 - 80
val res3: Int = -30  // マイナスの結果も扱えます
```

**マイナスの数も大丈夫！**
- `-30` は「マイナス30」
- 温度計で「マイナス5度」というのと同じ考え方です

```scala
scala> 0 - 100      // ゼロから100を引く
val res4: Int = -100

scala> -20 - 10     // マイナスの数からも引ける
val res5: Int = -30
```

#### 掛け算（乗算）- アスタリスク（*）を使おう

学校では「×」を使いますが、プログラミングでは `*`（アスタリスク）を使います。

```scala
scala> 5 * 6
val res4: Int = 30
```

**なぜ * を使うの？**
- キーボードに「×」がないから
- 世界中のプログラマーが `*` を使う約束をしているから

```scala
scala> 12 * 12
val res5: Int = 144

scala> 2 * 3 * 4    // 連続でかけ算もできる
val res6: Int = 24

scala> 100 * 0      // ゼロをかけると...
val res7: Int = 0   // やっぱりゼロ！
```

#### 割り算（除算）- スラッシュ（/）を使おう

割り算は `/`（スラッシュ）を使います。

```scala
scala> 20 / 4
val res6: Int = 5

scala> 17 / 5
val res7: Int = 3  // 整数同士の割り算は整数になります（小数点以下は切り捨て）
```

**重要な注意点**：17 ÷ 5 = 3.4 ですが、答えは `3` になります
- 整数（Int）同士の割り算は、小数点以下が消えちゃいます
- 3.4 の `.4` の部分がなくなって `3` だけ残る
- これを「切り捨て」と言います

### 余りの計算 - パーセント記号（%）を使おう

割り算の「余り」を知りたいときは `%`（パーセント記号）を使います。

**余りって何？**
例：17個のお菓子を5人で分けると、1人3個ずつもらえて、2個余ります。
この「2個」が余りです。

```scala
scala> 17 % 5
val res8: Int = 2  // 17 ÷ 5 = 3 余り 2
```

他の例も見てみましょう：

```scala
scala> 10 % 3
val res9: Int = 1  // 10 ÷ 3 = 3 余り 1
// 10個のりんごを3人で分けると、1人3個で1個余る

scala> 20 % 4
val res10: Int = 0  // 20 ÷ 4 = 5 余り 0（割り切れる）
// 20個のクッキーを4人で分けると、ちょうど1人5個（余りなし）
```

💡 **余りはいつ使うの？**
- 偶数・奇数の判定：`数 % 2` が0なら偶数、1なら奇数
- 曜日の計算：日数を7で割った余りで曜日がわかる
- グループ分け：人数を班の数で割った余りで、どの班に入るか決める

## 計算の優先順位

### 通常の数学と同じルール

算数で習った「かけ算・わり算は、たし算・ひき算より先」のルールは、プログラミングでも同じです！

```scala
scala> 2 + 3 * 4
val res11: Int = 14  // 3 * 4が先に計算される（2 + 12 = 14）
```

**計算の順番**：
1. まず `3 * 4 = 12`
2. 次に `2 + 12 = 14`

もう一つの例：

```scala
scala> 10 - 6 / 2
val res12: Int = 7   // 6 / 2が先に計算される（10 - 3 = 7）
```

**計算の順番**：
1. まず `6 / 2 = 3`
2. 次に `10 - 3 = 7`

### 括弧を使った優先順位の変更

「たし算を先にしたい！」というときは、括弧 `()` を使います。

```scala
scala> (2 + 3) * 4
val res13: Int = 20  // 括弧内が先に計算される（5 * 4 = 20）
```

**計算の順番**：
1. まず括弧の中 `(2 + 3) = 5`
2. 次に `5 * 4 = 20`

括弧があるときとないときを比べてみましょう：

```scala
scala> 2 + 3 * 4    // 括弧なし
val res11: Int = 14  // 2 + 12 = 14

scala> (2 + 3) * 4  // 括弧あり
val res13: Int = 20  // 5 * 4 = 20
```

全然違う答えになりましたね！

### 複雑な計算の例

括弧が何重にもなっている計算も、内側から順番に計算します：

```scala
scala> ((5 + 3) * 2 - 10) / 3
val res15: Int = 2
```

**計算の流れを追ってみましょう**：
```
((5 + 3) * 2 - 10) / 3
    ↓ まず一番内側の括弧
(  8    * 2 - 10) / 3
    ↓ 次にかけ算
(    16     - 10) / 3
    ↓ 引き算
(        6      ) / 3
    ↓ 最後に割り算
         2
```

💡 **コツ**：複雑な計算は、紙に書いて順番を確認すると間違えにくいです！

## 小数を使った計算

### Double型（小数）って何？

今まで使っていた `Int` は整数（1, 2, 3...）でしたが、
`Double` は小数点がある数（1.5, 3.14...）を表します。

**Int と Double の違い**：
- `Int`（Integer = 整数）: 1, 42, -100 など
- `Double`（倍精度浮動小数点数）: 3.14, 0.5, -2.7 など

```scala
scala> 3.14
val res16: Double = 3.14  // 「Double」と表示される！

scala> 10.5 + 2.3
val res17: Double = 12.8

scala> 7.0 / 2.0
val res18: Double = 3.5  // 小数同士の割り算は小数になる
```

整数の割り算と比べてみましょう：

```scala
scala> 7 / 2        // 整数同士
val res19: Int = 3   // 小数点以下が消える

scala> 7.0 / 2.0    // 小数同士
val res20: Double = 3.5  // ちゃんと3.5になる！
```

### 整数と小数の混在

整数と小数を一緒に計算すると、結果は自動的に小数（Double）になります：

```scala
scala> 10 + 2.5
val res19: Double = 12.5  // 結果は自動的にDoubleになる
```

**なぜDoubleになるの？**
- 10（整数）と 2.5（小数）を足すと 12.5
- 12.5 は小数なので、Intでは表せない
- だから自動的にDoubleになる！

割り算でも同じです：

```scala
scala> 15 / 2      // 整数同士
val res20: Int = 7  // 切り捨てられる

scala> 15 / 2.0    // 片方が小数
val res21: Double = 7.5   // ちゃんと7.5になる！
```

💡 **テクニック**：正確な割り算をしたいときは、`.0` をつけて小数にしましょう！

## 変数を使った計算

### プログラムファイルでの計算

実際のプログラムでは、計算結果を変数に保存して使います。
お買い物の計算プログラムを作ってみましょう！

`Calculator.scala`というファイルを作成：

```scala
// Calculator.scala
@main def calculate(): Unit = {
  // 商品の価格計算
  val price = 1200        // 商品の単価
  val quantity = 3        // 個数
  val total = price * quantity
  
  println(s"単価: ${price}円")
  println(s"個数: ${quantity}個")
  println(s"合計: ${total}円")
  
  // 消費税の計算
  val taxRate = 0.1       // 消費税率10%
  val tax = total * taxRate
  val totalWithTax = total + tax
  
  println(s"消費税: ${tax}円")
  println(s"税込み合計: ${totalWithTax}円")
}
```

**コードの詳しい説明**：

1. **変数の定義**
   ```scala
   val price = 1200        // 「price」という箱に1200を入れる
   val quantity = 3        // 「quantity」という箱に3を入れる
   ```

2. **計算**
   ```scala
   val total = price * quantity  // 1200 × 3 = 3600
   ```
   - `price` の中身（1200）と `quantity` の中身（3）をかけ算
   - 結果の3600を `total` という新しい箱に入れる

3. **消費税の計算**
   ```scala
   val taxRate = 0.1       // 10% = 0.1
   val tax = total * taxRate  // 3600 × 0.1 = 360.0
   ```
   - パーセントは小数で表す（10% = 0.1、8% = 0.08）

4. **最終的な合計**
   ```scala
   val totalWithTax = total + tax  // 3600 + 360.0 = 3960.0
   ```

実行結果：

```
単価: 1200円
個数: 3個
合計: 3600円
消費税: 360.0円
税込み合計: 3960.0円
```

## 便利な数学関数

### Math オブジェクトって何？

Scalaには「Math」という便利な道具箱があります。
難しい計算をやってくれる関数（機能）がたくさん入っています！

### べき乗（累乗）の計算

「2の3乗」（2×2×2）のような計算を「べき乗」と言います：

```scala
// PowerAndSqrt.scala
@main def mathFunctions(): Unit = {
  // べき乗（2の3乗）
  val power = Math.pow(2, 3)
  println(s"2の3乗 = ${power}")
```

**Math.pow の使い方**：
- `Math.pow(基数, 指数)`
- `Math.pow(2, 3)` = 2³ = 2×2×2 = 8
- `Math.pow(5, 2)` = 5² = 5×5 = 25
  
  // 平方根
  val sqrt = Math.sqrt(16)
  println(s"16の平方根 = ${sqrt}")
  
  // 絶対値
  val abs1 = Math.abs(-10)
  val abs2 = Math.abs(10)
  println(s"|-10| = ${abs1}")
  println(s"|10| = ${abs2}")
  
  // 最大値と最小値
  val max = Math.max(15, 23)
  val min = Math.min(15, 23)
  println(s"15と23の大きい方: ${max}")
  println(s"15と23の小さい方: ${min}")
}
```

実行結果：

```
2の3乗 = 8.0
16の平方根 = 4.0
|-10| = 10
|10| = 10
15と23の大きい方: 23
15と23の小さい方: 15
```

### 四捨五入、切り上げ、切り捨て

```scala
// Rounding.scala
@main def rounding(): Unit = {
  val number = 3.7
  
  // 四捨五入
  val rounded = Math.round(number)
  println(s"${number}の四捨五入: ${rounded}")
  
  // 切り上げ
  val ceiling = Math.ceil(number)
  println(s"${number}の切り上げ: ${ceiling}")
  
  // 切り捨て
  val floor = Math.floor(number)
  println(s"${number}の切り捨て: ${floor}")
  
  // 別の例
  val number2 = 3.2
  println(s"\n${number2}の場合:")
  println(s"四捨五入: ${Math.round(number2)}")
  println(s"切り上げ: ${Math.ceil(number2)}")
  println(s"切り捨て: ${Math.floor(number2)}")
}
```

実行結果：

```
3.7の四捨五入: 4
3.7の切り上げ: 4.0
3.7の切り捨て: 3.0

3.2の場合:
四捨五入: 3
切り上げ: 4.0
切り捨て: 3.0
```

## 大きな数値の扱い

### Long型（大きな整数）

Int型では約21億までしか扱えませんが、Long型ならもっと大きな数を扱えます：

```scala
// BigNumbers.scala
@main def bigNumbers(): Unit = {
  val population = 7_800_000_000L  // 世界人口（約78億）
  val distance = 384_400L          // 地球から月までの距離（km）
  
  println(s"世界人口: ${population}人")
  println(s"地球から月まで: ${distance}km")
  
  // 大きな計算
  val totalDistance = distance * 2  // 往復
  println(s"地球-月往復: ${totalDistance}km")
}
```

注意：
- 数値にアンダースコア`_`を入れて読みやすくできます
- Long型の数値には最後に`L`をつけます

## 型の変換

### 自動的な型変換

```scala
scala> val intNum: Int = 10
scala> val doubleNum: Double = intNum  // IntからDoubleへ自動変換
val doubleNum: Double = 10.0
```

### 明示的な型変換

```scala
// TypeConversion.scala
@main def typeConversion(): Unit = {
  val doubleValue = 3.9
  val intValue = doubleValue.toInt  // 小数点以下切り捨て
  
  println(s"元の値: ${doubleValue}")
  println(s"Int型に変換: ${intValue}")
  
  // 文字列から数値への変換
  val str1 = "123"
  val num1 = str1.toInt
  println(s"\"${str1}\" → ${num1}")
  
  val str2 = "45.67"
  val num2 = str2.toDouble
  println(s"\"${str2}\" → ${num2}")
}
```

## よくあるエラーと対処法

### エラー例1：ゼロ除算

ゼロで割るとエラーが発生します：

```scala
scala> 10 / 0
java.lang.ArithmeticException: / by zero
```

**エラーの意味**：
- `ArithmeticException` = 算術例外（計算できない！）
- `/ by zero` = ゼロで割った

**なぜエラー？**
10個のリンゴを0人で分けることはできませんよね？

**対処法**: 割る前にチェックする

```scala
@main def safeDivision(): Unit = {
  val a = 10
  val b = 0
  
  if (b != 0) {  // bが0じゃないときだけ割り算する
    println(s"${a} / ${b} = ${a / b}")
  } else {       // bが0のとき
    println("エラー: ゼロで割ることはできません")
  }
}
```

**ポイント**：`if` 文を使って「もし～なら」という条件を作ります（詳しくは第14章で！）

### エラー例2：オーバーフロー（桁あふれ）

Int型には「最大値」があります。それを超えると変なことが起きます：

```scala
scala> val big: Int = 2_000_000_000  // 20億
scala> val result = big + big         // 20億 + 20億 = 40億のはずが...
val result: Int = -294967296          // マイナスになった！？
```

**なぜこうなるの？**
Int型は約-21億～+21億までしか扱えません。
それを超えると「一周して」マイナスから始まります。

**対処法**: 大きな数にはLong型を使う

```scala
val big: Long = 2_000_000_000L  // 最後に「L」をつける
val result = big + big           // 4000000000L（正しい！）
```

💡 **豆知識**：Long型は約-900京～+900京まで扱えます！

### エラー例3：文字列から数値への変換エラー

数字じゃない文字列を数値に変換しようとすると：

```scala
scala> "abc".toInt
java.lang.NumberFormatException: For input string: "abc"
```

**エラーの意味**：
- `NumberFormatException` = 数値の形式例外
- `For input string: "abc"` = 「abc」という文字列に対して

**つまり**：「abc」を数字に変換できません！

**正しい例**：
```scala
"123".toInt    // OK：123になる
"45.6".toDouble // OK：45.6になる
"100円".toInt   // エラー：「円」が入ってる
```

**対処法**: 今は「数字だけの文字列」を使いましょう（後の章でエラー処理を学びます）

## 実践的な例：BMI計算プログラム

今まで学んだことを使って、健康管理に役立つBMI計算プログラムを作りましょう！

**BMIって何？**
Body Mass Index（ボディ・マス指数）の略で、身長と体重から計算する肥満度の指標です。

```scala
// BMICalculator.scala
@main def calculateBMI(): Unit = {
  // 身長と体重の設定
  val heightCm = 170.0    // 身長（センチメートル）
  val weight = 65.0       // 体重（キログラム）
  
  // BMIの計算
  // BMI = 体重(kg) ÷ 身長(m) ÷ 身長(m)
  val heightM = heightCm / 100.0  // cmをmに変換（170cm → 1.7m）
  val bmi = weight / (heightM * heightM)
  
  // 結果の表示
  println("=== BMI計算結果 ===")
  println(s"身長: ${heightCm}cm")
  println(s"体重: ${weight}kg")
  println(s"BMI: ${Math.round(bmi * 10) / 10.0}")  // 小数第1位まで表示
  
  // BMIの判定（簡易版）
  if (bmi < 18.5) {
    println("判定: やせ型")
  } else if (bmi < 25) {
    println("判定: 標準")
  } else {
    println("判定: 肥満")
  }
}
```

**コードの詳しい説明**：

1. **小数第1位まで表示するテクニック**
   ```scala
   Math.round(bmi * 10) / 10.0
   ```
   - 例：bmi = 22.4567 の場合
   - 22.4567 × 10 = 224.567
   - Math.round(224.567) = 225
   - 225 ÷ 10.0 = 22.5

2. **if-else if-else の使い方**
   - 最初の条件から順番にチェック
   - どれか一つに当てはまったら、そこで終了

実行結果：
```
=== BMI計算結果 ===
身長: 170.0cm
体重: 65.0kg
BMI: 22.5
判定: 標準
```

## 練習問題

### 問題1：温度変換

摂氏温度を華氏温度に変換するプログラムを作成してください。
- 変換式：華氏 = 摂氏 × 9/5 + 32
- 摂氏20度の場合の華氏温度を表示

### 問題2：円の計算

半径10の円について、以下を計算して表示するプログラムを作成してください：
- 円周（2 × π × 半径）
- 面積（π × 半径²）
- πには`Math.PI`を使用

### 問題3：おつりの計算

1000円札で678円の買い物をした時のおつりを計算し、以下のように表示してください：
```
支払い: 1000円
購入金額: 678円
おつり: 322円
```

### 問題4：割り勘計算

合計金額4980円を3人で割り勘する場合：
- 一人あたりの金額（1円未満切り上げ）
- 合計で集める金額
- 余る金額

### 問題5：エラーを修正

以下のプログラムのエラーを修正してください：

```scala
@main def broken(): Unit = {
  val x = 10
  val y = 3.5
  val result = x / 0
  println(s"結果: ${result}")
}
```

## まとめ

この章では以下のことを学びました：

1. **基本的な四則演算**
    - 足し算、引き算、掛け算、割り算
    - 余りの計算（`%`）

2. **計算の優先順位**
    - 通常の数学と同じルール
    - 括弧による優先順位の変更

3. **数値の型**
    - Int型（整数）
    - Double型（小数）
    - Long型（大きな整数）

4. **便利な数学関数**
    - Math.pow（べき乗）
    - Math.sqrt（平方根）
    - Math.round（四捨五入）

5. **型の変換**
    - 自動変換と明示的な変換
    - 文字列から数値への変換

次の章では、値と変数についてより詳しく学びます。変数の命名規則や、値を変更できる変数と変更できない変数の違いなどを見ていきましょう！

## 補足：数値リテラルの表記法

Scalaでは数値を見やすく書くための工夫があります：

```scala
// アンダースコアで区切る
val million = 1_000_000
val binary = 0b1010_1010  // 2進数
val hex = 0xFF_FF        // 16進数

// 指数表記
val scientific = 1.23e4   // 1.23 × 10^4 = 12300.0
val tiny = 1.5e-3        // 1.5 × 10^-3 = 0.0015
```