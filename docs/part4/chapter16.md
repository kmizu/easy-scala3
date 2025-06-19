# 第16章 関数の定義と利用

## はじめに

料理のレシピを思い出してください。「卵を割る」「野菜を切る」「炒める」など、同じ作業を何度も繰り返しますよね。プログラミングでも同じように、よく使う処理をまとめて名前をつけておくと便利です。

これが「関数」です！関数を使えば、プログラムがスッキリして、同じコードを何度も書かなくて済みます。

## 関数って何だろう？

### 日常生活の関数

```scala
// FunctionsInLife.scala
@main def functionsInLife(): Unit =
  // 関数は「入力」を受け取って「出力」を返す機械のようなもの
  
  // 例1：消費税を計算する関数
  def addTax(price: Int): Int =
    (price * 1.1).toInt
  
  println(s"100円の税込価格: ${addTax(100)}円")
  println(s"500円の税込価格: ${addTax(500)}円")
  
  // 例2：あいさつを作る関数
  def greet(name: String): String =
    s"こんにちは、${name}さん！"
  
  println(greet("太郎"))
  println(greet("花子"))
```

## 関数の定義

### 基本的な関数

```scala
// BasicFunctions.scala
@main def basicFunctions(): Unit =
  // 最もシンプルな関数
  def sayHello(): Unit =
    println("Hello, Scala!")
  
  // 呼び出し
  sayHello()
  
  // 引数（パラメータ）がある関数
  def greetPerson(name: String): Unit =
    println(s"こんにちは、${name}さん！")
  
  greetPerson("山田太郎")
  
  // 値を返す関数
  def double(x: Int): Int =
    x * 2
  
  val result = double(5)
  println(s"5の2倍は$result")
  
  // 複数の引数
  def add(a: Int, b: Int): Int =
    a + b
  
  println(s"3 + 4 = ${add(3, 4)}")
```

### 関数の構成要素

```scala
// FunctionComponents.scala
@main def functionComponents(): Unit =
  // 関数の構成要素を詳しく見てみよう
  
  def calculateArea(width: Double, height: Double): Double =
    width * height
  
  // def：関数を定義するキーワード
  // calculateArea：関数名
  // (width: Double, height: Double)：引数リスト
  // Double：戻り値の型
  // width * height：関数本体
  
  val area = calculateArea(5.0, 3.0)
  println(f"面積: $area%.2f")
  
  // 複数行の関数
  def describePerson(name: String, age: Int): String =
    val category = if age < 20 then "若者" else "大人"
    val message = s"$name さんは $age 歳の $category です。"
    message  // 最後の式が戻り値
  
  println(describePerson("田中", 25))
```

## いろいろな関数の書き方

### 単一式関数

```scala
// SingleExpressionFunctions.scala
@main def singleExpressionFunctions(): Unit =
  // 1行で書ける関数
  def square(x: Int): Int = x * x
  def isEven(n: Int): Boolean = n % 2 == 0
  def max(a: Int, b: Int): Int = if a > b then a else b
  
  println(s"3の2乗: ${square(3)}")
  println(s"4は偶数？: ${isEven(4)}")
  println(s"10と20の大きい方: ${max(10, 20)}")
```

### ブロック式関数

```scala
// BlockFunctions.scala
@main def blockFunctions(): Unit =
  def calculateBMI(weight: Double, height: Double): (Double, String) =
    val heightInMeters = height / 100  // cmをmに変換
    val bmi = weight / (heightInMeters * heightInMeters)
    
    val category = if bmi < 18.5 then "低体重"
                   else if bmi < 25 then "標準"
                   else if bmi < 30 then "肥満1度"
                   else "肥満2度"
    
    (bmi, category)  // タプルで返す
  
  val (bmi, category) = calculateBMI(65, 170)
  println(f"BMI: $bmi%.1f ($category)")
```

### デフォルト引数

```scala
// DefaultArguments.scala
@main def defaultArguments(): Unit =
  // デフォルト値を持つ引数
  def greet(name: String, greeting: String = "こんにちは"): String =
    s"$greeting、$name さん！"
  
  println(greet("太郎"))  // デフォルトの挨拶
  println(greet("花子", "おはよう"))  // カスタム挨拶
  
  // 複数のデフォルト引数
  def createProfile(
    name: String,
    age: Int = 20,
    city: String = "東京"
  ): String =
    s"$name（$age歳）- $city在住"
  
  println(createProfile("山田"))
  println(createProfile("田中", 25))
  println(createProfile("佐藤", 30, "大阪"))
```

### 名前付き引数

```scala
// NamedArguments.scala
@main def namedArguments(): Unit =
  def orderCoffee(
    size: String = "M",
    sugar: Boolean = false,
    milk: Boolean = false
  ): String =
    val additions = List(
      if sugar then "砂糖" else "",
      if milk then "ミルク" else ""
    ).filter(_.nonEmpty)
    
    val addStr = if additions.isEmpty then "" 
                 else s"（${additions.mkString("、")}入り）"
    
    s"${size}サイズのコーヒー$addStr"
  
  // 名前を指定して呼び出し
  println(orderCoffee(milk = true))
  println(orderCoffee(size = "L", sugar = true))
  println(orderCoffee(sugar = true, milk = true, size = "S"))
```

