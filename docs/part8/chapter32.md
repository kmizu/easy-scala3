# 第32章 効率的なコレクション操作

## はじめに

大量の書類を整理するとき、一枚ずつ処理するより、まとめて処理した方が効率的ですよね。似た書類をグループ化したり、不要なものを先に除外したり、必要な情報だけを抜き出したり。

プログラミングでも同じです。大量のデータを扱うとき、効率的な操作方法を知っているかどうかで、処理速度が大きく変わります。この章で、プロのテクニックを身につけましょう！

## 遅延評価とビュー

### ビューの基本

```scala
// ViewBasics.scala
@main def viewBasics(): Unit =
  // 通常の操作（即座に評価）
  println("=== 通常の操作（即座評価） ===")
  
  val numbers = (1 to 1000000).toList
  
  val result1 = numbers
    .map { n =>
      println(s"map: $n")
      n * 2
    }
    .filter { n =>
      println(s"filter: $n")
      n > 10
    }
    .take(5)
  
  println(s"結果: $result1")
  println("（すべての要素が処理された！）")
  
  // ビューを使った操作（遅延評価）
  println("\n=== ビューを使った操作（遅延評価） ===")
  
  val result2 = numbers.view
    .map { n =>
      println(s"map: $n")
      n * 2
    }
    .filter { n =>
      println(s"filter: $n")
      n > 10
    }
    .take(5)
    .toList
  
  println(s"結果: $result2")
  println("（必要な分だけ処理された！）")
  
  // パフォーマンス比較
  println("\n=== パフォーマンス比較 ===")
  
  def measureTime[T](name: String)(block: => T): T =
    val start = System.nanoTime()
    val result = block
    val end = System.nanoTime()
    println(f"$name: ${(end - start) / 1000000.0}%.2f ms")
    result
  
  val bigList = (1 to 10000000).toList
  
  measureTime("通常の処理") {
    bigList
      .map(_ * 2)
      .filter(_ % 2 == 0)
      .map(_ + 1)
      .take(100)
  }
  
  measureTime("ビューを使った処理") {
    bigList.view
      .map(_ * 2)
      .filter(_ % 2 == 0)
      .map(_ + 1)
      .take(100)
      .toList
  }
```

### 実践的なビューの活用

```scala
// PracticalViews.scala
@main def practicalViews(): Unit =
  import scala.io.Source
  
  // ファイル処理の例（仮想的なログファイル）
  val logLines = List(
    "2024-01-01 10:00:00 INFO User login: user1",
    "2024-01-01 10:00:01 ERROR Failed to connect to database",
    "2024-01-01 10:00:02 INFO User action: view_page",
    "2024-01-01 10:00:03 WARN Slow query detected",
    "2024-01-01 10:00:04 ERROR Null pointer exception",
    "2024-01-01 10:00:05 INFO User logout: user1"
  )
  
  // エラーログだけを抽出（最初の3件）
  val errors = logLines.view
    .filter(_.contains("ERROR"))
    .map { line =>
      val parts = line.split(" ", 4)
      (parts(0), parts(1), parts(3))
    }
    .take(3)
    .toList
  
  println("=== エラーログ ===")
  errors.foreach { case (date, time, message) =>
    println(s"$date $time: $message")
  }
  
  // 無限シーケンスの処理
  println("\n=== 無限シーケンス ===")
  
  def naturals: LazyList[Int] = LazyList.from(1)
  
  val perfectSquares = naturals.view
    .map(n => n * n)
    .filter(_ % 10 == 1)  // 1の位が1
    .take(5)
    .toList
  
  println(s"1の位が1の平方数: $perfectSquares")
  
  // 複雑な変換チェーン
  case class Transaction(id: Int, amount: Double, category: String)
  
  val transactions = List(
    Transaction(1, 100.0, "food"),
    Transaction(2, 50.0, "transport"),
    Transaction(3, 200.0, "food"),
    Transaction(4, 1000.0, "rent"),
    Transaction(5, 30.0, "food"),
    Transaction(6, 80.0, "utilities")
  )
  
  // カテゴリ別の統計（ビューを使って効率的に）
  val foodStats = transactions.view
    .filter(_.category == "food")
    .map(_.amount)
    .foldLeft((0.0, 0)) { case ((sum, count), amount) =>
      (sum + amount, count + 1)
    }
  
  val (totalFood, countFood) = foodStats
  println(f"\n食費: 合計 $$${totalFood}%.2f, 平均 $$${totalFood / countFood}%.2f")
```

