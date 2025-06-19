# 付録E 練習問題解答集

## はじめに

各章の練習問題の解答例です。「正解」は一つではありません。ここに示すのは、あくまで参考例です。自分なりの解法を見つけることも、プログラミングの楽しさの一つです！

## 第1章の解答

### 練習1：Hello, World!を改造

```scala
// 基本の改造
@main def hello(): Unit = {
  println("こんにちは、Scala！")
  println("プログラミングの世界へようこそ！")
  println("一緒に楽しく学びましょう！")
}

// 名前を受け取るバージョン
@main def helloWithName(name: String): Unit = {
  println(s"こんにちは、$name さん！")
  println(s"$name さん、Scalaの世界へようこそ！")
}

// 時間によって挨拶を変える
@main def helloByTime(): Unit = {
  val hour = java.time.LocalDateTime.now().getHour
  val greeting = if (hour < 12) "おはようございます"
                 else if (hour < 18) "こんにちは"
                 else "こんばんは"
  println(s"$greeting、Scala！")
}
```

### 練習2：エラーメッセージと友達になる

```scala
// わざとエラーを起こしてみる

// 1. セミコロン忘れ（Scala 3では問題なし）
val x = 10
val y = 20  // OK

// 2. 括弧の不一致
// println("Hello")  // 正しい
// println("Hello"   // error: ')' expected but eof found

// 3. タイプミス
// prntln("Hello")   // error: not found: value prntln
// println("Hello")  // 正しい

// 4. 文字列の引用符
// println('Hello')  // error: unclosed character literal
// println("Hello")  // 正しい
```

## 第2章の解答

### 練習1：計算機を作る

```scala
@main def calculator(): Unit = {
  // 基本的な四則演算
  val a = 10
  val b = 3
  
  println(s"$a + $b = ${a + b}")
  println(s"$a - $b = ${a - b}")
  println(s"$a * $b = ${a * b}")
  println(s"$a / $b = ${a / b}")
  println(s"$a % $b = ${a % b}")
  
  // 複雑な計算
  val taxRate = 0.1
  val price = 1000
  val taxIncludedPrice = price * (1 + taxRate)
  println(s"税込価格: ${taxIncludedPrice.toInt}円")
}
```

### 練習2：温度変換

```scala
@main def temperatureConverter(): Unit = {
  // 摂氏から華氏へ
  def celsiusToFahrenheit(c: Double): Double = c * 9/5 + 32
  
  // 華氏から摂氏へ
  def fahrenheitToCelsius(f: Double): Double = (f - 32) * 5/9
  
  val celsius = 25.0
  val fahrenheit = celsiusToFahrenheit(celsius)
  println(s"${celsius}°C = ${fahrenheit}°F")
  
  val f = 77.0
  val c = fahrenheitToCelsius(f)
  println(f"${f}°F = ${c}%.1f°C")
}
```

## 第3章の解答

### 練習1：変数と定数

```scala
@main def variablesPractice(): Unit = {
  // 定数（変更不可）
  val pi = 3.14159
  val myName = "太郎"
  
  // 変数（変更可能）
  var age = 20
  var score = 0
  
  println(s"最初: 年齢=$age, スコア=$score")
  
  // 1年後
  age = age + 1
  score = score + 100
  
  println(s"1年後: 年齢=$age, スコア=$score")
  
  // val は変更できない
  // pi = 3.14  // error: reassignment to val
}
```

### 練習2：型を意識する

```scala
@main def typesPractice(): Unit = {
  // 明示的な型指定
  val name: String = "Scala"
  val version: Double = 3.3
  val isAwesome: Boolean = true
  val releaseYear: Int = 2023
  
  // 型推論
  val language = "Scala"  // String型と推論
  val pi = 3.14159        // Double型と推論
  val count = 42          // Int型と推論
  
  // 型の確認（REPLで試すと良い）
  println(s"$name is version $version")
  println(s"Released in $releaseYear")
  println(s"Is it awesome? $isAwesome")
}
```

## 第8章の解答

### 練習1：リスト操作

```scala
@main def listOperations(): Unit = {
  val numbers = List(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
  
  // 偶数だけ抽出
  val evens = numbers.filter(_ % 2 == 0)
  println(s"偶数: $evens")
  
  // 各要素を2倍
  val doubled = numbers.map(_ * 2)
  println(s"2倍: $doubled")
  
  // 合計値
  val sum = numbers.sum
  println(s"合計: $sum")
  
  // 平均値
  val average = sum.toDouble / numbers.length
  println(f"平均: $average%.1f")
  
  // 最大値と最小値
  println(s"最大: ${numbers.max}, 最小: ${numbers.min}")
}
```

