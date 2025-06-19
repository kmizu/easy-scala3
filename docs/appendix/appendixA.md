# 付録A よくあるエラーメッセージ完全ガイド

## はじめに

プログラミングを学んでいると、必ずエラーメッセージに出会います。最初は怖く感じるかもしれませんが、エラーメッセージは「何が間違っているか」を教えてくれる親切なガイドなんです。この付録では、Scalaでよく見るエラーメッセージとその解決方法を詳しく説明します。

## コンパイルエラー

### 型の不一致

```scala
// エラー例1：型の不一致
val number: Int = "123"
// error: type mismatch;
//  found   : String("123")
//  required: Int

// 解決方法
val number: Int = 123
// または
val number: Int = "123".toInt
```

**エラーの意味**: 期待されている型と異なる型の値を代入しようとしています。

**よくある原因**:
- 文字列を数値型の変数に代入
- 異なる型のコレクションを混在
- 戻り値の型が宣言と異なる

```scala
// エラー例2：関数の戻り値
def add(a: Int, b: Int): Int = {
  s"$a + $b = ${a + b}"  // Stringを返している
}
// error: type mismatch;
//  found   : String
//  required: Int

// 解決方法
def add(a: Int, b: Int): Int = {
  a + b
}
// または型を修正
def addWithMessage(a: Int, b: Int): String = {
  s"$a + $b = ${a + b}"
}
```

### 未定義の識別子

```scala
// エラー例
println(messge)  // タイポ
// error: not found: value messge

// 解決方法
val message = "Hello"
println(message)
```

**エラーの意味**: 使用しようとしている変数、関数、クラスなどが定義されていません。

**よくある原因**:
- タイプミス
- インポート忘れ
- スコープ外での参照

```scala
// エラー例：スコープの問題
def example(): Unit = {
  if (true) {
    val localVar = 42
  }
  println(localVar)  // スコープ外
}
// error: not found: value localVar

// 解決方法
def example(): Unit = {
  val localVar = if (true) {
    42
  } else {
    0
  }
  println(localVar)
}
```

### メソッドが見つからない

```scala
// エラー例
val numbers = List(1, 2, 3)
numbers.push(4)
// error: value push is not a member of List[Int]

// 解決方法
val numbers = List(1, 2, 3)
val updated = numbers :+ 4  // または numbers.appended(4)
```

**エラーの意味**: オブジェクトに存在しないメソッドを呼び出そうとしています。

**よくある原因**:
- 他の言語のメソッド名を使用
- タイプミス
- 異なる型のメソッドを使用

### アクセス修飾子エラー

```scala
// エラー例
class MyClass {
  private val secret = "秘密"
}

val obj = new MyClass
println(obj.secret)
// error: value secret cannot be accessed as a member of MyClass

// 解決方法
class MyClass {
  private val secret = "秘密"
  def getSecret: String = secret
}
```

**エラーの意味**: privateやprotectedなメンバーに外部からアクセスしようとしています。

### ケースクラスのパターンマッチエラー

```scala
// エラー例
sealed trait Animal
case class Dog(name: String) extends Animal
case class Cat(name: String) extends Animal

def speak(animal: Animal): String = animal match {
  case Dog(name) => s"$name says Woof!"
}
// warning: match may not be exhaustive.
// It would fail on the following input: Cat(_)

// 解決方法
def speak(animal: Animal): String = animal match {
  case Dog(name) => s"$name says Woof!"
  case Cat(name) => s"$name says Meow!"
}
```

**エラーの意味**: パターンマッチですべてのケースを網羅していません。

## 実行時エラー

### NullPointerException

```scala
// エラー例
var message: String = null
println(message.length)
// java.lang.NullPointerException

// 解決方法1：Option型を使う
var message: Option[String] = None
println(message.map(_.length).getOrElse(0))

// 解決方法2：nullチェック
var message: String = null
if (message != null) {
  println(message.length)
}
```

**エラーの意味**: null値に対してメソッドを呼び出そうとしています。

**予防方法**:
- Option型の使用
- 初期値の設定
- nullチェックの実施

### ArrayIndexOutOfBoundsException

```scala
// エラー例
val array = Array(1, 2, 3)
println(array(5))
// java.lang.ArrayIndexOutOfBoundsException: Index 5 out of bounds for length 3

// 解決方法1：範囲チェック
val array = Array(1, 2, 3)
val index = 5
if (index >= 0 && index < array.length) {
  println(array(index))
} else {
  println(s"インデックス $index は範囲外です")
}

// 解決方法2：liftメソッド
val array = Array(1, 2, 3)
println(array.lift(5).getOrElse("要素なし"))
```

**エラーの意味**: 配列やリストの範囲外のインデックスにアクセスしようとしています。

### NumberFormatException

```scala
// エラー例
val number = "abc".toInt
// java.lang.NumberFormatException: For input string: "abc"

// 解決方法1：Try を使う
import scala.util.Try

val number = Try("abc".toInt).getOrElse(0)

// 解決方法2：独自の安全な変換関数
def parseIntSafe(s: String): Option[Int] = {
  try {
    Some(s.toInt)
  } catch {
    case _: NumberFormatException => None
  }
}
```

**エラーの意味**: 文字列を数値に変換できません。

### MatchError

