# 第19章 OptionとEitherで安全に

## はじめに

プログラミングでよくある問題：「この値、あるかないか分からない」「エラーが起きるかもしれない」

例えば、辞書で単語を調べたとき、その単語が載っていないかもしれません。割り算をするとき、ゼロで割ってしまうかもしれません。

Scalaには、こうした「不確実性」を安全に扱うための素晴らしい仕組みがあります。それが`Option`と`Either`です！

## Option：値があるかもしれない

### Optionの基本

```scala
// OptionBasics.scala
@main def optionBasics(): Unit = {
  // Optionは「値があるかもしれない」を表す
  val some: Option[Int] = Some(42)      // 値がある
  val none: Option[Int] = None          // 値がない
  
  println(s"値あり: $some")
  println(s"値なし: $none")
  
  // 実用例：辞書検索
  val dictionary = Map(
    "apple" -> "りんご",
    "banana" -> "バナナ",
    "orange" -> "オレンジ"
  )
  
  val result1 = dictionary.get("apple")    // Some("りんご")
  val result2 = dictionary.get("grape")    // None
  
  println(s"appleの意味: $result1")
  println(s"grapeの意味: $result2")
  
  // 安全に値を取り出す
  result1 match {
    case Some(meaning) => println(s"見つかった: $meaning")
    case None => println("見つかりませんでした")
  }
}
```

### Optionの便利なメソッド

```scala
// OptionMethods.scala
@main def optionMethods(): Unit = {
  val someValue: Option[Int] = Some(10)
  val noneValue: Option[Int] = None
  
  // getOrElse：値がなければデフォルト値
  println(s"値あり: ${someValue.getOrElse(0)}")
  println(s"値なし: ${noneValue.getOrElse(0)}")
  
  // map：値があれば変換
  val doubled = someValue.map(_ * 2)
  println(s"2倍: $doubled")
  
  // filter：条件を満たさなければNone
  val filtered = someValue.filter(_ > 5)
  println(s"5より大: $filtered")
  
  // flatMap：Optionを返す関数と組み合わせ
  def half(n: Int): Option[Int] =
    if (n % 2 == 0) Some(n / 2)
    else None
  
  val result = someValue.flatMap(half)
  println(s"半分: $result")
  
  // 複数のOptionを組み合わせる
  val opt1 = Some(10)
  val opt2 = Some(20)
  val opt3: Option[Int] = None
  
  val sum = for {
    a <- opt1
    b <- opt2
    c <- opt3
  } yield a + b + c
  
  println(s"合計: $sum")  // None（1つでもNoneがあれば結果もNone）
}
```

### 実践的な使い方

```scala
// PracticalOption.scala
@main def practicalOption(): Unit =
  // ユーザー検索システム
  case class User(id: Int, name: String, email: Option[String])
  
  val users = List(
    User(1, "太郎", Some("taro@example.com")),
    User(2, "花子", None),  // メールアドレス未登録
    User(3, "次郎", Some("jiro@example.com"))
  )
  
  def findUserById(id: Int): Option[User] =
    users.find(_.id == id)
  
  def sendEmail(userId: Int, message: String): String =
    findUserById(userId) match {
      case Some(user) =>
        user.email match {
          case Some(email) =>
            s"${user.name}さん($email)にメールを送信: $message"
          case None =>
            s"${user.name}さんはメールアドレスが未登録です"
        }
      case None =>
        "ユーザーが見つかりません"
    }
  
  println(sendEmail(1, "お知らせ"))
  println(sendEmail(2, "お知らせ"))
  println(sendEmail(99, "お知らせ"))
  
  // より簡潔に書く方法
  def sendEmailV2(userId: Int, message: String): String =
    (for {
      user <- findUserById(userId)
      email <- user.email
    } yield s"${user.name}さん($email)にメールを送信: $message")
      .getOrElse("送信できません（ユーザー不在またはメールアドレス未登録）")
  
  println("\n=== 簡潔版 ===")
  println(sendEmailV2(1, "お知らせ"))
  println(sendEmailV2(2, "お知らせ"))
}
```

## Either：成功か失敗か

### Eitherの基本

```scala
// EitherBasics.scala
@main def eitherBasics(): Unit = {
  // Eitherは「成功(Right)か失敗(Left)か」を表す
  val success: Either[String, Int] = Right(42)
  val failure: Either[String, Int] = Left("エラーが発生しました")
  
  println(s"成功: $success")
  println(s"失敗: $failure")
  
  // 実用例：割り算
  def divide(a: Int, b: Int): Either[String, Double] =
    if (b == 0) Left("ゼロで割ることはできません")
    else Right(a.toDouble / b)
  
  println(divide(10, 2))
  println(divide(10, 0))
  
  // パターンマッチで処理
  divide(20, 4) match {
    case Right(result) => println(s"結果: $result")
    case Left(error) => println(s"エラー: $error")
  }
}
```

### Eitherの便利な操作