### 練習2：ショッピングリスト

```scala
@main def shoppingList(): Unit = {
  case class Item(name: String, price: Int, quantity: Int)
  
  val items = List(
    Item("りんご", 150, 3),
    Item("バナナ", 100, 2),
    Item("オレンジ", 200, 1),
    Item("ぶどう", 500, 1)
  )
  
  // 合計金額
  val total = items.map(item => item.price * item.quantity).sum
  println(s"合計金額: ${total}円")
  
  // 最も高い商品
  val mostExpensive = items.maxBy(_.price)
  println(s"最も高い商品: ${mostExpensive.name} (${mostExpensive.price}円)")
  
  // 200円以下の商品
  val affordable = items.filter(_.price <= 200)
  println(s"200円以下: ${affordable.map(_.name)}")
}
```

## 第14章の解答

### 練習1：成績判定

```scala
@main def gradeChecker(): Unit = {
  def getGrade(score: Int): String = {
    if (score >= 90) "S"
    else if (score >= 80) "A"
    else if (score >= 70) "B"
    else if (score >= 60) "C"
    else "D"
  }
  
  val scores = List(95, 82, 73, 65, 45)
  scores.foreach { score =>
    println(s"点数: $score → 成績: ${getGrade(score)}")
  }
}
```

### 練習2：パターンマッチで曜日

```scala
@main def dayOfWeek(): Unit = {
  def getDayType(day: String): String = day match {
    case "月曜日" | "火曜日" | "水曜日" | "木曜日" | "金曜日" => "平日"
    case "土曜日" | "日曜日" => "週末"
    case _ => "不明な曜日"
  }
  
  val days = List("月曜日", "土曜日", "日曜日", "祝日")
  days.foreach { day =>
    println(s"$day は ${getDayType(day)}")
  }
}
```

## 第16章の解答

### 練習1：関数を作る

```scala
@main def functionsPractice(): Unit = {
  // 面積を計算する関数
  def rectangleArea(width: Double, height: Double): Double = 
    width * height
  
  def circleArea(radius: Double): Double = 
    math.Pi * radius * radius
  
  def triangleArea(base: Double, height: Double): Double = 
    base * height / 2
  
  // 使用例
  println(f"長方形(5×3): ${rectangleArea(5, 3)}%.2f")
  println(f"円(半径4): ${circleArea(4)}%.2f")
  println(f"三角形(底6×高4): ${triangleArea(6, 4)}%.2f")
}
```

### 練習2：高階関数

```scala
@main def higherOrderFunctions(): Unit = {
  // 演算を受け取る関数
  def calculate(a: Int, b: Int, op: (Int, Int) => Int): Int = 
    op(a, b)
  
  val add = (x: Int, y: Int) => x + y
  val multiply = (x: Int, y: Int) => x * y
  val max = (x: Int, y: Int) => if (x > y) x else y
  
  println(s"10 + 5 = ${calculate(10, 5, add)}")
  println(s"10 * 5 = ${calculate(10, 5, multiply)}")
  println(s"max(10, 5) = ${calculate(10, 5, max)}")
  
  // カスタム演算
  val power = (x: Int, y: Int) => math.pow(x, y).toInt
  println(s"2^8 = ${calculate(2, 8, power)}")
}
```

## 第19章の解答

### 練習1：安全な除算

```scala
@main def safeDivision(): Unit = {
  def divide(a: Double, b: Double): Option[Double] = 
    if (b == 0) None else Some(a / b)
  
  val testCases = List((10.0, 2.0), (5.0, 0.0), (15.0, 3.0))
  
  testCases.foreach { case (a, b) =>
    divide(a, b) match {
      case Some(result) => println(f"$a / $b = $result%.2f")
      case None => println(s"$a / $b = エラー: ゼロ除算")
    }
  }
}
```

### 練習2：Either でエラー処理

```scala
@main def errorHandling(): Unit = {
  def parseInt(s: String): Either[String, Int] = 
    try {
      Right(s.toInt)
    } catch {
      case _: NumberFormatException => 
        Left(s"'$s' は数値に変換できません")
    }
  
  val inputs = List("123", "abc", "45.6", "789")
  
  inputs.foreach { input =>
    parseInt(input) match {
      case Right(n) => println(s"成功: $input → $n")
      case Left(error) => println(s"エラー: $error")
    }
  }
}
```

