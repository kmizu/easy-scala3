# 第17章 関数の引数をもっと賢く

## はじめに

レストランで注文するとき、「ハンバーガー」と言えば基本のハンバーガーが出てきますが、「チーズを追加」「ピクルス抜き」「ポテトLサイズ」のように、カスタマイズできますよね。

プログラミングの関数も同じです！この章では、関数の引数をもっと柔軟に、もっと賢く使う方法を学びます。

## 可変長引数：いくつでも受け取れる

### 基本の可変長引数

```scala
// VarArgs.scala
@main def varArgs(): Unit = {
  // * をつけると、いくつでも引数を受け取れる
  def sum(numbers: Int*): Int =
    numbers.sum
  
  println(sum(1))           // 1個
  println(sum(1, 2, 3))     // 3個
  println(sum(1, 2, 3, 4, 5)) // 5個
  println(sum())            // 0個でもOK！
  
  // 文字列を連結
  def joinWords(words: String*): String =
    words.mkString(" ")
  
  println(joinWords("Hello", "Scala", "World"))
  println(joinWords("プログラミング", "は", "楽しい"))
}
```

### 可変長引数の実用例

```scala
// VarArgsExamples.scala
@main def varArgsExamples(): Unit = {
  // ログ出力関数
  def log(level: String, messages: String*): Unit =
    val timestamp = java.time.LocalDateTime.now()
    val allMessages = messages.mkString(" ")
    println(s"[$timestamp] [$level] $allMessages")
  
  log("INFO", "アプリケーション開始")
  log("ERROR", "ファイルが", "見つかりません:", "data.txt")
  log("DEBUG", "変数x =", "42,", "変数y =", "13")
  
  // 最大値を求める（いくつでも）
  def maxOf(first: Int, rest: Int*): Int =
    (first +: rest).max  // firstとrestを結合してmax
  
  println(s"最大値: ${maxOf(5)}")
  println(s"最大値: ${maxOf(3, 7, 2)}")
  println(s"最大値: ${maxOf(10, 20, 15, 25, 8)}")
}
```

### リストを可変長引数として渡す

```scala
// SpreadOperator.scala
@main def spreadOperator(): Unit = {
  def multiply(numbers: Int*): Int =
    numbers.product
  
  // リストを持っている場合
  val myList = List(2, 3, 4)
  
  // そのままでは渡せない
  // multiply(myList)  // エラー！
  
  // _* を使って展開
  println(s"積: ${multiply(myList*)}")  // OK！
  
  // 実用例：フォーマット関数
  def format(template: String, values: Any*): String =
    var result = template
    values.zipWithIndex.foreach { case (value, index) =>
      result = result.replace(s"{$index}", value.toString)
    }
    result
  
  val data = List("太郎", 25, "エンジニア")
  val message = format("{0}さん（{1}歳）は{2}です", data*)
  println(message)
}
```

## カリー化：関数を分割する

### カリー化の基本

```scala
// Currying.scala
@main def currying(): Unit = {
  // 通常の関数
  def add(x: Int, y: Int): Int = x + y
  
  // カリー化した関数
  def addCurried(x: Int)(y: Int): Int = x + y
  
  // 使い方
  println(add(3, 4))        // 通常
  println(addCurried(3)(4)) // カリー化
  
  // 部分適用
  val add3 = addCurried(3)  // 3を足す関数
  println(add3(4))  // 7
  println(add3(10)) // 13
  
  // 実用例：税率計算
  def calculatePrice(taxRate: Double)(price: Int): Int =
    (price * (1 + taxRate)).toInt
  
  val withTax10 = calculatePrice(0.10)  // 10%税率
  val withTax8 = calculatePrice(0.08)   // 8%税率
  
  println(s"1000円（10%税）: ${withTax10(1000)}円")
  println(s"1000円（8%税）: ${withTax8(1000)}円")
}
```

### カリー化の実践例

```scala
// CurryingExamples.scala
@main def curryingExamples(): Unit = {
  // ログ出力（レベル固定）
  def log(level: String)(message: String): Unit =
    println(s"[$level] $message")
  
  val info = log("INFO")
  val error = log("ERROR")
  val debug = log("DEBUG")
  
  info("アプリケーション開始")
  error("接続エラー")
  debug("変数の値: 42")
  
  // 設定可能なフォーマッター
  def formatCurrency(symbol: String)(amount: Double): String =
    f"$symbol$amount%.2f"
  
  val formatYen = formatCurrency("¥")
  val formatDollar = formatCurrency("$")
  val formatEuro = formatCurrency("€")
  
  println(formatYen(1234.5))
  println(formatDollar(1234.5))
  println(formatEuro(1234.5))
  
  // フィルター関数の生成
  def createFilter(minValue: Int)(maxValue: Int)(value: Int): Boolean =
    value >= minValue && value <= maxValue
  
  val isValidAge = createFilter(0)(120)
  val isValidScore = createFilter(0)(100)
  
  println(s"年齢25は有効？: ${isValidAge(25)}")
  println(s"点数150は有効？: ${isValidScore(150)}")
}
```

