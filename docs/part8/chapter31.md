# 第31章 コレクションの選び方

## はじめに

料理をするとき、材料によって適切な道具を選びますよね。野菜を切るなら包丁、スープを混ぜるならお玉、パスタを茹でるなら大きな鍋。同じように、プログラミングでも扱うデータによって最適なコレクションを選ぶ必要があります。

この章では、Scalaの豊富なコレクションから、あなたのニーズにぴったりのものを選ぶ方法を学びましょう！

## コレクションの全体像

### コレクション階層

```scala
// CollectionHierarchy.scala
@main def collectionHierarchy(): Unit =
  // Scalaのコレクション階層
  println("=== コレクション階層 ===")
  println("Iterable")
  println("├── Seq（順序あり）")
  println("│   ├── IndexedSeq（インデックスアクセス高速）")
  println("│   │   ├── Vector")
  println("│   │   ├── Array")
  println("│   │   └── ArraySeq")
  println("│   └── LinearSeq（先頭アクセス高速）")
  println("│       ├── List")
  println("│       ├── LazyList")
  println("│       └── Queue")
  println("├── Set（重複なし）")
  println("│   ├── HashSet")
  println("│   ├── TreeSet")
  println("│   └── BitSet")
  println("└── Map（キーと値）")
  println("    ├── HashMap")
  println("    ├── TreeMap")
  println("    └── ListMap")
  
  // 基本的な性質の比較
  println("\n=== 基本的な性質 ===")
  
  // 順序の保持
  val list = List(3, 1, 4, 1, 5)
  val set = Set(3, 1, 4, 1, 5)
  
  println(s"List（順序保持、重複あり）: $list")
  println(s"Set（順序なし、重複なし）: $set")
  
  // インデックスアクセス
  val vector = Vector(10, 20, 30, 40, 50)
  println(s"\nVector[2] = ${vector(2)}  // O(log n)")
  
  // キーでのアクセス
  val map = Map("one" -> 1, "two" -> 2, "three" -> 3)
  println(s"Map(\"two\") = ${map("two")}  // O(1)")
```

### パフォーマンス特性

```scala
// PerformanceCharacteristics.scala
@main def performanceCharacteristics(): Unit =
  import scala.collection.mutable
  
  // パフォーマンス比較のヘルパー
  def measureTime[T](name: String)(block: => T): T =
    val start = System.nanoTime()
    val result = block
    val end = System.nanoTime()
    println(f"$name%-20s: ${(end - start) / 1000000.0}%.2f ms")
    result
  
  val size = 100000
  val range = 0 until size
  
  println("=== 作成時間 ===")
  
  val list = measureTime("List") {
    range.toList
  }
  
  val vector = measureTime("Vector") {
    range.toVector
  }
  
  val array = measureTime("Array") {
    range.toArray
  }
  
  val set = measureTime("Set") {
    range.toSet
  }
  
  println("\n=== ランダムアクセス ===")
  val indices = scala.util.Random.shuffle((0 until 1000).toList)
  
  measureTime("List（遅い）") {
    indices.foreach(i => list(i % size))
  }
  
  measureTime("Vector（速い）") {
    indices.foreach(i => vector(i % size))
  }
  
  measureTime("Array（最速）") {
    indices.foreach(i => array(i % size))
  }
  
  println("\n=== 先頭への追加 ===")
  
  measureTime("List（最速）") {
    var l = List.empty[Int]
    for i <- 0 until 1000 do
      l = i :: l
  }
  
  measureTime("Vector（速い）") {
    var v = Vector.empty[Int]
    for i <- 0 until 1000 do
      v = i +: v
  }
  
  measureTime("mutable.ListBuffer") {
    val buffer = mutable.ListBuffer.empty[Int]
    for i <- 0 until 1000 do
      i +=: buffer
  }
```

## 用途別コレクション選択ガイド

### 順序が重要な場合

