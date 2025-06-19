# 第23章 シールドトレイトで網羅的に

## はじめに

信号機の色は「赤」「黄」「青」の3つだけですよね。「紫」や「オレンジ」の信号機はありません。プログラミングでも、「これとこれとこれだけ」という限定されたパターンを表現したいことがよくあります。

シールドトレイト（sealed trait）を使えば、すべての可能性を漏れなく、重複なく表現できます。まるで、完璧なチェックリストのように！

## シールドトレイトって何だろう？

### 基本的な使い方

```scala
// SealedTraitBasics.scala
@main def sealedTraitBasics(): Unit =
  // 信号機の色（これだけ！）
  sealed trait TrafficLight
  case object Red extends TrafficLight
  case object Yellow extends TrafficLight  
  case object Green extends TrafficLight
  
  // 信号の意味を返す関数
  def meaning(light: TrafficLight): String = light match
    case Red => "止まれ"
    case Yellow => "注意"
    case Green => "進め"
    // すべてのケースを網羅しているので、デフォルトケースは不要！
  
  val currentLight: TrafficLight = Red
  println(s"${currentLight}: ${meaning(currentLight)}")
  
  // もし1つでもケースを忘れると...
  def nextLight(light: TrafficLight): TrafficLight = light match
    case Red => Green
    case Green => Yellow
    // case Yellow => Red  // コメントアウトすると警告！
  
  // コンパイラが「Yellowのケースがないよ」と教えてくれる
```

### sealed vs 通常のtrait

```scala
// SealedVsNormal.scala
@main def sealedVsNormal(): Unit =
  // 通常のtrait（どこでも継承できる）
  trait Animal
  case class Dog(name: String) extends Animal
  case class Cat(name: String) extends Animal
  // 他のファイルでも継承できてしまう...
  
  // sealed trait（同じファイル内でのみ継承可能）
  sealed trait PaymentMethod
  case class CreditCard(number: String, cvv: String) extends PaymentMethod
  case class BankTransfer(accountNumber: String) extends PaymentMethod
  case object Cash extends PaymentMethod
  // これ以外の支払い方法は存在しない！
  
  def processPayment(method: PaymentMethod): String = method match
    case CreditCard(number, _) => s"カード決済: ****${number.takeRight(4)}"
    case BankTransfer(account) => s"銀行振込: $account"
    case Cash => "現金決済"
    // すべてのケースを網羅！
  
  val payment1 = CreditCard("1234567890123456", "123")
  val payment2 = Cash
  
  println(processPayment(payment1))
  println(processPayment(payment2))
```

## 実践的な例：注文管理システム