```scala
// エラー例
val value: Any = 3.14

val result = value match {
  case i: Int => s"整数: $i"
  case s: String => s"文字列: $s"
}
// scala.MatchError: 3.14 (of class java.lang.Double)

// 解決方法：デフォルトケースを追加
val result = value match {
  case i: Int => s"整数: $i"
  case s: String => s"文字列: $s"
  case other => s"その他: $other"
}
```

**エラーの意味**: パターンマッチで該当するケースがありません。

## 並行処理のエラー

### TimeoutException

```scala
// エラー例
import scala.concurrent.Future
import scala.concurrent.ExecutionContext.Implicits.global
import scala.concurrent.duration._

val future = Future {
  Thread.sleep(5000)
  "完了"
}

val result = Await.result(future, 1.second)
// java.util.concurrent.TimeoutException: Future timed out after [1 second]

// 解決方法1：タイムアウトを延長
val result = Await.result(future, 10.seconds)

// 解決方法2：タイムアウト時の処理
val resultOption = Try(Await.result(future, 1.second)).toOption
```

**エラーの意味**: 非同期処理が指定時間内に完了しませんでした。

### 共有状態の競合

```scala
// エラーが起きやすい例
var counter = 0

val futures = (1 to 1000).map { _ =>
  Future {
    counter += 1  // 競合状態
  }
}

// 解決方法：AtomicIntegerを使用
import java.util.concurrent.atomic.AtomicInteger

val counter = new AtomicInteger(0)

val futures = (1 to 1000).map { _ =>
  Future {
    counter.incrementAndGet()
  }
}
```

## よくある警告

### 未使用の変数

```scala
// 警告例
def example(): Unit = {
  val unused = 42  // warning: local val unused in method example is never used
  println("Hello")
}

// 解決方法1：使用する
def example(): Unit = {
  val number = 42
  println(s"Number is $number")
}

// 解決方法2：アンダースコアを使う
def example(): Unit = {
  val _ = expensiveComputation()  // 戻り値を明示的に無視
  println("Hello")
}
```

### 非推奨の機能

```scala
// 警告例
val list = List(1, 2, 3)
list./::(0)  // warning: method /:: in trait SeqOps is deprecated

// 解決方法：新しいAPIを使用
val list = List(1, 2, 3)
0 +: list  // または list.prepended(0)
```

## デバッグのヒント

### スタックトレースの読み方

```
Exception in thread "main" java.lang.ArrayIndexOutOfBoundsException: 10
    at com.example.MyApp$.main(MyApp.scala:15)  // ← ここでエラーが発生
    at com.example.MyApp.main(MyApp.scala)
    at sun.reflect.NativeMethodAccessorImpl.invoke0(Native Method)
```

**読み方**:
1. 一番上がエラーの種類とメッセージ
2. atで始まる行が呼び出し履歴
3. 最初のatがエラー発生箇所

### よくあるデバッグテクニック

```scala
// 1. println デバッグ
def complexCalculation(x: Int): Int = {
  println(s"Input: $x")
  val step1 = x * 2
  println(s"After step1: $step1")
  val step2 = step1 + 10
  println(s"After step2: $step2")
  step2
}

// 2. assert を使った前提条件チェック
def divide(a: Int, b: Int): Int = {
  assert(b != 0, "除数は0以外である必要があります")
  a / b
}

// 3. ログを使ったデバッグ
import scala.util.{Try, Success, Failure}

def riskyOperation(): Try[String] = {
  Try {
    // 危険な操作
    "成功"
  } match {
    case Success(value) =>
      println(s"操作成功: $value")
      Success(value)
    case Failure(exception) =>
      println(s"操作失敗: ${exception.getMessage}")
      exception.printStackTrace()
      Failure(exception)
  }
}
```

## エラー対処のベストプラクティス

### 1. エラーメッセージを読む

```scala
// エラーメッセージは友達です！
// found   : String("123")  ← 実際の型
// required: Int            ← 期待される型
```

### 2. 小さく分割して確認

```scala
// 複雑な式でエラーが出たら...
val result = list.map(_.toString).filter(_.length > 3).flatMap(_.split(","))

// 段階的に確認
val step1 = list.map(_.toString)
println(s"step1: $step1")

val step2 = step1.filter(_.length > 3)
println(s"step2: $step2")

val step3 = step2.flatMap(_.split(","))
println(s"step3: $step3")
```

### 3. 型を明示する

```scala
// 型推論でエラーが分かりにくい場合
def process(data: ???) = ???  // 何を返すか不明

// 型を明示
def process(data: List[String]): Map[String, Int] = {
  // 実装
}
```

### 4. IDEを活用する

- 赤い波線：コンパイルエラー
- 黄色い波線：警告
- ホバーでエラー詳細表示
- Quick Fixで自動修正

## まとめ

エラーメッセージは敵ではありません。プログラムを正しく書くための味方です。最初は難しく感じても、パターンを覚えれば必ず理解できるようになります。エラーが出たら：

1. **落ち着いて**エラーメッセージを読む
2. **エラーの場所**を特定する
3. **エラーの種類**を理解する
4. **解決方法**を試す
5. それでも分からなければ**検索**する

プログラミングは試行錯誤の連続です。エラーと友達になって、楽しくScalaを学んでいきましょう！