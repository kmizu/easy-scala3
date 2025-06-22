# 第36章 テストを書こう

## はじめに

新しい料理を作るとき、味見をしながら調整しますよね。塩加減は大丈夫？火の通りは？最後に全体の味のバランスは？プログラミングでも同じです。コードが正しく動くか、一つ一つ確認しながら作っていく。

それが「テスト」です。この章では、品質の高いコードを書くための、テストの書き方を学びましょう！

## テストの基本

### 最初のテスト

```scala
// FirstTest.scala
// src/test/scala/FirstTest.scalaに配置

import org.scalatest.funsuite.AnyFunSuite
import org.scalatest.matchers.should.Matchers

class FirstTest extends AnyFunSuite with Matchers {
  
  // 基本的なテスト
  test("1 + 1 は 2 になる") {
    val result = 1 + 1
    result shouldBe 2
  }
  
  test("文字列の連結") {
    val hello = "Hello"
    val world = "World"
    val result = s"$hello $world"
    
    result shouldBe "Hello World"
    result should include("Hello")
    result should include("World")
    result should have length 11
  }
  
  test("リストの操作") {
    val numbers = List(1, 2, 3, 4, 5)
    
    numbers should have size 5
    numbers should contain(3)
    numbers shouldNot contain(10)
    numbers.head shouldBe 1
    numbers.last shouldBe 5
  }
  
  // 例外のテスト
  test("ゼロ除算は例外を投げる") {
    def divide(a: Int, b: Int): Int = a / b
    
    an [ArithmeticException] should be thrownBy divide(10, 0)
  }
  
  // より詳細な検証
  test("Personクラスの動作") {
    case class Person(name: String, age: Int) {
      def isAdult: Boolean = age >= 18
      def greet: String = s"Hello, I'm $name"
    }
    
    val person = Person("太郎", 25)
    
    person.name shouldBe "太郎"
    person.age shouldBe 25
    person.isAdult shouldBe true
    person.greet should startWith("Hello")
    person.greet should endWith("太郎")
  }
```

### テストの構造とアサーション

```scala
// TestStructure.scala
import org.scalatest.funsuite.AnyFunSuite
import org.scalatest.matchers.should.Matchers
import org.scalatest.BeforeAndAfter

class TestStructure extends AnyFunSuite with Matchers with BeforeAndAfter {
  
  // テストの前後で実行される処理
  var testData: List[Int] = Nil
  
  before {
    println("テストの準備")
    testData = List(1, 2, 3, 4, 5)
  }
  
  after {
    println("テストの後片付け")
    testData = Nil
  }
  
  // Arrange-Act-Assert パターン
  test("リストのフィルタリング") {
    // Arrange（準備）
    val numbers = testData
    val threshold = 3
    
    // Act（実行）
    val result = numbers.filter(_ > threshold)
    
    // Assert（検証）
    result shouldBe List(4, 5)
    result should have size 2
    all(result) should be > threshold
  }
  
  // 複数の検証をグループ化
  test("統計情報の計算") {
    case class Stats(min: Int, max: Int, sum: Int, avg: Double)
    
    def calculateStats(numbers: List[Int]): Stats = {
      Stats(
        min = numbers.min,
        max = numbers.max,
        sum = numbers.sum,
        avg = numbers.sum.toDouble / numbers.size
      )
    }
    
    val stats = calculateStats(testData)
    
    // 個別の検証
    stats.min shouldBe 1
    stats.max shouldBe 5
    stats.sum shouldBe 15
    stats.avg shouldBe 3.0
    
    // まとめて検証
    stats should have(
      Symbol("min") (1),
      Symbol("max") (5),
      Symbol("sum") (15)
    )
  }
  
  // テーブル駆動テスト
  test("複数の入力でのテスト") {
    def isPrime(n: Int): Boolean = {
      if (n <= 1) { false }
      else if (n <= 3) { true }
      else { (2 to math.sqrt(n).toInt).forall(n % _ != 0) }
    }
    
    val testCases = Table(
      ("input", "expected"),
      (1, false),
      (2, true),
      (3, true),
      (4, false),
      (5, true),
      (10, false),
      (11, true)
    )
    
    forAll(testCases) { (input, expected) =>
      isPrime(input) shouldBe expected
    }
  }
```

