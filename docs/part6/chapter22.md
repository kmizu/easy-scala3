# 第22章 ケースクラスの便利さ

## はじめに

お店で商品を管理するとき、「商品名」「価格」「在庫数」など、関連する情報をまとめて扱いたいですよね。プログラミングでも同じです。

Scalaの「ケースクラス」は、関連するデータをまとめる最高の方法です。まるで、専用の収納ボックスを作るように、データを整理整頓できます！

## ケースクラスって何だろう？

### 通常のクラス vs ケースクラス

```scala
// ClassVsCaseClass.scala
@main def classVsCaseClass(): Unit =
  // 通常のクラス（面倒...）
  class PersonClass(val name: String, val age: Int)
  
  val person1 = new PersonClass("太郎", 25)
  // println(person1)  // 意味不明な出力
  // val person2 = person1.copy()  // copyメソッドがない！
  
  // ケースクラス（便利！）
  case class Person(name: String, age: Int)
  
  val person3 = Person("花子", 30)  // newが不要
  println(person3)  // Person(花子,30) と読みやすい！
  
  val person4 = person3.copy(age = 31)  // 簡単にコピー＆変更
  println(person4)
  
  // 自動的に使えるメソッドたち
  println(s"名前: ${person3.name}")
  println(s"年齢: ${person3.age}")
  println(s"同じ？: ${person3 == Person("花子", 30)}")  // true！
```

## ケースクラスの基本機能

### 自動生成される便利な機能

```scala
// CaseClassFeatures.scala
@main def caseClassFeatures(): Unit =
  case class Product(
    id: Int,
    name: String,
    price: Double,
    inStock: Boolean = true
  )
  
  // 1. コンパニオンオブジェクトのapplyメソッド（newが不要）
  val product1 = Product(1, "ノートPC", 89800.0)
  
  // 2. toStringメソッド
  println(product1)  // Product(1,ノートPC,89800.0,true)
  
  // 3. equalsメソッド（==で内容を比較）
  val product2 = Product(1, "ノートPC", 89800.0)
  println(s"同じ商品？: ${product1 == product2}")  // true
  
  // 4. hashCodeメソッド（MapやSetで使える）
  val productSet = Set(product1, product2)
  println(s"セットのサイズ: ${productSet.size}")  // 1（重複除去）
  
  // 5. copyメソッド
  val discounted = product1.copy(price = 79800.0)
  println(s"割引後: $discounted")
  
  // 6. パターンマッチで分解
  product1 match
    case Product(id, name, price, true) =>
      println(f"$name (ID:$id) は ${price}%.0f円で在庫あり")
    case Product(_, name, _, false) =>
      println(s"$name は在庫切れ")
```

### unapplyメソッドとパターンマッチ

```scala
// PatternMatchingCaseClass.scala
@main def patternMatchingCaseClass(): Unit =
  // 異なる種類の通知
  sealed trait Notification
  case class Email(sender: String, title: String, body: String) extends Notification
  case class SMS(caller: String, message: String) extends Notification
  case class Push(app: String, content: String, urgent: Boolean) extends Notification
  
  def handleNotification(notification: Notification): String =
    notification match
      case Email(sender, title, _) =>
        s"📧 メール: $sender から「$title」"
      
      case SMS(caller, message) if message.length > 50 =>
        s"📱 長いSMS: $caller から（${message.take(20)}...）"
      
      case SMS(caller, message) =>
        s"📱 SMS: $caller から「$message」"
      
      case Push(app, content, true) =>
        s"🔴 緊急通知: $app - $content"
      
      case Push(app, content, false) =>
        s"🔵 通知: $app - $content"
  
  // いろいろな通知を処理
  val notifications = List(
    Email("boss@company.com", "会議の件", "明日の会議は10時からです"),
    SMS("090-1234-5678", "今どこ？"),
    SMS("080-9876-5432", "今日はありがとう！とても楽しかったです。また会いましょう"),
    Push("カレンダー", "15分後に会議", true),
    Push("ニュース", "新着記事があります", false)
  )
  
  notifications.foreach { n =>
    println(handleNotification(n))
  }
```