## 効率的な変換操作

### collectとpartition

```scala
// EfficientTransformations.scala
@main def efficientTransformations(): Unit =
  // collect：フィルタとマップを同時に
  println("=== collect（部分関数） ===")
  
  val mixed: List[Any] = List(1, "hello", 2.5, 3, "world", 4.7, 5)
  
  // 非効率な方法
  val integers1 = mixed
    .filter(_.isInstanceOf[Int])
    .map(_.asInstanceOf[Int])
  
  // 効率的な方法
  val integers2 = mixed.collect {
    case n: Int => n
  }
  
  println(s"整数のみ: $integers2")
  
  // より複雑な例
  val strings = mixed.collect {
    case s: String => s.toUpperCase
    case n: Int => s"数値: $n"
  }
  
  println(s"変換結果: $strings")
  
  // partition：条件で2つに分割
  println("\n=== partition ===")
  
  val numbers = List(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
  val (evens, odds) = numbers.partition(_ % 2 == 0)
  
  println(s"偶数: $evens")
  println(s"奇数: $odds")
  
  // groupBy：グループ化
  println("\n=== groupBy ===")
  
  case class Student(name: String, grade: Int, score: Int)
  
  val students = List(
    Student("太郎", 1, 85),
    Student("花子", 2, 92),
    Student("次郎", 1, 78),
    Student("美咲", 3, 88),
    Student("健太", 2, 95),
    Student("さくら", 1, 90)
  )
  
  val byGrade = students.groupBy(_.grade)
  
  println("学年別:")
  byGrade.foreach { case (grade, students) =>
    val avg = students.map(_.score).sum.toDouble / students.length
    println(f"  $grade 年生: ${students.map(_.name).mkString(", ")} (平均: $avg%.1f)")
  }
  
  // groupMapReduce：グループ化して集計
  val gradeAverages = students.groupMapReduce(
    _.grade
  )(
    _.score
  )(
    (sum, score) => sum + score
  ).map { case (grade, total) =>
    val count = students.count(_.grade == grade)
    (grade, total.toDouble / count)
  }
  
  println(s"\n学年別平均点: $gradeAverages")
```

### フォールド操作の最適化

```scala
// OptimizedFolding.scala
@main def optimizedFolding(): Unit =
  // 基本的なfold
  println("=== 基本的なfold ===")
  
  val numbers = List(1, 2, 3, 4, 5)
  
  val sum = numbers.foldLeft(0)(_ + _)
  val product = numbers.foldLeft(1)(_ * _)
  
  println(s"合計: $sum")
  println(s"積: $product")
  
  // 複雑な集計
  case class Stats(count: Int, sum: Double, min: Double, max: Double):
    def mean: Double = if count > 0 then sum / count else 0.0
    def +(value: Double): Stats = Stats(
      count + 1,
      sum + value,
      math.min(min, value),
      math.max(max, value)
    )
  
  val measurements = List(23.5, 18.2, 25.1, 19.8, 22.3, 24.6)
  
  val stats = measurements.foldLeft(
    Stats(0, 0.0, Double.MaxValue, Double.MinValue)
  )(_ + _)
  
  println(f"\n統計: 件数=${stats.count}, 平均=${stats.mean}%.1f, " +
          f"最小=${stats.min}%.1f, 最大=${stats.max}%.1f")
  
  // foldLeftとfoldRightの違い
  println("\n=== foldLeft vs foldRight ===")
  
  // リスト構築
  val list1 = (1 to 5).foldLeft(List.empty[Int])((acc, n) => n :: acc)
  val list2 = (1 to 5).foldRight(List.empty[Int])((n, acc) => n :: acc)
  
  println(s"foldLeft: $list1 （逆順）")
  println(s"foldRight: $list2 （正順）")
  
  // scanで中間結果も保持
  println("\n=== scan（累積結果） ===")
  
  val runningSum = numbers.scanLeft(0)(_ + _)
  val runningProduct = numbers.scanLeft(1)(_ * _)
  
  println(s"累積和: $runningSum")
  println(s"累積積: $runningProduct")
  
  // 実用例：残高計算
  case class Transaction(date: String, amount: Double)
  
  val transactions = List(
    Transaction("2024-01-01", 1000.0),   // 入金
    Transaction("2024-01-02", -200.0),   // 出金
    Transaction("2024-01-03", -150.0),   // 出金
    Transaction("2024-01-04", 500.0),    // 入金
    Transaction("2024-01-05", -300.0)    // 出金
  )
  
  val initialBalance = 5000.0
  val balances = transactions.scanLeft((initialBalance, "初期残高")) {
    case ((balance, _), transaction) =>
      (balance + transaction.amount, transaction.date)
  }
  
  println("\n残高推移:")
  balances.foreach { case (balance, date) =>
    println(f"$date%-12s: ¥$balance%,.0f")
  }
```