```scala
// EitherOperations.scala
@main def eitherOperations(): Unit = {
  // 年齢検証
  def validateAge(age: Int): Either[String, Int] =
    if (age < 0) Left("年齢は負の数にできません")
    else if (age > 150) Left("年齢が大きすぎます")
    else Right(age)
  
  // 名前検証
  def validateName(name: String): Either[String, String] =
    if (name.trim.isEmpty) Left("名前が空です")
    else if (name.length > 50) Left("名前が長すぎます")
    else Right(name.trim)
  
  // 複数の検証を組み合わせる
  def createUser(name: String, age: Int): Either[String, String] =
    for {
      validName <- validateName(name)
      validAge <- validateAge(age)
    } yield s"ユーザー作成: $validName（$validAge歳）"
  
  println(createUser("太郎", 25))
  println(createUser("", 25))
  println(createUser("花子", -5))
  
  // map, flatMapも使える
  val result = validateAge(30)
    .map(_ * 2)
    .flatMap(validateAge)
  
  println(s"30歳を2倍して検証: $result")
}
```

## OptionとEitherの変換

```scala
// OptionEitherConversion.scala
@main def optionEitherConversion(): Unit = {
  // Option → Either
  val opt1: Option[Int] = Some(42)
  val opt2: Option[Int] = None
  
  val either1 = opt1.toRight("値がありません")
  val either2 = opt2.toRight("値がありません")
  
  println(s"Some → Either: $either1")
  println(s"None → Either: $either2")
  
  // Either → Option
  val right: Either[String, Int] = Right(100)
  val left: Either[String, Int] = Left("エラー")
  
  println(s"Right → Option: ${right.toOption}")
  println(s"Left → Option: ${left.toOption}")
  
  // 実用例：設定ファイルの読み込み
  def loadConfig(key: String): Option[String] =
    Map(
      "host" -> "localhost",
      "port" -> "8080"
    ).get(key)
  
  def parsePort(portStr: String): Either[String, Int] =
    try Right(portStr.toInt)
    catch 
      case _: NumberFormatException => 
        Left(s"'$portStr'は有効なポート番号ではありません")
  
  def getPort(): Either[String, Int] =
    loadConfig("port")
      .toRight("ポート設定が見つかりません")
      .flatMap(parsePort)
  
  println(s"ポート取得: ${getPort()}")
}
```

## 実践例：フォーム検証

```scala
// FormValidation.scala
@main def formValidation(): Unit = {
  case class RegistrationForm(
    username: String,
    email: String,
    password: String,
    age: String
  )
  
  // 個別の検証関数
  def validateUsername(username: String): Either[String, String] = {
    if (username.length < 3) {
      Left("ユーザー名は3文字以上必要です")
    } else if (!username.matches("^[a-zA-Z0-9]+$")) {
      Left("ユーザー名は英数字のみ使用可能です")
    } else {
      Right(username)
    }
  }
  
  def validateEmail(email: String): Either[String, String] = {
    if (!email.contains("@")) {
      Left("有効なメールアドレスではありません")
    } else {
      Right(email)
    }
  }
  
  def validatePassword(password: String): Either[String, String] = {
    if (password.length < 8) {
      Left("パスワードは8文字以上必要です")
    } else if (!password.exists(_.isDigit)) {
      Left("パスワードには数字を含める必要があります")
    } else {
      Right(password)
    }
  }
  
  def validateAge(ageStr: String): Either[String, Int] = {
    try {
      val age = ageStr.toInt
      if (age < 13) Left("13歳以上である必要があります")
      else if (age > 120) Left("年齢が不正です")
      else Right(age)
    } catch {
      case _: NumberFormatException =>
        Left("年齢は数値で入力してください")
    }
  }
  
  // すべての検証を実行
  def validateForm(form: RegistrationForm): Either[List[String], String] =
    val validations = List(
      validateUsername(form.username),
      validateEmail(form.email),
      validatePassword(form.password),
      validateAge(form.age).map(_.toString)
    )
    
    val errors = validations.collect {
      case Left(error) => error
    }
    
    if (errors.isEmpty) {
      Right(s"登録成功: ${form.username}")
    } else {
      Left(errors)
    }
  
  // テストケース
  val forms = List(
    RegistrationForm("user123", "user@example.com", "pass1234", "25"),
    RegistrationForm("ab", "invalid-email", "short", "abc"),
    RegistrationForm("validuser", "valid@email.com", "weak", "10")
  )
  
  forms.zipWithIndex.foreach { case (form, index) =>
    println(s"\n=== フォーム${index + 1} ===")
    validateForm(form) match {
      case Right(message) => println(s"✓ $message")
      case Left(errors) =>
        println("✗ エラー:")
        errors.foreach(e => println(s"  - $e"))
    }
  }
}
```

## Try：例外を安全に扱う

