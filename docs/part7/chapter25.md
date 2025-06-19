# 第25章 関数合成で処理を組み立てる

## はじめに

料理をするとき、「野菜を洗う」→「切る」→「炒める」という手順を組み合わせて一つの料理を作りますよね。プログラミングでも、小さな関数を組み合わせて大きな処理を作ることができます。

これが「関数合成」です。レゴブロックのように、小さな部品を組み合わせて、複雑なものを作り上げる楽しさを味わいましょう！

## 関数合成って何だろう？

### 関数をつなげる

```scala
// FunctionCompositionBasics.scala
@main def functionCompositionBasics(): Unit =
  // 単純な関数たち
  val double = (x: Int) => x * 2
  val addTen = (x: Int) => x + 10
  val square = (x: Int) => x * x
  
  // 手動で組み合わせる（面倒...）
  val result1 = square(addTen(double(3)))
  println(s"3を2倍して10足して2乗: $result1")
  
  // andThenで組み合わせる（読みやすい！）
  val combined = double.andThen(addTen).andThen(square)
  val result2 = combined(3)
  println(s"関数合成の結果: $result2")
  
  // composeで逆順に組み合わせる
  val reversed = square.compose(addTen).compose(double)
  val result3 = reversed(3)
  println(s"composeの結果: $result3")
  
  // 実用例：文字列処理パイプライン
  val trim = (s: String) => s.trim
  val toLowerCase = (s: String) => s.toLowerCase
  val removeSpaces = (s: String) => s.replace(" ", "_")
  
  val normalize = trim.andThen(toLowerCase).andThen(removeSpaces)
  
  val inputs = List(
    "  Hello World  ",
    "  SCALA Programming  ",
    "  Functional Composition  "
  )
  
  println("\n=== 文字列の正規化 ===")
  inputs.foreach { input =>
    println(s"'$input' → '${normalize(input)}'")
  }
```

### パイプライン演算子風の実装

```scala
// PipelineOperator.scala
@main def pipelineOperator(): Unit =
  // パイプライン風の拡張メソッド
  extension [A](value: A)
    def |>[B](f: A => B): B = f(value)
    def tap(f: A => Unit): A = 
      f(value)
      value
  
  // 使用例
  val result = 5
    |> (_ * 2)
    |> (_ + 10)
    |> (_ * _ )
    .tap(x => println(s"中間結果: $x"))
    |> (_ / 5)
  
  println(s"最終結果: $result")
  
  // 実用例：データ変換パイプライン
  case class User(name: String, email: String, age: Int)
  
  val processUser = User("  John Doe  ", "JOHN@EXAMPLE.COM", 25)
    |> (u => u.copy(name = u.name.trim))
    |> (u => u.copy(email = u.email.toLowerCase))
    .tap(u => println(s"処理中: $u"))
    |> (u => if u.age >= 18 then Some(u) else None)
  
  processUser match
    case Some(user) => println(s"有効なユーザー: $user")
    case None => println("無効なユーザー")
```

## 実践的な関数合成

### データ検証パイプライン

```scala
// ValidationPipeline.scala
@main def validationPipeline(): Unit =
  // 検証結果を表す型
  type Validation[A] = Either[String, A]
  
  // 検証関数の型
  type Validator[A] = A => Validation[A]
  
  // 基本的な検証関数
  val notEmpty: Validator[String] = s =>
    if s.trim.nonEmpty then Right(s)
    else Left("空文字列は許可されません")
  
  val minLength: Int => Validator[String] = min => s =>
    if s.length >= min then Right(s)
    else Left(s"${min}文字以上必要です")
  
  val maxLength: Int => Validator[String] = max => s =>
    if s.length <= max then Right(s)
    else Left(s"${max}文字以下にしてください")
  
  val alphanumeric: Validator[String] = s =>
    if s.matches("^[a-zA-Z0-9]+$") then Right(s)
    else Left("英数字のみ使用可能です")
  
  // 検証関数を合成
  def andThen[A](v1: Validator[A], v2: Validator[A]): Validator[A] = a =>
    v1(a).flatMap(v2)
  
  def combine[A](validators: Validator[A]*): Validator[A] =
    validators.reduce(andThen)
  
  // ユーザー名の検証パイプライン
  val validateUsername = combine(
    notEmpty,
    minLength(3),
    maxLength(20),
    alphanumeric
  )
  
  // テスト
  val testCases = List(
    "john123",
    "ab",
    "verylongusernamethatexceedslimit",
    "user@name",
    "ValidUser123",
    ""
  )
  
  println("=== ユーザー名検証 ===")
  testCases.foreach { username =>
    validateUsername(username) match
      case Right(valid) => println(s"✓ '$valid'")
      case Left(error) => println(s"✗ '$username': $error")
  }
```