## 実践的な関数の例

### 検証関数

```scala
// ValidationFunctions.scala
@main def validationFunctions(): Unit =
  // メールアドレスの簡易チェック
  def isValidEmail(email: String): Boolean =
    email.contains("@") && email.contains(".")
  
  // パスワードの強度チェック
  def checkPasswordStrength(password: String): String =
    val length = password.length
    val hasUpper = password.exists(_.isUpper)
    val hasLower = password.exists(_.isLower)
    val hasDigit = password.exists(_.isDigit)
    
    val score = List(
      if length >= 8 then 1 else 0,
      if hasUpper then 1 else 0,
      if hasLower then 1 else 0,
      if hasDigit then 1 else 0
    ).sum
    
    score match
      case 4 => "強い"
      case 3 => "普通"
      case 2 => "弱い"
      case _ => "とても弱い"
  
  // テスト
  val emails = List("test@example.com", "invalid-email", "user@domain")
  emails.foreach { email =>
    println(s"$email: ${if isValidEmail(email) then "有効" else "無効"}")
  }
  
  val passwords = List("abc", "Abc123", "MyP@ssw0rd", "password123")
  passwords.foreach { pwd =>
    println(s"$pwd: ${checkPasswordStrength(pwd)}")
  }
```

### 計算関数

```scala
// CalculationFunctions.scala
@main def calculationFunctions(): Unit =
  // 階乗を計算
  def factorial(n: Int): Long =
    if n <= 1 then 1
    else n * factorial(n - 1)
  
  // 最大公約数
  def gcd(a: Int, b: Int): Int =
    if b == 0 then a
    else gcd(b, a % b)
  
  // 素数判定
  def isPrime(n: Int): Boolean =
    if n <= 1 then false
    else if n == 2 then true
    else !(2 to math.sqrt(n).toInt).exists(n % _ == 0)
  
  println(s"5! = ${factorial(5)}")
  println(s"gcd(48, 18) = ${gcd(48, 18)}")
  println(s"17は素数？: ${isPrime(17)}")
  
  // 統計関数
  def statistics(numbers: List[Double]): (Double, Double, Double) =
    val sum = numbers.sum
    val mean = sum / numbers.length
    val variance = numbers.map(x => math.pow(x - mean, 2)).sum / numbers.length
    val stdDev = math.sqrt(variance)
    
    (mean, variance, stdDev)
  
  val data = List(10.0, 20.0, 30.0, 40.0, 50.0)
  val (mean, variance, stdDev) = statistics(data)
  println(f"平均: $mean%.2f, 分散: $variance%.2f, 標準偏差: $stdDev%.2f")
```

### 文字列処理関数

```scala
// StringFunctions.scala
@main def stringFunctions(): Unit =
  // 文字列を中央寄せ
  def center(text: String, width: Int, fill: Char = ' '): String =
    val padding = (width - text.length) / 2
    if padding <= 0 then text
    else fill.toString * padding + text + fill.toString * padding
  
  // 単語の頻度をカウント
  def wordFrequency(text: String): Map[String, Int] =
    text.toLowerCase
        .split("\\s+")
        .filter(_.nonEmpty)
        .groupBy(identity)
        .view.mapValues(_.length)
        .toMap
  
  // キャメルケースに変換
  def toCamelCase(text: String): String =
    text.split("[-_\\s]+")
        .filter(_.nonEmpty)
        .zipWithIndex
        .map { case (word, index) =>
          if index == 0 then word.toLowerCase
          else word.capitalize
        }
        .mkString
  
  // 使用例
  println(center("Title", 20, '*'))
  
  val text = "Scala is fun Scala is powerful"
  println(s"単語の頻度: ${wordFrequency(text)}")
  
  println(s"キャメルケース: ${toCamelCase("hello-world-example")}")
}
```

## 関数を使う利点

### コードの再利用

```scala
// CodeReuse.scala
@main def codeReuse(): Unit =
  // 関数を使わない場合（同じコードの繰り返し）
  println("=== 関数なし ===")
  val price1 = 100
  val tax1 = (price1 * 0.1).toInt
  val total1 = price1 + tax1
  println(s"商品1: ${price1}円 + 税${tax1}円 = ${total1}円")
  
  val price2 = 250
  val tax2 = (price2 * 0.1).toInt
  val total2 = price2 + tax2
  println(s"商品2: ${price2}円 + 税${tax2}円 = ${total2}円")
  
  // 関数を使う場合（スッキリ！）
  println("\n=== 関数あり ===")
  def calculateTotal(price: Int): (Int, Int, Int) =
    val tax = (price * 0.1).toInt
    val total = price + tax
    (price, tax, total)
  
  List(100, 250, 500).foreach { price =>
    val (p, t, total) = calculateTotal(price)
    println(s"商品: ${p}円 + 税${t}円 = ${total}円")
  }
```

