# 第24章 イミュータブルなデータ設計

## はじめに

写真を撮ったら、その瞬間が永遠に保存されますよね。後から「あの時の空を青く塗り替える」ことはできません。新しく加工した写真を作ることはできますが、元の写真は変わりません。

イミュータブル（不変）なデータ設計も同じ考え方です。一度作ったデータは変更せず、新しいデータを作る。この方法で、より安全で予測可能なプログラムが書けるんです！

## イミュータブルって何だろう？

### ミュータブル vs イミュータブル

```scala
// MutableVsImmutable.scala
@main def mutableVsImmutable(): Unit =
  import scala.collection.mutable
  
  // ミュータブル（変更可能）- 危険な例
  println("=== ミュータブルの問題 ===")
  val mutableList = mutable.ListBuffer(1, 2, 3)
  val reference = mutableList  // 同じリストを参照
  
  println(s"元のリスト: $mutableList")
  reference += 4  // referenceを変更
  println(s"元のリスト（変更後）: $mutableList")  // 元も変わってしまう！
  
  // イミュータブル（変更不可）- 安全な例
  println("\n=== イミュータブルの安全性 ===")
  val immutableList = List(1, 2, 3)
  val newList = immutableList :+ 4  // 新しいリストを作成
  
  println(s"元のリスト: $immutableList")  // 変わらない
  println(s"新しいリスト: $newList")      // 新しい値
  
  // 実例：銀行口座
  case class BankAccount(
    accountNumber: String,
    balance: Double,
    transactions: List[String] = List.empty
  )
  
  val account1 = BankAccount("123456", 10000.0)
  
  // 入金（新しいアカウントオブジェクトを作成）
  def deposit(account: BankAccount, amount: Double): BankAccount =
    account.copy(
      balance = account.balance + amount,
      transactions = account.transactions :+ s"入金: ${amount}円"
    )
  
  val account2 = deposit(account1, 5000)
  
  println(s"\n元の口座: $account1")
  println(s"入金後の口座: $account2")
  // 元の口座は変わっていない！
```

## イミュータブルデータの利点

### スレッドセーフティ

```scala
// ThreadSafety.scala
@main def threadSafety(): Unit =
  import scala.concurrent.{Future, Await}
  import scala.concurrent.duration.*
  import scala.concurrent.ExecutionContext.Implicits.global
  
  // イミュータブルなカウンター
  case class Counter(value: Int):
    def increment: Counter = Counter(value + 1)
    def add(n: Int): Counter = Counter(value + n)
  
  val counter = Counter(0)
  
  // 1000個の並行タスクがカウンターを操作
  val futures = (1 to 1000).map { _ =>
    Future {
      Thread.sleep(1)  // 少し待機
      counter.increment  // 新しいカウンターを作成（元は変わらない）
    }
  }
  
  // すべて完了を待つ
  val results = Await.result(Future.sequence(futures), 10.seconds)
  
  println(s"元のカウンター: ${counter.value}")  // 0のまま！
  println(s"作成されたカウンター数: ${results.length}")
  
  // ミュータブルだと競合状態（race condition）が発生する
  class MutableCounter(var value: Int):
    def increment(): Unit = value += 1  // 危険！
  
  // イミュータブルなら安全に共有できる
  val sharedData = List(1, 2, 3, 4, 5)
  
  val processingFutures = (1 to 10).map { id =>
    Future {
      val processed = sharedData.map(_ * id)  // 安全に読み取り
      s"Worker $id: $processed"
    }
  }
  
  val processResults = Await.result(Future.sequence(processingFutures), 5.seconds)
  processResults.foreach(println)
```

### 履歴の管理