## 第22章の解答

### 練習1：ケースクラス

```scala
@main def caseClassPractice(): Unit = {
  case class Book(
    title: String,
    author: String,
    price: Int,
    year: Int
  ) {
    def discountPrice(rate: Double): Int = 
      (price * (1 - rate)).toInt
  }
  
  val books = List(
    Book("プログラミング入門", "山田太郎", 3000, 2023),
    Book("Scala実践ガイド", "鈴木花子", 3500, 2024),
    Book("関数型プログラミング", "佐藤次郎", 4000, 2022)
  )
  
  // 2023年以降の本
  val recentBooks = books.filter(_.year >= 2023)
  println("最近の本:")
  recentBooks.foreach(println)
  
  // 20%割引価格
  println("\n20%割引後:")
  books.foreach { book =>
    println(s"${book.title}: ${book.discountPrice(0.2)}円")
  }
}
```

## 第25章の解答

### 練習1：関数合成

```scala
@main def functionComposition(): Unit = {
  // 文字列処理の関数
  val trim: String => String = _.trim
  val toUpper: String => String = _.toUpperCase
  val addExclamation: String => String = _ + "!"
  
  // 合成
  val shout = trim andThen toUpper andThen addExclamation
  
  val inputs = List(
    "  hello  ",
    " scala ",
    "  programming  "
  )
  
  inputs.foreach { input =>
    println(s"'$input' → '${shout(input)}'")
  }
  
  // 数値処理の合成
  val double: Int => Int = _ * 2
  val addTen: Int => Int = _ + 10
  val square: Int => Int = x => x * x
  
  val complexCalc = double andThen addTen andThen square
  
  (1 to 5).foreach { n =>
    println(s"f($n) = ${complexCalc(n)}")
  }
}
```

## 第30章の解答

### 練習1：for式

```scala
@main def forComprehension(): Unit = {
  // 九九の表
  println("九九の表:")
  val multiplication = for {
    i <- 1 to 9
    j <- 1 to 9
  } yield s"$i × $j = ${i * j}"
  
  multiplication.grouped(9).foreach { row =>
    println(row.mkString(" | "))
  }
  
  // フィルタリング付き
  println("\n偶数の積のみ:")
  val evenProducts = for {
    i <- 1 to 9
    j <- 1 to 9
    if (i * j) % 2 == 0
  } yield (i, j, i * j)
  
  evenProducts.take(10).foreach { case (i, j, product) =>
    println(s"$i × $j = $product")
  }
}
```

## 第33章の解答

### 練習1：並行処理

```scala
import scala.concurrent._
import scala.concurrent.duration._
import ExecutionContext.Implicits.global

@main def parallelProcessing(): Unit = {
  def fetchData(id: Int): Future[String] = Future {
    Thread.sleep(1000) // 1秒の遅延をシミュレート
    s"データ$id"
  }
  
  val startTime = System.currentTimeMillis()
  
  // 並行実行
  val futures = (1 to 5).map(fetchData)
  val combinedFuture = Future.sequence(futures)
  
  val results = Await.result(combinedFuture, 10.seconds)
  val endTime = System.currentTimeMillis()
  
  println(s"結果: ${results.mkString(", ")}")
  println(s"実行時間: ${endTime - startTime}ms")
  // 約1秒で完了（5秒ではない）
}
```

## 第36章の解答

### 練習1：電卓のテスト

```scala
import org.scalatest.funsuite.AnyFunSuite
import org.scalatest.matchers.should.Matchers

class Calculator {
  def add(a: Double, b: Double): Double = a + b
  def subtract(a: Double, b: Double): Double = a - b
  def multiply(a: Double, b: Double): Double = a * b
  def divide(a: Double, b: Double): Either[String, Double] = 
    if (b == 0) Left("ゼロ除算エラー") 
    else Right(a / b)
}

class CalculatorTest extends AnyFunSuite with Matchers {
  val calc = new Calculator
  
  test("加算") {
    calc.add(2, 3) shouldBe 5
    calc.add(-1, 1) shouldBe 0
    calc.add(0.1, 0.2) shouldBe 0.3 +- 0.01
  }
  
  test("減算") {
    calc.subtract(5, 3) shouldBe 2
    calc.subtract(0, 5) shouldBe -5
  }
  
  test("乗算") {
    calc.multiply(3, 4) shouldBe 12
    calc.multiply(-2, 3) shouldBe -6
    calc.multiply(0, 100) shouldBe 0
  }
  
  test("除算") {
    calc.divide(10, 2) shouldBe Right(5)
    calc.divide(7, 2) shouldBe Right(3.5)
    calc.divide(5, 0) shouldBe Left("ゼロ除算エラー")
  }
}
```

