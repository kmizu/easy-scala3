# 第28章 暗黙の引数とは

## はじめに

レストランで「いつもの」と言えば、お気に入りの料理が出てきますよね。毎回「カツ丼の大盛りで、味噌汁は豆腐で」と言わなくても、店員さんが覚えていてくれます。

Scalaの暗黙の引数（implicit parameters）も同じです。よく使う値を「いつもの」として登録しておけば、毎回書かなくても自動的に使ってくれるんです！

## 暗黙の引数って何だろう？

### 基本的な使い方

```scala
// ImplicitParametersBasics.scala
@main def implicitParametersBasics(): Unit = {
  // 通常の引数（毎回指定が必要）
  def greet(name: String, greeting: String): String =
    s"$greeting, $name!"
  
  println(greet("太郎", "こんにちは"))
  println(greet("花子", "こんにちは"))  // 毎回「こんにちは」を書くのは面倒...
  
  // 暗黙の引数を使った改良版
  def greetImplicit(name: String)(implicit greeting: String): String =
    s"$greeting, $name!"
  
  // 暗黙の値を定義
  implicit val defaultGreeting: String = "こんにちは"
  
  // 暗黙の引数は省略できる！
  println(greetImplicit("太郎"))  // "こんにちは"が自動的に使われる
  println(greetImplicit("花子"))
  
  // 明示的に指定することも可能
  println(greetImplicit("ジョン")("Hello"))
  
  // スコープを変えて別の暗黙の値を定義
  def englishContext(): Unit =
    implicit val englishGreeting: String = "Hello"
    println(greetImplicit("太郎"))  // このスコープでは"Hello"が使われる
  
  englishContext()
```

### コンテキストの提供

```scala
// ContextProviding.scala
@main def contextProviding(): Unit = {
  // 実行コンテキスト
  case class ExecutionContext(
    userId: String,
    requestId: String,
    timestamp: Long
  )
  
  // ログ出力（コンテキストが必要）
  def log(message: String)(implicit ctx: ExecutionContext): Unit =
    println(f"[${ctx.timestamp}%tT] [${ctx.requestId}] [${ctx.userId}] $message")
  
  // データベース操作（コンテキストが必要）
  def saveUser(name: String, email: String)(implicit ctx: ExecutionContext): Unit =
    log(s"ユーザー保存開始: $name")
    // 実際の保存処理...
    log(s"ユーザー保存完了: $name ($email)")
  
  def updateEmail(userId: String, newEmail: String)(implicit ctx: ExecutionContext): Unit =
    log(s"メール更新開始: $userId → $newEmail")
    // 実際の更新処理...
    log(s"メール更新完了")
  
  // サービスクラス
  class UserService:
    def registerUser(name: String, email: String)(implicit ctx: ExecutionContext): Unit =
      saveUser(name, email)  // ctxは自動的に渡される
      updateEmail(ctx.userId, email)
      log("登録処理完了")
  
  // 使用例
  implicit val context = ExecutionContext(
    userId = "user123",
    requestId = "req-456",
    timestamp = System.currentTimeMillis()
  )
  
  val service = new UserService
  service.registerUser("田中太郎", "tanaka@example.com")
  
  // 別のコンテキストで実行
  def anotherUserContext(): Unit =
    implicit val ctx = ExecutionContext(
      userId = "admin",
      requestId = "req-789",
      timestamp = System.currentTimeMillis()
    )
    service.registerUser("管理者", "admin@example.com")
  
  Thread.sleep(100)
  anotherUserContext()
```

## 実践的な暗黙の引数

### 設定の注入