## メモリ効率の良い操作

### イテレータの活用

```scala
// IteratorUsage.scala
@main def iteratorUsage(): Unit =
  // イテレータの基本
  println("=== イテレータ（一度だけ走査） ===")
  
  val iter = Iterator(1, 2, 3, 4, 5)
  
  println(s"最初の要素: ${iter.next()}")
  println(s"残りの合計: ${iter.sum}")
  // println(iter.toList)  // エラー！既に消費済み
  
  // 大きなファイルの処理
  println("\n=== 大量データの処理 ===")
  
  // 仮想的な大きなデータソース
  def bigDataSource: Iterator[String] = 
    Iterator.tabulate(1000000)(i => s"Record $i")
  
  // メモリ効率的な処理
  val result = bigDataSource
    .filter(_.contains("999"))
    .map(_.split(" ")(1))
    .take(10)
    .toList
  
  println(s"999を含む最初の10件: $result")
  
  // グループ化しながら処理
  println("\n=== バッチ処理 ===")
  
  def processInBatches[A, B](
    data: Iterator[A],
    batchSize: Int
  )(process: List[A] => List[B]): Iterator[B] =
    data.grouped(batchSize).flatMap(batch => process(batch))
  
  val numbers = Iterator.range(1, 101)
  val batchResults = processInBatches(numbers, 10) { batch =>
    val sum = batch.sum
    val avg = sum.toDouble / batch.length
    List(s"Batch: ${batch.head}-${batch.last}, Sum: $sum, Avg: $avg")
  }
  
  println("バッチ処理結果:")
  batchResults.take(5).foreach(println)
  
  // sliding window
  println("\n=== スライディングウィンドウ ===")
  
  val timeSeries = List(10, 12, 15, 14, 18, 20, 19, 22, 25, 23)
  val movingAverage = timeSeries.sliding(3).map { window =>
    window.sum.toDouble / window.length
  }.toList
  
  println(s"元のデータ: $timeSeries")
  println(s"3点移動平均: ${movingAverage.map(a => f"$a%.1f")}")
```

### バッファリングとストリーミング

```scala
// BufferingAndStreaming.scala
@main def bufferingAndStreaming(): Unit =
  import scala.collection.mutable
  
  // バッファを使った効率的な処理
  println("=== バッファリング ===")
  
  class EfficientProcessor[A]:
    private val buffer = mutable.ArrayBuffer[A]()
    private val bufferSize = 1000
    
    def process(item: A)(flush: List[A] => Unit): Unit =
      buffer += item
      if buffer.size >= bufferSize then
        flush(buffer.toList)
        buffer.clear()
    
    def flush(flush: List[A] => Unit): Unit =
      if buffer.nonEmpty then
        flush(buffer.toList)
        buffer.clear()
  
  // 使用例
  val processor = new EfficientProcessor[Int]
  var totalProcessed = 0
  
  // データを少しずつ処理
  (1 to 2500).foreach { n =>
    processor.process(n) { batch =>
      println(s"バッチ処理: ${batch.length}件")
      totalProcessed += batch.length
    }
  }
  
  // 残りをフラッシュ
  processor.flush { batch =>
    println(s"最終バッチ: ${batch.length}件")
    totalProcessed += batch.length
  }
  
  println(s"合計処理数: $totalProcessed")
  
  // ストリーミング集計
  println("\n=== ストリーミング集計 ===")
  
  class StreamingStats:
    private var count = 0L
    private var sum = 0.0
    private var sumOfSquares = 0.0
    
    def add(value: Double): Unit =
      count += 1
      sum += value
      sumOfSquares += value * value
    
    def mean: Double = if count > 0 then sum / count else 0.0
    
    def variance: Double = 
      if count > 0 then
        (sumOfSquares / count) - (mean * mean)
      else 0.0
    
    def stdDev: Double = math.sqrt(variance)
    
    override def toString: String =
      f"Count: $count, Mean: $mean%.2f, StdDev: $stdDev%.2f"
  
  val stats = new StreamingStats
  
  // 大量のデータをストリーミング処理
  Iterator.tabulate(100000) { _ =>
    scala.util.Random.nextGaussian() * 10 + 50
  }.foreach(stats.add)
  
  println(s"ストリーミング統計: $stats")
```

