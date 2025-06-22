# 第15章 パターンマッチングの威力

## はじめに

前章で学んだif式は便利でしたが、Scalaにはもっと強力な「パターンマッチング」という機能があります。

パターンマッチングは、データの「形」を見て処理を分岐できる、まるで「仕分け名人」のような機能です。郵便局で手紙を仕分けるように、データを見て適切な処理に振り分けられます。

この章では、Scalaの真骨頂であるパターンマッチングを楽しく学んでいきましょう！

## match式の基本

### シンプルなマッチング

```scala
// BasicMatch.scala
@main def basicMatch(): Unit = {
  val day = "月曜日"
  
  val message = day match {
    case "月曜日" => "今週も頑張りましょう！"
    case "金曜日" => "もうすぐ週末ですね！"
    case "土曜日" | "日曜日" => "休日を楽しみましょう！"
    case _ => "今日も一日お疲れさまです"
  }
  
  println(message)
  
  // 数値のマッチング
  val number = 3
  
  number match {
    case 1 => println("最初の数")
    case 2 => println("2番目")
    case 3 => println("3番目")
    case n => println(s"その他の数: $n")
  }
}
```

`match`は値を見て、最初にマッチした`case`の処理を実行します。`_`は「その他すべて」を表す特別な記号です。

### 型でマッチング

```scala
// TypeMatching.scala
@main def typeMatching(): Unit = {
  def describe(x: Any): String = x match {
    case i: Int => s"整数: $i"
    case d: Double => s"小数: $d"
    case s: String => s"文字列: '$s'"
    case b: Boolean => s"真偽値: $b"
    case _ => "その他の型"
  }
  
  println(describe(42))
  println(describe(3.14))
  println(describe("Hello"))
  println(describe(true))
  println(describe(List(1, 2, 3)))
```

## パターンの種類

### リストのパターン

```scala
// ListPatterns.scala
@main def listPatterns(): Unit = {
  def describeList(list: List[Int]): String = list match {
    case Nil => "空のリスト"
    case head :: Nil => s"要素が1つ: $head"
    case head :: tail => s"先頭: $head, 残り: $tail"
  }
  
  println(describeList(List()))
  println(describeList(List(1)))
  println(describeList(List(1, 2, 3)))
  
  // より複雑なパターン
  def sumFirstTwo(list: List[Int]): Int = list match {
    case first :: second :: _ => first + second
    case first :: Nil => first
    case Nil => 0
  }
  
  println(s"最初の2つの和: ${sumFirstTwo(List(10, 20, 30))}")
  println(s"要素1つ: ${sumFirstTwo(List(5))}")
  println(s"空リスト: ${sumFirstTwo(List())}")
}
```

### タプルのパターン

```scala
// TuplePatterns.scala
@main def tuplePatterns(): Unit = {
  val person = ("太郎", 25, "エンジニア")
  
  person match {
    case (name, age, job) =>
      println(s"$name さん（$age歳）は$jobです")
  }
  
  // 一部だけ使う
  val point = (10, 20)
  
  point match {
    case (0, 0) => println("原点")
    case (x, 0) => println(s"X軸上の点: ($x, 0)")
    case (0, y) => println(s"Y軸上の点: (0, $y)")
    case (x, y) => println(s"一般の点: ($x, $y)")
  }
  
  // 複数の値を返す関数と組み合わせ
  def divide(a: Int, b: Int): (Boolean, Int, Int) =
    if (b == 0) (false, 0, 0)
    else (true, a / b, a % b)
  
  divide(17, 5) match {
    case (false, _, _) => println("エラー：ゼロ除算")
    case (true, q, r) => println(s"17 ÷ 5 = $q 余り $r")
  }
}
```

### ケースクラスのパターン

