# 第13章 マップで関連付けて保存

## はじめに

前章でマップの基本を学びました。今回は、マップを使ってもっと複雑なデータを扱う方法を学びます。

現実世界では、データは単純ではありません。「生徒には複数の科目の成績がある」「お店には複数の商品があり、それぞれに在庫と価格がある」など、データには関連性があります。

この章では、マップを使ってこうした複雑な関連を表現する方法を、楽しく学んでいきましょう！

## 複雑なデータの関連付け

### ネストしたマップ

```scala
// NestedMaps.scala
@main def nestedMaps(): Unit = {
  // 生徒ごとの科目別成績
  val gradeBook = Map(
    "田中太郎" -> Map(
      "数学" -> 85,
      "英語" -> 78,
      "理科" -> 92
    ),
    "山田花子" -> Map(
      "数学" -> 92,
      "英語" -> 88,
      "理科" -> 85
    ),
    "佐藤次郎" -> Map(
      "数学" -> 78,
      "英語" -> 95,
      "理科" -> 80
    )
  )
  
  // 特定の生徒の特定の科目を調べる
  val taroMath = gradeBook("田中太郎")("数学")
  println(s"田中太郎の数学: $taroMath点")
  
  // 安全にアクセス
  gradeBook.get("山田花子") match {
    case Some(subjects) =>
      subjects.get("英語") match {
        case Some(score) => println(s"山田花子の英語: $score点")
        case None => println("英語の成績がありません")
      }
    case None => println("その生徒は見つかりません")
  }
}
```

### マップとケースクラス

```scala
// MapWithCaseClass.scala
@main def mapWithCaseClass(): Unit = {
  // 商品情報を表すケースクラス
  case class Product(
    name: String,
    price: Int,
    stock: Int,
    category: String
  )
  
  // 商品IDと商品情報のマップ
  val products = Map(
    "P001" -> Product("ノートPC", 80000, 5, "電子機器"),
    "P002" -> Product("マウス", 2000, 20, "アクセサリ"),
    "P003" -> Product("キーボード", 5000, 15, "アクセサリ"),
    "P004" -> Product("モニター", 30000, 8, "電子機器")
  )
  
  // カテゴリ別に商品を表示
  println("=== カテゴリ: 電子機器 ===")
  products.filter { case (_, product) =>
    product.category == "電子機器"
  }.foreach { case (id, product) =>
    println(f"$id: ${product.name}%-15s ${product.price}%,d円 (在庫: ${product.stock})")
  }
  
  // 在庫が少ない商品
  println("\n=== 在庫警告（10個以下）===")
  products.filter(_._2.stock <= 10).foreach { case (id, product) =>
    println(s"⚠️ $id: ${product.name} - 残り${product.stock}個")
  }
}
```

## 実践例：図書館管理システム

```scala
// LibrarySystem.scala
@main def librarySystem(): Unit = {
  // 本の情報
  case class Book(
    title: String,
    author: String,
    isbn: String,
    available: Boolean = true
  )
  
  // 貸出記録
  case class Rental(
    bookIsbn: String,
    userId: String,
    rentDate: String,
    returnDate: Option[String] = None
  )
  
  // データベース
  var books = Map(
    "978-4-123456-78-9" -> Book("Scalaプログラミング", "山田太郎", "978-4-123456-78-9"),
    "978-4-234567-89-0" -> Book("関数型入門", "田中花子", "978-4-234567-89-0"),
    "978-4-345678-90-1" -> Book("型安全の極意", "佐藤次郎", "978-4-345678-90-1")
  )
  
  var rentals = List[Rental]()
  
  // 本を借りる
  def rentBook(isbn: String, userId: String, date: String): Unit = {
    books.get(isbn) match {
      case Some(book) if book.available =>
        books = books + (isbn -> book.copy(available = false))
        rentals = Rental(isbn, userId, date) :: rentals
        println(s"✓ 「${book.title}」を貸出しました")
      case Some(book) =>
        println(s"❌ 「${book.title}」は貸出中です")
      case None =>
        println(s"❌ ISBN: $isbn の本は見つかりません")
    }
  }
  
  // 本を返す
  def returnBook(isbn: String, date: String): Unit = {
    books.get(isbn) match {
      case Some(book) if !book.available =>
        books = books + (isbn -> book.copy(available = true))
        // 貸出記録を更新
        rentals = rentals.map { rental =>
          if (rental.bookIsbn == isbn && rental.returnDate.isEmpty)
            rental.copy(returnDate = Some(date))
          else
            rental
        }
        println(s"✓ 「${book.title}」を返却しました")
      case Some(book) =>
        println(s"❌ 「${book.title}」は貸出されていません")
      case None =>
        println(s"❌ ISBN: $isbn の本は見つかりません")
    }
  }
  
  // 利用状況を表示
  def showStatus(): Unit = {
    println("\n=== 蔵書一覧 ===")
    books.foreach { case (isbn, book) =>
      val status = if (book.available) "貸出可能" else "貸出中"
      println(f"${book.title}%-20s by ${book.author}%-10s [$status]")
    }
    
    println("\n=== 現在の貸出 ===")
    rentals.filter(_.returnDate.isEmpty).foreach { rental =>
      books.get(rental.bookIsbn).foreach { book =>
        println(s"${book.title} -> ${rental.userId} (${rental.rentDate}～)")
      }
    }
  }
  
  // 使ってみる
  showStatus()
  
  println("\n--- 貸出処理 ---")
  rentBook("978-4-123456-78-9", "U001", "2024-01-15")
  rentBook("978-4-234567-89-0", "U002", "2024-01-15")
  rentBook("978-4-123456-78-9", "U003", "2024-01-16")  // すでに貸出中
  
  println("\n--- 返却処理 ---")
  returnBook("978-4-123456-78-9", "2024-01-20")
  
  showStatus()
}
```