## 実践的な使い方

### ショッピングカートシステム

```scala
// ShoppingCartSystem.scala
@main def shoppingCartSystem(): Unit =
  // 商品情報
  case class Product(
    id: String,
    name: String,
    price: Int,
    category: String
  )
  
  // カートアイテム（商品と数量）
  case class CartItem(
    product: Product,
    quantity: Int
  ):
    def subtotal: Int = product.price * quantity
  
  // ショッピングカート
  case class Cart(
    items: List[CartItem] = List.empty
  ):
    def addItem(product: Product, quantity: Int = 1): Cart =
      val existingItem = items.find(_.product.id == product.id)
      
      existingItem match
        case Some(item) =>
          val updated = item.copy(quantity = item.quantity + quantity)
          val newItems = items.map(i => 
            if i.product.id == product.id then updated else i
          )
          copy(items = newItems)
        
        case None =>
          copy(items = items :+ CartItem(product, quantity))
    
    def removeItem(productId: String): Cart =
      copy(items = items.filterNot(_.product.id == productId))
    
    def updateQuantity(productId: String, newQuantity: Int): Cart =
      if newQuantity <= 0 then
        removeItem(productId)
      else
        val newItems = items.map { item =>
          if item.product.id == productId then
            item.copy(quantity = newQuantity)
          else
            item
        }
        copy(items = newItems)
    
    def total: Int = items.map(_.subtotal).sum
    
    def itemCount: Int = items.map(_.quantity).sum
    
    def summary: String =
      if items.isEmpty then
        "カートは空です"
      else
        val itemList = items.map { item =>
          f"${item.product.name}%-15s × ${item.quantity}%2d = ${item.subtotal}%,6d円"
        }.mkString("\n")
        
        s"""$itemList
           |${"=" * 40}
           |合計: ${total}%,d円（${itemCount}点）""".stripMargin
  
  // 商品カタログ
  val products = List(
    Product("P001", "Tシャツ", 2980, "衣類"),
    Product("P002", "ジーンズ", 5980, "衣類"),
    Product("P003", "スニーカー", 8980, "靴"),
    Product("P004", "リュック", 4980, "バッグ")
  )
  
  // カートの操作をシミュレート
  var myCart = Cart()
  
  println("=== ショッピング開始 ===\n")
  
  // 商品を追加
  myCart = myCart.addItem(products(0), 2)  // Tシャツ2枚
  println("Tシャツを2枚追加")
  println(myCart.summary)
  
  println("\n" + "=" * 50 + "\n")
  
  myCart = myCart.addItem(products(1))  // ジーンズ1本
  myCart = myCart.addItem(products(2))  // スニーカー1足
  println("ジーンズとスニーカーを追加")
  println(myCart.summary)
  
  println("\n" + "=" * 50 + "\n")
  
  // 数量変更
  myCart = myCart.updateQuantity("P001", 1)  // Tシャツを1枚に
  println("Tシャツを1枚に変更")
  println(myCart.summary)
```

### ユーザー管理システム