```scala
// SequentialCollections.scala
@main def sequentialCollections(): Unit =
  // List：関数型スタイル、先頭への追加が高速
  println("=== List（イミュータブル、関数型） ===")
  
  val todoList = List("買い物", "掃除", "勉強")
  val newTodo = "運動" :: todoList  // O(1)
  
  println(s"元のリスト: $todoList")
  println(s"新しいリスト: $newTodo")
  
  // 再帰処理に適している
  def sum(list: List[Int]): Int = list match
    case Nil => 0
    case head :: tail => head + sum(tail)
  
  println(s"合計: ${sum(List(1, 2, 3, 4, 5))}")
  
  // Vector：バランスの取れた性能
  println("\n=== Vector（ランダムアクセスも高速） ===")
  
  val scores = Vector(85, 92, 78, 95, 88)
  val updated = scores.updated(2, 80)  // O(log n)
  
  println(s"元のスコア: $scores")
  println(s"更新後: $updated")
  
  // 大量データの処理に適している
  val bigData = Vector.tabulate(10000)(i => i * i)
  println(s"10番目: ${bigData(10)}, 9999番目: ${bigData(9999)}")
  
  // LazyList：遅延評価
  println("\n=== LazyList（無限リスト可能） ===")
  
  def fibonacci: LazyList[Int] =
    def fib(a: Int, b: Int): LazyList[Int] = a #:: fib(b, a + b)
    fib(0, 1)
  
  val fib10 = fibonacci.take(10).toList
  println(s"フィボナッチ数列: $fib10")
  
  // 必要な分だけ計算
  val primes = LazyList.from(2).filter { n =>
    (2 until n).forall(n % _ != 0)
  }
  
  println(s"最初の10個の素数: ${primes.take(10).toList}")
```

### 重複を避けたい場合

```scala
// SetCollections.scala
@main def setCollections(): Unit =
  // HashSet：高速な要素チェック
  println("=== HashSet（一般的な用途） ===")
  
  val tags = Set("scala", "programming", "functional", "scala")
  println(s"タグ（重複自動削除）: $tags")
  
  // 集合演算
  val skills1 = Set("Java", "Scala", "Python")
  val skills2 = Set("Scala", "Haskell", "Python")
  
  println(s"\n両方が持つスキル: ${skills1 & skills2}")
  println(s"どちらかが持つスキル: ${skills1 | skills2}")
  println(s"1だけが持つスキル: ${skills1 -- skills2}")
  
  // TreeSet：自動ソート
  println("\n=== TreeSet（順序付き） ===")
  
  val sortedNumbers = scala.collection.immutable.TreeSet(5, 2, 8, 1, 9, 3)
  println(s"自動ソート: $sortedNumbers")
  
  // 範囲クエリ
  val range = sortedNumbers.range(3, 8)
  println(s"3以上8未満: $range")
  
  // BitSet：Int専用、メモリ効率的
  println("\n=== BitSet（整数の集合） ===")
  
  val primesBits = scala.collection.immutable.BitSet(2, 3, 5, 7, 11, 13)
  val evenBits = scala.collection.immutable.BitSet(2, 4, 6, 8, 10, 12)
  
  println(s"素数: $primesBits")
  println(s"偶数: $evenBits")
  println(s"偶数かつ素数: ${primesBits & evenBits}")
```

### キーと値のペア