## 暗黙の引数（using/given）

### 基本的な使い方

```scala
// ImplicitParams.scala
@main def implicitParams(): Unit = {
  // 設定を表すケースクラス
  case class Config(language: String, debug: Boolean)
  
  // 暗黙の値を定義
  given defaultConfig: Config = Config("ja", false)
  
  // usingで暗黙の引数を受け取る
  def greet(name: String)(using config: Config): String =
    config.language match {
      case "ja" => s"こんにちは、$name さん"
      case "en" => s"Hello, $name"
      case _ => s"Hi, $name"
    }
  
  // 暗黙の値が自動的に渡される
  println(greet("太郎"))  // 日本語であいさつ
  
  // 別の設定を使いたい場合
  given englishConfig: Config = Config("en", true)
  
  println(greet("Taro")(using englishConfig))  // 英語であいさつ
}
```

### 実践的な暗黙の引数

```scala
// PracticalImplicits.scala
@main def practicalImplicits(): Unit = {
  // 実行コンテキスト
  case class ExecutionContext(user: String, timestamp: Long)
  
  // データベース操作
  trait Database:
    def save(data: String)(using ctx: ExecutionContext): Unit =
      println(s"[${ctx.timestamp}] User ${ctx.user} saved: $data")
    
    def load(id: Int)(using ctx: ExecutionContext): String =
      println(s"[${ctx.timestamp}] User ${ctx.user} loaded id: $id")
      s"Data for id $id"
  
  val db = new Database {}
  
  // 暗黙のコンテキストを用意
  given ctx: ExecutionContext = ExecutionContext("admin", System.currentTimeMillis())
  
  // 自動的にコンテキストが渡される
  db.save("重要なデータ")
  val data = db.load(123)
  
  // フォーマッター
  trait Formatter[T]:
    def format(value: T): String
  
  given intFormatter: Formatter[Int] with
    def format(value: Int): String = f"整数: $value%,d"
  
  given doubleFormatter: Formatter[Double] with
    def format(value: Double): String = f"小数: $value%.2f"
  
  def printFormatted[T](value: T)(using fmt: Formatter[T]): Unit =
    println(fmt.format(value))
  
  printFormatted(1234567)
  printFormatted(3.14159)
}
```

## by-name引数：遅延評価

```scala
// ByNameParams.scala
@main def byNameParams(): Unit = {
  // 通常の引数（即座に評価）
  def normalParam(x: Int): Unit =
    println("関数が呼ばれました")
    println(s"値: $x")
  
  // by-name引数（使うときに評価）
  def byNameParam(x: => Int): Unit =
    println("関数が呼ばれました")
    println(s"値: $x")  // ここで初めて評価
  
  println("=== 通常の引数 ===")
  normalParam({
    println("引数を評価中...")
    42
  })
  
  println("\n=== by-name引数 ===")
  byNameParam({
    println("引数を評価中...")
    42
  })
  
  // 実用例：条件付き実行
  def whenTrue(condition: Boolean)(action: => Unit): Unit =
    if (condition) action
  
  var count = 0
  
  whenTrue(true) {
    count += 1
    println(s"実行されました: $count")
  }
  
  whenTrue(false) {
    count += 1  // 実行されない
    println(s"実行されました: $count")
  }
  
  println(s"最終カウント: $count")  // 1
}
```

## 関数を引数として受け取る

