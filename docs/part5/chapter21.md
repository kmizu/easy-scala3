# 第21章 Try[T]で例外を扱う

## はじめに

料理をしていて、うっかり塩と砂糖を間違えたことはありませんか？プログラムでも、予期しないことが起きることがあります。ファイルが見つからない、ネットワークが切れる、計算でゼロ除算してしまう...

従来のプログラミングでは、こうした「例外」が起きるとプログラムが止まってしまいます。でも、Scalaの`Try`を使えば、エラーも「普通の値」として扱えるんです！

## 例外って何だろう？

### 従来の例外処理

```scala
// TraditionalExceptionHandling.scala
@main def traditionalExceptionHandling(): Unit = {
  // 危険な割り算（ゼロ除算の可能性）
  def divide(a: Int, b: Int): Int = a / b
  
  // try-catchで例外を捕まえる（従来の方法）
  try {
    val result = divide(10, 0)
    println(s"結果: $result")
  } catch {
    case e: ArithmeticException =>
      println(s"算術エラー: ${e.getMessage}")
    case e: Exception =>
      println(s"その他のエラー: ${e.getMessage}")
  }
  
  // 問題点：
  // 1. エラー処理を忘れやすい
  // 2. どこで例外が起きるか分かりにくい
  // 3. 正常系と異常系のコードが混在
  
  // もっと良い方法があります！
}
```

## Tryの基本

### Success（成功）とFailure（失敗）

```scala
// TryBasics.scala
@main def tryBasics(): Unit = {
  import scala.util.{Try, Success, Failure}
  
  // Tryで安全に割り算
  def safeDivide(a: Int, b: Int): Try[Int] = Try {
    a / b  // この中で例外が起きてもOK
  }
  
  // 成功する場合
  val result1 = safeDivide(10, 2)
  println(s"10 ÷ 2 = $result1")  // Success(5)
  
  // 失敗する場合
  val result2 = safeDivide(10, 0)
  println(s"10 ÷ 0 = $result2")  // Failure(java.lang.ArithmeticException: / by zero)
  
  // パターンマッチで処理
  result1 match {
    case Success(value) => println(s"成功！答えは $value")
    case Failure(error) => println(s"失敗: ${error.getMessage}")
  }
  
  result2 match {
    case Success(value) => println(s"成功！答えは $value")
    case Failure(error) => println(s"失敗: ${error.getMessage}")
  }
}
```

### Tryの作成方法

```scala
// CreatingTry.scala
@main def creatingTry(): Unit = {
  import scala.util.{Try, Success, Failure}
  
  // 方法1：Try { ... } を使う
  val try1 = Try {
    "123".toInt
  }
  println(s"文字列→数値: $try1")
  
  // 方法2：直接SuccessまたはFailureを作る
  val try2 = Success(42)
  val try3 = Failure(new IllegalArgumentException("不正な引数"))
  
  // 実用例：ファイル読み込み
  import scala.io.Source
  
  def readFile(filename: String): Try[String] = Try {
    val source = Source.fromFile(filename)
    try {
      source.mkString
    } finally {
      source.close()
    }
  }
  
  val content = readFile("test.txt")
  content match {
    case Success(text) => println(s"ファイルの内容: ${text.take(50)}...")
    case Failure(error) => println(s"ファイル読み込みエラー: ${error.getMessage}")
  }
}
```

## Tryの便利なメソッド

### map、flatMap、filter

```scala
// TryTransformations.scala
@main def tryTransformations(): Unit = {
  import scala.util.{Try, Success, Failure}
  
  // map：成功時に値を変換
  val try1 = Try("123".toInt)
  val doubled = try1.map(_ * 2)
  println(s"2倍: $doubled")
  
  // 失敗の場合はそのまま伝播
  val try2 = Try("abc".toInt)
  val doubled2 = try2.map(_ * 2)
  println(s"失敗の場合: $doubled2")
  
  // flatMap：Tryを返す関数と組み合わせ
  def sqrt(x: Double): Try[Double] = {
    if (x >= 0) Success(math.sqrt(x))
    else Failure(new IllegalArgumentException("負の数の平方根は計算できません"))
  }
  
  val result = for {
    num <- Try("16".toDouble)
    root <- sqrt(num)
  } yield root
  
  println(s"√16 = $result")
  
  // filter：条件を満たさない場合は失敗に
  val filtered = Try(10).filter(_ > 5)
  println(s"10 > 5: $filtered")
  
  val filtered2 = Try(3).filter(_ > 5)
  println(s"3 > 5: $filtered2")
}
```