```scala
// HistoryManagement.scala
@main def historyManagement(): Unit =
  // ドキュメントエディタの例
  case class Document(
    content: String,
    version: Int = 1,
    lastModified: Long = System.currentTimeMillis()
  )
  
  case class DocumentHistory(
    current: Document,
    history: List[Document] = List.empty,
    maxHistory: Int = 10
  ):
    def edit(newContent: String): DocumentHistory =
      val newDoc = Document(
        content = newContent,
        version = current.version + 1
      )
      
      val newHistory = (current :: history).take(maxHistory)
      
      DocumentHistory(newDoc, newHistory, maxHistory)
    
    def undo: Option[DocumentHistory] = history match
      case Nil => None
      case prev :: rest => Some(DocumentHistory(prev, rest, maxHistory))
    
    def getVersion(version: Int): Option[Document] =
      if current.version == version then Some(current)
      else history.find(_.version == version)
  
  // 使用例
  var docHistory = DocumentHistory(Document("初期内容"))
  
  println("=== ドキュメント編集履歴 ===")
  println(s"v${docHistory.current.version}: ${docHistory.current.content}")
  
  // 編集を繰り返す
  docHistory = docHistory.edit("第1章を追加")
  println(s"v${docHistory.current.version}: ${docHistory.current.content}")
  
  docHistory = docHistory.edit("第1章を追加\n第2章を追加")
  println(s"v${docHistory.current.version}: ${docHistory.current.content}")
  
  docHistory = docHistory.edit("第1章を追加\n第2章を追加\n第3章を追加")
  println(s"v${docHistory.current.version}: ${docHistory.current.content}")
  
  // アンドゥ
  println("\n=== アンドゥ ===")
  docHistory.undo match
    case Some(previous) =>
      docHistory = previous
      println(s"v${docHistory.current.version}に戻しました: ${docHistory.current.content}")
    case None =>
      println("これ以上戻れません")
  
  // 特定バージョンの取得
  println("\n=== バージョン取得 ===")
  docHistory.getVersion(2) match
    case Some(doc) => println(s"v2の内容: ${doc.content}")
    case None => println("v2は見つかりません")
```

## イミュータブルなデータ構造の設計

### ショッピングカートの実装

```scala
// ImmutableShoppingCart.scala
@main def immutableShoppingCart(): Unit =
  // 商品
  case class Product(
    id: String,
    name: String,
    price: BigDecimal
  )
  
  // カートアイテム
  case class CartItem(
    product: Product,
    quantity: Int
  ):
    def subtotal: BigDecimal = product.price * quantity
    def updateQuantity(newQty: Int): CartItem = copy(quantity = newQty)
  
  // ショッピングカート（イミュータブル）
  case class ShoppingCart(
    items: Map[String, CartItem] = Map.empty,
    appliedCoupon: Option[String] = None
  ):
    def addItem(product: Product, quantity: Int = 1): ShoppingCart =
      val newItems = items.get(product.id) match
        case Some(existing) =>
          items.updated(
            product.id,
            existing.updateQuantity(existing.quantity + quantity)
          )
        case None =>
          items.updated(product.id, CartItem(product, quantity))
      
      copy(items = newItems)
    
    def removeItem(productId: String): ShoppingCart =
      copy(items = items.removed(productId))
    
    def updateQuantity(productId: String, quantity: Int): ShoppingCart =
      if quantity <= 0 then
        removeItem(productId)
      else
        items.get(productId) match
          case Some(item) =>
            copy(items = items.updated(productId, item.updateQuantity(quantity)))
          case None =>
            this  // 変更なし
    
    def applyCoupon(code: String): ShoppingCart =
      copy(appliedCoupon = Some(code))
    
    def removeCoupon: ShoppingCart =
      copy(appliedCoupon = None)
    
    def subtotal: BigDecimal = items.values.map(_.subtotal).sum
    
    def discount: BigDecimal = appliedCoupon match
      case Some("SAVE10") => subtotal * 0.1
      case Some("SAVE20") => subtotal * 0.2
      case _ => 0
    
    def total: BigDecimal = subtotal - discount
    
    def summary: String =
      if items.isEmpty then
        "カートは空です"
      else
        val itemLines = items.values.map { item =>
          f"${item.product.name}%-20s × ${item.quantity}%2d = ¥${item.subtotal}%,.0f"
        }.mkString("\n")
        
        val couponLine = appliedCoupon match
          case Some(code) => f"\nクーポン ($code): -¥${discount}%,.0f"
          case None => ""
        
        s"""$itemLines
           |${"=" * 50}
           |小計: ¥${subtotal}%,.0f$couponLine
           |合計: ¥${total}%,.0f""".stripMargin
  
  // 商品カタログ
  val products = Map(
    "P001" -> Product("P001", "プログラミング入門書", 2800),
    "P002" -> Product("P002", "Scalaパーフェクトガイド", 3500),
    "P003" -> Product("P003", "関数型プログラミング", 4200)
  )
  
  // カートの操作（各操作で新しいカートが作られる）
  val cart1 = ShoppingCart()
  val cart2 = cart1.addItem(products("P001"))
  val cart3 = cart2.addItem(products("P002"), 2)
  val cart4 = cart3.applyCoupon("SAVE10")
  val cart5 = cart4.updateQuantity("P001", 2)
  
  // 各段階のカートはすべて保持されている
  println("=== カート1（初期状態）===")
  println(cart1.summary)
  
  println("\n=== カート5（最終状態）===")
  println(cart5.summary)
  
  // メソッドチェーンでも書ける
  val finalCart = ShoppingCart()
    .addItem(products("P001"))
    .addItem(products("P002"), 2)
    .addItem(products("P003"))
    .applyCoupon("SAVE20")
    .updateQuantity("P002", 1)
  
  println("\n=== メソッドチェーンの結果 ===")
  println(finalCart.summary)
```