```scala
// OrderManagementSystem.scala
@main def orderManagementSystem(): Unit =
  import java.time.LocalDateTime
  
  // 注文の状態（すべての可能な状態）
  sealed trait OrderStatus
  case object Pending extends OrderStatus
  case object Confirmed extends OrderStatus
  case object Processing extends OrderStatus
  case object Shipped extends OrderStatus
  case object Delivered extends OrderStatus
  case object Cancelled extends OrderStatus
  
  // 注文イベント（すべての可能なイベント）
  sealed trait OrderEvent
  case class OrderPlaced(orderId: String, items: List[String], total: Double) extends OrderEvent
  case class OrderConfirmed(orderId: String, confirmedAt: LocalDateTime) extends OrderEvent
  case class OrderShipped(orderId: String, trackingNumber: String) extends OrderEvent
  case class OrderDelivered(orderId: String, deliveredAt: LocalDateTime) extends OrderEvent
  case class OrderCancelled(orderId: String, reason: String) extends OrderEvent
  
  // 注文
  case class Order(
    id: String,
    status: OrderStatus,
    items: List[String],
    total: Double,
    events: List[OrderEvent] = List.empty
  )
  
  // 状態遷移を管理
  object OrderStateMachine:
    def canTransition(from: OrderStatus, to: OrderStatus): Boolean = (from, to) match
      case (Pending, Confirmed) => true
      case (Pending, Cancelled) => true
      case (Confirmed, Processing) => true
      case (Confirmed, Cancelled) => true
      case (Processing, Shipped) => true
      case (Shipped, Delivered) => true
      case _ => false
    
    def processEvent(order: Order, event: OrderEvent): Either[String, Order] =
      event match
        case OrderConfirmed(orderId, _) if order.id == orderId =>
          if canTransition(order.status, Confirmed) then
            Right(order.copy(
              status = Confirmed,
              events = order.events :+ event
            ))
          else
            Left(s"${order.status}からConfirmedへの遷移はできません")
        
        case OrderShipped(orderId, _) if order.id == orderId =>
          if canTransition(order.status, Shipped) then
            Right(order.copy(
              status = Shipped,
              events = order.events :+ event
            ))
          else
            Left(s"${order.status}からShippedへの遷移はできません")
        
        case OrderDelivered(orderId, _) if order.id == orderId =>
          if canTransition(order.status, Delivered) then
            Right(order.copy(
              status = Delivered,
              events = order.events :+ event
            ))
          else
            Left(s"${order.status}からDeliveredへの遷移はできません")
        
        case OrderCancelled(orderId, _) if order.id == orderId =>
          if order.status == Pending || order.status == Confirmed then
            Right(order.copy(
              status = Cancelled,
              events = order.events :+ event
            ))
          else
            Left(s"${order.status}の注文はキャンセルできません")
        
        case _ =>
          Left("不正なイベント")
    
    def getStatusMessage(status: OrderStatus): String = status match
      case Pending => "注文確認中"
      case Confirmed => "注文確定"
      case Processing => "商品準備中"
      case Shipped => "発送済み"
      case Delivered => "配達完了"
      case Cancelled => "キャンセル済み"
  
  // 使用例
  val order = Order(
    id = "ORD-001",
    status = Pending,
    items = List("商品A", "商品B"),
    total = 5000.0
  )
  
  println(s"初期状態: ${OrderStateMachine.getStatusMessage(order.status)}")
  
  // イベントを順に処理
  val events = List(
    OrderConfirmed("ORD-001", LocalDateTime.now()),
    OrderShipped("ORD-001", "TRK-123456"),
    OrderDelivered("ORD-001", LocalDateTime.now())
  )
  
  val finalOrder = events.foldLeft[Either[String, Order]](Right(order)) {
    case (Right(currentOrder), event) =>
      OrderStateMachine.processEvent(currentOrder, event) match
        case Right(updated) =>
          println(s"✓ ${event.getClass.getSimpleName}: ${OrderStateMachine.getStatusMessage(updated.status)}")
          Right(updated)
        case Left(error) =>
          println(s"✗ エラー: $error")
          Left(error)
    case (error, _) => error
  }
  
  finalOrder match
    case Right(order) =>
      println(s"\n最終状態: ${OrderStateMachine.getStatusMessage(order.status)}")
      println(s"イベント数: ${order.events.length}")
    case Left(error) =>
      println(s"\n処理失敗: $error")
```

## ADT（代数的データ型）

### 直和型と直積型

```scala
// AlgebraicDataTypes.scala
@main def algebraicDataTypes(): Unit =
  // 直和型（OR型）：いずれか1つ
  sealed trait Shape
  case class Circle(radius: Double) extends Shape
  case class Rectangle(width: Double, height: Double) extends Shape
  case class Triangle(base: Double, height: Double) extends Shape
  
  // 面積を計算（すべてのケースを処理）
  def area(shape: Shape): Double = shape match
    case Circle(r) => math.Pi * r * r
    case Rectangle(w, h) => w * h
    case Triangle(b, h) => b * h / 2
  
  // 周囲長を計算
  def perimeter(shape: Shape): Double = shape match
    case Circle(r) => 2 * math.Pi * r
    case Rectangle(w, h) => 2 * (w + h)
    case Triangle(b, h) => 
      val hypotenuse = math.sqrt(b * b + h * h)
      b + h + hypotenuse
  
  val shapes = List(
    Circle(5.0),
    Rectangle(4.0, 6.0),
    Triangle(3.0, 4.0)
  )
  
  shapes.foreach { shape =>
    println(f"${shape}: 面積=${area(shape)}%.2f, 周囲=${perimeter(shape)}%.2f")
  }
  
  // 直積型（AND型）：すべてを含む
  case class Point(x: Double, y: Double)
  case class ColoredShape(shape: Shape, color: String, position: Point)
  
  val coloredCircle = ColoredShape(
    Circle(3.0),
    "赤",
    Point(10.0, 20.0)
  )
  
  println(s"\n色付き図形: ${coloredCircle.color}の${coloredCircle.shape}")
```