```scala
// MapCollections.scala
@main def mapCollections(): Unit =
  // HashMap：一般的な用途
  println("=== HashMap（高速アクセス） ===")
  
  val inventory = Map(
    "りんご" -> 10,
    "バナナ" -> 15,
    "オレンジ" -> 8
  )
  
  // 安全なアクセス
  println(s"りんごの在庫: ${inventory.get("りんご")}")
  println(s"ぶどうの在庫: ${inventory.getOrElse("ぶどう", 0)}")
  
  // 更新（新しいMapを作成）
  val updated = inventory + ("ぶどう" -> 20)
  println(s"更新後: $updated")
  
  // TreeMap：キーでソート
  println("\n=== TreeMap（順序付き） ===")
  
  val scores = scala.collection.immutable.TreeMap(
    "Charlie" -> 85,
    "Alice" -> 92,
    "Bob" -> 78
  )
  
  println("名前順のスコア:")
  scores.foreach { case (name, score) =>
    println(s"  $name: $score")
  }
  
  // MultiMap的な使い方
  println("\n=== 複数値のマップ ===")
  
  val tags = Map[String, Set[String]]()
    .withDefaultValue(Set.empty)
  
  def addTag(map: Map[String, Set[String]], key: String, tag: String) =
    map + (key -> (map(key) + tag))
  
  val taggedItems = List(
    ("doc1", "scala"),
    ("doc1", "tutorial"),
    ("doc2", "java"),
    ("doc2", "tutorial")
  ).foldLeft(tags) { case (map, (key, tag)) =>
    addTag(map, key, tag)
  }
  
  println(s"タグ付けされた項目: $taggedItems")
```

## 特殊な用途のコレクション

### 可変コレクション

```scala
// MutableCollections.scala
@main def mutableCollections(): Unit =
  import scala.collection.mutable
  
  // ArrayBuffer：可変長配列
  println("=== ArrayBuffer（動的配列） ===")
  
  val buffer = mutable.ArrayBuffer[String]()
  buffer += "最初"
  buffer += "次"
  buffer.insert(1, "間に挿入")
  
  println(s"バッファ: $buffer")
  
  // ListBuffer：効率的なリスト構築
  println("\n=== ListBuffer（リスト構築用） ===")
  
  val listBuffer = mutable.ListBuffer[Int]()
  for i <- 1 to 5 do
    listBuffer += i * i
  
  val immutableList = listBuffer.toList
  println(s"構築したリスト: $immutableList")
  
  // StringBuilder：文字列の効率的な構築
  println("\n=== StringBuilder ===")
  
  val sb = new StringBuilder
  sb.append("Hello")
  sb.append(" ")
  sb.append("World")
  sb.insert(5, ",")
  
  println(s"構築した文字列: ${sb.toString}")
  
  // Queue：FIFO
  println("\n=== Queue（先入れ先出し） ===")
  
  val queue = mutable.Queue[String]()
  queue.enqueue("タスク1")
  queue.enqueue("タスク2")
  queue.enqueue("タスク3")
  
  println(s"処理: ${queue.dequeue()}")
  println(s"残り: $queue")
  
  // Stack：LIFO
  println("\n=== Stack（後入れ先出し） ===")
  
  val stack = mutable.Stack[String]()
  stack.push("プレート1")
  stack.push("プレート2")
  stack.push("プレート3")
  
  println(s"取り出し: ${stack.pop()}")
  println(s"残り: $stack")
```

### 並行コレクション

```scala
// ConcurrentCollections.scala
@main def concurrentCollections(): Unit =
  import scala.collection.parallel.CollectionConverters._
  import scala.collection.concurrent
  
  // 並列コレクション
  println("=== 並列コレクション ===")
  
  val numbers = (1 to 1000000).toVector
  
  // 通常の処理
  val start1 = System.currentTimeMillis()
  val sum1 = numbers.map(_ * 2).sum
  val time1 = System.currentTimeMillis() - start1
  
  // 並列処理
  val start2 = System.currentTimeMillis()
  val sum2 = numbers.par.map(_ * 2).sum
  val time2 = System.currentTimeMillis() - start2
  
  println(f"通常処理: $time1%d ms (結果: $sum1)")
  println(f"並列処理: $time2%d ms (結果: $sum2)")
  
  // TrieMap：並行アクセス可能
  println("\n=== TrieMap（スレッドセーフ） ===")
  
  val trieMap = concurrent.TrieMap[String, Int]()
  
  // 複数スレッドから安全にアクセス
  val futures = (1 to 10).map { i =>
    scala.concurrent.Future {
      trieMap.put(s"key$i", i * 100)
      Thread.sleep(10)
      trieMap.get(s"key$i")
    }(scala.concurrent.ExecutionContext.global)
  }
  
  // 結果を待つ
  Thread.sleep(200)
  println(s"TrieMapの内容: ${trieMap.toMap}")
```

