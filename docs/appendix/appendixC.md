# 付録C 便利なメソッド・関数リファレンス

## コレクション操作

### List（リスト）

```scala
// 作成と基本操作
val list = List(1, 2, 3, 4, 5)
val empty = List.empty[Int]
val filled = List.fill(5)(0)         // List(0, 0, 0, 0, 0)
val range = List.range(1, 6)         // List(1, 2, 3, 4, 5)
val tabulated = List.tabulate(5)(i => i * i)  // List(0, 1, 4, 9, 16)

// 要素の追加
0 :: list                             // List(0, 1, 2, 3, 4, 5)
list :+ 6                             // List(1, 2, 3, 4, 5, 6)
list ++ List(6, 7)                    // List(1, 2, 3, 4, 5, 6, 7)

// 要素の取得
list.head                             // 1
list.tail                             // List(2, 3, 4, 5)
list.last                             // 5
list.init                             // List(1, 2, 3, 4)
list(2)                               // 3
list.apply(2)                         // 3
list.lift(10)                         // None（安全なアクセス）

// 変換
list.map(_ * 2)                       // List(2, 4, 6, 8, 10)
list.flatMap(x => List(x, x))        // List(1, 1, 2, 2, 3, 3, 4, 4, 5, 5)
list.collect { case x if x % 2 == 0 => x * x }  // List(4, 16)

// フィルタリング
list.filter(_ % 2 == 0)               // List(2, 4)
list.filterNot(_ % 2 == 0)            // List(1, 3, 5)
list.partition(_ % 2 == 0)            // (List(2, 4), List(1, 3, 5))
list.find(_ > 3)                      // Some(4)
list.takeWhile(_ < 4)                 // List(1, 2, 3)
list.dropWhile(_ < 4)                 // List(4, 5)

// 集約
list.sum                              // 15
list.product                          // 120
list.min                              // 1
list.max                              // 5
list.reduce(_ + _)                    // 15
list.fold(0)(_ + _)                   // 15
list.scan(0)(_ + _)                   // List(0, 1, 3, 6, 10, 15)

// その他の便利なメソッド
list.reverse                          // List(5, 4, 3, 2, 1)
list.sorted                           // List(1, 2, 3, 4, 5)
list.distinct                         // 重複を削除
list.take(3)                          // List(1, 2, 3)
list.drop(3)                          // List(4, 5)
list.slice(1, 4)                      // List(2, 3, 4)
list.grouped(2).toList                // List(List(1, 2), List(3, 4), List(5))
list.sliding(3).toList                // List(List(1, 2, 3), List(2, 3, 4), List(3, 4, 5))
list.zip(List('a', 'b', 'c'))         // List((1,a), (2,b), (3,c))
list.zipWithIndex                     // List((1,0), (2,1), (3,2), (4,3), (5,4))
```

### Set（セット）

```scala
// 作成と基本操作
val set = Set(1, 2, 3, 4, 5)
val empty = Set.empty[Int]

// 要素の操作
set + 6                               // Set(1, 2, 3, 4, 5, 6)
set - 3                               // Set(1, 2, 4, 5)
set ++ Set(6, 7)                      // Set(1, 2, 3, 4, 5, 6, 7)
set -- Set(3, 4)                      // Set(1, 2, 5)

// 集合演算
val set1 = Set(1, 2, 3)
val set2 = Set(2, 3, 4)
set1 & set2                           // Set(2, 3) - 積集合
set1 | set2                           // Set(1, 2, 3, 4) - 和集合
set1 &~ set2                          // Set(1) - 差集合
set1.diff(set2)                       // Set(1) - 差集合

// 判定
set.contains(3)                       // true
set(3)                                // true（関数として呼び出し）
set.subsetOf(Set(1, 2, 3, 4, 5, 6))  // true
```

### Map（マップ）

```scala
// 作成と基本操作
val map = Map("a" -> 1, "b" -> 2, "c" -> 3)
val empty = Map.empty[String, Int]

// 要素の操作
map + ("d" -> 4)                      // 要素を追加
map - "b"                             // キーを削除
map ++ Map("d" -> 4, "e" -> 5)       // 複数追加
map -- List("a", "b")                 // 複数削除

// 値の取得
map("a")                              // 1（存在しない場合は例外）
map.get("a")                          // Some(1)
map.getOrElse("z", 0)                 // 0（デフォルト値）
map.withDefaultValue(0)("z")          // 0

// 変換
map.map { case (k, v) => (k, v * 2) } // Map(a -> 2, b -> 4, c -> 6)
map.mapValues(_ * 2)                  // Map(a -> 2, b -> 4, c -> 6)（非推奨）
map.view.mapValues(_ * 2).toMap      // Map(a -> 2, b -> 4, c -> 6)

// その他
map.keys                              // Set(a, b, c)
map.values                            // Iterable(1, 2, 3)
map.keySet                            // Set(a, b, c)
map.contains("a")                     // true
map.filter { case (k, v) => v > 1 }  // Map(b -> 2, c -> 3)
```