```scala
// ConfigurationInjection.scala
@main def configurationInjection(): Unit = {
  // アプリケーション設定
  case class AppConfig(
    apiUrl: String,
    timeout: Int,
    retryCount: Int,
    debugMode: Boolean
  )
  
  // APIクライアント
  class ApiClient:
    def get(path: String)(implicit config: AppConfig): String = {
      if (config.debugMode) {
        println(s"[DEBUG] GET ${config.apiUrl}$path")
      }
      s"Response from ${config.apiUrl}$path"
    }
    
    def post(path: String, data: String)(implicit config: AppConfig): String = {
      if (config.debugMode) {
        println(s"[DEBUG] POST ${config.apiUrl}$path with $data")
      }
      s"Posted to ${config.apiUrl}$path"
    }
  
  // サービスクラス
  class UserApiService(client: ApiClient):
    def getUser(id: String)(implicit config: AppConfig): String =
      client.get(s"/users/$id")
    
    def createUser(name: String)(implicit config: AppConfig): String =
      client.post("/users", s"""{"name": "$name"}""")
  
  // 本番環境の設定
  implicit val productionConfig = AppConfig(
    apiUrl = "https://api.example.com",
    timeout = 5000,
    retryCount = 3,
    debugMode = false
  )
  
  val client = new ApiClient
  val userService = new UserApiService(client)
  
  println("=== 本番環境 ===")
  println(userService.getUser("123"))
  println(userService.createUser("新規ユーザー"))
  
  // 開発環境の設定
  def developmentEnvironment(): Unit =
    implicit val devConfig = AppConfig(
      apiUrl = "http://localhost:8080",
      timeout = 30000,
      retryCount = 0,
      debugMode = true
    )
    
    println("\n=== 開発環境 ===")
    println(userService.getUser("456"))
    println(userService.createUser("テストユーザー"))
  
  developmentEnvironment()
```

### 型変換の自動化

```scala
// ImplicitConversions.scala
@main def implicitConversions(): Unit = {
  // JSONライクなデータ構造
  sealed trait JsonValue
  case class JsonString(value: String) extends JsonValue
  case class JsonNumber(value: Double) extends JsonValue
  case class JsonBoolean(value: Boolean) extends JsonValue
  case class JsonArray(values: List[JsonValue]) extends JsonValue
  case class JsonObject(fields: Map[String, JsonValue]) extends JsonValue
  case object JsonNull extends JsonValue
  
  // JSON変換用の型クラス
  trait JsonEncoder[A]:
    def encode(value: A): JsonValue
  
  object JsonEncoder:
    // 基本型のエンコーダー（暗黙の値として定義）
    implicit val stringEncoder: JsonEncoder[String] = new JsonEncoder[String]:
      def encode(value: String): JsonValue = JsonString(value)
    
    implicit val intEncoder: JsonEncoder[Int] = new JsonEncoder[Int]:
      def encode(value: Int): JsonValue = JsonNumber(value.toDouble)
    
    implicit val doubleEncoder: JsonEncoder[Double] = new JsonEncoder[Double]:
      def encode(value: Double): JsonValue = JsonNumber(value)
    
    implicit val booleanEncoder: JsonEncoder[Boolean] = new JsonEncoder[Boolean]:
      def encode(value: Boolean): JsonValue = JsonBoolean(value)
    
    // リストのエンコーダー
    implicit def listEncoder[A](implicit encoder: JsonEncoder[A]): JsonEncoder[List[A]] =
      new JsonEncoder[List[A]]:
        def encode(values: List[A]): JsonValue =
          JsonArray(values.map(encoder.encode))
    
    // オプションのエンコーダー
    implicit def optionEncoder[A](implicit encoder: JsonEncoder[A]): JsonEncoder[Option[A]] =
      new JsonEncoder[Option[A]]:
        def encode(value: Option[A]): JsonValue = value match {
          case Some(v) => encoder.encode(v)
          case None => JsonNull
        }
  
  // JSONに変換する関数
  def toJson[A](value: A)(implicit encoder: JsonEncoder[A]): JsonValue =
    encoder.encode(value)
  
  // 使用例
  println("=== 基本型の変換 ===")
  println(toJson("Hello"))
  println(toJson(42))
  println(toJson(3.14))
  println(toJson(true))
  
  println("\n=== コレクションの変換 ===")
  println(toJson(List(1, 2, 3)))
  println(toJson(List("A", "B", "C")))
  
  println("\n=== オプションの変換 ===")
  println(toJson(Some("値あり")))
  println(toJson(None: Option[String]))
  
  // カスタム型のエンコーダー
  case class User(name: String, age: Int, email: Option[String])
  
  implicit val userEncoder: JsonEncoder[User] = new JsonEncoder[User]:
    def encode(user: User): JsonValue = JsonObject(Map(
      "name" -> toJson(user.name),
      "age" -> toJson(user.age),
      "email" -> toJson(user.email)
    ))
  
  val user = User("太郎", 25, Some("taro@example.com"))
  println(s"\n=== カスタム型の変換 ===")
  println(toJson(user))
```

## 暗黙の優先順位