### 画像処理パイプライン

```scala
// ImageProcessingPipeline.scala
@main def imageProcessingPipeline(): Unit =
  // 画像を表す簡単なモデル
  case class Image(
    width: Int,
    height: Int,
    pixels: Vector[Int],  // 簡略化のため1次元配列
    metadata: Map[String, String] = Map.empty
  )
  
  // 画像処理関数の型
  type ImageProcessor = Image => Image
  
  // 基本的な画像処理関数
  val resize: (Int, Int) => ImageProcessor = (newWidth, newHeight) => img =>
    // 実際のリサイズロジックは省略
    img.copy(
      width = newWidth,
      height = newHeight,
      metadata = img.metadata + ("resized" -> s"${newWidth}x${newHeight}")
    )
  
  val grayscale: ImageProcessor = img =>
    img.copy(
      metadata = img.metadata + ("filter" -> "grayscale")
    )
  
  val blur: Int => ImageProcessor = radius => img =>
    img.copy(
      metadata = img.metadata + ("blur" -> s"radius:$radius")
    )
  
  val compress: Int => ImageProcessor = quality => img =>
    img.copy(
      metadata = img.metadata + ("compression" -> s"quality:$quality")
    )
  
  val addWatermark: String => ImageProcessor = text => img =>
    img.copy(
      metadata = img.metadata + ("watermark" -> text)
    )
  
  // 処理パイプラインの構築
  class ImagePipeline(processors: List[ImageProcessor] = List.empty):
    def add(processor: ImageProcessor): ImagePipeline =
      new ImagePipeline(processors :+ processor)
    
    def process(image: Image): Image =
      processors.foldLeft(image)((img, proc) => proc(img))
    
    def timed(image: Image): (Image, Long) =
      val start = System.currentTimeMillis()
      val result = process(image)
      val time = System.currentTimeMillis() - start
      (result, time)
  
  // パイプラインの定義
  val thumbnailPipeline = ImagePipeline()
    .add(resize(150, 150))
    .add(compress(85))
  
  val artisticPipeline = ImagePipeline()
    .add(grayscale)
    .add(blur(3))
    .add(addWatermark("© 2024"))
  
  val webOptimizedPipeline = ImagePipeline()
    .add(resize(800, 600))
    .add(compress(75))
    .add(addWatermark("example.com"))
  
  // テスト画像
  val originalImage = Image(1920, 1080, Vector.empty)
  
  // 各パイプラインを実行
  println("=== 画像処理パイプライン ===")
  
  List(
    ("サムネイル", thumbnailPipeline),
    ("アート", artisticPipeline),
    ("Web最適化", webOptimizedPipeline)
  ).foreach { case (name, pipeline) =>
    val (processed, time) = pipeline.timed(originalImage)
    println(s"\n$name パイプライン ($time ms):")
    processed.metadata.foreach { case (k, v) =>
      println(s"  $k: $v")
    }
  }
```

## 関数の部分適用とカリー化