### Vector（ベクター）

```scala
// Listと同様の操作が可能で、ランダムアクセスが高速
val vec = Vector(1, 2, 3, 4, 5)
vec(2)                                // 3（O(log n)）
vec.updated(2, 10)                    // Vector(1, 2, 10, 4, 5)
vec :+ 6                              // Vector(1, 2, 3, 4, 5, 6)
0 +: vec                              // Vector(0, 1, 2, 3, 4, 5)
```

## 文字列操作

```scala
val str = "Hello, Scala World!"

// 基本操作
str.length                            // 18
str.isEmpty                           // false
str.nonEmpty                          // true
str.charAt(0)                         // 'H'
str(0)                                // 'H'

// 検索
str.contains("Scala")                 // true
str.startsWith("Hello")               // true
str.endsWith("!")                     // true
str.indexOf("Scala")                  // 7
str.lastIndexOf("o")                  // 15

// 変換
str.toLowerCase                       // "hello, scala world!"
str.toUpperCase                       // "HELLO, SCALA WORLD!"
str.trim                              // 前後の空白を削除
str.replace("Scala", "Java")          // "Hello, Java World!"
str.replaceAll("\\s+", "_")           // "Hello,_Scala_World!"

// 分割と結合
str.split(" ")                        // Array("Hello,", "Scala", "World!")
str.split("\\s+")                     // 正規表現で分割
List("A", "B", "C").mkString(", ")   // "A, B, C"
List("A", "B", "C").mkString("[", ", ", "]")  // "[A, B, C]"

// 部分文字列
str.substring(7)                      // "Scala World!"
str.substring(7, 12)                  // "Scala"
str.take(5)                           // "Hello"
str.drop(7)                           // "Scala World!"
str.slice(7, 12)                      // "Scala"

// フォーマット
"Name: %s, Age: %d".format("太郎", 25)  // "Name: 太郎, Age: 25"
f"Pi: ${math.Pi}%.2f"                // "Pi: 3.14"
s"1 + 1 = ${1 + 1}"                   // "1 + 1 = 2"

// 便利なメソッド
"  hello  ".trim                      // "hello"
"hello".capitalize                    // "Hello"
"123".toInt                           // 123
"3.14".toDouble                       // 3.14
"true".toBoolean                      // true
```

## Option操作

```scala
val some = Some(42)
val none = None: Option[Int]

// 基本操作
some.get                              // 42（Noneの場合は例外）
some.getOrElse(0)                     // 42
none.getOrElse(0)                     // 0
some.orElse(Some(0))                  // Some(42)
none.orElse(Some(0))                  // Some(0)

// 変換
some.map(_ * 2)                       // Some(84)
none.map(_ * 2)                       // None
some.flatMap(x => Some(x * 2))       // Some(84)
some.filter(_ > 30)                   // Some(42)
some.filter(_ > 50)                   // None

// 判定
some.isDefined                        // true
none.isEmpty                          // true
some.contains(42)                     // true
some.exists(_ > 30)                   // true
some.forall(_ > 30)                   // true

// その他
some.fold(0)(_ * 2)                   // 84
none.fold(0)(_ * 2)                   // 0
some.toList                           // List(42)
none.toList                           // List()
```

## Either操作

```scala
val right: Either[String, Int] = Right(42)
val left: Either[String, Int] = Left("Error")

// 基本操作
right.isRight                         // true
left.isLeft                           // true
right.getOrElse(0)                    // 42
left.getOrElse(0)                     // 0

// 変換
right.map(_ * 2)                      // Right(84)
left.map(_ * 2)                       // Left("Error")
right.flatMap(x => Right(x * 2))     // Right(84)
right.filterOrElse(_ > 30, "Too small")  // Right(42)

// 値の取得
right.toOption                        // Some(42)
left.toOption                         // None
right.toTry                           // Success(42)

// エラー処理
left.swap                             // Right("Error")
right.fold(err => 0, value => value) // 42
```

## Try操作