## 並列コレクション

```scala
// ParallelCollections.scala
@main def parallelCollections(): Unit =
  import scala.collection.parallel.CollectionConverters._
  
  // 並列処理の基本
  println("=== 並列処理 ===")
  
  val numbers = (1 to 10000000).toVector
  
  def isPrime(n: Int): Boolean =
    if n <= 1 then false
    else if n <= 3 then true
    else if n % 2 == 0 || n % 3 == 0 then false
    else
      var i = 5
      while i * i <= n do
        if n % i == 0 || n % (i + 2) == 0 then return false
        i += 6
      true
  
  // 通常処理
  val start1 = System.currentTimeMillis()
  val primes1 = numbers.filter(isPrime).length
  val time1 = System.currentTimeMillis() - start1
  
  // 並列処理
  val start2 = System.currentTimeMillis()
  val primes2 = numbers.par.filter(isPrime).length
  val time2 = System.currentTimeMillis() - start2
  
  println(f"通常処理: $primes1 個の素数, $time1 ms")
  println(f"並列処理: $primes2 個の素数, $time2 ms")
  println(f"高速化: ${time1.toDouble / time2}%.2f 倍")
  
  // 並列処理の注意点
  println("\n=== 並列処理の注意点 ===")
  
  // 副作用のある操作は危険
  var counter1 = 0
  (1 to 10000).foreach { _ =>
    counter1 += 1  // 順次処理なので正確
  }
  
  var counter2 = 0
  (1 to 10000).par.foreach { _ =>
    counter2 += 1  // 並列処理で競合状態！
  }
  
  println(s"順次カウント: $counter1")
  println(s"並列カウント: $counter2 （不正確！）")
  
  // 正しい並列集計
  val sum = (1 to 10000).par.sum
  println(s"並列合計: $sum （正確）")
  
  // 並列処理が有効な場合
  println("\n=== 並列処理の効果的な使用 ===")
  
  case class Point(x: Double, y: Double):
    def distanceToOrigin: Double = math.sqrt(x * x + y * y)
  
  val points = Vector.tabulate(1000000) { i =>
    Point(scala.util.Random.nextDouble() * 100, 
          scala.util.Random.nextDouble() * 100)
  }
  
  // 重い計算を並列化
  val start3 = System.currentTimeMillis()
  val avgDistance = points.par
    .map(_.distanceToOrigin)
    .sum / points.length
  val time3 = System.currentTimeMillis() - start3
  
  println(f"平均距離: $avgDistance%.2f ($time3 ms)")
```

## 実践例：データ分析パイプライン