## グループ化と集計

### groupByを使った分類

```scala
// GroupingData.scala
@main def groupingData(): Unit = {
  // 従業員データ
  case class Employee(
    name: String,
    department: String,
    salary: Int,
    years: Int
  )
  
  val employees = List(
    Employee("田中", "営業", 400000, 5),
    Employee("山田", "開発", 500000, 3),
    Employee("佐藤", "営業", 450000, 7),
    Employee("鈴木", "開発", 550000, 8),
    Employee("高橋", "人事", 380000, 2),
    Employee("渡辺", "開発", 480000, 4)
  )
  
  // 部署ごとにグループ化
  val byDepartment = employees.groupBy(_.department)
  
  println("=== 部署別人数 ===")
  byDepartment.foreach { case (dept, emps) =>
    println(s"$dept: ${emps.length}人")
  }
  
  // 部署ごとの平均給与
  println("\n=== 部署別平均給与 ===")
  byDepartment.foreach { case (dept, emps) =>
    val avgSalary = emps.map(_.salary).sum / emps.length
    println(f"$dept: ${avgSalary}%,d円")
  }
  
  // 経験年数でグループ化
  val byExperience = employees.groupBy { emp =>
    if emp.years < 3 then "新人"
    else if emp.years < 7 then "中堅"
    else "ベテラン"
  }
  
  println("\n=== 経験別分布 ===")
  byExperience.foreach { case (level, emps) =>
    println(s"$level: ${emps.map(_.name).mkString(", ")}")
  }
```

### 複数キーでの集計

```scala
// MultiKeyAggregation.scala
@main def multiKeyAggregation(): Unit = {
  // 売上データ
  case class Sale(
    date: String,
    product: String,
    category: String,
    amount: Int
  )
  
  val sales = List(
    Sale("2024-01-01", "コーヒー", "飲み物", 300),
    Sale("2024-01-01", "サンドイッチ", "食べ物", 500),
    Sale("2024-01-01", "コーヒー", "飲み物", 300),
    Sale("2024-01-02", "紅茶", "飲み物", 250),
    Sale("2024-01-02", "ケーキ", "食べ物", 400),
    Sale("2024-01-02", "コーヒー", "飲み物", 300)
  )
  
  // 日付ごとの売上
  val dailySales = sales.groupBy(_.date).map { case (date, daySales) =>
    date -> daySales.map(_.amount).sum
  }
  
  println("=== 日別売上 ===")
  dailySales.toList.sorted.foreach { case (date, total) =>
    println(f"$date: ${total}%,d円")
  }
  
  // カテゴリ別売上
  val categorySales = sales.groupBy(_.category).map { case (cat, catSales) =>
    cat -> catSales.map(_.amount).sum
  }
  
  println("\n=== カテゴリ別売上 ===")
  categorySales.foreach { case (category, total) =>
    println(f"$category: ${total}%,d円")
  }
  
  // 商品別の販売回数と売上
  val productStats = sales.groupBy(_.product).map { case (product, productSales) =>
    val count = productSales.length
    val total = productSales.map(_.amount).sum
    (product, count, total)
  }
  
  println("\n=== 商品別統計 ===")
  productStats.foreach { case (product, count, total) =>
    println(f"$product: $count回 ${total}%,d円")
  }
```

## 高度なマップ操作

### マップの変換とマッピング