### getOrElse、orElse、recover

```scala
// TryRecovery.scala
@main def tryRecovery(): Unit = {
  import scala.util.{Try, Success, Failure}
  
  def parseNumber(s: String): Try[Int] = Try(s.toInt)
  
  // getOrElse：失敗時のデフォルト値
  val num1 = parseNumber("123").getOrElse(0)
  val num2 = parseNumber("abc").getOrElse(0)
  
  println(s"成功時: $num1")
  println(s"失敗時: $num2")
  
  // orElse：失敗時に別のTryを試す
  val primary = parseNumber("abc")
  val fallback = parseNumber("999")
  val result = primary.orElse(fallback)
  
  println(s"フォールバック: $result")
  
  // recover：特定の例外から回復
  val recovered = parseNumber("xyz").recover {
    case _: NumberFormatException => -1
    case _: NullPointerException => -2
  }
  
  println(s"リカバー: $recovered")
  
  // recoverWith：別のTryで回復
  def parseWithDefault(s: String, default: String): Try[Int] = {
    parseNumber(s).recoverWith {
      case _: NumberFormatException => parseNumber(default)
    }
  }
  
  println(s"デフォルト付き: ${parseWithDefault("abc", "100")}")
}
```

## 実践例：設定ファイルの読み込み

```scala
// ConfigLoader.scala
@main def configLoader(): Unit = {
  import scala.util.{Try, Success, Failure}
  import scala.io.Source
  
  case class Config(
    host: String,
    port: Int,
    timeout: Int,
    debug: Boolean
  )
  
  object ConfigLoader {
    def load(filename: String): Try[Config] =
      for {
        content <- readFile(filename)
        parsed <- parseConfig(content)
        validated <- validateConfig(parsed)
      } yield validated
    
    private def readFile(filename: String): Try[String] = Try {
      val source = Source.fromFile(filename)
      try {
        source.mkString
      } finally {
        source.close()
      }
    }
    
    private def parseConfig(content: String): Try[Map[String, String]] = Try {
      content.split("\n")
        .filter(_.contains("="))
        .map { line =>
          val Array(key, value) = line.split("=", 2)
          key.trim -> value.trim
        }
        .toMap
    }
    
    private def validateConfig(data: Map[String, String]): Try[Config] = Try {
      Config(
        host = data.getOrElse("host", "localhost"),
        port = data.get("port").map(_.toInt).getOrElse(8080),
        timeout = data.get("timeout").map(_.toInt).getOrElse(30),
        debug = data.get("debug").map(_.toBoolean).getOrElse(false)
      )
    }
  }
  
  // テスト用の設定ファイルを作成
  import java.io.PrintWriter
  Try {
    val writer = new PrintWriter("app.conf")
    try {
      writer.println("host = example.com")
      writer.println("port = 3000")
      writer.println("timeout = 60")
      writer.println("debug = true")
    } finally {
      writer.close()
    }
  }
  
  // 設定を読み込む
  ConfigLoader.load("app.conf") match {
    case Success(config) =>
      println("設定読み込み成功:")
      println(s"  ホスト: ${config.host}")
      println(s"  ポート: ${config.port}")
      println(s"  タイムアウト: ${config.timeout}秒")
      println(s"  デバッグ: ${config.debug}")
    case Failure(error) =>
      println(s"設定読み込みエラー: ${error.getMessage}")
  }
  
  // 存在しないファイル
  ConfigLoader.load("missing.conf") match {
    case Success(_) => println("成功（あり得ない）")
    case Failure(error) => println(s"予想通りエラー: ${error.getMessage}")
  }
}
```

## TryとOptionの変換

