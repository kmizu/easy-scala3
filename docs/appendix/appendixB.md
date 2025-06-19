# 付録B REPL完全活用法

## REPLとは？

REPL（Read-Eval-Print Loop）は、Scalaコードを対話的に実行できる環境です。コードを1行ずつ試しながら学習できる、最高の練習場です！

## REPLの起動と基本操作

### 起動方法

```bash
# Scala 3のREPLを起動
$ scala

# または（sbtプロジェクト内で）
$ sbt console

Welcome to Scala 3.3.1 (11.0.20, Java OpenJDK 64-Bit Server VM).
Type in expressions for evaluation. Or try :help.

scala>
```

### 基本的な使い方

```scala
scala> 1 + 1
val res0: Int = 2

scala> val message = "Hello, REPL!"
val message: String = Hello, REPL!

scala> println(message)
Hello, REPL!

scala> def greet(name: String) = s"こんにちは、$name さん！"
def greet(name: String): String

scala> greet("太郎")
val res1: String = こんにちは、太郎 さん！
```

## REPLコマンド

### ヘルプと情報表示

```scala
// 利用可能なコマンド一覧
scala> :help
:type <expression>      式の型を表示
:kind <type>           型の種類を表示
:imports               現在のインポートを表示
:reset                 REPLをリセット
:quit                  REPLを終了
// ... その他多数

// 式の型を確認
scala> :type List(1, 2, 3)
List[Int]

scala> :type (x: Int) => x * 2
Int => Int

// 型の種類を確認
scala> :kind List
List's kind is F[+A]

scala> :kind Map
Map's kind is F[K, +V]
```

### 履歴とナビゲーション

```scala
// 履歴の表示
scala> :history

// 前の結果を参照
scala> 10 * 20
val res0: Int = 200

scala> res0 + 50
val res1: Int = 250

// 履歴の検索（Ctrl+R）
// 上下矢印キーで履歴をナビゲート
```

## 高度な使い方

### 複数行入力

```scala
// 複数行の入力（自動検出）
scala> def factorial(n: Int): Int =
     |   if n <= 1 then 1
     |   else n * factorial(n - 1)
def factorial(n: Int): Int

// 明示的な複数行モード
scala> :paste
// Entering paste mode (ctrl-D to finish)

case class Person(name: String, age: Int) {
  def greet(): String = s"Hello, I'm $name"
  def isAdult: Boolean = age >= 18
}

val people = List(
  Person("Alice", 25),
  Person("Bob", 17),
  Person("Charlie", 30)
)

// Exiting paste mode, now interpreting.
```

### インポートとクラスパス

```scala
// ライブラリのインポート
scala> import scala.concurrent._
import scala.concurrent._

scala> import scala.concurrent.duration._
import scala.concurrent.duration._

scala> import ExecutionContext.Implicits.global
import ExecutionContext.Implicits.global

// 現在のインポートを確認
scala> :imports
import java.lang._
import scala._
import scala.Predef._
import scala.concurrent._
import scala.concurrent.duration._
import scala.concurrent.ExecutionContext.Implicits.global

// 外部JARの追加（起動時）
$ scala -cp /path/to/library.jar
```

### REPLでのデバッグ

```scala
// 値の検査
scala> val numbers = List(1, 2, 3, 4, 5)
val numbers: List[Int] = List(1, 2, 3, 4, 5)

scala> numbers.map { x =>
     |   println(s"Processing: $x")
     |   x * 2
     | }
Processing: 1
Processing: 2
Processing: 3
Processing: 4
Processing: 5
val res0: List[Int] = List(2, 4, 6, 8, 10)

// 中間結果の確認
scala> val result = for {
     |   x <- List(1, 2, 3)
     |   _ = println(s"x = $x")
     |   y <- List(10, 20)
     |   _ = println(s"  y = $y")
     | } yield x * y
x = 1
  y = 10
  y = 20
x = 2
  y = 10
  y = 20
x = 3
  y = 10
  y = 20
val result: List[Int] = List(10, 20, 20, 40, 30, 60)
```

## 実践的なREPL活用法

### アルゴリズムの実験

```scala
// ソートアルゴリズムの実装と検証
scala> def bubbleSort(arr: Array[Int]): Array[Int] = {
     |   val n = arr.length
     |   for {
     |     i <- 0 until n - 1
     |     j <- 0 until n - i - 1
     |     if arr(j) > arr(j + 1)
     |   } {
     |     val temp = arr(j)
     |     arr(j) = arr(j + 1)
     |     arr(j + 1) = temp
     |   }
     |   arr
     | }

scala> val test = Array(64, 34, 25, 12, 22, 11, 90)
scala> bubbleSort(test)
val res0: Array[Int] = Array(11, 12, 22, 25, 34, 64, 90)

// パフォーマンス測定
scala> def time[T](block: => T): T = {
     |   val start = System.nanoTime()
     |   val result = block
     |   val end = System.nanoTime()
     |   println(s"実行時間: ${(end - start) / 1000000.0} ms")
     |   result
     | }

scala> time { (1 to 1000000).sum }
実行時間: 12.345 ms
val res1: Int = 500000500000
```

### データ探索

```scala
// CSVデータの簡易解析
scala> val csvData = """
     | name,age,city
     | Alice,25,Tokyo
     | Bob,30,Osaka
     | Charlie,22,Kyoto
     | """.trim

scala> val lines = csvData.split("\n").toList
scala> val header = lines.head.split(",").toList
scala> val data = lines.tail.map(_.split(",").toList)

scala> case class Person(name: String, age: Int, city: String)

scala> val people = data.map { row =>
     |   Person(row(0), row(1).toInt, row(2))
     | }

scala> people.filter(_.age > 24)
val res0: List[Person] = List(Person(Alice,25,Tokyo), Person(Bob,30,Osaka))

scala> people.groupBy(_.city).mapValues(_.length)
val res1: Map[String, Int] = Map(Tokyo -> 1, Osaka -> 1, Kyoto -> 1)
```