```scala
import scala.util.{Try, Success, Failure}

val success = Try(10 / 2)
val failure = Try(10 / 0)

// 基本操作
success.isSuccess                     // true
failure.isFailure                     // true
success.get                           // 5
success.getOrElse(0)                  // 5

// 変換
success.map(_ * 2)                    // Success(10)
failure.map(_ * 2)                    // Failure(ArithmeticException)
success.flatMap(x => Try(x * 2))     // Success(10)

// エラー処理
failure.recover {
  case _: ArithmeticException => 0
}                                     // Success(0)

failure.recoverWith {
  case _: ArithmeticException => Success(0)
}                                     // Success(0)

// 変換
success.toOption                      // Some(5)
failure.toOption                      // None
success.toEither                      // Right(5)
failure.toEither                      // Left(ArithmeticException)
```

## Future操作

```scala
import scala.concurrent.Future
import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.duration._
import scala.util.{Success, Failure}

// 作成
val future = Future { Thread.sleep(1000); 42 }
val immediate = Future.successful(42)
val failed = Future.failed(new Exception("Error"))

// 変換
future.map(_ * 2)                     // Future(84)
future.flatMap(x => Future(x * 2))   // Future(84)
future.filter(_ > 30)                 // Future(42)

// 合成
val f1 = Future(1)
val f2 = Future(2)
val f3 = Future(3)

Future.sequence(List(f1, f2, f3))     // Future(List(1, 2, 3))
for {
  a <- f1
  b <- f2
  c <- f3
} yield a + b + c                      // Future(6)

// エラー処理
future.recover {
  case _: Exception => 0
}

future.recoverWith {
  case _: Exception => Future.successful(0)
}

// コールバック
future.onComplete {
  case Success(value) => println(s"成功: $value")
  case Failure(error) => println(s"失敗: $error")
}

// 待機（テスト用）
import scala.concurrent.Await
Await.result(future, 5.seconds)        // 42
```

## 数値操作

```scala
// 基本的な数学関数
math.abs(-5)                          // 5
math.max(3, 7)                        // 7
math.min(3, 7)                        // 3
math.pow(2, 3)                        // 8.0
math.sqrt(16)                         // 4.0
math.cbrt(27)                         // 3.0

// 丸め
math.round(3.7)                       // 4
math.floor(3.7)                       // 3.0
math.ceil(3.2)                        // 4.0

// 三角関数
math.sin(math.Pi / 2)                 // 1.0
math.cos(0)                           // 1.0
math.tan(math.Pi / 4)                 // 1.0

// 乱数
scala.util.Random.nextInt(100)        // 0〜99のランダムな整数
scala.util.Random.nextDouble()        // 0.0〜1.0のランダムな小数
scala.util.Random.shuffle(List(1,2,3,4,5))  // ランダムに並び替え

// 数値の変換
42.toString                           // "42"
"42".toInt                            // 42
"3.14".toDouble                       // 3.14
42.toDouble                           // 42.0
3.14.toInt                            // 3
```

## 日付と時刻

```scala
import java.time._
import java.time.format.DateTimeFormatter

// 現在日時
val now = LocalDateTime.now()
val today = LocalDate.now()
val currentTime = LocalTime.now()

// 作成
val date = LocalDate.of(2024, 1, 15)
val time = LocalTime.of(14, 30, 0)
val dateTime = LocalDateTime.of(date, time)

// 操作
date.plusDays(7)                      // 1週間後
date.minusMonths(1)                   // 1ヶ月前
date.withYear(2025)                   // 年を変更

// フォーマット
val formatter = DateTimeFormatter.ofPattern("yyyy/MM/dd HH:mm:ss")
dateTime.format(formatter)            // "2024/01/15 14:30:00"

// パース
LocalDate.parse("2024-01-15")
LocalDateTime.parse("2024-01-15T14:30:00")
```

## ファイル操作

```scala
import java.nio.file._
import scala.io.Source

// ファイル読み込み
val source = Source.fromFile("file.txt")
val lines = source.getLines().toList
source.close()

// より安全な方法
import scala.util.Using
Using(Source.fromFile("file.txt")) { source =>
  source.getLines().toList
}

// ファイル書き込み
Files.write(Paths.get("output.txt"), "Hello, World!".getBytes)

// ディレクトリ操作
Files.createDirectory(Paths.get("newdir"))
Files.exists(Paths.get("file.txt"))
Files.delete(Paths.get("file.txt"))
```

## まとめ

このリファレンスは、Scalaでよく使うメソッドや関数をまとめたものです。これらを覚えておくと、効率的にコードを書けるようになります。

**ポイント**：
- コレクションには豊富なメソッドがある
- Option/Either/Tryでエラーを安全に扱える
- 文字列操作は直感的
- 標準ライブラリは充実している

詳細な使い方は公式ドキュメントやIDEの補完機能を活用しましょう！