### 再帰的なデータ構造

```scala
// RecursiveDataStructures.scala
@main def recursiveDataStructures(): Unit =
  // 二分木
  sealed trait BinaryTree[+A]
  case object Empty extends BinaryTree[Nothing]
  case class Node[A](value: A, left: BinaryTree[A], right: BinaryTree[A]) extends BinaryTree[A]
  
  // 木の深さを計算
  def depth[A](tree: BinaryTree[A]): Int = tree match
    case Empty => 0
    case Node(_, left, right) => 1 + math.max(depth(left), depth(right))
  
  // 木の要素数を数える
  def size[A](tree: BinaryTree[A]): Int = tree match
    case Empty => 0
    case Node(_, left, right) => 1 + size(left) + size(right)
  
  // 木を文字列で表現
  def toString[A](tree: BinaryTree[A], indent: String = ""): String = tree match
    case Empty => s"${indent}Empty"
    case Node(value, left, right) =>
      s"""${indent}Node($value)
         |${toString(left, indent + "  ")}
         |${toString(right, indent + "  ")}""".stripMargin
  
  // サンプルの木を作成
  val tree = Node(
    1,
    Node(
      2,
      Node(4, Empty, Empty),
      Node(5, Empty, Empty)
    ),
    Node(
      3,
      Empty,
      Node(6, Empty, Empty)
    )
  )
  
  println("二分木:")
  println(toString(tree))
  println(s"\n深さ: ${depth(tree)}")
  println(s"要素数: ${size(tree)}")
  
  // 式の木
  sealed trait Expression
  case class Number(value: Double) extends Expression
  case class Add(left: Expression, right: Expression) extends Expression
  case class Multiply(left: Expression, right: Expression) extends Expression
  case class Subtract(left: Expression, right: Expression) extends Expression
  
  // 式を評価
  def evaluate(expr: Expression): Double = expr match
    case Number(value) => value
    case Add(left, right) => evaluate(left) + evaluate(right)
    case Multiply(left, right) => evaluate(left) * evaluate(right)
    case Subtract(left, right) => evaluate(left) - evaluate(right)
  
  // 式を文字列に
  def exprToString(expr: Expression): String = expr match
    case Number(value) => value.toString
    case Add(left, right) => s"(${exprToString(left)} + ${exprToString(right)})"
    case Multiply(left, right) => s"(${exprToString(left)} * ${exprToString(right)})"
    case Subtract(left, right) => s"(${exprToString(left)} - ${exprToString(right)})"
  
  // (2 + 3) * (10 - 5)
  val expression = Multiply(
    Add(Number(2), Number(3)),
    Subtract(Number(10), Number(5))
  )
  
  println(s"\n式: ${exprToString(expression)}")
  println(s"結果: ${evaluate(expression)}")
```

## 実践例：ゲームの状態管理