```scala
// ImplicitPriority.scala
@main def implicitPriority(): Unit = {
  trait Printer[A]:
    def print(value: A): String
  
  // 低優先度の暗黙の値（トレイト内）
  trait LowPriorityImplicits:
    implicit def defaultPrinter[A]: Printer[A] = new Printer[A]:
      def print(value: A): String = s"デフォルト: $value"
  
  // 通常優先度の暗黙の値（オブジェクト内）
  object Printer extends LowPriorityImplicits:
    implicit val stringPrinter: Printer[String] = new Printer[String]:
      def print(value: String): String = s"文字列: '$value'"
    
    implicit val intPrinter: Printer[Int] = new Printer[Int]:
      def print(value: Int): String = s"整数: $value"
  
  import Printer._
  
  def prettyPrint[A](value: A)(implicit printer: Printer[A]): String =
    printer.print(value)
  
  // 特定の型には専用のプリンターが使われる
  println(prettyPrint("Hello"))      // 文字列プリンター
  println(prettyPrint(42))           // 整数プリンター
  println(prettyPrint(3.14))         // デフォルトプリンター
  
  // ローカルスコープの暗黙の値が最優先
  implicit val customIntPrinter: Printer[Int] = new Printer[Int]:
    def print(value: Int): String = s"カスタム整数: [$value]"
  
  println(prettyPrint(100))          // カスタムプリンター
  
  // 暗黙の値の探索順序
  println("\n=== 暗黙の値の探索順序 ===")
  println("1. ローカルスコープ")
  println("2. インポートされた暗黙の値")
  println("3. コンパニオンオブジェクト")
  println("4. 継承された暗黙の値")
  println("5. パッケージオブジェクト")
```

## 実践例：依存性注入

```scala
// DependencyInjection.scala
@main def dependencyInjection(): Unit = {
  // サービスのインターフェース
  trait UserRepository:
    def findById(id: String): Option[String]
    def save(id: String, name: String): Unit
  
  trait EmailService:
    def send(to: String, subject: String, body: String): Unit
  
  trait Logger:
    def info(message: String): Unit
    def error(message: String): Unit
  
  // 実装
  class InMemoryUserRepository extends UserRepository:
    private var users = Map[String, String]()
    
    def findById(id: String): Option[String] = users.get(id)
    def save(id: String, name: String): Unit = users += (id -> name)
  
  class ConsoleEmailService extends EmailService:
    def send(to: String, subject: String, body: String): Unit =
      println(s"📧 To: $to\n   Subject: $subject\n   Body: $body")
  
  class ConsoleLogger extends Logger:
    def info(message: String): Unit = println(s"[INFO] $message")
    def error(message: String): Unit = println(s"[ERROR] $message")
  
  // ビジネスロジック（依存性は暗黙の引数）
  class UserService:
    def registerUser(id: String, name: String, email: String)
                    (implicit repo: UserRepository, 
                     emailService: EmailService,
                     logger: Logger): Unit =
      logger.info(s"ユーザー登録開始: $id")
      
      repo.findById(id) match {
        case Some(_) =>
          logger.error(s"ユーザーID $id は既に存在します")
        case None =>
          repo.save(id, name)
          emailService.send(
            email,
            "登録完了のお知らせ",
            s"$name 様、ご登録ありがとうございます！"
          )
          logger.info(s"ユーザー登録完了: $id")
      }
    
    def getUser(id: String)(implicit repo: UserRepository, logger: Logger): Option[String] =
      logger.info(s"ユーザー検索: $id")
      repo.findById(id)
  
  // 依存性の注入
  implicit val userRepo: UserRepository = new InMemoryUserRepository
  implicit val emailService: EmailService = new ConsoleEmailService
  implicit val logger: Logger = new ConsoleLogger
  
  // 使用（依存性は自動的に注入される）
  val userService = new UserService
  
  println("=== ユーザー登録 ===")
  userService.registerUser("001", "田中太郎", "tanaka@example.com")
  
  println("\n=== ユーザー検索 ===")
  userService.getUser("001") match {
    case Some(name) => println(s"見つかりました: $name")
    case None => println("見つかりません")
  }
  
  // テスト環境では別の実装を注入
  def testEnvironment(): Unit =
    implicit val testLogger: Logger = new Logger:
      def info(message: String): Unit = ()  // ログを出力しない
      def error(message: String): Unit = println(s"[TEST ERROR] $message")
    
    println("\n=== テスト環境 ===")
    userService.registerUser("001", "重複テスト", "test@example.com")
```