### イベントソーシングパターン

```scala
// EventSourcing.scala
@main def eventSourcing(): Unit =
  import java.time.LocalDateTime
  
  // イベントの定義
  sealed trait AccountEvent:
    def timestamp: LocalDateTime
    def amount: BigDecimal
  
  case class AccountOpened(
    initialDeposit: BigDecimal,
    timestamp: LocalDateTime = LocalDateTime.now()
  ) extends AccountEvent:
    def amount = initialDeposit
  
  case class MoneyDeposited(
    amount: BigDecimal,
    timestamp: LocalDateTime = LocalDateTime.now()
  ) extends AccountEvent
  
  case class MoneyWithdrawn(
    amount: BigDecimal,
    timestamp: LocalDateTime = LocalDateTime.now()
  ) extends AccountEvent
  
  case class InterestCredited(
    amount: BigDecimal,
    timestamp: LocalDateTime = LocalDateTime.now()
  ) extends AccountEvent
  
  // アカウントの状態（イベントから計算）
  case class AccountState(
    balance: BigDecimal,
    events: List[AccountEvent]
  ):
    def applyEvent(event: AccountEvent): AccountState =
      val newBalance = event match
        case AccountOpened(amount, _) => amount
        case MoneyDeposited(amount, _) => balance + amount
        case MoneyWithdrawn(amount, _) => balance - amount
        case InterestCredited(amount, _) => balance + amount
      
      AccountState(newBalance, events :+ event)
    
    def deposit(amount: BigDecimal): AccountState =
      if amount > 0 then
        applyEvent(MoneyDeposited(amount))
      else
        this
    
    def withdraw(amount: BigDecimal): Either[String, AccountState] =
      if amount > balance then
        Left(s"残高不足: 残高${balance}円に対して${amount}円の出金")
      else if amount <= 0 then
        Left("出金額は正の数である必要があります")
      else
        Right(applyEvent(MoneyWithdrawn(amount)))
    
    def creditInterest(rate: BigDecimal): AccountState =
      val interest = balance * rate
      applyEvent(InterestCredited(interest))
    
    def transactionHistory: String =
      events.map {
        case AccountOpened(amount, time) =>
          f"$time%tF %tT | 口座開設 | +¥${amount}%,.0f"
        case MoneyDeposited(amount, time) =>
          f"$time%tF %tT | 入金     | +¥${amount}%,.0f"
        case MoneyWithdrawn(amount, time) =>
          f"$time%tF %tT | 出金     | -¥${amount}%,.0f"
        case InterestCredited(amount, time) =>
          f"$time%tF %tT | 利息     | +¥${amount}%,.0f"
      }.mkString("\n")
  
  // アカウントの作成と操作
  val account0 = AccountState(0, List.empty)
  val account1 = account0.applyEvent(AccountOpened(10000))
  val account2 = account1.deposit(5000)
  val account3 = account2.withdraw(3000).getOrElse(account2)
  val account4 = account3.creditInterest(0.001)  // 0.1%の利息
  
  println("=== 最終残高 ===")
  println(f"¥${account4.balance}%,.0f")
  
  println("\n=== 取引履歴 ===")
  println(account4.transactionHistory)
  
  // イベントから状態を再構築
  def rebuildState(events: List[AccountEvent]): AccountState =
    events.foldLeft(AccountState(0, List.empty)) { (state, event) =>
      state.applyEvent(event)
    }
  
  val rebuiltAccount = rebuildState(account4.events)
  println(s"\n再構築後の残高: ¥${rebuiltAccount.balance}")
```