```scala
// GameStateManagement.scala
@main def gameStateManagement(): Unit =
  // プレイヤーの行動
  sealed trait PlayerAction
  case object MoveUp extends PlayerAction
  case object MoveDown extends PlayerAction
  case object MoveLeft extends PlayerAction
  case object MoveRight extends PlayerAction
  case object Attack extends PlayerAction
  case object Defend extends PlayerAction
  case object UseItem extends PlayerAction
  
  // ゲームの状態
  sealed trait GameState
  case object MainMenu extends GameState
  case class Playing(
    playerHealth: Int,
    playerPosition: (Int, Int),
    enemyCount: Int,
    score: Int
  ) extends GameState
  case object Paused extends GameState
  case class GameOver(finalScore: Int, victory: Boolean) extends GameState
  
  // ゲームイベント
  sealed trait GameEvent
  case object StartGame extends GameEvent
  case object PauseGame extends GameEvent
  case object ResumeGame extends GameEvent
  case class PlayerDamaged(damage: Int) extends GameEvent
  case class EnemyDefeated(points: Int) extends GameEvent
  case object AllEnemiesDefeated extends GameEvent
  case object PlayerDied extends GameEvent
  
  // ゲームエンジン
  class GameEngine:
    def processEvent(state: GameState, event: GameEvent): GameState =
      (state, event) match
        case (MainMenu, StartGame) =>
          Playing(100, (5, 5), 10, 0)
        
        case (Playing(health, pos, enemies, score), PauseGame) =>
          Paused
        
        case (Paused, ResumeGame) =>
          Playing(100, (5, 5), 10, 0)  // 簡略化のため固定値
        
        case (Playing(health, pos, enemies, score), PlayerDamaged(damage)) =>
          val newHealth = health - damage
          if newHealth <= 0 then
            GameOver(score, false)
          else
            Playing(newHealth, pos, enemies, score)
        
        case (Playing(health, pos, enemies, score), EnemyDefeated(points)) =>
          val newEnemies = enemies - 1
          val newScore = score + points
          if newEnemies == 0 then
            GameOver(newScore, true)
          else
            Playing(health, pos, newEnemies, newScore)
        
        case (Playing(health, pos, enemies, score), AllEnemiesDefeated) =>
          GameOver(score, true)
        
        case (Playing(_, _, _, score), PlayerDied) =>
          GameOver(score, false)
        
        case _ => state  // 無効な遷移は現在の状態を保持
    
    def processAction(state: GameState, action: PlayerAction): GameState =
      state match
        case Playing(health, (x, y), enemies, score) =>
          action match
            case MoveUp => Playing(health, (x, y - 1), enemies, score)
            case MoveDown => Playing(health, (x, y + 1), enemies, score)
            case MoveLeft => Playing(health, (x - 1, y), enemies, score)
            case MoveRight => Playing(health, (x + 1, y), enemies, score)
            case Attack =>
              // 攻撃の結果をシミュレート
              if scala.util.Random.nextBoolean() then
                processEvent(state, EnemyDefeated(100))
              else
                state
            case Defend =>
              // 防御は体力を少し回復
              Playing(math.min(100, health + 5), (x, y), enemies, score)
            case UseItem =>
              // アイテム使用（体力回復）
              Playing(math.min(100, health + 20), (x, y), enemies, score)
        
        case _ => state  // プレイ中以外は行動できない
    
    def stateDescription(state: GameState): String = state match
      case MainMenu => "メインメニュー"
      case Playing(health, pos, enemies, score) =>
        f"プレイ中 - 体力:$health%3d 位置:$pos 敵:$enemies%2d 得点:$score%,d"
      case Paused => "一時停止中"
      case GameOver(score, true) => f"勝利！ 最終得点: $score%,d"
      case GameOver(score, false) => f"敗北... 最終得点: $score%,d"
  
  // ゲームプレイのシミュレーション
  val engine = new GameEngine
  var state: GameState = MainMenu
  
  println("=== ゲーム開始 ===")
  println(engine.stateDescription(state))
  
  // イベントのシーケンス
  val events = List(
    StartGame,
    PlayerDamaged(20),
    EnemyDefeated(100),
    PlayerDamaged(30),
    EnemyDefeated(150),
    PlayerDamaged(60)
  )
  
  events.foreach { event =>
    state = engine.processEvent(state, event)
    println(s"\nイベント: $event")
    println(engine.stateDescription(state))
  }
```

## エラーを防ぐ設計