```scala
// AdvancedMapOperations.scala
@main def advancedMapOperations(): Unit = {
  // 元データ：生徒ID -> (名前, 点数リスト)
  val students = Map(
    "S001" -> ("田中", List(85, 90, 78)),
    "S002" -> ("山田", List(92, 88, 95)),
    "S003" -> ("佐藤", List(78, 82, 80))
  )
  
  // 平均点を計算してマップに変換
  val averages = students.map { case (id, (name, scores)) =>
    val avg = scores.sum.toDouble / scores.length
    (id, (name, avg))
  }
  
  println("=== 平均点 ===")
  averages.foreach { case (id, (name, avg)) =>
    println(f"$id: $name - $avg%.1f点")
  }
  
  // 成績ランクを追加
  val withRank = averages.map { case (id, (name, avg)) =>
    val rank = avg match
      case a if a >= 90 => "A"
      case a if a >= 80 => "B"
      case a if a >= 70 => "C"
      case _ => "D"
    (id, (name, avg, rank))
  }
  
  println("\n=== 成績ランク ===")
  withRank.foreach { case (id, (name, avg, rank)) =>
    println(f"$id: $name - $avg%.1f点 [ランク$rank]")
  }
```

### マップのマージ戦略

```scala
// MapMergeStrategies.scala
@main def mapMergeStrategies(): Unit = {
  // 店舗Aの在庫
  val storeA = Map(
    "りんご" -> 50,
    "バナナ" -> 30,
    "オレンジ" -> 40
  )
  
  // 店舗Bの在庫
  val storeB = Map(
    "りんご" -> 30,
    "バナナ" -> 50,
    "ぶどう" -> 20
  )
  
  // 戦略1：合計する
  val totalStock = (storeA.keySet ++ storeB.keySet).map { fruit =>
    val stockA = storeA.getOrElse(fruit, 0)
    val stockB = storeB.getOrElse(fruit, 0)
    fruit -> (stockA + stockB)
  }.toMap
  
  println("=== 合計在庫 ===")
  totalStock.foreach { case (fruit, total) =>
    println(s"$fruit: $total個")
  }
  
  // 戦略2：店舗別に保持
  val allStores = Map(
    "店舗A" -> storeA,
    "店舗B" -> storeB
  )
  
  println("\n=== 店舗別在庫 ===")
  allStores.foreach { case (store, inventory) =>
    println(s"$store:")
    inventory.foreach { case (fruit, count) =>
      println(s"  $fruit: $count個")
    }
  }
  
  // 戦略3：商品ごとに店舗情報を保持
  val byProduct = (storeA.keySet ++ storeB.keySet).map { fruit =>
    val stores = Map(
      "店舗A" -> storeA.getOrElse(fruit, 0),
      "店舗B" -> storeB.getOrElse(fruit, 0)
    ).filter(_._2 > 0)  // 在庫0は除外
    fruit -> stores
  }.toMap
  
  println("\n=== 商品別の店舗在庫 ===")
  byProduct.foreach { case (fruit, stores) =>
    println(s"$fruit: ${stores.map{case(s,c) => s"$s($c個)"}.mkString(", ")}")
  }
```

## 実用例：ショッピングカートシステム

```scala
// ShoppingCartSystem.scala
@main def shoppingCartSystem(): Unit = {
  // 商品カタログ
  val catalog = Map(
    "P001" -> ("Tシャツ", 2000),
    "P002" -> ("ジーンズ", 5000),
    "P003" -> ("スニーカー", 8000),
    "P004" -> ("キャップ", 3000)
  )
  
  // ユーザーのカート（ユーザーID -> 商品IDと数量のマップ）
  var carts = Map[String, Map[String, Int]]()
  
  // カートに商品を追加
  def addToCart(userId: String, productId: String, quantity: Int): Unit =
    if catalog.contains(productId) then
      val userCart = carts.getOrElse(userId, Map())
      val currentQty = userCart.getOrElse(productId, 0)
      val updatedCart = userCart + (productId -> (currentQty + quantity))
      carts = carts + (userId -> updatedCart)
      
      val (name, _) = catalog(productId)
      println(s"✓ $name を${quantity}個カートに追加しました")
    else
      println(s"❌ 商品ID: $productId は存在しません")
  
  // カートの中身を表示
  def showCart(userId: String): Unit =
    carts.get(userId) match
      case Some(cart) if cart.nonEmpty =>
        println(s"\n=== $userId さんのカート ===")
        var total = 0
        cart.foreach { case (productId, quantity) =>
          val (name, price) = catalog(productId)
          val subtotal = price * quantity
          total += subtotal
          println(f"$name%-15s: ${price}%,d円 × $quantity = ${subtotal}%,d円")
        }
        println(f"合計: ${total}%,d円")
        
      case _ =>
        println(s"\n$userId さんのカートは空です")
  
  // クーポン適用
  def applyCoupon(userId: String, discount: Double): Int =
    carts.get(userId) match
      case Some(cart) =>
        val total = cart.map { case (productId, quantity) =>
          val (_, price) = catalog(productId)
          price * quantity
        }.sum
        val discounted = (total * (1 - discount)).toInt
        println(f"\n💰 ${(discount * 100).toInt}%%クーポン適用: ${total}%,d円 → ${discounted}%,d円")
        discounted
        
      case None =>
        println("カートが空です")
        0
  
  // 使ってみる
  println("=== 商品カタログ ===")
  catalog.foreach { case (id, (name, price)) =>
    println(f"$id: $name%-15s ${price}%,d円")
  }
  
  // ユーザー1の買い物
  addToCart("user1", "P001", 2)  // Tシャツ2枚
  addToCart("user1", "P003", 1)  // スニーカー1足
  showCart("user1")
  
  // ユーザー2の買い物
  addToCart("user2", "P002", 1)  // ジーンズ1本
  addToCart("user2", "P004", 2)  // キャップ2個
  addToCart("user2", "P001", 1)  // Tシャツ1枚
  showCart("user2")
  
  // クーポン適用
  applyCoupon("user1", 0.1)  // 10%オフ
  applyCoupon("user2", 0.2)  // 20%オフ
```