```scala
// TryExample.scala
@main def tryExample(): Unit = {
  import scala.util.{Try, Success, Failure}
  
  // Tryは例外を値として扱う
  def parseNumber(str: String): Try[Int] =
    Try(str.toInt)
  
  println(parseNumber("123"))    // Success(123)
  println(parseNumber("abc"))    // Failure(...)
  
  // ファイル読み込み
  import scala.io.Source
  
  def readFile(filename: String): Try[String] =
    Try {
      val source = Source.fromFile(filename)
      try source.mkString
      finally source.close()
    }
  
  // Try → Either
  def loadConfigFile(filename: String): Either[String, String] =
    readFile(filename) match {
      case Success(content) => Right(content)
      case Failure(e) => Left(s"ファイル読み込みエラー: ${e.getMessage}")
    }
  
  println(loadConfigFile("config.txt"))
  
  // Tryのチェーン
  val calculation = for {
    a <- Try("10".toInt)
    b <- Try("20".toInt)
    c <- Try((a + b) / (a - 10))  // ゼロ除算の可能性
  } yield c
  
  calculation match {
    case Success(result) => println(s"計算結果: $result")
    case Failure(e) => println(s"計算エラー: ${e.getMessage}")
  }
}
```

## ベストプラクティス

```scala
// BestPractices.scala
@main def bestPractices(): Unit = {
  // 1. nullの代わりにOptionを使う
  case class Config(
    host: String,
    port: Int,
    timeout: Option[Int] = None  // nullではなくOption
  )
  
  val config = Config("localhost", 8080, Some(5000))
  val defaultTimeout = 3000
  val actualTimeout = config.timeout.getOrElse(defaultTimeout)
  println(s"タイムアウト: ${actualTimeout}ms")
  
  // 2. 例外の代わりにEitherを使う
  def findUser(id: Int): Either[String, String] =
    if (id == 1) Right("太郎")
    else Left(s"ユーザーID $id は存在しません")
  
  // 3. for式で複数の操作を組み合わせる
  def processUser(userId: Int): Either[String, String] =
    for {
      user <- findUser(userId)
      upper = user.toUpperCase  // 通常の処理も混ぜられる
      result <- Right(s"処理完了: $upper")
    } yield result
  
  println(processUser(1))
  println(processUser(99))
  
  // 4. エラーの詳細情報を保持
  sealed trait AppError
  case class ValidationError(field: String, message: String) extends AppError
  case class DatabaseError(cause: String) extends AppError
  case object NetworkError extends AppError
  
  def complexOperation(): Either[AppError, String] =
    Left(ValidationError("email", "無効な形式です"))
  
  complexOperation() match {
    case Right(result) => println(s"成功: $result")
    case Left(ValidationError(field, msg)) => println(s"検証エラー[$field]: $msg")
    case Left(DatabaseError(cause)) => println(s"DBエラー: $cause")
    case Left(NetworkError) => println("ネットワークエラー")
  }
}
```

## 練習してみよう！

### 練習1：安全な計算機

文字列を受け取って四則演算を行う計算機を作ってください。
- 数値変換の失敗
- ゼロ除算
- 不正な演算子
これらのエラーをEitherで適切に処理してください。

### 練習2：ユーザープロフィール

以下の情報を持つユーザープロフィールを作成する関数を作ってください：
- 必須：名前、メールアドレス
- 任意：電話番号、住所
OptionとEitherを適切に使ってください。

### 練習3：設定ファイルパーサー

キーと値のペアから設定を読み込む関数を作ってください。
- 必須項目が存在しない場合はエラー
- 数値項目が不正な場合はエラー
- オプション項目はデフォルト値を使用

## この章のまとめ

安全なプログラミングの方法を学びました！

### できるようになったこと

✅ **Option**
- 値の有無を表現
- 安全な値の取り出し
- map, flatMapでの操作

✅ **Either**
- 成功と失敗を表現
- エラー情報の保持
- 複数の検証の組み合わせ

✅ **実践的な使い方**
- nullの回避
- 例外の回避
- エラーハンドリング

✅ **ベストプラクティス**
- 適切な型の選択
- for式での組み合わせ
- エラーの詳細情報

### 使い分けのコツ

1. **Option**
    - 値があるかないか
    - エラーの詳細不要
    - シンプルな有無

2. **Either**
    - エラー情報が必要
    - 複数の失敗パターン
    - 処理の成功/失敗

3. **Try**
    - 既存の例外を扱う
    - 外部ライブラリとの連携
    - I/O操作

### 次の部では...

第V部では、非同期処理とエラーハンドリングについてさらに深く学んでいきます。FutureとTryを使った実践的なプログラミングを習得しましょう！

### 最後に

OptionとEitherは「プログラムの安全装置」です。車のシートベルトのように、問題が起きたときに私たちを守ってくれます。最初は面倒に感じるかもしれませんが、慣れれば「これなしでは不安」と感じるようになるでしょう。安全で堅牢なプログラムを作る習慣を身につけてください！