## モックとスタブ

### 依存性のテスト

```scala
// MockingTest.scala
import org.scalatest.funsuite.AnyFunSuite
import org.scalatest.matchers.should.Matchers
import org.scalatestplus.mockito.MockitoSugar
import org.mockito.Mockito._
import org.mockito.ArgumentMatchers._

// テスト対象のコード
trait EmailService:
  def send(to: String, subject: String, body: String): Boolean

trait UserRepository:
  def findById(id: String): Option[User]
  def save(user: User): Unit

case class User(id: String, name: String, email: String)

class UserService(
  emailService: EmailService,
  userRepository: UserRepository
):
  def registerUser(name: String, email: String): Either[String, User] =
    val userId = java.util.UUID.randomUUID().toString
    val user = User(userId, name, email)
    
    try
      userRepository.save(user)
      
      val emailSent = emailService.send(
        email,
        "登録完了",
        s"$name 様、ご登録ありがとうございます！"
      )
      
      if (emailSent) { Right(user)
      else Left("メール送信に失敗しました")
      
    catch
      case e: Exception => Left(s"登録エラー: ${e.getMessage}")
  
  def getUser(id: String): Option[User] =
    userRepository.findById(id)

// テストクラス
class MockingTest extends AnyFunSuite with Matchers with MockitoSugar:
  
  test("ユーザー登録 - 成功ケース") {
    // モックの作成
    val mockEmailService = mock[EmailService]
    val mockUserRepository = mock[UserRepository]
    
    // モックの振る舞いを定義
    when(mockEmailService.send(any[String], any[String], any[String]))
      .thenReturn(true)
    
    // テスト実行
    val userService = new UserService(mockEmailService, mockUserRepository)
    val result = userService.registerUser("太郎", "taro@example.com")
    
    // 検証
    result should be a Symbol("right")
    result.map(_.name) shouldBe Right("太郎")
    result.map(_.email) shouldBe Right("taro@example.com")
    
    // モックが正しく呼ばれたか確認
    verify(mockUserRepository, times(1)).save(any[User])
    verify(mockEmailService, times(1)).send(
      "taro@example.com",
      "登録完了",
      "太郎 様、ご登録ありがとうございます！"
    )
  }
  
  test("ユーザー登録 - メール送信失敗") {
    val mockEmailService = mock[EmailService]
    val mockUserRepository = mock[UserRepository]
    
    // メール送信が失敗する設定
    when(mockEmailService.send(any[String], any[String], any[String]))
      .thenReturn(false)
    
    val userService = new UserService(mockEmailService, mockUserRepository)
    val result = userService.registerUser("花子", "hanako@example.com")
    
    result shouldBe Left("メール送信に失敗しました")
    
    // ユーザーは保存されているはず
    verify(mockUserRepository, times(1)).save(any[User])
  }
  
  test("ユーザー検索") {
    val mockEmailService = mock[EmailService]
    val mockUserRepository = mock[UserRepository]
    
    val testUser = User("123", "次郎", "jiro@example.com")
    
    // リポジトリの振る舞いを定義
    when(mockUserRepository.findById("123")).thenReturn(Some(testUser))
    when(mockUserRepository.findById("999")).thenReturn(None)
    
    val userService = new UserService(mockEmailService, mockUserRepository)
    
    // 存在するユーザー
    userService.getUser("123") shouldBe Some(testUser)
    
    // 存在しないユーザー
    userService.getUser("999") shouldBe None
    
    // メールサービスは呼ばれないはず
    verify(mockEmailService, never()).send(any[String], any[String], any[String])
  }
```

## 非同期処理のテスト

### Futureのテスト