### テストしやすい

```scala
// TestableFunctions.scala
@main def testableFunctions(): Unit =
  // テストしやすい純粋関数
  def discount(price: Int, rate: Double): Int =
    (price * (1 - rate)).toInt
  
  // テストケース
  val testCases = List(
    (1000, 0.1, 900),   // 10%オフ
    (500, 0.2, 400),    // 20%オフ
    (2000, 0.3, 1400)   // 30%オフ
  )
  
  println("=== 割引計算のテスト ===")
  testCases.foreach { case (price, rate, expected) =>
    val result = discount(price, rate)
    val status = if result == expected then "✓" else "✗"
    println(f"$status $price円の${(rate*100).toInt}%%オフ = $result円 (期待値: $expected円)")
  }
```

## ローカル関数

```scala
// LocalFunctions.scala
@main def localFunctions(): Unit =
  def processOrder(items: List[(String, Int, Int)]): Int =
    // 関数の中で関数を定義
    def calculateSubtotal(quantity: Int, price: Int): Int =
      quantity * price
    
    def applyDiscount(subtotal: Int): Int =
      if subtotal >= 5000 then (subtotal * 0.9).toInt
      else subtotal
    
    // メインの処理
    val subtotal = items.map { case (_, qty, price) =>
      calculateSubtotal(qty, price)
    }.sum
    
    val total = applyDiscount(subtotal)
    
    println(s"小計: ${subtotal}円")
    if subtotal >= 5000 then
      println("10%割引が適用されました")
    println(s"合計: ${total}円")
    
    total
  
  val order = List(
    ("商品A", 2, 1500),
    ("商品B", 1, 2000),
    ("商品C", 3, 800)
  )
  
  processOrder(order)
```

## 再帰関数

```scala
// RecursiveFunctions.scala
@main def recursiveFunctions(): Unit =
  // フィボナッチ数列
  def fibonacci(n: Int): Int =
    if n <= 1 then n
    else fibonacci(n - 1) + fibonacci(n - 2)
  
  // リストの合計（再帰版）
  def sumList(list: List[Int]): Int = list match
    case Nil => 0
    case head :: tail => head + sumList(tail)
  
  // ツリー構造の探索
  case class TreeNode(value: Int, left: Option[TreeNode], right: Option[TreeNode])
  
  def treeSum(node: Option[TreeNode]): Int = node match
    case None => 0
    case Some(TreeNode(value, left, right)) =>
      value + treeSum(left) + treeSum(right)
  
  // 使用例
  println("フィボナッチ数列:")
  (0 to 10).foreach { n =>
    print(s"${fibonacci(n)} ")
  }
  println()
  
  println(s"\nリストの合計: ${sumList(List(1, 2, 3, 4, 5))}")
  
  val tree = Some(TreeNode(
    10,
    Some(TreeNode(5, None, None)),
    Some(TreeNode(15, None, None))
  ))
  println(s"ツリーの合計: ${treeSum(tree)}")
```

## 練習してみよう！

### 練習1：温度変換

摂氏を華氏に、華氏を摂氏に変換する関数を作ってください。
- 摂氏→華氏: F = C × 9/5 + 32
- 華氏→摂氏: C = (F - 32) × 5/9

### 練習2：文字列操作

文字列を受け取って、以下を行う関数を作ってください：
- 回文（前から読んでも後ろから読んでも同じ）かどうか判定
- 文字列中の母音の数を数える
- 各単語の最初の文字を大文字にする

### 練習3：リスト処理

数値のリストを受け取って、以下を計算する関数を作ってください：
- 偶数のみの合計
- 最大値と最小値の差
- 平均値より大きい要素の個数

## この章のまとめ

関数の定義と利用について学びました！

### できるようになったこと

✅ **関数の基本**
- 関数の定義方法
- 引数と戻り値
- 関数の呼び出し

✅ **いろいろな書き方**
- 単一式関数
- ブロック式関数
- デフォルト引数
- 名前付き引数

✅ **実践的な関数**
- 検証関数
- 計算関数
- 文字列処理

✅ **高度な機能**
- ローカル関数
- 再帰関数
- 関数の設計原則

### 関数を使うコツ

1. **単一責任の原則**
   - 1つの関数は1つのことをする
   - 名前から機能が分かるように
   - 短く、理解しやすく

2. **適切な抽象化**
   - 共通部分を関数に
   - パラメータで柔軟性を
   - 再利用を意識

3. **テストしやすさ**
   - 入力と出力が明確
   - 副作用を避ける
   - 純粋関数を心がける

### 次の章では...

関数の引数をもっと賢く使う方法を学びます。可変長引数やカリー化など、さらに高度な機能を習得しましょう！

### 最後に

関数は「プログラムの部品」です。良い部品を作れば、複雑なプログラムも簡単に組み立てられます。レゴブロックのように、小さな関数を組み合わせて大きなプログラムを作る楽しさを味わってください！