# 第18章 高階関数とは何か

## はじめに

「高階関数」という名前を聞くと難しそうに感じるかもしれません。でも、実は私たちの日常にもあるんです。

例えば、「やることリスト」アプリを考えてください。「完了したタスクだけ表示」「重要なタスクを赤色で表示」など、表示方法を切り替えられますよね。これは「どう処理するか」を指定できる、高階関数の考え方そのものです！

## 高階関数って何だろう？

### 関数を受け取る関数

```scala
// FunctionAsArgument.scala
@main def functionAsArgument(): Unit =
  // 高階関数：関数を引数に取る
  def doTwice(action: () => Unit): Unit =
    action()
    action()
  
  // 使ってみる
  doTwice(() => println("Hello!"))
  
  // もっと実用的な例
  def measureTime(action: () => Unit): Long =
    val start = System.currentTimeMillis()
    action()
    val end = System.currentTimeMillis()
    end - start
  
  val time = measureTime(() => {
    Thread.sleep(100)  // 100ミリ秒待つ
    println("処理完了")
  })
  
  println(s"実行時間: ${time}ミリ秒")
```

### 関数を返す関数

```scala
// FunctionReturningFunction.scala
@main def functionReturningFunction(): Unit =
  // 関数を返す関数
  def createGreeter(greeting: String): String => String =
    (name: String) => s"$greeting, $name!"
  
  val morningGreeter = createGreeter("おはよう")
  val eveningGreeter = createGreeter("こんばんは")
  
  println(morningGreeter("太郎"))
  println(eveningGreeter("花子"))
  
  // 計算関数を作る関数
  def createCalculator(operation: String): (Int, Int) => Int =
    operation match
      case "+" => (a, b) => a + b
      case "-" => (a, b) => a - b
      case "*" => (a, b) => a * b
      case "/" => (a, b) => if b != 0 then a / b else 0
      case _ => (a, b) => 0
  
  val adder = createCalculator("+")
  val multiplier = createCalculator("*")
  
  println(s"10 + 5 = ${adder(10, 5)}")
  println(s"10 * 5 = ${multiplier(10, 5)}")
```

## よく使う高階関数

### map：変換する

```scala
// MapFunction.scala
@main def mapFunction(): Unit =
  val numbers = List(1, 2, 3, 4, 5)
  
  // 各要素を2倍にする
  val doubled = numbers.map(x => x * 2)
  println(s"2倍: $doubled")
  
  // 文字列に変換
  val strings = numbers.map(x => s"数値$x")
  println(s"文字列化: $strings")
  
  // 実用例：商品の価格を税込みに
  case class Product(name: String, price: Int)
  
  val products = List(
    Product("ペン", 100),
    Product("ノート", 200),
    Product("消しゴム", 50)
  )
  
  val withTax = products.map(p => 
    p.copy(price = (p.price * 1.1).toInt)
  )
  
  withTax.foreach(p => 
    println(s"${p.name}: ${p.price}円（税込）")
  )
```

### filter：選別する

```scala
// FilterFunction.scala
@main def filterFunction(): Unit =
  val numbers = List(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
  
  // 偶数だけ選ぶ
  val evens = numbers.filter(x => x % 2 == 0)
  println(s"偶数: $evens")
  
  // 5より大きい数
  val largeNumbers = numbers.filter(_ > 5)
  println(s"5より大: $largeNumbers")
  
  // 実用例：合格者の選別
  case class Student(name: String, score: Int)
  
  val students = List(
    Student("太郎", 85),
    Student("花子", 92),
    Student("次郎", 68),
    Student("桜", 78)
  )
  
  val passed = students.filter(_.score >= 80)
  
  println("合格者:")
  passed.foreach(s => println(s"  ${s.name}: ${s.score}点"))
```

### reduce/fold：集約する

```scala
// ReduceFoldFunction.scala
@main def reduceFoldFunction(): Unit =
  val numbers = List(1, 2, 3, 4, 5)
  
  // reduce：要素を1つに集約
  val sum = numbers.reduce((a, b) => a + b)
  val product = numbers.reduce(_ * _)
  
  println(s"合計: $sum")
  println(s"積: $product")
  
  // fold：初期値を指定して集約
  val sumWithInit = numbers.fold(100)(_ + _)  // 100から始める
  println(s"100 + 合計: $sumWithInit")
  
  // 文字列の連結
  val words = List("Scala", "is", "awesome")
  val sentence = words.fold("")((acc, word) => 
    if acc.isEmpty then word else s"$acc $word"
  )
  println(s"文章: $sentence")
  
  // 実用例：買い物カートの合計
  case class Item(name: String, price: Int, quantity: Int)
  
  val cart = List(
    Item("りんご", 100, 3),
    Item("バナナ", 80, 5),
    Item("オレンジ", 120, 2)
  )
  
  val total = cart.map(item => item.price * item.quantity).sum
  println(f"合計金額: $total%,d円")
```