```scala
// TryOptionConversion.scala
@main def tryOptionConversion(): Unit = {
  import scala.util.{Try, Success, Failure}
  
  // Try → Option
  val try1: Try[Int] = Success(42)
  val try2: Try[Int] = Failure(new Exception("エラー"))
  
  val opt1 = try1.toOption
  val opt2 = try2.toOption
  
  println(s"Success → Option: $opt1")  // Some(42)
  println(s"Failure → Option: $opt2")  // None
  
  // Option → Try
  val some: Option[String] = Some("Hello")
  val none: Option[String] = None
  
  val try3 = some.map(Success(_)).getOrElse(
    Failure(new NoSuchElementException("値がありません"))
  )
  val try4 = none.map(Success(_)).getOrElse(
    Failure(new NoSuchElementException("値がありません"))
  )
  
  println(s"Some → Try: $try3")
  println(s"None → Try: $try4")
  
  // 実用例：安全なデータ変換
  def parseAndDouble(s: String): Option[Int] =
    Try(s.toInt).map(_ * 2).toOption
  
  println(s"正常: ${parseAndDouble("5")}")
  println(s"エラー: ${parseAndDouble("abc")}")
}
```

## TryとFutureの組み合わせ

```scala
// TryWithFuture.scala
@main def tryWithFuture(): Unit = {
  import scala.util.{Try, Success, Failure}
  import scala.concurrent.{Future, Await}
  import scala.concurrent.duration.*
  import scala.concurrent.ExecutionContext.Implicits.global
  
  // 非同期でファイルを読む
  def readFileAsync(filename: String): Future[Try[String]] = Future {
    Try {
      val source = scala.io.Source.fromFile(filename)
      try {
        source.mkString
      } finally {
        source.close()
      }
    }
  }
  
  // 複数ファイルを並行で読む
  val files = List("file1.txt", "file2.txt", "file3.txt")
  
  val futureResults = Future.sequence(
    files.map(readFileAsync)
  )
  
  val results = Await.result(futureResults, 5.seconds)
  
  results.zipWithIndex.foreach { case (result, index) =>
    result match {
      case Success(content) =>
        println(s"ファイル${index + 1}: 成功（${content.length}文字）")
      case Failure(error) =>
        println(s"ファイル${index + 1}: 失敗（${error.getMessage}）")
    }
  }
  
  // Future[Try[T]] を Try[Future[T]] に変換
  def sequence[T](futures: List[Future[Try[T]]]): Future[Try[List[T]]] = {
    Future.sequence(futures).map { results =>
      results.foldLeft[Try[List[T]]](Success(Nil)) { (acc, result) =>
        acc.flatMap { list =>
          result.map(list :+ _)
        }
      }
    }
  }
}
```

## エラーハンドリングのベストプラクティス

```scala
// ErrorHandlingBestPractices.scala
@main def errorHandlingBestPractices(): Unit = {
  import scala.util.{Try, Success, Failure}
  
  // カスタムエラー型
  sealed trait AppError extends Exception
  case class ValidationError(message: String) extends AppError
  case class NetworkError(message: String) extends AppError
  case class DatabaseError(message: String) extends AppError
  
  // エラーを分類して処理
  def processData(input: String): Try[String] =
    validateInput(input)
      .flatMap(fetchFromNetwork)
      .flatMap(saveToDatabase)
      .recover {
        case ValidationError(msg) =>
          s"入力エラー: $msg"
        case NetworkError(msg) =>
          s"通信エラー: $msg（ローカルキャッシュを使用）"
        case DatabaseError(msg) =>
          s"保存エラー: $msg（リトライが必要）"
      }
  
  def validateInput(input: String): Try[String] = {
    if (input.trim.isEmpty) {
      Failure(ValidationError("入力が空です"))
    } else if (input.length > 100) {
      Failure(ValidationError("入力が長すぎます"))
    } else {
      Success(input)
    }
  }
  
  def fetchFromNetwork(data: String): Try[String] = {
    if (scala.util.Random.nextBoolean()) {
      Success(s"ネットワークから取得: $data")
    } else {
      Failure(NetworkError("接続できません"))
    }
  }
  
  def saveToDatabase(data: String): Try[String] = {
    if (scala.util.Random.nextBoolean()) {
      Success(s"保存完了: $data")
    } else {
      Failure(DatabaseError("ディスク容量不足"))
    }
  }
  
  // テスト
  val inputs = List("", "正常なデータ", "a" * 150)
  
  inputs.foreach { input =>
    println(s"\n入力: '${input.take(20)}...'")
    processData(input) match {
      case Success(result) => println(s"成功: $result")
      case Failure(error) => println(s"失敗: ${error.getMessage}")
    }
  }
}
```