```scala
// FunctionAsParams.scala
@main def functionAsParams(): Unit = {
  // 関数を引数に取る関数
  def applyTwice(f: Int => Int, x: Int): Int =
    f(f(x))
  
  val double = (x: Int) => x * 2
  val addOne = (x: Int) => x + 1
  
  println(s"2倍を2回: ${applyTwice(double, 3)}")  // 12
  println(s"+1を2回: ${applyTwice(addOne, 3)}")   // 5
  
  // リストの操作
  def processlist(
    numbers: List[Int],
    filter: Int => Boolean,
    transform: Int => Int
  ): List[Int] =
    numbers.filter(filter).map(transform)
  
  val data = List(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
  
  val result1 = processlist(
    data,
    x => x % 2 == 0,  // 偶数のみ
    x => x * x        // 2乗する
  )
  
  println(s"偶数の2乗: $result1")
  
  // カスタム比較関数
  def findBest[T](items: List[T], isBetter: (T, T) => Boolean): Option[T] =
    items match {
      case Nil => None
      case head :: tail =>
        Some(tail.foldLeft(head)((best, item) =>
          if (isBetter(item, best)) item else best
        ))
    }
  
  case class Product(name: String, price: Int, rating: Double)
  
  val products = List(
    Product("商品A", 1000, 4.5),
    Product("商品B", 1500, 4.8),
    Product("商品C", 800, 4.2)
  )
  
  val cheapest = findBest(products, (a, b) => a.price < b.price)
  val highestRated = findBest(products, (a, b) => a.rating > b.rating)
  
  println(s"最安: $cheapest")
  println(s"最高評価: $highestRated")
}
```

## 実践例：DSL（ドメイン特化言語）の作成

```scala
// DSLExample.scala
@main def dslExample(): Unit = {
  // HTMLビルダーDSL
  class HtmlBuilder:
    private val content = scala.collection.mutable.StringBuilder()
    
    def tag(name: String)(body: => Unit): this.type =
      content.append(s"<$name>")
      body
      content.append(s"</$name>")
      this
    
    def text(value: String): this.type =
      content.append(value)
      this
    
    def attr(name: String, value: String): this.type =
      content.insert(content.lastIndexOf(">"), s""" $name="$value"""")
      this
    
    override def toString: String = content.toString
  
  // 使いやすいAPI
  def html(body: HtmlBuilder => Unit): String =
    val builder = new HtmlBuilder
    body(builder)
    builder.toString
  
  // DSLを使う
  val page = html { h =>
    h.tag("div") {
      h.attr("class", "container")
       .tag("h1") {
         h.text("Scalaで作るDSL")
       }
       .tag("p") {
         h.text("関数の引数を活用すると、")
          .tag("strong") {
            h.text("読みやすい")
          }
          .text("コードが書けます。")
       }
    }
  }
  
  println(page)
  
  // 設定DSL
  case class ServerConfig(
    host: String = "localhost",
    port: Int = 8080,
    ssl: Boolean = false
  )
  
  def server(configure: ServerConfig => ServerConfig): ServerConfig =
    configure(ServerConfig())
  
  val config = server { c =>
    c.copy(
      host = "example.com",
      port = 443,
      ssl = true
    )
  }
  
  println(s"サーバー設定: $config")
}
```

## 練習してみよう！

### 練習1：可変長引数

以下の関数を作ってください：
- 複数の文字列を受け取り、指定された区切り文字で連結する
- 数値をいくつでも受け取り、平均値を計算する
- 可変長引数で受け取った値の中から、条件に合うものだけを返す

### 練習2：カリー化

以下をカリー化を使って実装してください：
- 割引率を固定した価格計算関数
- ログレベルを固定したロガー関数
- 範囲チェック関数（最小値と最大値を段階的に設定）

### 練習3：高階関数

リストと複数の関数を受け取って、順番に適用する関数を作ってください。
例：filter → map → reduce のような処理のパイプライン

## この章のまとめ

関数の引数の高度な使い方を学びました！

### できるようになったこと

✅ **可変長引数**
- 任意の数の引数を受け取る
- リストの展開
- 実用的な使い方

✅ **カリー化**
- 関数の部分適用
- 設定の固定
- DSLの作成

✅ **特殊な引数**
- 暗黙の引数（using/given）
- by-name引数
- 関数を引数として渡す

✅ **実践的な応用**
- 柔軟なAPI設計
- DSLの構築
- 高階関数の活用

### 賢い引数設計のコツ

1. **使いやすさを重視**
    - デフォルト値の活用
    - 必須引数は最小限に
    - 名前付き引数の活用

2. **柔軟性の確保**
    - 可変長引数で拡張性
    - カリー化で部分適用
    - 関数引数でカスタマイズ

3. **型安全性**
    - 暗黙の引数で文脈を管理
    - 型パラメータの活用
    - コンパイル時チェック

### 次の章では...

高階関数についてさらに深く学びます。関数を組み合わせて、より強力で表現力豊かなプログラムを作る方法を習得しましょう！

### 最後に

関数の引数は「関数への入口」です。この入口を上手に設計すれば、使いやすく、強力で、美しいAPIが作れます。まるで、良いデザインの建物の入口のように、入った瞬間から使い方が分かる、そんな関数を目指しましょう！