```scala
// UserManagementSystem.scala
@main def userManagementSystem(): Unit =
  import java.time.LocalDateTime
  
  // ユーザーの状態
  sealed trait UserStatus
  case object Active extends UserStatus
  case object Suspended extends UserStatus
  case object Deleted extends UserStatus
  
  // ユーザー情報
  case class User(
    id: String,
    name: String,
    email: String,
    status: UserStatus = Active,
    createdAt: LocalDateTime = LocalDateTime.now(),
    lastLoginAt: Option[LocalDateTime] = None
  )
  
  // ユーザーイベント（監査ログ用）
  sealed trait UserEvent
  case class UserCreated(user: User, timestamp: LocalDateTime) extends UserEvent
  case class UserUpdated(oldUser: User, newUser: User, timestamp: LocalDateTime) extends UserEvent
  case class UserLoggedIn(userId: String, timestamp: LocalDateTime) extends UserEvent
  case class UserStatusChanged(userId: String, from: UserStatus, to: UserStatus, timestamp: LocalDateTime) extends UserEvent
  
  // ユーザー管理クラス
  class UserManager:
    private var users = Map.empty[String, User]
    private var events = List.empty[UserEvent]
    
    def createUser(name: String, email: String): Either[String, User] =
      if users.values.exists(_.email == email) then
        Left(s"メールアドレス $email は既に使用されています")
      else
        val user = User(
          id = s"U${System.currentTimeMillis()}",
          name = name,
          email = email
        )
        users += (user.id -> user)
        events ::= UserCreated(user, LocalDateTime.now())
        Right(user)
    
    def updateUser(userId: String, name: Option[String] = None, email: Option[String] = None): Either[String, User] =
      users.get(userId) match
        case None => Left(s"ユーザー $userId が見つかりません")
        case Some(oldUser) =>
          val newUser = oldUser.copy(
            name = name.getOrElse(oldUser.name),
            email = email.getOrElse(oldUser.email)
          )
          users += (userId -> newUser)
          events ::= UserUpdated(oldUser, newUser, LocalDateTime.now())
          Right(newUser)
    
    def login(userId: String): Either[String, User] =
      users.get(userId) match
        case None => Left(s"ユーザー $userId が見つかりません")
        case Some(user) if user.status != Active => Left("アカウントが無効です")
        case Some(user) =>
          val updatedUser = user.copy(lastLoginAt = Some(LocalDateTime.now()))
          users += (userId -> updatedUser)
          events ::= UserLoggedIn(userId, LocalDateTime.now())
          Right(updatedUser)
    
    def changeStatus(userId: String, newStatus: UserStatus): Either[String, User] =
      users.get(userId) match
        case None => Left(s"ユーザー $userId が見つかりません")
        case Some(user) =>
          val updatedUser = user.copy(status = newStatus)
          users += (userId -> updatedUser)
          events ::= UserStatusChanged(userId, user.status, newStatus, LocalDateTime.now())
          Right(updatedUser)
    
    def findByEmail(email: String): Option[User] =
      users.values.find(_.email == email)
    
    def listActiveUsers: List[User] =
      users.values.filter(_.status == Active).toList
    
    def getAuditLog: List[UserEvent] = events.reverse
  
  // 使用例
  val userManager = new UserManager
  
  println("=== ユーザー管理システム ===\n")
  
  // ユーザー作成
  val result1 = userManager.createUser("田中太郎", "taro@example.com")
  result1 match
    case Right(user) => println(s"ユーザー作成成功: $user")
    case Left(error) => println(s"エラー: $error")
  
  // 重複メールアドレス
  userManager.createUser("山田花子", "taro@example.com") match
    case Right(user) => println(s"ユーザー作成成功: $user")
    case Left(error) => println(s"エラー: $error")
  
  // 別のユーザー作成
  val Right(user2) = userManager.createUser("山田花子", "hanako@example.com")
  
  // ログイン
  userManager.login(user2.id) match
    case Right(user) => println(s"\nログイン成功: ${user.name}")
    case Left(error) => println(s"ログインエラー: $error")
  
  // アクティブユーザー一覧
  println("\n=== アクティブユーザー ===")
  userManager.listActiveUsers.foreach { user =>
    val lastLogin = user.lastLoginAt.map(_.toString).getOrElse("未ログイン")
    println(s"${user.name} (${user.email}) - 最終ログイン: $lastLogin")
  }
```

## ケースクラスの応用

### ネストしたケースクラス