```scala
// PartialApplicationAndCurrying.scala
@main def partialApplicationAndCurrying(): Unit =
  // カリー化された関数
  def log(level: String)(message: String)(timestamp: Long = System.currentTimeMillis()): String =
    f"[$timestamp%tT] [$level%-5s] $message"
  
  // 部分適用でロガーを作成
  val infoLog = log("INFO")
  val errorLog = log("ERROR")
  val debugLog = log("DEBUG")
  
  println("=== ロギング ===")
  println(infoLog("アプリケーション起動")())
  Thread.sleep(100)
  println(errorLog("接続エラー")())
  Thread.sleep(100)
  println(debugLog("変数x = 42")())
  
  // 関数ファクトリー
  def createValidator(min: Int, max: Int): Int => Boolean =
    value => value >= min && value <= max
  
  def createFormatter(prefix: String, suffix: String): Any => String =
    value => s"$prefix$value$suffix"
  
  def createCalculator(operation: String): (Double, Double) => Double =
    operation match
      case "+" => _ + _
      case "-" => _ - _
      case "*" => _ * _
      case "/" => (a, b) => if b != 0 then a / b else 0
      case "^" => math.pow
      case _ => (_, _) => 0
  
  // 使用例
  val isValidAge = createValidator(0, 120)
  val isValidScore = createValidator(0, 100)
  
  val jsonFormatter = createFormatter("{\"value\": \"", "\"}")
  val xmlFormatter = createFormatter("<value>", "</value>")
  
  val add = createCalculator("+")
  val multiply = createCalculator("*")
  val power = createCalculator("^")
  
  println("\n=== バリデーター ===")
  println(s"年齢150は有効？: ${isValidAge(150)}")
  println(s"スコア85は有効？: ${isValidScore(85)}")
  
  println("\n=== フォーマッター ===")
  println(s"JSON: ${jsonFormatter("Hello")}")
  println(s"XML: ${xmlFormatter("World")}")
  
  println("\n=== 計算機 ===")
  println(s"10 + 5 = ${add(10, 5)}")
  println(s"10 * 5 = ${multiply(10, 5)}")
  println(s"2 ^ 8 = ${power(2, 8)}")
```

## モナディック合成

```scala
// MonadicComposition.scala
@main def monadicComposition(): Unit =
  // Optionのための合成
  def parseInt(s: String): Option[Int] =
    try Some(s.toInt)
    catch case _: NumberFormatException => None
  
  def divide(a: Int, b: Int): Option[Double] =
    if b != 0 then Some(a.toDouble / b) else None
  
  def sqrt(x: Double): Option[Double] =
    if x >= 0 then Some(math.sqrt(x)) else None
  
  // for式で合成
  def calculate(aStr: String, bStr: String): Option[Double] =
    for
      a <- parseInt(aStr)
      b <- parseInt(bStr)
      divided <- divide(a, b)
      result <- sqrt(divided)
    yield result
  
  println("=== 計算パイプライン ===")
  val testCases = List(
    ("100", "4"),   // √(100/4) = 5
    ("16", "4"),    // √(16/4) = 2
    ("10", "0"),    // ゼロ除算
    ("abc", "4"),   // パースエラー
    ("-16", "4")    // 負の平方根
  )
  
  testCases.foreach { case (a, b) =>
    calculate(a, b) match
      case Some(result) => println(f"√($a/$b) = $result%.2f")
      case None => println(s"計算できません: $a, $b")
  }
  
  // Eitherのための合成
  sealed trait AppError
  case class ParseError(msg: String) extends AppError
  case class MathError(msg: String) extends AppError
  
  def parseIntE(s: String): Either[AppError, Int] =
    try Right(s.toInt)
    catch case _: NumberFormatException => 
      Left(ParseError(s"'$s'は数値ではありません"))
  
  def divideE(a: Int, b: Int): Either[AppError, Double] =
    if b != 0 then Right(a.toDouble / b)
    else Left(MathError("ゼロで除算はできません"))
  
  def sqrtE(x: Double): Either[AppError, Double] =
    if x >= 0 then Right(math.sqrt(x))
    else Left(MathError(s"負の数の平方根は計算できません: $x"))
  
  def calculateE(aStr: String, bStr: String): Either[AppError, Double] =
    for
      a <- parseIntE(aStr)
      b <- parseIntE(bStr)
      divided <- divideE(a, b)
      result <- sqrtE(divided)
    yield result
  
  println("\n=== エラー付き計算パイプライン ===")
  testCases.foreach { case (a, b) =>
    calculateE(a, b) match
      case Right(result) => println(f"√($a/$b) = $result%.2f")
      case Left(ParseError(msg)) => println(s"パースエラー: $msg")
      case Left(MathError(msg)) => println(s"計算エラー: $msg")
  }
```