### 練習2：TODOリストのテスト

```scala
case class Task(id: Int, title: String, completed: Boolean = false)

class TodoList {
  private var tasks = Map[Int, Task]()
  private var nextId = 1
  
  def add(title: String): Task = {
    val task = Task(nextId, title)
    tasks = tasks + (nextId -> task)
    nextId += 1
    task
  }
  
  def remove(id: Int): Boolean = {
    if (tasks.contains(id)) {
      tasks = tasks - id
      true
    } else false
  }
  
  def complete(id: Int): Boolean = {
    tasks.get(id) match {
      case Some(task) =>
        tasks = tasks.updated(id, task.copy(completed = true))
        true
      case None => false
    }
  }
  
  def list(onlyIncomplete: Boolean = false): List[Task] = {
    val allTasks = tasks.values.toList
    if (onlyIncomplete) allTasks.filterNot(_.completed)
    else allTasks
  }
}

class TodoListTest extends AnyFunSuite with Matchers {
  test("タスクの追加") {
    val todo = new TodoList
    val task = todo.add("買い物")
    
    task.title shouldBe "買い物"
    task.completed shouldBe false
    todo.list() should have size 1
  }
  
  test("タスクの削除") {
    val todo = new TodoList
    val task = todo.add("勉強")
    
    todo.remove(task.id) shouldBe true
    todo.list() shouldBe empty
    todo.remove(999) shouldBe false
  }
  
  test("タスクの完了") {
    val todo = new TodoList
    val task = todo.add("運動")
    
    todo.complete(task.id) shouldBe true
    todo.list().head.completed shouldBe true
  }
  
  test("フィルタリング") {
    val todo = new TodoList
    val task1 = todo.add("タスク1")
    val task2 = todo.add("タスク2")
    todo.complete(task1.id)
    
    todo.list() should have size 2
    todo.list(onlyIncomplete = true) should have size 1
    todo.list(onlyIncomplete = true).head.id shouldBe task2.id
  }
}
```

## デバッグのヒント

### よくある間違いと解決方法

```scala
// 1. 括弧の数が合わない
// 間違い
// val result = list.map(x => x * 2).filter(_ > 5
// エラー: ')' expected but eof found

// 正解
val result = list.map(x => x * 2).filter(_ > 5)

// 2. 型の不一致
// 間違い
// val numbers: List[Int] = List(1, 2, "3")
// エラー: type mismatch

// 正解
val numbers: List[Int] = List(1, 2, 3)
// または
val mixed: List[Any] = List(1, 2, "3")

// 3. 変数名のタイポ
// 間違い
val message = "Hello"
// println(mesage)  // エラー: not found: value mesage

// 正解
println(message)

// 4. メソッドの引数不足
// 間違い
// List(1, 2, 3).map()  // エラー: missing argument

// 正解
List(1, 2, 3).map(_ * 2)

// 5. valの再代入
// 間違い
val x = 10
// x = 20  // エラー: reassignment to val

// 正解
var x = 10
x = 20
```

## 学習のアドバイス

### 効果的な練習方法

1. **小さく始める**
   - まず動くコードを書く
   - 少しずつ機能を追加
   - エラーが出たらすぐ確認

2. **たくさん試す**
   - REPLで実験
   - 同じ問題を違う方法で解く
   - エラーを恐れない

3. **コードを読む**
   - 他の人の解答を見る
   - 標準ライブラリを調べる
   - より良い書き方を学ぶ

4. **定期的に復習**
   - 以前解いた問題を再挑戦
   - 忘れた概念を確認
   - 新しい知識で改善

## まとめ

プログラミングは「習うより慣れろ」です。たくさんコードを書いて、たくさんエラーを経験して、少しずつ上達していきます。

**覚えておきたいこと**：
- 正解は一つではない
- エラーは学習のチャンス
- 動くコードから始める
- 楽しみながら続ける

がんばって練習を続けましょう！