```scala
// NestedCaseClasses.scala
@main def nestedCaseClasses(): Unit =
  // 住所
  case class Address(
    street: String,
    city: String,
    postalCode: String,
    country: String = "日本"
  )
  
  // 連絡先
  case class Contact(
    email: Option[String],
    phone: Option[String],
    address: Option[Address]
  )
  
  // 従業員
  case class Employee(
    id: String,
    name: String,
    department: String,
    contact: Contact,
    salary: Int
  )
  
  val employee = Employee(
    id = "E001",
    name = "佐藤次郎",
    department = "開発部",
    contact = Contact(
      email = Some("jiro@company.com"),
      phone = Some("03-1234-5678"),
      address = Some(Address(
        street = "千代田区丸の内1-1-1",
        city = "東京都",
        postalCode = "100-0001"
      ))
    ),
    salary = 500000
  )
  
  // 深いネストへのアクセス
  employee.contact.address match
    case Some(addr) => println(s"${employee.name}の住所: ${addr.city}${addr.street}")
    case None => println(s"${employee.name}の住所は未登録")
  
  // copyでネストした値を更新
  val relocated = employee.copy(
    contact = employee.contact.copy(
      address = employee.contact.address.map(_.copy(
        street = "渋谷区渋谷2-2-2",
        city = "東京都",
        postalCode = "150-0002"
      ))
    )
  )
  
  println(s"転居後: ${relocated.contact.address}")
```

### ジェネリックなケースクラス

```scala
// GenericCaseClasses.scala
@main def genericCaseClasses(): Unit =
  // APIレスポンスを表現
  case class ApiResponse[T](
    success: Boolean,
    data: Option[T],
    error: Option[String],
    timestamp: Long = System.currentTimeMillis()
  )
  
  // ページネーション付きリスト
  case class Page[A](
    items: List[A],
    currentPage: Int,
    totalPages: Int,
    totalItems: Int
  ):
    def hasNext: Boolean = currentPage < totalPages
    def hasPrevious: Boolean = currentPage > 1
  
  // 使用例
  case class Article(id: Int, title: String, content: String)
  
  val articlesResponse = ApiResponse(
    success = true,
    data = Some(Page(
      items = List(
        Article(1, "Scalaの基礎", "内容..."),
        Article(2, "ケースクラス入門", "内容...")
      ),
      currentPage = 1,
      totalPages = 5,
      totalItems = 48
    )),
    error = None
  )
  
  articlesResponse.data match
    case Some(page) =>
      println(s"${page.currentPage}/${page.totalPages}ページ")
      page.items.foreach { article =>
        println(s"- ${article.title}")
      }
      if page.hasNext then println("次のページがあります")
      
    case None =>
      println("データがありません")
```

## 練習してみよう！

### 練習1：図書管理システム

以下の要件を満たす図書管理システムを作ってください：
- Book（書籍）: タイトル、著者、ISBN、貸出可能か
- Member（会員）: ID、名前、貸出中の本のリスト
- 本の貸出・返却機能

### 練習2：レシピ管理

料理のレシピを管理するケースクラスを設計してください：
- 材料（名前、量、単位）
- 手順（順番、説明、所要時間）
- レシピ（名前、材料リスト、手順リスト、総調理時間）

### 練習3：イベントソーシング

銀行口座の操作を記録するシステムを作ってください：
- イベント: 入金、出金、送金
- 口座の現在の残高を計算
- 取引履歴の表示

## この章のまとめ

ケースクラスの素晴らしさを体験できましたね！

### できるようになったこと

✅ **ケースクラスの基本**
- 簡潔な定義方法
- 自動生成される機能
- イミュータブルなデータ

✅ **便利な機能**
- パターンマッチング
- copyメソッド
- 自動的なequals/hashCode

✅ **実践的な使い方**
- ドメインモデルの表現
- イベントの記録
- APIレスポンスの型付け

✅ **高度な応用**
- ネストした構造
- ジェネリック型
- sealed trait との組み合わせ

### ケースクラスを使うべき場面

1. **データの入れ物**
   - 値オブジェクト
   - DTOパターン
   - イミュータブルな設定

2. **パターンマッチング**
   - 状態の表現
   - メッセージパッシング
   - イベントソーシング

3. **関数型プログラミング**
   - 純粋関数の引数/戻り値
   - 不変データ構造
   - 並行処理での安全性

### 次の章では...

シールドトレイトを使って、さらに型安全なプログラミングを学びます。すべてのケースを網羅する、完璧な型設計を目指しましょう！

### 最後に

ケースクラスは「データの宝石箱」です。大切なデータを美しく、安全に保管できます。`new`も`equals`も`toString`も、全部Scalaが用意してくれる。こんなに便利な機能、使わない手はありませんよね！