## 実践例：CSVパーサー

```scala
// CsvParser.scala
@main def csvParser(): Unit = {
  import scala.util.{Try, Success, Failure}
  
  case class Person(name: String, age: Int, email: String)
  
  object CsvParser {
    def parseFile(filename: String): Try[List[Person]] =
      for {
        content <- readFile(filename)
        lines <- Try(content.split("\n").toList)
        header <- parseHeader(lines.headOption)
        data <- parseData(lines.drop(1), header)
      } yield data
    
    private def readFile(filename: String): Try[String] = Try {
      val source = scala.io.Source.fromFile(filename)
      try source.mkString
      finally source.close()
    }
    
    private def parseHeader(headerOpt: Option[String]): Try[List[String]] =
      headerOpt match {
        case Some(header) => Success(header.split(",").map(_.trim).toList)
        case None => Failure(new Exception("ヘッダーがありません"))
      }
    
    private def parseData(lines: List[String], header: List[String]): Try[List[Person]] =
      Try {
        lines.filter(_.trim.nonEmpty).map { line =>
          val values = line.split(",").map(_.trim)
          if (values.length != header.length) {
            throw new Exception(s"列数が一致しません: $line")
          }
          
          val data = header.zip(values).toMap
          Person(
            name = data.getOrElse("name", throw new Exception("名前がありません")),
            age = data.get("age").map(_.toInt).getOrElse(throw new Exception("年齢がありません")),
            email = data.getOrElse("email", throw new Exception("メールがありません"))
          )
        }
      }
  }
  
  // テスト用CSVファイルを作成
  import java.io.PrintWriter
  Try {
    val writer = new PrintWriter("people.csv")
    try {
      writer.println("name,age,email")
      writer.println("田中太郎,25,taro@example.com")
      writer.println("山田花子,30,hanako@example.com")
      writer.println("佐藤次郎,invalid,jiro@example.com")  // エラーデータ
    } finally {
      writer.close()
    }
  }
  
  // パース実行
  CsvParser.parseFile("people.csv") match {
    case Success(people) =>
      println("パース成功:")
      people.foreach(println)
    case Failure(error) =>
      println(s"パースエラー: ${error.getMessage}")
      error.printStackTrace()
  }
}
```

## 練習してみよう！

### 練習1：JSON風パーサー

簡単なJSON風の文字列（`key:value,key:value`形式）をパースする関数を作ってください。
不正な形式の場合は適切なエラーメッセージを返してください。

### 練習2：計算機

文字列で数式を受け取って計算する関数を作ってください。
（例："10 + 20", "100 / 5"）
不正な入力やゼロ除算を適切に処理してください。

### 練習3：バッチ処理

ファイルのリストを受け取って、すべてのファイルを処理する関数を作ってください。
一部のファイルが失敗しても、処理可能なファイルはすべて処理し、
最後に成功数と失敗数をレポートしてください。

## この章のまとめ

例外を値として扱う方法を学びました！

### できるようになったこと

✅ **Tryの基本**
- Success と Failure
- 例外の安全な処理
- Try の作成方法

✅ **Tryの操作**
- map, flatMap での変換
- recover でのエラー回復
- filter での条件チェック

✅ **実践的な使い方**
- ファイル読み込み
- 設定の解析
- データ変換

✅ **他の型との連携**
- Option との変換
- Future との組み合わせ
- エラーの分類と処理

### Try を使うコツ

1. **早期のTry化**
    - 例外が起きる可能性のある処理は即Try
    - 境界部分でのエラー処理
    - 外部リソースへのアクセス

2. **エラーの分類**
    - カスタムエラー型の定義
    - recover での適切な処理
    - ユーザーフレンドリーなメッセージ

3. **関数型スタイル**
    - for式での組み合わせ
    - map/flatMapの活用
    - 例外を投げない設計

### 次の部では...

第VI部では、型で設計するデータ構造について学びます。ケースクラスやシールドトレイトを使った、より安全で表現力豊かなプログラミングを習得しましょう！

### 最後に

Try は「エラーの救急箱」のようなものです。プログラムで何か問題が起きても、慌てずに対処できます。例外を恐れずに、むしろ「普通の値」として扱うことで、より堅牢なプログラムが書けるようになります。エラーと友達になりましょう！