## 関数の組み合わせ

### メソッドチェーン

```scala
// MethodChaining.scala
@main def methodChaining(): Unit =
  val numbers = List(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
  
  // 複数の操作を連鎖
  val result = numbers
    .filter(_ % 2 == 0)      // 偶数のみ
    .map(_ * 3)              // 3倍
    .filter(_ > 10)          // 10より大
    .sorted                  // ソート
  
  println(s"結果: $result")
  
  // 実用例：データ処理パイプライン
  case class Sale(product: String, amount: Int, date: String)
  
  val sales = List(
    Sale("商品A", 1000, "2024-01-01"),
    Sale("商品B", 2000, "2024-01-01"),
    Sale("商品A", 1500, "2024-01-02"),
    Sale("商品C", 3000, "2024-01-02"),
    Sale("商品A", 2500, "2024-01-03")
  )
  
  // 商品Aの売上を集計
  val productASales = sales
    .filter(_.product == "商品A")
    .map(_.amount)
    .sum
  
  println(s"商品Aの総売上: ${productASales}円")
  
  // 日付ごとの売上TOP商品
  val topByDate = sales
    .groupBy(_.date)
    .view.mapValues(_.maxBy(_.amount))
    .toMap
  
  topByDate.foreach { case (date, sale) =>
    println(s"$date の最高売上: ${sale.product} (${sale.amount}円)")
  }
```

### 関数合成

```scala
// FunctionComposition.scala
@main def functionComposition(): Unit =
  // 関数を定義
  val double = (x: Int) => x * 2
  val addTen = (x: Int) => x + 10
  val square = (x: Int) => x * x
  
  // andThenで順次実行
  val doubleThenAdd = double.andThen(addTen)
  println(s"5を2倍して10足す: ${doubleThenAdd(5)}")  // 20
  
  // composeで逆順実行
  val addThenDouble = double.compose(addTen)
  println(s"5に10足して2倍: ${addThenDouble(5)}")  // 30
  
  // 3つ以上の関数を組み合わせ
  val combined = double
    .andThen(addTen)
    .andThen(square)
  
  println(s"5を処理: ${combined(5)}")  // 400
  
  // 実用例：データ変換パイプライン
  val trimSpace = (s: String) => s.trim
  val toLowerCase = (s: String) => s.toLowerCase
  val removeSpecial = (s: String) => s.replaceAll("[^a-z0-9]", "")
  
  val normalize = trimSpace
    .andThen(toLowerCase)
    .andThen(removeSpecial)
  
  val inputs = List(
    "  Hello World!  ",
    "Scala-Programming",
    "123 ABC xyz"
  )
  
  inputs.foreach { input =>
    println(s"'$input' → '${normalize(input)}'")
  }
```

## 実践的な高階関数

### カスタムコレクション操作

```scala
// CustomCollectionOps.scala
@main def customCollectionOps(): Unit =
  // takeWhile: 条件を満たす間だけ取る
  def takeWhileCustom[A](list: List[A], p: A => Boolean): List[A] =
    list match
      case Nil => Nil
      case head :: tail =>
        if p(head) then head :: takeWhileCustom(tail, p)
        else Nil
  
  val numbers = List(1, 2, 3, 4, 5, 1, 2, 3)
  val result = takeWhileCustom(numbers, _ < 4)
  println(s"4未満の要素: $result")
  
  // groupBy: 要素をグループ化
  case class Person(name: String, age: Int, city: String)
  
  val people = List(
    Person("太郎", 25, "東京"),
    Person("花子", 30, "大阪"),
    Person("次郎", 28, "東京"),
    Person("桜", 35, "大阪")
  )
  
  val byCity = people.groupBy(_.city)
  byCity.foreach { case (city, persons) =>
    println(s"$city: ${persons.map(_.name).mkString(", ")}")
  }
  
  // partition: 2つに分割
  val (adults, young) = people.partition(_.age >= 30)
  println(s"30歳以上: ${adults.map(_.name)}")
  println(s"30歳未満: ${young.map(_.name)}")
```

### リトライ機構

```scala
// RetryMechanism.scala
@main def retryMechanism(): Unit =
  import scala.util.{Try, Success, Failure}
  import scala.util.Random
  
  // リトライ機能を持つ高階関数
  def retry[T](times: Int)(action: () => T): Try[T] =
    var lastError: Option[Throwable] = None
    
    for i <- 1 to times do
      Try(action()) match
        case Success(value) =>
          println(s"成功！（${i}回目）")
          return Success(value)
        case Failure(e) =>
          lastError = Some(e)
          println(s"失敗（${i}回目）: ${e.getMessage}")
    
    Failure(lastError.getOrElse(new Exception("Unknown error")))
  
  // 不安定な処理（50%の確率で失敗）
  def unstableOperation(): String =
    if Random.nextBoolean() then "成功データ"
    else throw new Exception("ネットワークエラー")
  
  // 3回までリトライ
  retry(3)(() => unstableOperation()) match
    case Success(data) => println(s"最終結果: $data")
    case Failure(e) => println(s"すべて失敗: ${e.getMessage}")
```