```scala
// AsyncTest.scala
import org.scalatest.funsuite.AsyncFunSuite
import org.scalatest.matchers.should.Matchers
import scala.concurrent.Future
import scala.concurrent.duration._

class AsyncTest extends AsyncFunSuite with Matchers:
  
  // 非同期APIのシミュレーション
  def fetchUserAsync(id: String): Future[String] = Future {
    Thread.sleep(100)
    s"User-$id"
  }
  
  def fetchScoreAsync(userId: String): Future[Int] = Future {
    Thread.sleep(100)
    userId.length * 10
  }
  
  test("単一のFutureのテスト") {
    val future = fetchUserAsync("123")
    
    future.map { result =>
      result shouldBe "User-123"
    }
  }
  
  test("複数のFutureの組み合わせ") {
    val combinedFuture = for
      user <- fetchUserAsync("456")
      score <- fetchScoreAsync(user)
    yield (user, score)
    
    combinedFuture.map { case (user, score) =>
      user shouldBe "User-456"
      score shouldBe 80
    }
  }
  
  test("エラーケースのテスト") {
    def riskyOperation(n: Int): Future[Int] = Future {
      if (n < 0) { throw new IllegalArgumentException("負の数は不可")
      n * 2
    }
    
    // 成功ケース
    riskyOperation(5).map { result =>
      result shouldBe 10
    }
    
    // 失敗ケース
    recoverToSucceededIf[IllegalArgumentException] {
      riskyOperation(-5)
    }
  }
  
  test("タイムアウトのテスト") {
    def slowOperation(): Future[String] = Future {
      Thread.sleep(5000)
      "完了"
    }
    
    // ScalaTestのタイムアウト機能
    assertThrows[org.scalatest.concurrent.TimeoutField] {
      failAfter(1.second) {
        slowOperation()
      }
    }
  }
```

## プロパティベーステスト

### ScalaCheckを使ったテスト

```scala
// PropertyBasedTest.scala
import org.scalatest.funsuite.AnyFunSuite
import org.scalatest.matchers.should.Matchers
import org.scalatestplus.scalacheck.ScalaCheckPropertyChecks
import org.scalacheck.Gen
import org.scalacheck.Prop.forAll

class PropertyBasedTest extends AnyFunSuite 
  with Matchers 
  with ScalaCheckPropertyChecks:
  
  // リストの逆順の性質
  test("リストを2回逆順にすると元に戻る") {
    forAll { (list: List[Int]) =>
      list.reverse.reverse shouldBe list
    }
  }
  
  // ソートの性質
  test("ソート済みリストの性質") {
    forAll { (list: List[Int]) =>
      val sorted = list.sorted
      
      // 性質1：サイズは変わらない
      sorted.size shouldBe list.size
      
      // 性質2：すべての要素が含まれる
      sorted.toSet shouldBe list.toSet
      
      // 性質3：隣接する要素は順序が正しい
      sorted.sliding(2).foreach {
        case List(a, b) => a should be <= b
        case _ => // 単一要素の場合はスキップ
      }
    }
  }
  
  // カスタムジェネレータ
  test("ユーザー登録の検証") {
    case class User(name: String, age: Int, email: String)
    
    // ユーザー用のジェネレータ
    val userGen: Gen[User] = for
      name <- Gen.alphaStr.suchThat(_.nonEmpty)
      age <- Gen.choose(0, 120)
      domain <- Gen.oneOf("gmail.com", "yahoo.com", "example.com")
      email = s"$name@$domain"
    yield User(name, age, email)
    
    forAll(userGen) { user =>
      user.name should not be empty
      user.age should be >= 0
      user.age should be <= 120
      user.email should include("@")
      user.email should endWith(".com")
    }
  }
  
  // 関数の性質テスト
  test("文字列処理関数の性質") {
    def sanitize(input: String): String =
      input.trim.toLowerCase.replaceAll("[^a-z0-9]", "")
    
    forAll { (s: String) =>
      val result = sanitize(s)
      
      // 性質1：結果は小文字のみ
      result shouldBe result.toLowerCase
      
      // 性質2：空白なし
      result should not include " "
      
      // 性質3：冪等性（2回適用しても同じ）
      sanitize(result) shouldBe result
    }
  }
  
  // 境界値のテスト
  test("除算関数の境界値") {
    def safeDivide(a: Double, b: Double): Option[Double] =
      if (b == 0) { None else Some(a / b)
    
    val edgeCases = Table(
      ("a", "b", "expected"),
      (10.0, 2.0, Some(5.0)),
      (0.0, 5.0, Some(0.0)),
      (10.0, 0.0, None),
      (Double.MaxValue, 1.0, Some(Double.MaxValue)),
      (1.0, Double.MinValue, Some(1.0 / Double.MinValue))
    )
    
    forAll(edgeCases) { (a, b, expected) =>
      safeDivide(a, b) shouldBe expected
    }
  }
```