## レンズパターン（ネストした更新）

```scala
// LensPattern.scala
@main def lensPattern(): Unit =
  // ネストしたデータ構造
  case class Address(
    street: String,
    city: String,
    postalCode: String
  )
  
  case class Company(
    name: String,
    address: Address
  )
  
  case class Employee(
    id: String,
    name: String,
    company: Company,
    salary: Int
  )
  
  // 簡易レンズの実装
  case class Lens[A, B](
    get: A => B,
    set: (A, B) => A
  ):
    def modify(f: B => B)(a: A): A = set(a, f(get(a)))
    
    def compose[C](other: Lens[B, C]): Lens[A, C] =
      Lens(
        get = a => other.get(get(a)),
        set = (a, c) => set(a, other.set(get(a), c))
      )
  
  // レンズの定義
  val companyLens = Lens[Employee, Company](
    get = _.company,
    set = (emp, company) => emp.copy(company = company)
  )
  
  val addressLens = Lens[Company, Address](
    get = _.address,
    set = (company, address) => company.copy(address = address)
  )
  
  val cityLens = Lens[Address, String](
    get = _.city,
    set = (address, city) => address.copy(city = city)
  )
  
  // レンズの合成
  val employeeCityLens = companyLens.compose(addressLens).compose(cityLens)
  
  // 使用例
  val employee = Employee(
    "E001",
    "田中太郎",
    Company(
      "テック株式会社",
      Address("千代田区1-1", "東京都", "100-0001")
    ),
    500000
  )
  
  println("=== 元の従業員 ===")
  println(employee)
  
  // 深くネストした値の更新（従来の方法）
  val updatedTraditional = employee.copy(
    company = employee.company.copy(
      address = employee.company.address.copy(
        city = "大阪府"
      )
    )
  )
  
  // レンズを使った更新
  val updatedWithLens = employeeCityLens.set(employee, "大阪府")
  
  println("\n=== 更新後（レンズ使用）===")
  println(updatedWithLens)
  
  // modifyを使った更新
  val salaryLens = Lens[Employee, Int](
    get = _.salary,
    set = (emp, salary) => emp.copy(salary = salary)
  )
  
  val promoted = salaryLens.modify(_ * 1.1)(employee)
  println(s"\n昇給後の給与: ${promoted.salary}")
```

## パフォーマンスの考慮