## コレクション選択のベストプラクティス

```scala
// CollectionBestPractices.scala
@main def collectionBestPractices(): Unit =
  // 1. デフォルトはイミュータブル
  println("=== イミュータブル優先 ===")
  
  // 良い例
  val goodList = List(1, 2, 3)
  val updated = 0 :: goodList  // 新しいリストを作成
  
  // 避けるべき例（必要な場合のみ）
  import scala.collection.mutable
  val badList = mutable.ListBuffer(1, 2, 3)
  badList.prepend(0)  // 元のリストを変更
  
  // 2. 適切なファクトリメソッド
  println("\n=== 効率的な構築 ===")
  
  // 良い例：Builderを使う
  val efficientVector = Vector.newBuilder[Int]
  for i <- 1 to 10000 do
    efficientVector += i
  val result = efficientVector.result()
  
  // 良い例：unfoldを使う
  val fibonacci = LazyList.unfold((0, 1)) { case (a, b) =>
    Some((a, (b, a + b)))
  }
  
  println(s"フィボナッチ: ${fibonacci.take(10).toList}")
  
  // 3. 変換の連鎖
  println("\n=== 効率的な変換 ===")
  
  val data = List(1, 2, 3, 4, 5)
  
  // 良い例：viewを使って遅延評価
  val efficient = data.view
    .map(_ * 2)
    .filter(_ > 5)
    .map(_ + 1)
    .toList
  
  println(s"効率的な結果: $efficient")
  
  // 4. 適切なコレクションの選択フロー
  println("\n=== 選択の指針 ===")
  
  def chooseCollection(requirements: Set[String]): String =
    if requirements.contains("順序保持") then
      if requirements.contains("高速ランダムアクセス") then
        "Vector"
      else if requirements.contains("先頭追加が多い") then
        "List"
      else
        "Vector（汎用的）"
    else if requirements.contains("重複なし") then
      if requirements.contains("順序付き") then
        "TreeSet"
      else
        "HashSet"
    else if requirements.contains("キー値ペア") then
      if requirements.contains("順序付き") then
        "TreeMap"
      else
        "HashMap"
    else
      "List（デフォルト）"
  
  val requirements1 = Set("順序保持", "高速ランダムアクセス")
  println(s"要件: $requirements1 → ${chooseCollection(requirements1)}")
  
  val requirements2 = Set("重複なし", "順序付き")
  println(s"要件: $requirements2 → ${chooseCollection(requirements2)}")
```

## 実践例：アプリケーションでの使い分け