## 統合テスト

### データベースを含むテスト

```scala
// IntegrationTest.scala
import org.scalatest.funsuite.AnyFunSuite
import org.scalatest.matchers.should.Matchers
import org.scalatest.BeforeAndAfterAll
import org.scalatest.BeforeAndAfterEach

// 仮想的なデータベース接続
trait Database {
  def connect(): Unit
  def disconnect(): Unit
  def execute(sql: String): Unit
  def query[T](sql: String): List[T]
}

// リポジトリ実装
class UserRepositoryImpl(db: Database) extends UserRepository {
  def findById(id: String): Option[User] = {
    db.query[User](s"SELECT * FROM users WHERE id = '$id'").headOption
  }
  
  def save(user: User): Unit = {
    db.execute(
      s"INSERT INTO users (id, name, email) VALUES ('${user.id}', '${user.name}', '${user.email}')"
    )
  }
}

class IntegrationTest extends AnyFunSuite 
  with Matchers 
  with BeforeAndAfterAll
  with BeforeAndAfterEach {
  
  // テスト用のインメモリデータベース
  class InMemoryDatabase extends Database {
    private var users: List[User] = List.empty
    private var connected = false
    
    def connect(): Unit = connected = true
    def disconnect(): Unit = connected = false
    
    def execute(sql: String): Unit = {
      if (sql.startsWith("INSERT INTO users")) {
        // 簡易的なパース（実際はもっと適切に）
        val pattern = """VALUES \('([^']+)', '([^']+)', '([^']+)'\)""".r
        sql match {
          case pattern(id, name, email) =>
            users = users :+ User(id, name, email)
          case _ =>
            throw new Exception("Invalid SQL")
        }
      }
    }
    
    def query[T](sql: String): List[T] = {
      if (sql.contains("WHERE id =")) {
        val idPattern = """WHERE id = '([^']+)'""".r
        sql match {
          case idPattern(id) =>
            users.filter(_.id == id).asInstanceOf[List[T]]
          case _ => List.empty
        }
      } else {
        users.asInstanceOf[List[T]]
      }
    }
    
    def clearData(): Unit = users = List.empty
  }
  
  var database: InMemoryDatabase = _
  var repository: UserRepository = _
  
  override def beforeAll(): Unit =
    database = new InMemoryDatabase
    database.connect()
  
  override def afterAll(): Unit =
    database.disconnect()
  
  override def beforeEach(): Unit =
    database.clearData()
    repository = new UserRepositoryImpl(database)
  
  test("ユーザーの保存と取得") {
    // Given
    val user = User("123", "太郎", "taro@example.com")
    
    // When
    repository.save(user)
    val retrieved = repository.findById("123")
    
    // Then
    retrieved shouldBe Some(user)
  }
  
  test("存在しないユーザーの検索") {
    // When
    val result = repository.findById("999")
    
    // Then
    result shouldBe None
  }
  
  test("複数ユーザーの管理") {
    // Given
    val users = List(
      User("1", "太郎", "taro@example.com"),
      User("2", "花子", "hanako@example.com"),
      User("3", "次郎", "jiro@example.com")
    )
    
    // When
    users.foreach(repository.save)
    
    // Then
    repository.findById("1") shouldBe Some(users(0))
    repository.findById("2") shouldBe Some(users(1))
    repository.findById("3") shouldBe Some(users(2))
  }
```

## テスト駆動開発（TDD）

### TDDの実践例