## 実践例：ETLパイプライン

```scala
// ETLPipeline.scala
@main def etlPipeline(): Unit =
  import scala.util.Try
  
  // データモデル
  case class RawData(line: String)
  case class ParsedRecord(id: Int, name: String, value: Double)
  case class ValidatedRecord(record: ParsedRecord)
  case class TransformedRecord(id: Int, name: String, value: Double, category: String)
  
  // ETLステップの型
  type ETLStep[A, B] = A => Either[String, B]
  
  // Extract: 生データの読み込み
  val extract: String => Either[String, RawData] = line =>
    if line.trim.nonEmpty then Right(RawData(line))
    else Left("空行です")
  
  // Parse: CSV形式のパース
  val parse: ETLStep[RawData, ParsedRecord] = raw =>
    raw.line.split(",") match
      case Array(idStr, name, valueStr) =>
        for
          id <- Try(idStr.trim.toInt).toEither.left.map(_ => s"IDが不正: $idStr")
          value <- Try(valueStr.trim.toDouble).toEither.left.map(_ => s"値が不正: $valueStr")
        yield ParsedRecord(id, name.trim, value)
      case _ =>
        Left(s"フォーマットエラー: ${raw.line}")
  
  // Validate: データの検証
  val validate: ETLStep[ParsedRecord, ValidatedRecord] = record =>
    if record.id > 0 && record.name.nonEmpty && record.value >= 0 then
      Right(ValidatedRecord(record))
    else
      Left(s"検証エラー: $record")
  
  // Transform: データの変換
  val transform: ETLStep[ValidatedRecord, TransformedRecord] = validated =>
    val record = validated.record
    val category = record.value match
      case v if v < 100 => "低"
      case v if v < 1000 => "中"
      case _ => "高"
    Right(TransformedRecord(record.id, record.name, record.value, category))
  
  // パイプラインの合成
  def pipeline(line: String): Either[String, TransformedRecord] =
    for
      raw <- extract(line)
      parsed <- parse(raw)
      validated <- validate(parsed)
      transformed <- transform(validated)
    yield transformed
  
  // バッチ処理
  class ETLBatch:
    private var successCount = 0
    private var errorCount = 0
    private val errors = scala.collection.mutable.ListBuffer[String]()
    
    def process(lines: List[String]): List[TransformedRecord] =
      lines.flatMap { line =>
        pipeline(line) match
          case Right(record) =>
            successCount += 1
            Some(record)
          case Left(error) =>
            errorCount += 1
            errors += s"行 '$line': $error"
            None
      }
    
    def report(): String =
      s"""ETL処理結果:
         |  成功: $successCount 件
         |  エラー: $errorCount 件
         |${if errors.nonEmpty then s"  エラー詳細:\n${errors.map("    - " + _).mkString("\n")}" else ""}
         |""".stripMargin
  
  // テストデータ
  val csvData = List(
    "1,商品A,250.50",
    "2,商品B,1500.00",
    "invalid,商品C,300",
    "3,,100.00",
    "4,商品D,-50.00",
    "5,商品E,750.25",
    "",
    "6,商品F,3000.00"
  )
  
  // ETL実行
  val batch = new ETLBatch
  val results = batch.process(csvData)
  
  println("=== 変換結果 ===")
  results.foreach { record =>
    println(f"ID:${record.id}%3d ${record.name}%-10s ¥${record.value}%,8.2f [${record.category}]")
  }
  
  println(s"\n${batch.report()}")
```