```scala
// CaseClassPatterns.scala
@main def caseClassPatterns(): Unit = {
  // ケースクラスの定義
  case class Person(name: String, age: Int)
  case class Book(title: String, author: String, year: Int)
  
  val item1: Any = Person("田中太郎", 30)
  val item2: Any = Book("Scala入門", "山田花子", 2024)
  
  def describe(item: Any): String = item match {
    case Person(name, age) =>
      s"$name さん、$age 歳"
    case Book(title, author, year) =>
      s"「$title」 著者: $author ($year年)"
    case _ =>
      "不明なアイテム"
  }
  
  println(describe(item1))
  println(describe(item2))
  
  // より実践的な例
  case class Student(name: String, score: Int, passed: Boolean)
  
  val students = List(
    Student("太郎", 85, true),
    Student("花子", 92, true),
    Student("次郎", 58, false)
  )
  
  students.foreach {
    case Student(name, score, true) =>
      println(s"$name: 合格！($score点)")
    case Student(name, score, false) =>
      println(s"$name: 不合格($score点)")
  }
}
```

## ガード条件

### ifガードを使った詳細な条件

```scala
// PatternGuards.scala
@main def patternGuards(): Unit = {
  def categorizeNumber(x: Int): String = x match {
    case n if n < 0 => "負の数"
    case 0 => "ゼロ"
    case n if n % 2 == 0 => "正の偶数"
    case n if n % 2 == 1 => "正の奇数"
  }
  
  List(-5, 0, 4, 7).foreach { n =>
    println(s"$n は ${categorizeNumber(n)}")
  }
  
  // 成績評価
  case class Score(subject: String, point: Int)
  
  def evaluate(score: Score): String = score match {
    case Score(_, p) if p >= 90 => "S"
    case Score(_, p) if p >= 80 => "A"
    case Score(_, p) if p >= 70 => "B"
    case Score(_, p) if p >= 60 => "C"
    case Score(_, _) => "D"
  }
  
  val scores = List(
    Score("数学", 95),
    Score("英語", 82),
    Score("理科", 68)
  )
  
  scores.foreach { s =>
    println(s"${s.subject}: ${s.point}点 → ${evaluate(s)}評価")
  }
}
```

## 実践的な例

### 電卓プログラム

```scala
// Calculator.scala
@main def calculator(): Unit = {
  sealed trait Operation
  case class Add(a: Double, b: Double) extends Operation
  case class Subtract(a: Double, b: Double) extends Operation
  case class Multiply(a: Double, b: Double) extends Operation
  case class Divide(a: Double, b: Double) extends Operation
  
  def calculate(op: Operation): Either[String, Double] = op match {
    case Add(a, b) => Right(a + b)
    case Subtract(a, b) => Right(a - b)
    case Multiply(a, b) => Right(a * b)
    case Divide(a, b) if b != 0 => Right(a / b)
    case Divide(_, _) => Left("エラー：ゼロで除算はできません")
  }
  
  val operations = List(
    Add(10, 5),
    Subtract(10, 3),
    Multiply(4, 7),
    Divide(20, 4),
    Divide(10, 0)
  )
  
  operations.foreach { op =>
    val opStr = op match {
      case Add(a, b) => s"$a + $b"
      case Subtract(a, b) => s"$a - $b"
      case Multiply(a, b) => s"$a × $b"
      case Divide(a, b) => s"$a ÷ $b"
    }
    
    calculate(op) match {
      case Right(result) => println(s"$opStr = $result")
      case Left(error) => println(s"$opStr → $error")
    }
  }
}
```

### JSONライクなデータ処理