```scala
// TDDExample.scala
import org.scalatest.funsuite.AnyFunSuite
import org.scalatest.matchers.should.Matchers

// ステップ1：失敗するテストを書く
class ShoppingCartTest extends AnyFunSuite with Matchers {
  
  test("空のカートの合計は0") {
    val cart = new ShoppingCart
    cart.total shouldBe 0.0
  }
  
  test("商品を追加できる") {
    val cart = new ShoppingCart
    cart.addItem("リンゴ", 100.0, 2)
    
    cart.itemCount shouldBe 1
    cart.total shouldBe 200.0
  }
  
  test("同じ商品を追加すると数量が増える") {
    val cart = new ShoppingCart
    cart.addItem("リンゴ", 100.0, 2)
    cart.addItem("リンゴ", 100.0, 3)
    
    cart.itemCount shouldBe 1
    cart.getQuantity("リンゴ") shouldBe 5
    cart.total shouldBe 500.0
  }
  
  test("商品を削除できる") {
    val cart = new ShoppingCart
    cart.addItem("リンゴ", 100.0, 2)
    cart.addItem("バナナ", 80.0, 3)
    
    cart.removeItem("リンゴ")
    
    cart.itemCount shouldBe 1
    cart.total shouldBe 240.0
  }
  
  test("割引を適用できる") {
    val cart = new ShoppingCart
    cart.addItem("リンゴ", 100.0, 5)
    cart.applyDiscount(0.1) // 10%割引
    
    cart.total shouldBe 450.0
  }
  
  test("クーポンコードを適用できる") {
    val cart = new ShoppingCart
    cart.addItem("リンゴ", 100.0, 3)
    
    cart.applyCoupon("SAVE50") shouldBe true
    cart.total shouldBe 250.0
    
    cart.applyCoupon("INVALID") shouldBe false
  }

// ステップ2：テストを通すための実装
case class CartItem(name: String, price: Double, quantity: Int)

class ShoppingCart {
  private var items = Map[String, CartItem]()
  private var discountRate = 0.0
  private var couponDiscount = 0.0
  
  private val validCoupons = Map(
    "SAVE50" -> 50.0,
    "SAVE100" -> 100.0
  )
  
  def addItem(name: String, price: Double, quantity: Int): Unit = {
    items.get(name) match {
      case Some(existing) =>
        items = items.updated(
          name, 
          existing.copy(quantity = existing.quantity + quantity)
        )
      case None =>
        items = items + (name -> CartItem(name, price, quantity))
    }
  }
  
  def removeItem(name: String): Unit = {
    items = items - name
  }
  
  def getQuantity(name: String): Int = {
    items.get(name).map(_.quantity).getOrElse(0)
  }
  
  def itemCount: Int = items.size
  
  def applyDiscount(rate: Double): Unit = {
    discountRate = rate
  }
  
  def applyCoupon(code: String): Boolean = {
    validCoupons.get(code) match {
      case Some(discount) =>
        couponDiscount = discount
        true
      case None =>
        false
    }
  }
  
  def total: Double = {
    val subtotal = items.values.map(item => item.price * item.quantity).sum
    val afterDiscount = subtotal * (1 - discountRate)
    math.max(0, afterDiscount - couponDiscount)
  }
}

// ステップ3：リファクタリング（より良い設計に）
class ImprovedShoppingCart:
  import scala.collection.immutable.Map
  
  private case class State(
    items: Map[String, CartItem] = Map.empty,
    discountRate: Double = 0.0,
    couponDiscount: Double = 0.0
  )
  
  private var state = State()
  
  // イミュータブルな操作
  def addItem(name: String, price: Double, quantity: Int): ImprovedShoppingCart =
    val newItems = state.items.get(name) match {
      case Some(existing) =>
        state.items.updated(name, existing.copy(quantity = existing.quantity + quantity))
      case None =>
        state.items + (name -> CartItem(name, price, quantity))
    
    state = state.copy(items = newItems)
    this
  
  // 他のメソッドも同様にリファクタリング...
```

## 実践例：E2Eテスト