```scala
// ErrorPreventingDesign.scala
@main def errorPreventingDesign(): Unit =
  // メールアドレスの検証状態
  sealed trait EmailValidation
  case object Valid extends EmailValidation
  case class Invalid(reason: String) extends EmailValidation
  
  // パスワードの強度
  sealed trait PasswordStrength
  case object Weak extends PasswordStrength
  case object Medium extends PasswordStrength
  case object Strong extends PasswordStrength
  
  // アカウントの状態
  sealed trait AccountState
  case object Unverified extends AccountState
  case object Active extends AccountState
  case object Suspended extends AccountState
  case object Deleted extends AccountState
  
  // これらを組み合わせて、不正な状態を作れないようにする
  case class Account private (
    email: String,
    emailValidation: EmailValidation,
    passwordStrength: PasswordStrength,
    state: AccountState
  )
  
  object Account:
    // ファクトリメソッドで作成を制限
    def create(email: String, password: String): Either[String, Account] =
      val emailVal = validateEmail(email)
      val passStrength = checkPasswordStrength(password)
      
      (emailVal, passStrength) match
        case (Valid, Strong | Medium) =>
          Right(Account(email, emailVal, passStrength, Unverified))
        case (Valid, Weak) =>
          Left("パスワードが弱すぎます")
        case (Invalid(reason), _) =>
          Left(s"メールアドレスが無効: $reason")
    
    private def validateEmail(email: String): EmailValidation =
      if email.isEmpty then Invalid("空です")
      else if !email.contains("@") then Invalid("@がありません")
      else if !email.contains(".") then Invalid(".がありません")
      else Valid
    
    private def checkPasswordStrength(password: String): PasswordStrength =
      val hasUpper = password.exists(_.isUpper)
      val hasLower = password.exists(_.isLower)
      val hasDigit = password.exists(_.isDigit)
      val hasSpecial = password.exists(!_.isLetterOrDigit)
      val isLong = password.length >= 8
      
      val score = List(hasUpper, hasLower, hasDigit, hasSpecial, isLong).count(identity)
      
      if score >= 4 then Strong
      else if score >= 3 then Medium
      else Weak
  
  // 状態遷移も型安全に
  def activateAccount(account: Account): Either[String, Account] =
    account.state match
      case Unverified => Right(account.copy(state = Active))
      case _ => Left("未確認のアカウントのみアクティベートできます")
  
  // 使用例
  val results = List(
    ("user@example.com", "StrongP@ss1"),
    ("invalid-email", "password"),
    ("test@test.com", "weak")
  )
  
  results.foreach { case (email, password) =>
    println(s"\n登録試行: $email")
    Account.create(email, password) match
      case Right(account) =>
        println(s"✓ アカウント作成成功")
        println(s"  メール検証: ${account.emailValidation}")
        println(s"  パスワード強度: ${account.passwordStrength}")
      case Left(error) =>
        println(s"✗ エラー: $error")
  }
```

## 練習してみよう！

### 練習1：決済システム

以下の要件を満たす決済システムを設計してください：
- 決済方法：クレジットカード、銀行振込、コンビニ決済、PayPal
- 決済状態：保留中、処理中、成功、失敗、返金済み
- すべての組み合わせが有効なわけではない（例：コンビニ決済に返金はない）

### 練習2：チャットボット

チャットボットの会話フローを設計してください：
- 状態：待機中、挨拶、質問理解中、回答中、終了
- ユーザー入力タイプ：挨拶、質問、確認、終了
- 適切な状態遷移のみ許可

### 練習3：ファイル処理

ファイル処理システムを作ってください：
- ファイルタイプ：テキスト、画像、動画、不明
- 処理結果：成功、失敗（理由付き）、スキップ
- タイプごとに適切な処理を実装

## この章のまとめ

シールドトレイトの力を実感できましたね！

### できるようになったこと

✅ **シールドトレイトの基本**
- sealed trait の定義
- 継承の制限
- 網羅性チェック

✅ **ADT（代数的データ型）**
- 直和型（OR）
- 直積型（AND）
- 再帰的データ構造

✅ **実践的な設計**
- 状態管理
- イベント処理
- エラー防止

✅ **型安全な実装**
- すべてのケースを網羅
- 不正な状態を防ぐ
- コンパイル時チェック

### シールドトレイトを使うべき場面

1. **限定された選択肢**
   - 状態マシン
   - コマンドパターン
   - 設定オプション

2. **網羅的な処理**
   - すべてのケースを扱う
   - デフォルトケース不要
   - 安全性の保証

3. **型による設計**
   - ドメインモデリング
   - エラーハンドリング
   - プロトコル定義

### 次の章では...

イミュータブルなデータ設計について学びます。変更できないデータで、より安全で理解しやすいプログラムを作りましょう！

### 最後に

シールドトレイトは「完璧主義者の道具」です。すべての可能性を列挙し、1つも漏らさず、1つも重複させない。この厳密さが、バグのない堅牢なプログラムを生み出します。完璧を目指すあなたの、最高のパートナーです！