### イベントハンドラー

```scala
// EventHandler.scala
@main def eventHandler(): Unit =
  // イベントハンドラーシステム
  class EventSystem:
    private var handlers = Map[String, List[() => Unit]]()
    
    def on(event: String)(handler: () => Unit): Unit =
      handlers = handlers.updatedWith(event) {
        case Some(list) => Some(handler :: list)
        case None => Some(List(handler))
      }
    
    def trigger(event: String): Unit =
      handlers.get(event).foreach { handlerList =>
        handlerList.foreach(handler => handler())
      }
  
  val events = new EventSystem
  
  // イベントハンドラーを登録
  events.on("login") { () =>
    println("ログインしました")
  }
  
  events.on("login") { () =>
    println("最終ログイン時刻を更新")
  }
  
  events.on("logout") { () =>
    println("ログアウトしました")
  }
  
  // イベントを発火
  println("=== ログインイベント ===")
  events.trigger("login")
  
  println("\n=== ログアウトイベント ===")
  events.trigger("logout")
```

## 高階関数を使った問題解決

### データ検証システム

```scala
// ValidationSystem.scala
@main def validationSystem(): Unit =
  type Validator[T] = T => Either[String, T]
  
  // バリデーターを組み合わせる高階関数
  def combine[T](validators: Validator[T]*): Validator[T] =
    (value: T) =>
      validators.foldLeft[Either[String, T]](Right(value)) {
        case (Right(v), validator) => validator(v)
        case (error, _) => error
      }
  
  // 個別のバリデーター
  val notEmpty: Validator[String] = s =>
    if s.trim.nonEmpty then Right(s)
    else Left("空文字は許可されません")
  
  val minLength: Int => Validator[String] = min => s =>
    if s.length >= min then Right(s)
    else Left(s"${min}文字以上必要です")
  
  val maxLength: Int => Validator[String] = max => s =>
    if s.length <= max then Right(s)
    else Left(s"${max}文字以下にしてください")
  
  val alphaNumeric: Validator[String] = s =>
    if s.matches("^[a-zA-Z0-9]+$") then Right(s)
    else Left("英数字のみ使用可能です")
  
  // バリデーターを組み合わせ
  val usernameValidator = combine(
    notEmpty,
    minLength(3),
    maxLength(20),
    alphaNumeric
  )
  
  // テスト
  val testCases = List(
    "abc",
    "ab",
    "verylongusernamethatexceedslimit",
    "user123",
    "user-name",
    ""
  )
  
  testCases.foreach { username =>
    usernameValidator(username) match
      case Right(valid) => println(s"✓ '$valid' は有効です")
      case Left(error) => println(s"✗ '$username': $error")
  }
```

## 練習してみよう！

### 練習1：独自のmap関数

リストとを受け取って、各要素を変換する独自のmap関数を実装してください。
再帰を使って実装してみましょう。

### 練習2：フィルターチェーン

複数のフィルター関数を受け取って、すべての条件を満たす要素だけを返す関数を作ってください。

### 練習3：処理時間計測

任意の関数の実行時間を計測し、結果と実行時間の両方を返す高階関数を作ってください。

## この章のまとめ

高階関数の力を体験できましたね！

### できるようになったこと

✅ **高階関数の基本**
- 関数を引数に取る
- 関数を返す
- 関数の合成

✅ **標準的な高階関数**
- map（変換）
- filter（選別）
- reduce/fold（集約）

✅ **実践的な使い方**
- メソッドチェーン
- カスタム操作
- イベントシステム

✅ **問題解決**
- バリデーション
- リトライ機構
- データ処理パイプライン

### 高階関数を使うコツ

1. **小さく始める**
   - 単純な関数から
   - 徐々に組み合わせる
   - 読みやすさを重視

2. **既存の関数を活用**
   - map, filter, foldを使いこなす
   - 車輪の再発明を避ける
   - 標準ライブラリを知る

3. **関数の組み合わせ**
   - 単一責任の原則
   - 再利用可能な部品
   - テストしやすい設計

### 次の章では...

OptionとEitherを使った、より安全なプログラミング手法を学びます。エラーをスマートに扱う方法を身につけましょう！

### 最後に

高階関数は「プログラミングの魔法」のようなものです。関数を組み合わせることで、複雑な処理も簡潔に表現できます。最初は難しく感じるかもしれませんが、使いこなせるようになると、プログラミングの新しい世界が開けます。関数型プログラミングの醍醐味を味わってください！