## 暗黙の引数のベストプラクティス

```scala
// ImplicitBestPractices.scala
@main def implicitBestPractices(): Unit = {
  // 1. 明確な型名を使う
  case class DatabaseConnection(url: String)
  case class SecurityContext(userId: String, permissions: Set[String])
  
  // 良い例：型から用途が明確
  def executeQuery(query: String)(implicit db: DatabaseConnection): String =
    s"Executing on ${db.url}: $query"
  
  // 2. 暗黙の引数は最後の引数リストに
  def processData[A](data: List[A])(f: A => String)
                    (implicit ctx: SecurityContext): List[String] =
    if (ctx.permissions.contains("READ")) {
      data.map(f)
    } else {
      List("アクセス拒否")
    }
  
  // 3. デフォルト値を提供する
  object SecurityContext:
    implicit val defaultContext: SecurityContext = 
      SecurityContext("anonymous", Set("READ"))
  
  // 4. スコープを適切に管理
  class SecureService:
    def adminOperation()(implicit ctx: SecurityContext): String =
      if ctx.permissions.contains("ADMIN") then
        "管理者操作を実行"
      else
        "権限がありません"
  
  // 使用例
  implicit val db = DatabaseConnection("jdbc:postgresql://localhost/mydb")
  
  println("=== デフォルトコンテキスト ===")
  import SecurityContext.defaultContext
  println(executeQuery("SELECT * FROM users"))
  println(processData(List(1, 2, 3))(_.toString))
  
  val service = new SecureService
  println(service.adminOperation())
  
  // 管理者コンテキスト
  def adminContext(): Unit =
    implicit val adminCtx = SecurityContext("admin", Set("READ", "WRITE", "ADMIN"))
    println("\n=== 管理者コンテキスト ===")
    println(service.adminOperation())
  
  adminContext()
  
  // 5. 暗黙の引数の確認
  def checkImplicits(): Unit =
    val query = "SELECT * FROM products"
    
    // 明示的に暗黙の値を確認
    println("\n=== 暗黙の値の確認 ===")
    println(s"使用中のDB: ${implicitly[DatabaseConnection]}")
    println(s"使用中のセキュリティ: ${implicitly[SecurityContext]}")
    
    // implicitlyは暗黙の値を明示的に取得する
    val currentDb = implicitly[DatabaseConnection]
    println(s"URL: ${currentDb.url}")
  
  checkImplicits()
```

## 練習してみよう！

### 練習1：ロギングシステム

暗黙の引数を使ったロギングシステムを作ってください：
- ログレベル（DEBUG, INFO, WARN, ERROR）
- ログ出力先（コンソール、ファイル）
- タイムスタンプとコンテキスト情報

### 練習2：単位変換

暗黙の引数で単位変換を実装してください：
- 長さ（m, km, mile）
- 重さ（g, kg, pound）
- 温度（℃, ℉, K）

### 練習3：認証システム

暗黙の引数を使った認証システムを作ってください：
- ユーザー情報
- 権限チェック
- 操作の記録

## この章のまとめ

暗黙の引数の便利さを学びました！

### できるようになったこと

✅ **暗黙の引数の基本**
- implicit キーワード
- 自動的な値の解決
- 明示的な指定も可能

✅ **実践的な使い方**
- コンテキストの伝播
- 設定の注入
- 依存性注入

✅ **優先順位の理解**
- スコープのルール
- 探索順序
- 競合の解決

✅ **ベストプラクティス**
- 明確な型名
- 適切なスコープ管理
- デフォルト値の提供

### 暗黙の引数を使うコツ

1. **明確さを保つ**
    - 何が暗黙的か分かりやすく
    - 型から用途が推測できる
    - 必要に応じて明示的に

2. **スコープ管理**
    - 影響範囲を限定
    - インポートの活用
    - 競合を避ける

3. **デバッグしやすく**
    - implicitlyで確認
    - 明示的な指定でテスト
    - エラーメッセージを理解

### 次の章では...

型クラスパターンについて学びます。暗黙の引数を使った、より高度な抽象化の技法を習得しましょう！

### 最後に

暗黙の引数は「文脈を理解する賢い助手」のようなものです。いちいち説明しなくても、状況に応じて適切な値を選んでくれる。この便利さを活かせば、より簡潔で、それでいて柔軟なコードが書けるようになります。ただし、使いすぎには注意。明示的であることも、時には大切です！