```scala
// RealWorldExample.scala
@main def realWorldExample(): Unit =
  import scala.collection.mutable
  
  // ユーザー管理システムの例
  case class User(id: Int, name: String, email: String, tags: Set[String])
  
  class UserRepository:
    // ID検索用：HashMap（O(1)検索）
    private val usersById = mutable.HashMap[Int, User]()
    
    // メール検索用：HashMap（一意性保証）
    private val usersByEmail = mutable.HashMap[String, User]()
    
    // タグ検索用：MultiMap的な構造
    private val usersByTag = mutable.HashMap[String, mutable.Set[Int]]()
      .withDefaultValue(mutable.Set.empty)
    
    // 最近アクセスしたユーザー：LinkedHashSet（順序保持）
    private val recentlyAccessed = mutable.LinkedHashSet[Int]()
    private val maxRecent = 10
    
    def addUser(user: User): Unit =
      usersById(user.id) = user
      usersByEmail(user.email) = user
      
      user.tags.foreach { tag =>
        usersByTag(tag) = usersByTag(tag) + user.id
      }
    
    def findById(id: Int): Option[User] =
      val result = usersById.get(id)
      result.foreach { _ =>
        updateRecentlyAccessed(id)
      }
      result
    
    def findByEmail(email: String): Option[User] =
      usersByEmail.get(email)
    
    def findByTag(tag: String): List[User] =
      usersByTag(tag).toList.flatMap(usersById.get)
    
    private def updateRecentlyAccessed(id: Int): Unit =
      recentlyAccessed -= id  // 既存のものを削除
      recentlyAccessed += id  // 最後に追加
      
      if recentlyAccessed.size > maxRecent then
        recentlyAccessed -= recentlyAccessed.head
    
    def getRecentlyAccessed: List[User] =
      recentlyAccessed.toList.reverse.flatMap(usersById.get)
    
    def stats(): String =
      s"""ユーザー数: ${usersById.size}
         |タグ数: ${usersByTag.size}
         |最近アクセス: ${recentlyAccessed.size}
         |""".stripMargin
  
  // 使用例
  val repo = new UserRepository
  
  val users = List(
    User(1, "太郎", "taro@example.com", Set("scala", "java")),
    User(2, "花子", "hanako@example.com", Set("python", "scala")),
    User(3, "次郎", "jiro@example.com", Set("java", "kotlin"))
  )
  
  users.foreach(repo.addUser)
  
  println("=== ユーザー検索 ===")
  println(s"ID=2: ${repo.findById(2)}")
  println(s"Email=taro@example.com: ${repo.findByEmail("taro@example.com")}")
  println(s"Tag=scala: ${repo.findByTag("scala")}")
  
  // いくつかアクセス
  repo.findById(1)
  repo.findById(3)
  repo.findById(2)
  
  println(s"\n最近アクセス: ${repo.getRecentlyAccessed.map(_.name)}")
  println(s"\n${repo.stats()}")
```

## 練習してみよう！

### 練習1：キャッシュシステム

LRU（Least Recently Used）キャッシュを実装してください：
- 最大サイズの制限
- 最も使われていないものを削除
- O(1)でのアクセス

### 練習2：イベントストリーム

リアルタイムイベント処理システムを作ってください：
- イベントの順序保持
- 重複イベントの除去
- 時間窓での集計

### 練習3：グラフ構造

ソーシャルネットワークのグラフを表現してください：
- ユーザー間の関係
- 最短経路の探索
- コミュニティの検出

## この章のまとめ

様々なコレクションの特性と使い分けを学びました！

### できるようになったこと

✅ **コレクションの特性理解**
- パフォーマンス特性
- メモリ効率
- 操作の複雑度

✅ **用途別の選択**
- 順序重視：List、Vector
- 重複なし：Set系
- キー値：Map系

✅ **特殊用途**
- 可変コレクション
- 並行コレクション
- 特殊化コレクション

✅ **実践的な使い分け**
- 複数のコレクション組み合わせ
- パフォーマンス最適化
- メモリ効率の考慮

### コレクション選択のコツ

1. **デフォルトから始める**
   - List、Vector、Set、Map
   - イミュータブル優先
   - 必要に応じて特殊化

2. **パフォーマンスを測定**
   - 実際のデータで測定
   - ボトルネックを特定
   - 適切な最適化

3. **読みやすさも重要**
   - 意図が明確なコレクション
   - 過度な最適化を避ける
   - チームで共有できる選択

### 次の章では...

効率的なコレクション操作について学びます。大量のデータを扱うテクニックを習得しましょう！

### 最後に

コレクションは「データの入れ物」です。でも、ただの入れ物ではありません。それぞれに個性があり、得意不得意があります。料理人が食材に合わせて道具を選ぶように、プログラマーもデータに合わせてコレクションを選ぶ。この「選ぶ技術」が、効率的なプログラムを生み出す秘訣です！