```scala
// PerformanceConsiderations.scala
@main def performanceConsiderations(): Unit =
  import scala.collection.immutable.Vector
  
  // 構造共有（Structural Sharing）の例
  println("=== 構造共有 ===")
  
  val list1 = List(1, 2, 3, 4, 5)
  val list2 = 0 :: list1  // list1のデータを再利用
  
  println(s"list1: $list1")
  println(s"list2: $list2")
  // メモリ上では、list2は新しい要素0とlist1への参照だけを持つ
  
  // 効率的なデータ構造の選択
  println("\n=== データ構造の選択 ===")
  
  // Vector：ランダムアクセスが速い
  val vector = Vector(1, 2, 3, 4, 5)
  println(s"Vector[2]: ${vector(2)}")  // O(log n)
  
  // List：先頭への追加が速い
  val list = List(1, 2, 3, 4, 5)
  val newList = 0 :: list  // O(1)
  
  // バルク操作の最適化
  case class Stats(
    count: Int = 0,
    sum: Double = 0.0,
    min: Double = Double.MaxValue,
    max: Double = Double.MinValue
  ):
    def add(value: Double): Stats = Stats(
      count + 1,
      sum + value,
      math.min(min, value),
      math.max(max, value)
    )
    
    def average: Option[Double] =
      if count > 0 then Some(sum / count) else None
  
  // 大量のデータを効率的に処理
  val numbers = (1 to 10000).map(_.toDouble).toList
  
  val stats = numbers.foldLeft(Stats()) { (s, n) => s.add(n) }
  
  println(s"\n=== 統計情報 ===")
  println(f"件数: ${stats.count}%,d")
  println(f"合計: ${stats.sum}%,.0f")
  println(f"平均: ${stats.average.getOrElse(0.0)}%,.1f")
  println(f"最小: ${stats.min}%,.0f")
  println(f"最大: ${stats.max}%,.0f")
```

## 練習してみよう！

### 練習1：TODOリスト

イミュータブルなTODOリストアプリケーションを作ってください：
- タスクの追加、完了、削除
- フィルタリング（完了/未完了）
- すべての操作で新しいリストを返す

### 練習2：ゲームの状態管理

シンプルなRPGのキャラクター状態を管理してください：
- HP、MP、経験値、レベル
- ダメージ、回復、レベルアップ
- 戦闘履歴の記録

### 練習3：設定管理

アプリケーションの設定を管理するシステムを作ってください：
- ネストした設定構造
- 設定の更新（レンズパターンを使用）
- 設定履歴の保持

## この章のまとめ

イミュータブルなデータ設計の素晴らしさを学びました！

### できるようになったこと

✅ **イミュータブルの基本**
- 不変データの概念
- 新しいインスタンスの作成
- 構造共有

✅ **利点の理解**
- スレッドセーフティ
- 履歴管理
- デバッグの容易さ

✅ **設計パターン**
- イベントソーシング
- レンズパターン
- 関数型データ構造

✅ **実践的な実装**
- ショッピングカート
- 状態管理
- パフォーマンス最適化

### イミュータブル設計のコツ

1. **常に新しく作る**
   - 変更ではなく作成
   - copyメソッドの活用
   - メソッドチェーン

2. **履歴を活かす**
   - 過去の状態を保持
   - アンドゥ/リドゥ
   - 監査ログ

3. **適切なデータ構造**
   - 用途に応じた選択
   - 構造共有の活用
   - パフォーマンスの考慮

### 次の部では...

第VII部では、関数型プログラミングの基礎について深く学んでいきます。関数合成、型パラメータ、型クラスなど、Scalaの真の力を解き放ちましょう！

### 最後に

イミュータブルなデータは「時を止める魔法」のようなものです。データが勝手に変わる心配がなく、いつでも過去に戻れて、複数の未来を同時に試せる。この安心感が、複雑なプログラムも怖くなくなる秘訣です。変えられないことの強さを、味方につけてください！