## パフォーマンスを考える

```scala
// MapPerformance.scala
@main def mapPerformance(): Unit = {
  import scala.collection.mutable
  
  // イミュータブル vs ミュータブル
  
  // イミュータブル（小規模データに最適）
  var immutableMap = Map[String, Int]()
  for (i <- 1 to 100) {
    immutableMap = immutableMap + (s"key$i" -> i)
  }
  
  // ミュータブル（大規模データに最適）
  val mutableMap = mutable.Map[String, Int]()
  for (i <- 1 to 10000) {
    mutableMap(s"key$i") = i
  }
  
  println(s"イミュータブル: ${immutableMap.size}要素")
  println(s"ミュータブル: ${mutableMap.size}要素")
  
  // 効率的な初期化
  // 悪い例：一つずつ追加
  var slowMap = Map[Int, String]()
  for (i <- 1 to 100) {
    slowMap = slowMap + (i -> s"value$i")
  }
  
  // 良い例：一度に作成
  val fastMap = (1 to 100).map(i => i -> s"value$i").toMap
  
  // withDefaultValueで安全かつ高速に
  val scoreMap = Map(
    "太郎" -> 85,
    "花子" -> 92
  ).withDefaultValue(0)
  
  println(s"\n存在する: ${scoreMap("太郎")}")
  println(s"存在しない: ${scoreMap("次郎")}")  // 0が返る
```

## 練習してみよう！

### 練習1：生徒管理システム

生徒ID、名前、学年、成績（科目名と点数のマップ）を管理するシステムを作ってください。
- 生徒の追加
- 成績の更新
- 学年別の平均点表示

### 練習2：在庫管理の拡張

商品の在庫を店舗別、カテゴリ別に管理するシステムを作ってください。
- 店舗間の在庫移動
- カテゴリ別の在庫集計
- 在庫不足アラート

### 練習3：予約システム

会議室の予約を管理するシステムを作ってください。
- 日付と時間帯での予約
- 予約の重複チェック
- 利用統計の表示

## この章のまとめ

マップを使った高度なデータ管理について学びました！

### できるようになったこと

✅ **複雑なデータ構造**
- ネストしたマップの操作
- マップとケースクラスの組み合わせ
- 多次元のデータ管理

✅ **データの集計と分析**
- groupByによる分類
- 複数キーでの集計
- 統計情報の算出

✅ **実践的なシステム**
- 図書館管理システム
- ショッピングカート
- 在庫管理

✅ **高度な操作**
- マップの変換
- マージ戦略
- パフォーマンスの最適化

### マップ活用のコツ

1. **適切なキーの選択**
    - ユニークで変わらない値
    - 検索しやすい値
    - 意味のある識別子

2. **データ構造の設計**
    - 単純から始める
    - 必要に応じて複雑化
    - 読みやすさを重視

3. **安全性の確保**
    - getOrElseの活用
    - デフォルト値の設定
    - エラーハンドリング

### 次の部では...

第IV部では、プログラムに「判断力」を持たせる方法を学びます。条件分岐やパターンマッチングで、もっと賢いプログラムを作りましょう！

### 最後に

マップは「データの宝箱」です。うまく使えば、複雑なデータも整理整頓できます。これまでに学んだリスト、タプル、マップを組み合わせて、どんなデータ構造でも扱えるようになりました。すごい進歩ですね！