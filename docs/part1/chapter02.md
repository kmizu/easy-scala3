# 第2章 数値で遊んでみよう

## はじめに

プログラミングの基本は計算です。この章では、Scalaで数値を扱う方法を学びます。電卓のような簡単な計算から始めて、徐々に複雑な計算ができるようになりましょう。

## 基本的な計算

### 四則演算

まずはREPLを起動して、基本的な計算をしてみましょう：

```bash
scala
```

#### 足し算（加算）

```scala
scala> 10 + 20
val res0: Int = 30

scala> 123 + 456
val res1: Int = 579
```

#### 引き算（減算）

```scala
scala> 100 - 30
val res2: Int = 70

scala> 50 - 80
val res3: Int = -30  // マイナスの結果も扱えます
```

#### 掛け算（乗算）

```scala
scala> 5 * 6
val res4: Int = 30

scala> 12 * 12
val res5: Int = 144
```

#### 割り算（除算）

```scala
scala> 20 / 4
val res6: Int = 5

scala> 17 / 5
val res7: Int = 3  // 整数同士の割り算は整数になります（小数点以下は切り捨て）
```

### 余りの計算

割り算の余りを求めるには`%`を使います：

```scala
scala> 17 % 5
val res8: Int = 2  // 17 ÷ 5 = 3 余り 2

scala> 10 % 3
val res9: Int = 1  // 10 ÷ 3 = 3 余り 1

scala> 20 % 4
val res10: Int = 0  // 20 ÷ 4 = 5 余り 0（割り切れる）
```

## 計算の優先順位

### 通常の数学と同じルール

```scala
scala> 2 + 3 * 4
val res11: Int = 14  // 3 * 4が先に計算される（2 + 12 = 14）

scala> 10 - 6 / 2
val res12: Int = 7   // 6 / 2が先に計算される（10 - 3 = 7）
```

### 括弧を使った優先順位の変更

```scala
scala> (2 + 3) * 4
val res13: Int = 20  // 括弧内が先に計算される（5 * 4 = 20）

scala> (10 - 6) / 2
val res14: Int = 2   // 括弧内が先に計算される（4 / 2 = 2）
```

### 複雑な計算の例

```scala
scala> ((5 + 3) * 2 - 10) / 3
val res15: Int = 2
// 計算の流れ：
// 1. 5 + 3 = 8
// 2. 8 * 2 = 16
// 3. 16 - 10 = 6
// 4. 6 / 3 = 2
```

## 小数を使った計算

### Double型（小数）

これまでは整数（Int型）を扱ってきましたが、小数も扱えます：

```scala
scala> 3.14
val res16: Double = 3.14

scala> 10.5 + 2.3
val res17: Double = 12.8

scala> 7.0 / 2.0
val res18: Double = 3.5  // 小数同士の割り算は小数になる
```

### 整数と小数の混在

```scala
scala> 10 + 2.5
val res19: Double = 12.5  // 結果は自動的にDoubleになる

scala> 15 / 2.0
val res20: Double = 7.5   // 片方が小数なら結果も小数
```

## 変数を使った計算

### プログラムファイルでの計算

`Calculator.scala`というファイルを作成：

```scala
// Calculator.scala
@main def calculate(): Unit =
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

### Math オブジェクトの使用

Scalaには様々な数学関数が用意されています：

```scala
// PowerAndSqrt.scala
@main def mathFunctions(): Unit =
  // べき乗（2の3乗）
  val power = Math.pow(2, 3)
  println(s"2の3乗 = ${power}")
  
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
@main def rounding(): Unit =
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
@main def bigNumbers(): Unit =
  val population = 7_800_000_000L  // 世界人口（約78億）
  val distance = 384_400L          // 地球から月までの距離（km）
  
  println(s"世界人口: ${population}人")
  println(s"地球から月まで: ${distance}km")
  
  // 大きな計算
  val totalDistance = distance * 2  // 往復
  println(s"地球-月往復: ${totalDistance}km")
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
@main def typeConversion(): Unit =
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
```

## よくあるエラーと対処法

### エラー例1：ゼロ除算

```scala
scala> 10 / 0
java.lang.ArithmeticException: / by zero
```

**対処法**: 割る数がゼロにならないようにチェックする

```scala
@main def safeDivision(): Unit =
  val a = 10
  val b = 0
  
  if b != 0 then
    println(s"${a} / ${b} = ${a / b}")
  else
    println("エラー: ゼロで割ることはできません")
```

### エラー例2：オーバーフロー

```scala
scala> val big: Int = 2_000_000_000
scala> val result = big + big
val result: Int = -294967296  // 想定外の負の数になる！
```

**対処法**: 大きな数を扱う場合はLong型を使う

```scala
val big: Long = 2_000_000_000L
val result = big + big  // 4000000000L（正しい結果）
```

### エラー例3：文字列から数値への変換エラー

```scala
scala> "abc".toInt
java.lang.NumberFormatException: For input string: "abc"
```

**対処法**: 変換前に文字列が数値かチェックする（後の章で詳しく学びます）

## 実践的な例：BMI計算プログラム

```scala
// BMICalculator.scala
@main def calculateBMI(): Unit =
  // 身長と体重の設定
  val heightCm = 170.0    // 身長（センチメートル）
  val weight = 65.0       // 体重（キログラム）
  
  // BMIの計算
  val heightM = heightCm / 100.0  // メートルに変換
  val bmi = weight / (heightM * heightM)
  
  // 結果の表示
  println("=== BMI計算結果 ===")
  println(s"身長: ${heightCm}cm")
  println(s"体重: ${weight}kg")
  println(s"BMI: ${Math.round(bmi * 10) / 10.0}")  // 小数第1位まで表示
  
  // BMIの判定（簡易版）
  if bmi < 18.5 then
    println("判定: やせ型")
  else if bmi < 25 then
    println("判定: 標準")
  else
    println("判定: 肥満")
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
@main def broken(): Unit =
  val x = 10
  val y = 3.5
  val result = x / 0
  println(s"結果: ${result}")
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