```scala
// JsonLikeData.scala
@main def jsonLikeData(): Unit = {
  // シンプルなJSONライクな型
  sealed trait JsonValue
  case class JsonString(value: String) extends JsonValue
  case class JsonNumber(value: Double) extends JsonValue
  case class JsonBoolean(value: Boolean) extends JsonValue
  case object JsonNull extends JsonValue
  case class JsonArray(values: List[JsonValue]) extends JsonValue
  case class JsonObject(fields: Map[String, JsonValue]) extends JsonValue
  
  // JSONデータを文字列に変換
  def stringify(json: JsonValue): String = json match {
    case JsonString(s) => s""""$s""""
    case JsonNumber(n) => n.toString
    case JsonBoolean(b) => b.toString
    case JsonNull => "null"
    case JsonArray(values) =>
      values.map(stringify).mkString("[", ", ", "]")
    case JsonObject(fields) =>
      fields.map { case (k, v) => s""""$k": ${stringify(v)}""" }
        .mkString("{", ", ", "}")
  }
  
  // サンプルデータ
  val person = JsonObject(Map(
    "name" -> JsonString("田中太郎"),
    "age" -> JsonNumber(30),
    "active" -> JsonBoolean(true),
    "skills" -> JsonArray(List(
      JsonString("Scala"),
      JsonString("Python"),
      JsonString("JavaScript")
    ))
  ))
  
  println(stringify(person))
  
  // 特定のフィールドを取得
  def getField(json: JsonValue, path: String): Option[JsonValue] = 
    (json, path) match {
      case (JsonObject(fields), fieldName) => fields.get(fieldName)
      case _ => None
    }
  
  getField(person, "name") match {
    case Some(JsonString(name)) => println(s"名前: $name")
    case _ => println("名前が見つかりません")
  }
}
```

### 状態管理

```scala
// StateManagement.scala
@main def stateManagement(): Unit = {
  // 信号機の状態
  sealed trait TrafficLight
  case object Red extends TrafficLight
  case object Yellow extends TrafficLight
  case object Green extends TrafficLight
  
  def nextLight(current: TrafficLight): TrafficLight = current match {
    case Red => Green
    case Green => Yellow
    case Yellow => Red
  }
  
  def action(light: TrafficLight): String = light match {
    case Red => "止まれ"
    case Yellow => "注意"
    case Green => "進め"
  }
  
  // シミュレーション
  var light = Red
  for (i <- 1 to 6) {
    println(s"${i}. ${action(light)} ($light)")
    light = nextLight(light)
  }
  
  // 自動販売機の状態
  case class VendingMachine(money: Int, stock: Map[String, Int])
  
  sealed trait Command
  case class InsertMoney(amount: Int) extends Command
  case class SelectItem(name: String) extends Command
  case object ReturnMoney extends Command
  
  def processCommand(vm: VendingMachine, cmd: Command): VendingMachine = 
    cmd match {
      case InsertMoney(amount) =>
        println(s"${amount}円投入しました")
        vm.copy(money = vm.money + amount)
      
      case SelectItem(name) =>
        vm.stock.get(name) match {
          case Some(count) if count > 0 && vm.money >= 120 =>
            println(s"$name を購入しました")
            vm.copy(
              money = vm.money - 120,
              stock = vm.stock + (name -> (count - 1))
            )
          case Some(count) if count == 0 =>
            println(s"$name は売り切れです")
            vm
          case _ =>
            println("お金が足りません")
            vm
        }
      
      case ReturnMoney =>
        println(s"${vm.money}円返却しました")
        vm.copy(money = 0)
    }
  
  // 使ってみる
  var machine = VendingMachine(0, Map("コーラ" -> 3, "水" -> 2))
  
  val commands = List(
    InsertMoney(100),
    SelectItem("コーラ"),  // お金不足
    InsertMoney(50),
    SelectItem("コーラ"),  // 購入成功
    ReturnMoney
  )
  
  println("\n=== 自動販売機シミュレーション ===")
  commands.foreach { cmd =>
    machine = processCommand(machine, cmd)
  }
}
```

## 部分関数