## 関数合成のベストプラクティス

```scala
// CompositionBestPractices.scala
@main def compositionBestPractices(): Unit =
  // 1. 小さく、単一責任の関数を作る
  val trim = (s: String) => s.trim
  val nonEmpty = (s: String) => s.nonEmpty
  val capitalize = (s: String) => 
    if s.nonEmpty then s.head.toUpper + s.tail.toLowerCase
    else s
  
  // 2. 型を揃えて合成しやすくする
  type StringProcessor = String => String
  
  val processors: List[StringProcessor] = List(
    trim,
    s => if nonEmpty(s) then s else "デフォルト",
    capitalize,
    s => s.replace(" ", "_")
  )
  
  // 3. 合成関数を作る
  val processString: StringProcessor = 
    processors.reduce((f, g) => f.andThen(g))
  
  println("=== 文字列処理 ===")
  val testStrings = List(
    "  hello world  ",
    "  SCALA  ",
    "   ",
    "functional programming"
  )
  
  testStrings.foreach { s =>
    println(f"'$s%-25s' → '${processString(s)}'")
  }
  
  // 4. エラー処理を含む合成
  type Result[A] = Either[String, A]
  type SafeProcessor[A, B] = A => Result[B]
  
  def compose[A, B, C](
    f: SafeProcessor[A, B],
    g: SafeProcessor[B, C]
  ): SafeProcessor[A, C] = a =>
    f(a).flatMap(g)
  
  // 5. デバッグ可能な合成
  def debug[A](label: String)(value: A): A =
    println(s"[$label] $value")
    value
  
  val debuggablePipeline = (x: Int) => x
    |> (_ * 2)
    |> debug("2倍後")
    |> (_ + 10)
    |> debug("10足した後")
    |> (_ / 3)
    |> debug("3で割った後")
  
  println("\n=== デバッグ付きパイプライン ===")
  debuggablePipeline(15)
```

## 練習してみよう！

### 練習1：メール処理パイプライン

メールアドレスを処理するパイプラインを作ってください：
- トリム、小文字化
- 形式の検証
- ドメインの抽出
- スパムドメインのチェック

### 練習2：数値計算パイプライン

数値のリストを処理するパイプラインを作ってください：
- フィルタリング（範囲内の値のみ）
- 変換（スケーリング）
- 集計（平均、分散）

### 練習3：ログ解析パイプライン

ログファイルの行を解析するパイプラインを作ってください：
- タイムスタンプの抽出
- ログレベルの判定
- メッセージのパース
- 統計情報の集計

## この章のまとめ

関数合成の力を体験できましたね！

### できるようになったこと

✅ **関数合成の基本**
- andThenとcompose
- パイプライン演算子
- 関数の連鎖

✅ **実践的な合成**
- 検証パイプライン
- データ変換
- ETL処理

✅ **高度なテクニック**
- 部分適用
- カリー化
- モナディック合成

✅ **ベストプラクティス**
- 小さな関数の組み合わせ
- 型の統一
- エラー処理

### 関数合成を使うコツ

1. **小さく始める**
   - 単一責任の関数
   - 再利用可能な部品
   - テストしやすい単位

2. **型を意識する**
   - 入出力の型を揃える
   - 型エイリアスの活用
   - ジェネリックな設計

3. **読みやすさ重視**
   - 意味のある関数名
   - 適切な抽象度
   - デバッグのしやすさ

### 次の章では...

型パラメータについて詳しく学びます。ジェネリックプログラミングで、より汎用的で再利用可能なコードを書けるようになりましょう！

### 最後に

関数合成は「プログラミングの錬金術」です。シンプルな材料（関数）を組み合わせて、金（複雑な処理）を生み出す。この魔法のような技術をマスターすれば、どんな複雑な問題も、小さな部品の組み合わせで解決できるようになります！