### APIの実験

```scala
// コレクションAPIの実験
scala> val numbers = 1 to 10

scala> numbers.filter(_ % 2 == 0)
val res0: IndexedSeq[Int] = Vector(2, 4, 6, 8, 10)

scala> numbers.partition(_ % 2 == 0)
val res1: (IndexedSeq[Int], IndexedSeq[Int]) = (Vector(2, 4, 6, 8, 10),Vector(1, 3, 5, 7, 9))

scala> numbers.grouped(3).toList
val res2: List[IndexedSeq[Int]] = List(Range(1, 2, 3), Range(4, 5, 6), Range(7, 8, 9), Range(10))

scala> numbers.sliding(3).toList
val res3: List[IndexedSeq[Int]] = List(Range(1, 2, 3), Range(2, 3, 4), Range(3, 4, 5), ...)
```

## REPLのカスタマイズ

### 初期化ファイル

```scala
// ~/.scala/init.scala
// REPl起動時に自動的に実行されるコード

import scala.concurrent._
import scala.concurrent.duration._
import scala.util.{Try, Success, Failure}
import ExecutionContext.Implicits.global

// 便利な関数を定義
def time[T](label: String = "実行時間")(block: => T): T = {
  val start = System.nanoTime()
  val result = block
  val end = System.nanoTime()
  println(s"$label: ${(end - start) / 1000000.0} ms")
  result
}

// よく使う値
val numbers = List(1, 2, 3, 4, 5)
val words = List("scala", "java", "python", "ruby")

println("カスタム初期化完了！")
```

### REPLの設定

```scala
// プロンプトのカスタマイズ
scala> :power
scala> settings.prompt = "λ> "
λ> println("新しいプロンプト！")
新しいプロンプト！

// 結果表示のカスタマイズ
λ> settings.maxPrintString = 1000  // 長い文字列も表示
```

## トラブルシューティング

### メモリ不足

```scala
// 大きなデータ構造でOutOfMemoryError
scala> val huge = (1 to 10000000).toList.map(x => x.toString * 100)

// 解決策：JVMオプションを指定して起動
$ scala -J-Xmx2g  # ヒープサイズを2GBに
```

### 無限ループからの脱出

```scala
scala> while(true) { }  // Ctrl+C で中断

// より安全な方法
scala> def loop(n: Int): Unit = if (n > 0) {
     |   println(n)
     |   Thread.sleep(1000)
     |   loop(n - 1)
     | }
scala> loop(5)  // 5秒で終了
```

## REPLベストプラクティス

### 1. 実験的なコーディング

```scala
// アイデアを素早く試す
scala> List(1, 2, 3).zip(List('a', 'b', 'c'))
val res0: List[(Int, Char)] = List((1,a), (2,b), (3,c))

scala> res0.map { case (n, c) => s"$n-$c" }
val res1: List[String] = List(1-a, 2-b, 3-c)
```

### 2. ライブラリの学習

```scala
// 新しいライブラリのAPIを探索
scala> import java.time._

scala> LocalDate.now()
val res0: java.time.LocalDate = 2024-01-15

scala> res0.plusDays(7)
val res1: java.time.LocalDate = 2024-01-22

scala> Period.between(res0, res1)
val res2: java.time.Period = P7D
```

### 3. デバッグとテスト

```scala
// 関数の動作確認
scala> def factorial(n: Int): BigInt = {
     |   println(s"factorial($n)")
     |   if (n <= 1) 1 else n * factorial(n - 1)
     | }

scala> factorial(5)
factorial(5)
factorial(4)
factorial(3)
factorial(2)
factorial(1)
val res0: BigInt = 120
```

### 4. ドキュメントの確認

```scala
// Scaladocを参照（IDEと併用）
scala> :type List
List.type

scala> List.
!=   ##   $asInstanceOf   $isInstanceOf   ==   apply   canBuildFrom   
concat   empty   equals   fill   from   getClass   hashCode   iterate   
newBuilder   range   tabulate   toString   unapplySeq
```

## 高度なテクニック

### マクロとメタプログラミング

```scala
// inline関数の実験（Scala 3）
scala> inline def power(x: Double, inline n: Int): Double =
     |   inline if n == 0 then 1.0
     |   else if n % 2 == 0 then power(x * x, n / 2)
     |   else x * power(x, n - 1)

scala> power(2.0, 10)
val res0: Double = 1024.0
```

### 型レベルプログラミング

```scala
// 型の実験
scala> type Age = Int
scala> type Name = String

scala> case class Person(name: Name, age: Age)

scala> summon[Ordering[Int]]
val res0: Ordering[Int] = scala.math.Ordering$Int$@12345678
```

## まとめ

REPLは単なる電卓ではありません。強力な学習ツールであり、実験場であり、デバッガーです。REPLを使いこなすことで：

1. **即座にフィードバック**が得られる
2. **安全に実験**できる
3. **段階的に学習**できる
4. **実際の動作を確認**できる

プログラミングの上達には、たくさんのコードを書いて試すことが大切です。REPLを活用して、楽しくScalaを学んでいきましょう！

**REPLは最高の先生です。分からないことがあったら、まずREPLで試してみましょう！**