```scala
// PartialFunctions.scala
@main def partialFunctions(): Unit = {
  // 部分関数の定義
  val doubleEvens: PartialFunction[Int, Int] = {
    case x if x % 2 == 0 => x * 2
  }
  
  // collectで使う
  val numbers = List(1, 2, 3, 4, 5, 6)
  val doubled = numbers.collect(doubleEvens)
  println(s"偶数を2倍: $doubled")
  
  // 複数の部分関数を組み合わせ
  val processSpecial: PartialFunction[Int, String] = {
    case 0 => "ゼロ"
    case n if n > 0 && n % 2 == 0 => s"正の偶数: $n"
    case n if n < 0 => s"負の数: $n"
  }
  
  val special = List(-5, 0, 2, 3, 4, -2)
  val processed = special.collect(processSpecial)
  println(s"特別な数: $processed")
  
  // エラーハンドリングでの活用
  def safeDivide(a: Int, b: Int): Either[String, Int] =
    try Right(a / b)
    catch {
      case _: ArithmeticException => Left("ゼロ除算エラー")
      case _: Exception => Left("予期しないエラー")
    }
  
  List((10, 2), (10, 0), (20, 4)).foreach { case (a, b) =>
    safeDivide(a, b) match {
      case Right(result) => println(s"$a ÷ $b = $result")
      case Left(error) => println(s"$a ÷ $b → $error")
    }
  }
}
```

## パターンマッチングのコツ

### 網羅性の確認

```scala
// ExhaustiveMatching.scala
@main def exhaustiveMatching(): Unit = {
  sealed trait Color
  case object Red extends Color
  case object Green extends Color
  case object Blue extends Color
  
  // すべてのケースを網羅
  def toRGB(color: Color): String = color match {
    case Red => "#FF0000"
    case Green => "#00FF00"
    case Blue => "#0000FF"
    // sealed traitなので、すべてのケースが網羅されているかコンパイラがチェック
  }
  
  // Option型での網羅
  def processOption(opt: Option[String]): String = opt match {
    case Some(value) => s"値あり: $value"
    case None => "値なし"
  }
  
  println(processOption(Some("Hello")))
  println(processOption(None))
}
```

## 練習してみよう！

### 練習1：曜日判定

数値（1-7）を受け取って曜日名を返す関数を、パターンマッチングで作ってください。
範囲外の数値の場合はエラーメッセージを返してください。

### 練習2：図形の面積計算

以下の図形を表すケースクラスを定義し、面積を計算する関数を作ってください：
- Circle(radius: Double)
- Rectangle(width: Double, height: Double)
- Triangle(base: Double, height: Double)

### 練習3：コマンドラインパーサー

文字列のコマンドをパースして適切な処理を行う関数を作ってください：
- "help" → ヘルプを表示
- "add 数値 数値" → 2つの数値を足す
- "multiply 数値 数値" → 2つの数値を掛ける
- その他 → "不明なコマンド"

## この章のまとめ

パターンマッチングの威力を体験できましたね！

### できるようになったこと

✅ **match式の基本**
- 値のマッチング
- 型のマッチング
- デフォルトケース（_）

✅ **様々なパターン**
- リストのパターン
- タプルのパターン
- ケースクラスのパターン

✅ **高度な機能**
- ガード条件
- 部分関数
- 網羅性チェック

✅ **実践的な使い方**
- 状態管理
- データ処理
- エラーハンドリング

### パターンマッチングを使うべき場面

1. **複雑な条件分岐**
    - if-elseが複雑になったとき
    - データの構造で分岐したいとき

2. **データの分解**
    - タプルやケースクラスから値を取り出す
    - リストの要素にアクセス

3. **型安全な処理**
    - sealed traitで網羅性を保証
    - コンパイル時のチェック

### 次の章では...

関数の定義と利用について詳しく学びます。パターンマッチングと組み合わせると、さらに強力なプログラムが書けるようになりますよ！

### 最後に

パターンマッチングは「Scalaの花形機能」と言われています。最初は難しく感じるかもしれませんが、使いこなせるようになると、とてもエレガントなコードが書けるようになります。まるで、プログラムが自然言語のように読めるようになるんです！