```scala
// DataAnalysisPipeline.scala
@main def dataAnalysisPipeline(): Unit =
  import java.time.LocalDate
  import scala.util.Random
  
  // サンプルデータ：売上記録
  case class SalesRecord(
    date: LocalDate,
    productId: String,
    quantity: Int,
    unitPrice: Double,
    customerId: String,
    region: String
  ):
    def amount: Double = quantity * unitPrice
  
  // 大量のダミーデータ生成
  def generateSalesData(count: Int): Iterator[SalesRecord] =
    val products = Vector("P001", "P002", "P003", "P004", "P005")
    val regions = Vector("東京", "大阪", "名古屋", "福岡", "札幌")
    val baseDate = LocalDate.of(2024, 1, 1)
    
    Iterator.tabulate(count) { i =>
      SalesRecord(
        date = baseDate.plusDays(Random.nextInt(365)),
        productId = products(Random.nextInt(products.length)),
        quantity = Random.nextInt(10) + 1,
        unitPrice = (Random.nextInt(50) + 1) * 100.0,
        customerId = f"C${Random.nextInt(1000)}%04d",
        region = regions(Random.nextInt(regions.length))
      )
    }
  
  // 効率的なデータ分析
  println("=== データ分析パイプライン ===")
  
  val salesData = generateSalesData(100000)
  
  // 1. 地域別・月別の売上集計（ストリーミング処理）
  val regionMonthlyStats = salesData
    .map { record =>
      val month = record.date.getMonthValue
      ((record.region, month), record.amount)
    }
    .toList
    .groupMapReduce(_._1)(_._2)(_ + _)
  
  println("地域別・月別売上（一部）:")
  regionMonthlyStats
    .toList
    .sortBy(_._1)
    .take(10)
    .foreach { case ((region, month), amount) =>
      println(f"  $region - $month 月: ¥$amount%,.0f")
    }
  
  // 2. 商品別の売上ランキング（並列処理）
  val productRanking = generateSalesData(100000)
    .toVector
    .par
    .groupBy(_.productId)
    .mapValues { records =>
      val total = records.map(_.amount).sum
      val count = records.length
      (total, count)
    }
    .toList
    .sortBy(-_._2._1)
  
  println("\n商品別売上ランキング:")
  productRanking.foreach { case (productId, (total, count)) =>
    println(f"  $productId: ¥$total%,.0f ($count 件)")
  }
  
  // 3. 顧客セグメント分析（効率的なグループ化）
  case class CustomerStats(
    customerId: String,
    totalAmount: Double,
    orderCount: Int,
    avgOrderValue: Double,
    favoriteRegion: String
  )
  
  val customerStats = generateSalesData(100000)
    .toList
    .groupBy(_.customerId)
    .view  // ビューで遅延評価
    .map { case (customerId, records) =>
      val totalAmount = records.map(_.amount).sum
      val orderCount = records.length
      val avgOrderValue = totalAmount / orderCount
      val favoriteRegion = records
        .groupBy(_.region)
        .maxBy(_._2.length)
        ._1
      
      CustomerStats(
        customerId,
        totalAmount,
        orderCount,
        avgOrderValue,
        favoriteRegion
      )
    }
    .filter(_.orderCount >= 5)  // アクティブな顧客のみ
    .toList
    .sortBy(-_.totalAmount)
    .take(10)
  
  println("\n上位顧客:")
  customerStats.foreach { stats =>
    println(f"  ${stats.customerId}: " +
            f"¥${stats.totalAmount}%,.0f " +
            f"(${stats.orderCount}件, " +
            f"平均 ¥${stats.avgOrderValue}%,.0f, " +
            f"${stats.favoriteRegion})")
  }
```

## 練習してみよう！

### 練習1：ログ分析システム

大量のログファイルを効率的に分析するシステムを作ってください：
- エラーの頻度分析
- レスポンスタイムの統計
- 異常検知

### 練習2：リアルタイム集計

ストリーミングデータのリアルタイム集計を実装してください：
- 移動平均の計算
- トップN の更新
- 異常値の検出

### 練習3：大規模データ処理

メモリに収まらない大規模データを処理してください：
- 外部ソート
- 分散集計
- サンプリング

## この章のまとめ

効率的なコレクション操作の技術を習得しました！

### できるようになったこと

✅ **遅延評価の活用**
- ビューの使い方
- 必要な分だけ処理
- メモリ効率の改善

✅ **効率的な変換**
- collect の活用
- groupBy の最適化
- fold の使い分け

✅ **メモリ管理**
- イテレータの活用
- バッファリング
- ストリーミング処理

✅ **並列処理**
- 並列コレクション
- 注意点の理解
- 適切な使い分け

### 効率化のコツ

1. **測定してから最適化**
   - ボトルネックを特定
   - 実データで検証
   - 過度な最適化を避ける

2. **適切な手法を選ぶ**
   - データ量に応じて
   - 処理内容に応じて
   - メモリ制約を考慮

3. **読みやすさとのバランス**
   - 保守性を維持
   - コメントで意図を説明
   - チームで共有可能に

### 次の章では...

並行プログラミング入門について学びます。マルチコアの力を最大限に活用しましょう！

### 最後に

効率的なコレクション操作は「データ処理の極意」です。大量のデータも、適切な技術を使えば軽やかに処理できる。ビュー、イテレータ、並列処理...これらの道具を使いこなせば、どんな大きなデータも恐れることはありません。データの海を自在に泳ぐ技術を、あなたは手に入れました！