```scala
// E2ETest.scala
import org.scalatest.funsuite.AnyFunSuite
import org.scalatest.matchers.should.Matchers
import org.scalatest.BeforeAndAfterAll

// Webアプリケーションのシミュレーション
class WebApp {
  private var users = Map[String, User]()
  private var sessions = Map[String, String]() // sessionId -> userId
  
  def register(name: String, email: String, password: String): Either[String, String] = {
    if (users.values.exists(_.email == email)) {
      Left("メールアドレスは既に使用されています")
    } else {
      val userId = java.util.UUID.randomUUID().toString
      users = users + (userId -> User(userId, name, email))
      Right(userId)
    }
  }
  
  def login(email: String, password: String): Either[String, String] = {
    users.values.find(_.email == email) match {
      case Some(user) =>
        val sessionId = java.util.UUID.randomUUID().toString
        sessions = sessions + (sessionId -> user.id)
        Right(sessionId)
      case None =>
        Left("メールアドレスまたはパスワードが正しくありません")
    }
  }
  
  def getProfile(sessionId: String): Either[String, User] = {
    sessions.get(sessionId).flatMap(users.get) match {
      case Some(user) => Right(user)
      case None => Left("ログインが必要です")
    }
  }
  
  def logout(sessionId: String): Unit = {
    sessions = sessions - sessionId
  }
}

class E2ETest extends AnyFunSuite with Matchers with BeforeAndAfterAll {
  
  var app: WebApp = _
  
  override def beforeAll(): Unit = {
    app = new WebApp
  }
  
  test("ユーザー登録からログアウトまでの一連の流れ") {
    // 1. ユーザー登録
    val registerResult = app.register("太郎", "taro@example.com", "password123")
    registerResult should be a Symbol("right")
    
    // 2. ログイン
    val loginResult = app.login("taro@example.com", "password123")
    loginResult should be a Symbol("right")
    
    val sessionId = loginResult.getOrElse("")
    
    // 3. プロフィール取得
    val profileResult = app.getProfile(sessionId)
    profileResult should be a Symbol("right")
    
    profileResult.map { user =>
      user.name shouldBe "太郎"
      user.email shouldBe "taro@example.com"
    }
    
    // 4. ログアウト
    app.logout(sessionId)
    
    // 5. ログアウト後はプロフィールにアクセスできない
    val afterLogout = app.getProfile(sessionId)
    afterLogout shouldBe Left("ログインが必要です")
  }
  
  test("重複登録の防止") {
    // 最初の登録
    app.register("花子", "hanako@example.com", "pass1")
    
    // 同じメールアドレスで再登録
    val duplicate = app.register("花子2", "hanako@example.com", "pass2")
    duplicate shouldBe Left("メールアドレスは既に使用されています")
  }
  
  test("無効なログイン") {
    val result = app.login("unknown@example.com", "wrongpass")
    result shouldBe Left("メールアドレスまたはパスワードが正しくありません")
  }
  
  test("複数ユーザーの並行セッション") {
    // ユーザー1
    app.register("User1", "user1@example.com", "pass1")
    val session1 = app.login("user1@example.com", "pass1").getOrElse("")
    
    // ユーザー2
    app.register("User2", "user2@example.com", "pass2")
    val session2 = app.login("user2@example.com", "pass2").getOrElse("")
    
    // それぞれ正しいプロフィールが取得できる
    app.getProfile(session1).map(_.name) shouldBe Right("User1")
    app.getProfile(session2).map(_.name) shouldBe Right("User2")
  }
```

## 練習してみよう！

### 練習1：電卓のテスト

四則演算ができる電卓クラスのテストを書いてください：
- 基本的な計算
- エラーケース（ゼロ除算など）
- 連続計算

### 練習2：TODOリストのテスト

TODOリスト管理システムのテストを書いてください：
- タスクの追加・削除
- 完了状態の管理
- フィルタリング機能

### 練習3：APIクライアントのテスト

外部APIを呼び出すクライアントのテストを書いてください：
- 成功レスポンス
- エラーハンドリング
- タイムアウト処理

## この章のまとめ

テストの重要性と書き方を学びました！

### できるようになったこと

✅ **テストの基本**
- テストの構造
- アサーション
- セットアップとティアダウン

✅ **テスト技法**
- モックとスタブ
- 非同期テスト
- プロパティベーステスト

✅ **テスト戦略**
- 単体テスト
- 統合テスト
- E2Eテスト

✅ **TDD**
- Red-Green-Refactor
- テストファースト
- 継続的な改善

### テストを書くコツ

1. **分かりやすく書く**
    - 明確なテスト名
    - AAA パターン
    - 1テスト1検証

2. **網羅的に書く**
    - 正常ケース
    - 異常ケース
    - 境界値

3. **保守しやすく書く**
    - DRYの原則
    - テストの独立性
    - 適切な粒度

### 次の章では...

ビルドツールと依存性管理について学びます。プロジェクトの構築と管理の方法を習得しましょう！

### 最後に

テストは「品質の番人」です。料理人が味見をするように、プログラマーはテストでコードの動作を確認する。良いテストは、バグを早期に発見し、リファクタリングを安全にし、ドキュメントの役割も果たします。テストを書く習慣は、プロのプログラマーへの第一歩です！