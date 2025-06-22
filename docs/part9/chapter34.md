# 第34章 スレッドセーフを意識する

## はじめに

遊園地の人気アトラクションを想像してください。一度に一人しか乗れないなら問題ありませんが、複数の人が同時に乗ろうとしたらどうなるでしょう？安全ベルトの取り合い、座席の奪い合い、大混乱です。

プログラムでも同じです。複数のスレッドが同じデータに同時にアクセスすると、予期しない問題が起きます。この章では、そんな問題を防ぐ「スレッドセーフ」な設計を学びましょう！

## スレッドセーフとは？

### 非スレッドセーフの危険性

```scala
// ThreadUnsafeExample.scala
@main def threadUnsafeExample(): Unit = {
  import scala.concurrent.ExecutionContext.Implicits.global
  import scala.concurrent.Future
  import scala.collection.mutable
  
  // 危険な例1：可変状態の共有
  println("=== 非スレッドセーフの問題 ===")
  
  class UnsafeCounter {
    private var count = 0
    
    def increment(): Unit = {
      val current = count  // 読み込み
      Thread.sleep(1)      // 他の処理をシミュレート
      count = current + 1  // 書き込み
    }
    
    def getCount: Int = count
  }
  
  val counter = new UnsafeCounter
  
  // 100個のスレッドが同時にインクリメント
  val futures = (1 to 100).map { _ =>
    Future {
      counter.increment()
    }
  }
  
  Future.sequence(futures).foreach { _ =>
    println(s"最終カウント: ${counter.getCount} (100になるはず！)")
  }
  
  Thread.sleep(2000)
  
  // 危険な例2：可変コレクション
  println("\n=== 可変コレクションの問題 ===")
  
  val unsafeList = mutable.ListBuffer[Int]()
  
  val addFutures = (1 to 1000).map { i =>
    Future {
      unsafeList += i  // 同時追加で問題発生
    }
  }
  
  Future.sequence(addFutures).foreach { _ =>
    println(s"リストサイズ: ${unsafeList.size} (1000になるはず！)")
    val missing = (1 to 1000).toSet -- unsafeList.toSet
    println(s"欠落した要素数: ${missing.size}")
  }
  
  Thread.sleep(1000)
```

### スレッドセーフな実装

```scala
// ThreadSafeExample.scala
@main def threadSafeExample(): Unit = {
  import scala.concurrent.ExecutionContext.Implicits.global
  import scala.concurrent.Future
  import java.util.concurrent.atomic.{AtomicInteger, AtomicReference}
  import java.util.concurrent.ConcurrentHashMap
  
  // 解決策1：synchronizedブロック
  println("=== synchronizedによる解決 ===")
  
  class SynchronizedCounter {
    private var count = 0
    
    def increment(): Unit = this.synchronized {
      val current = count
      Thread.sleep(1)  // 他の処理
      count = current + 1
    }
    
    def getCount: Int = this.synchronized { count }
  }
  
  val syncCounter = new SynchronizedCounter
  val syncFutures = (1 to 100).map { _ =>
    Future { syncCounter.increment() }
  }
  
  Future.sequence(syncFutures).foreach { _ =>
    println(s"同期カウント: ${syncCounter.getCount}")
  }
  
  Thread.sleep(2000)
  
  // 解決策2：Atomic変数
  println("\n=== Atomic変数による解決 ===")
  
  class AtomicCounter {
    private val count = new AtomicInteger(0)
    
    def increment(): Unit = count.incrementAndGet()
    def getCount: Int = count.get()
    
    // より複雑な操作
    def incrementIfLessThan(limit: Int): Boolean = {
      count.updateAndGet { current =>
        if (current < limit) { current + 1 } else { current }
      } <= limit
    }
  }
  
  val atomicCounter = new AtomicCounter
  val atomicFutures = (1 to 150).map { _ =>
    Future {
      if (atomicCounter.incrementIfLessThan(100)) {
        "成功"
      } else {
        "制限到達"
      }
  }
  
  Future.sequence(atomicFutures).foreach { results =>
    val successCount = results.count(_ == "成功")
    println(s"Atomicカウント: ${atomicCounter.getCount}")
    println(s"成功: $successCount, 制限到達: ${150 - successCount}")
  }
  
  Thread.sleep(1000)
  
  // 解決策3：並行コレクション
  println("\n=== 並行コレクション ===")
  
  import scala.jdk.CollectionConverters._
  
  val concurrentMap = new ConcurrentHashMap[String, Int]().asScala
  
  val mapFutures = (1 to 100).flatMap { i =>
    List(
      Future { concurrentMap.put(s"key$i", i) },
      Future { concurrentMap.get(s"key$i") },
      Future { concurrentMap.getOrElseUpdate(s"new$i", i * 10) }
    )
  }
  
  Future.sequence(mapFutures).foreach { _ =>
    println(s"マップサイズ: ${concurrentMap.size}")
    println(s"サンプル値: ${concurrentMap.take(5).toMap}")
  }
  
  Thread.sleep(1000)
```

## イミュータブルによるスレッドセーフ

### イミュータブルデータ構造

```scala
// ImmutableThreadSafety.scala
@main def immutableThreadSafety(): Unit = {
  import scala.concurrent.ExecutionContext.Implicits.global
  import scala.concurrent.Future
  import java.util.concurrent.atomic.AtomicReference
  
  // イミュータブルな状態管理
  case class GameState(
    score: Int,
    level: Int,
    players: Set[String],
    items: Map[String, Int]
  ):
    def addScore(points: Int): GameState = {
      copy(score = score + points)
    }
    
    def levelUp: GameState = {
      copy(level = level + 1)
    }
    
    def addPlayer(name: String): GameState = {
      copy(players = players + name)
    }
    
    def addItem(item: String, quantity: Int): GameState = {
      copy(items = items + (item -> (items.getOrElse(item, 0) + quantity)))
    }
  
  // スレッドセーフな状態管理
  class ThreadSafeGameManager {
    private val state = new AtomicReference(GameState(0, 1, Set.empty, Map.empty))
    
    def updateState(f: GameState => GameState): GameState = {
      var oldState: GameState = null
      var newState: GameState = null
      
      do {
        oldState = state.get()
        newState = f(oldState)
      } while (!state.compareAndSet(oldState, newState))
      
      newState
    }
    
    def getState: GameState = state.get()
  }
  
  val gameManager = new ThreadSafeGameManager
  
  // 並行更新
  println("=== イミュータブルによるスレッドセーフ ===")
  
  val updateFutures = List(
    // スコア更新
    Future.sequence((1 to 50).map { _ =>
      Future { gameManager.updateState(_.addScore(10)) }
    }),
    
    // プレイヤー追加
    Future.sequence((1 to 20).map { i =>
      Future { gameManager.updateState(_.addPlayer(s"Player$i")) }
    }),
    
    // アイテム追加
    Future.sequence((1 to 30).map { _ =>
      Future {
        gameManager.updateState(_.addItem("coin", 1))
        gameManager.updateState(_.addItem("potion", 1))
      }
    })
  )
  
  Future.sequence(updateFutures).foreach { _ =>
    val finalState = gameManager.getState
    println(s"最終スコア: ${finalState.score}")
    println(s"プレイヤー数: ${finalState.players.size}")
    println(s"アイテム: ${finalState.items}")
  }
  
  Thread.sleep(1000)
  
  // メッセージパッシング
  println("\n=== メッセージパッシング ===")
  
  import java.util.concurrent.LinkedBlockingQueue
  
  sealed trait GameMessage
  case class AddScore(points: Int) extends GameMessage
  case class AddPlayer(name: String) extends GameMessage
  case class GetState(replyTo: GameState => Unit) extends GameMessage
  
  class MessageBasedGame {
    private val queue = new LinkedBlockingQueue[GameMessage]()
    @volatile private var running = true
    
    private var state = GameState(0, 1, Set.empty, Map.empty)
    
    private val processor = new Thread(() => {
      while (running) {
        Option(queue.poll(100, java.util.concurrent.TimeUnit.MILLISECONDS)).foreach {
          case AddScore(points) =>
            state = state.addScore(points)
            
          case AddPlayer(name) =>
            state = state.addPlayer(name)
            
            
          case GetState(replyTo) =>
            replyTo(state)
        }
      }
    })
    
    processor.start()
    
    def sendMessage(msg: GameMessage): Unit = queue.offer(msg)
    
    def stop(): Unit = {
      running = false
      processor.join()
    }
  }
  
  val messageGame = new MessageBasedGame
  
  // 並行メッセージ送信
  val messageFutures = (1 to 100).map { i =>
    Future {
      messageGame.sendMessage(AddScore(5))
      if (i % 10 == 0) {
        messageGame.sendMessage(AddPlayer(s"Player$i"))
      }
    }
  }
  
  Future.sequence(messageFutures).foreach { _ =>
    Thread.sleep(500)  // 処理完了を待つ
    
    val promise = scala.concurrent.Promise[GameState]()
    messageGame.sendMessage(GetState(state => promise.success(state)))
    
    promise.future.foreach { state =>
      println(s"メッセージベース - スコア: ${state.score}")
      println(s"メッセージベース - プレイヤー: ${state.players.size}")
    }
  }
  
  Thread.sleep(1000)
  messageGame.stop()
```

## ロックフリーアルゴリズム

### CAS（Compare-And-Swap）操作

```scala
// LockFreeAlgorithms.scala
@main def lockFreeAlgorithms(): Unit = {
  import scala.concurrent.ExecutionContext.Implicits.global
  import scala.concurrent.Future
  import java.util.concurrent.atomic.{AtomicReference, AtomicInteger}
  import scala.annotation.tailrec
  
  // ロックフリースタック
  println("=== ロックフリースタック ===")
  
  class LockFreeStack[T] {
    private class Node[T](val value: T, val next: AtomicReference[Node[T]])
    
    private val top = new AtomicReference[Node[T]](null)
    
    @tailrec
    final def push(value: T): Unit = {
      val newNode = new Node(value, new AtomicReference(top.get()))
      if (!top.compareAndSet(newNode.next.get(), newNode)) {
        newNode.next.set(top.get())
        push(value)  // リトライ
      }
    }
    
    @tailrec
    final def pop(): Option[T] = {
      val currentTop = top.get()
      if (currentTop == null) {
        None
      } else if (top.compareAndSet(currentTop, currentTop.next.get())) {
        Some(currentTop.value)
      } else {
        pop()  // リトライ
      }
    }
    
    def isEmpty: Boolean = top.get() == null
  }
  
  val stack = new LockFreeStack[Int]
  
  // 並行プッシュ
  val pushFutures = (1 to 100).map { i =>
    Future { stack.push(i) }
  }
  
  Future.sequence(pushFutures).foreach { _ =>
    println("プッシュ完了")
    
    // 並行ポップ
    val popFutures = (1 to 50).map { _ =>
      Future { stack.pop() }
    }
    
    Future.sequence(popFutures).foreach { results =>
      val popped = results.flatten
      println(s"ポップした要素数: ${popped.size}")
      println(s"残りの要素: ${!stack.isEmpty}")
    }
  }
  
  Thread.sleep(1000)
  
  // ロックフリーカウンター（ABA問題対策）
  println("\n=== ロックフリーカウンター ===")
  
  class StampedReference[T](initialRef: T, initialStamp: Int) {
    private val pair = new AtomicReference((initialRef, initialStamp))
    
    def get: (T, Int) = pair.get()
    
    def compareAndSet(
      expectedRef: T,
      newRef: T,
      expectedStamp: Int,
      newStamp: Int
    ): Boolean = {
      val current = pair.get()
      current._1 == expectedRef && 
      current._2 == expectedStamp &&
      pair.compareAndSet(current, (newRef, newStamp))
    }
  }
  
  // 使用例：ロックフリーな残高管理
  class LockFreeAccount(initialBalance: Double) {
    private val balance = new StampedReference(initialBalance, 0)
    
    @tailrec
    final def withdraw(amount: Double): Boolean = {
      val (currentBalance, stamp) = balance.get
      if (currentBalance >= amount) {
        if (balance.compareAndSet(
          currentBalance,
          currentBalance - amount,
          stamp,
          stamp + 1
        )) {
          true
        } else {
          withdraw(amount)  // リトライ
        }
      } else {
        false
      }
    }
    
    def getBalance: Double = balance.get._1
  }
  
  val account = new LockFreeAccount(1000.0)
  
  val withdrawFutures = (1 to 20).map { _ =>
    Future {
      val amount = 50.0
      if (account.withdraw(amount)) {
        s"出金成功: $amount"
      } else {
        s"出金失敗: 残高不足"
      }
  }
  
  Future.sequence(withdrawFutures).foreach { results =>
    val successes = results.count(_.contains("成功"))
    println(s"出金結果: 成功 $successes 件")
    println(s"最終残高: ${account.getBalance}")
  }
  
  Thread.sleep(1000)
```

## 実践的なスレッドセーフ設計

### プロデューサー・コンシューマーパターン

```scala
// ProducerConsumerPattern.scala
@main def producerConsumerPattern(): Unit = {
  import scala.concurrent.ExecutionContext.Implicits.global
  import scala.concurrent.Future
  import java.util.concurrent.{LinkedBlockingQueue, ArrayBlockingQueue}
  import java.util.concurrent.atomic.AtomicBoolean
  
  // スレッドセーフなキュー
  println("=== プロデューサー・コンシューマー ===")
  
  class WorkQueue[T](capacity: Int) {
    private val queue = new ArrayBlockingQueue[T](capacity)
    private val isShutdown = new AtomicBoolean(false)
    
    def produce(item: T): Boolean = {
      if (!isShutdown.get()) {
        queue.offer(item, 100, java.util.concurrent.TimeUnit.MILLISECONDS)
      } else {
        false
      }
    }
    
    def consume(): Option[T] = {
      if (!isShutdown.get() || !queue.isEmpty) {
        Option(queue.poll(100, java.util.concurrent.TimeUnit.MILLISECONDS))
      } else {
        None
      }
    }
    
    def shutdown(): Unit = isShutdown.set(true)
    
    def awaitTermination(): Unit =
      while !queue.isEmpty do Thread.sleep(10)
  
  // データ処理パイプライン
  case class Task(id: Int, data: String)
  case class Result(taskId: Int, result: String)
  
  val taskQueue = new WorkQueue[Task](10)
  val resultQueue = new WorkQueue[Result](10)
  
  // プロデューサー
  val producers = (1 to 3).map { producerId =>
    Future {
      for i <- 1 to 10 do
        val task = Task(producerId * 100 + i, s"Data-$producerId-$i")
        if taskQueue.produce(task) then
          println(s"生産[$producerId]: $task")
        Thread.sleep(50)
      println(s"プロデューサー$producerId 完了")
    }
  }
  
  // ワーカー（変換処理）
  val workers = (1 to 2).map { workerId =>
    Future {
      var processed = 0
      var continue = true
      
      while continue do
        taskQueue.consume() match {
          case Some(task) =>
            println(s"  処理[$workerId]: ${task.id}")
            Thread.sleep(100)  // 処理時間
            val result = Result(task.id, task.data.toUpperCase)
            resultQueue.produce(result)
            processed += 1
            
          case None =>
            if producers.forall(_.isCompleted) then
              continue = false
      
      println(s"ワーカー$workerId 完了: $processed 件処理")
    }
  }
  
  // コンシューマー
  val consumer = Future {
    var consumed = 0
    var continue = true
    
    while continue do
      resultQueue.consume() match {
        case Some(result) =>
          println(s"    消費: ${result.taskId} -> ${result.result}")
          consumed += 1
          
        case None =>
          if workers.forall(_.isCompleted) then
            continue = false
    
    println(s"コンシューマー完了: $consumed 件消費")
    consumed
  }
  
  // 完了を待つ
  for
    _ <- Future.sequence(producers)
    _ = taskQueue.shutdown()
    _ <- Future.sequence(workers)
    _ = resultQueue.shutdown()
    totalConsumed <- consumer
  yield
    println(s"\n=== パイプライン完了 ===")
    println(s"合計処理数: $totalConsumed")
  
  Thread.sleep(5000)
```

### リードライトロック

```scala
// ReadWriteLock.scala
@main def readWriteLock(): Unit = {
  import scala.concurrent.ExecutionContext.Implicits.global
  import scala.concurrent.Future
  import java.util.concurrent.locks.ReentrantReadWriteLock
  
  // 読み書きが偏るデータ構造
  class ThreadSafeCache[K, V]:
    private val cache = scala.collection.mutable.Map[K, V]()
    private val lock = new ReentrantReadWriteLock()
    private val readLock = lock.readLock()
    private val writeLock = lock.writeLock()
    
    def get(key: K): Option[V] =
      readLock.lock()
      try
        cache.get(key)
      finally
        readLock.unlock()
    
    def put(key: K, value: V): Unit =
      writeLock.lock()
      try
        cache.put(key, value)
      finally
        writeLock.unlock()
    
    def getOrCompute(key: K)(compute: => V): V =
      // まず読み取り試行
      readLock.lock()
      try
        cache.get(key) match {
          case Some(value) => return value
          case None => // 続行
      finally
        readLock.unlock()
      
      // 書き込みロックで再チェック
      writeLock.lock()
      try
        cache.getOrElseUpdate(key, compute)
      finally
        writeLock.unlock()
    
    def size: Int =
      readLock.lock()
      try
        cache.size
      finally
        readLock.unlock()
  
  println("=== リードライトロック ===")
  
  val cache = new ThreadSafeCache[String, String]
  
  // 多数の読み取りと少数の書き込み
  val operations = List(
    // 90% 読み取り
    List.fill(90)(Future {
      val key = s"key${scala.util.Random.nextInt(20)}"
      cache.get(key) match {
        case Some(value) => s"Hit: $key -> $value"
        case None => s"Miss: $key"
    }),
    
    // 10% 書き込み
    List.fill(10)(Future {
      val key = s"key${scala.util.Random.nextInt(20)}"
      val value = s"value${scala.util.Random.nextInt(100)}"
      cache.put(key, value)
      s"Put: $key -> $value"
    })
  ).flatten
  
  Future.sequence(scala.util.Random.shuffle(operations)).foreach { results =>
    val hits = results.count(_.startsWith("Hit"))
    val misses = results.count(_.startsWith("Miss"))
    val puts = results.count(_.startsWith("Put"))
    
    println(s"ヒット: $hits, ミス: $misses, 書き込み: $puts")
    println(s"キャッシュサイズ: ${cache.size}")
  }
  
  Thread.sleep(1000)
  
  // 計算の重複を避ける
  println("\n=== 計算の重複回避 ===")
  
  def expensiveComputation(key: String): String =
    println(s"高コスト計算: $key")
    Thread.sleep(1000)
    s"Result-$key"
  
  val computeFutures = (1 to 10).map { i =>
    Future {
      val key = s"compute${i % 3}"  // 3種類のキーのみ
      cache.getOrCompute(key)(expensiveComputation(key))
    }
  }
  
  Future.sequence(computeFutures).foreach { results =>
    println(s"計算結果: ${results.distinct}")
    println("（高コスト計算は3回のみ実行されるはず）")
  }
  
  Thread.sleep(2000)
```

## 実践例：スレッドセーフなメトリクス収集

```scala
// ThreadSafeMetrics.scala
@main def threadSafeMetrics(): Unit = {
  import scala.concurrent.ExecutionContext.Implicits.global
  import scala.concurrent.Future
  import java.util.concurrent.ConcurrentHashMap
  import java.util.concurrent.atomic.{AtomicLong, LongAdder}
  import scala.jdk.CollectionConverters._
  
  // スレッドセーフなメトリクス収集システム
  class MetricsCollector:
    // カウンター
    private val counters = new ConcurrentHashMap[String, LongAdder]()
    
    // ゲージ（最新値）
    private val gauges = new ConcurrentHashMap[String, AtomicLong]()
    
    // ヒストグラム（簡易版）
    private val histograms = new ConcurrentHashMap[String, Histogram]()
    
    def incrementCounter(name: String, delta: Long = 1): Unit =
      counters.computeIfAbsent(name, _ => new LongAdder()).add(delta)
    
    def setGauge(name: String, value: Long): Unit =
      gauges.computeIfAbsent(name, _ => new AtomicLong()).set(value)
    
    def recordValue(name: String, value: Long): Unit =
      histograms.computeIfAbsent(name, _ => new Histogram()).record(value)
    
    def getSnapshot: MetricsSnapshot =
      MetricsSnapshot(
        counters = counters.asScala.map { case (k, v) => k -> v.sum() }.toMap,
        gauges = gauges.asScala.map { case (k, v) => k -> v.get() }.toMap,
        histograms = histograms.asScala.map { case (k, v) => k -> v.getStats }.toMap
      )
  
  case class MetricsSnapshot(
    counters: Map[String, Long],
    gauges: Map[String, Long],
    histograms: Map[String, HistogramStats]
  )
  
  case class HistogramStats(
    count: Long,
    sum: Long,
    min: Long,
    max: Long,
    mean: Double
  )
  
  // 簡易ヒストグラム実装
  class Histogram:
    private val count = new LongAdder()
    private val sum = new LongAdder()
    private val min = new AtomicLong(Long.MaxValue)
    private val max = new AtomicLong(Long.MinValue)
    
    def record(value: Long): Unit =
      count.increment()
      sum.add(value)
      
      // 最小値更新
      var currentMin = min.get()
      while value < currentMin && !min.compareAndSet(currentMin, value) do
        currentMin = min.get()
      
      // 最大値更新
      var currentMax = max.get()
      while value > currentMax && !max.compareAndSet(currentMax, value) do
        currentMax = max.get()
    
    def getStats: HistogramStats =
      val c = count.sum()
      val s = sum.sum()
      HistogramStats(
        count = c,
        sum = s,
        min = if (c > 0) { min.get() else 0,
        max = if (c > 0) { max.get() else 0,
        mean = if (c > 0) { s.toDouble / c else 0.0
      )
  
  // 使用例：Webアプリケーションのメトリクス
  println("=== スレッドセーフメトリクス ===")
  
  val metrics = new MetricsCollector
  
  // 複数のリクエストハンドラーをシミュレート
  def handleRequest(requestId: Int): Future[Unit] = Future {
    val startTime = System.currentTimeMillis()
    
    // リクエストカウンター
    metrics.incrementCounter("requests.total")
    
    // 処理時間シミュレート
    val processingTime = scala.util.Random.nextInt(100) + 50
    Thread.sleep(processingTime)
    
    // レスポンスタイム記録
    val responseTime = System.currentTimeMillis() - startTime
    metrics.recordValue("response.time.ms", responseTime)
    
    // ステータスコード
    val statusCode = if scala.util.Random.nextDouble() > 0.1 then 200 else 500
    metrics.incrementCounter(s"response.status.$statusCode")
    
    // アクティブコネクション（ゲージ）
    val activeConnections = scala.util.Random.nextInt(100)
    metrics.setGauge("connections.active", activeConnections)
    
    if (requestId % 100 == 0) {
      println(s"リクエスト $requestId 処理完了")
  }
  
  // 1000リクエストを並行処理
  val requests = Future.sequence((1 to 1000).map(handleRequest))
  
  requests.foreach { _ =>
    val snapshot = metrics.getSnapshot
    
    println("\n=== メトリクスサマリー ===")
    
    println("\nカウンター:")
    snapshot.counters.foreach { case (name, value) =>
      println(f"  $name%-30s: $value%,d")
    }
    
    println("\nゲージ:")
    snapshot.gauges.foreach { case (name, value) =>
      println(f"  $name%-30s: $value%,d")
    }
    
    println("\nヒストグラム:")
    snapshot.histograms.foreach { case (name, stats) =>
      println(f"  $name%-30s:")
      println(f"    件数: ${stats.count}%,d")
      println(f"    平均: ${stats.mean}%.2f ms")
      println(f"    最小: ${stats.min} ms")
      println(f"    最大: ${stats.max} ms")
    }
    
    // エラー率計算
    val total = snapshot.counters.getOrElse("requests.total", 0L)
    val errors = snapshot.counters.getOrElse("response.status.500", 0L)
    val errorRate = if (total > 0) { errors.toDouble / total * 100 else 0.0
    println(f"\nエラー率: $errorRate%.1f%%")
  }
  
  Thread.sleep(3000)
```

## 練習してみよう！

### 練習1：スレッドセーフなLRUキャッシュ

最近使われたものを残すLRUキャッシュを実装してください：
- 最大サイズの制限
- スレッドセーフな操作
- 高速なアクセス

### 練習2：並行アクセスカウンター

Webサイトのアクセスカウンターを作ってください：
- ページ別のカウント
- ユニークユーザー数
- 時間帯別の統計

### 練習3：スレッドプール

カスタムスレッドプールを実装してください：
- タスクキュー
- ワーカースレッド管理
- 優雅なシャットダウン

## この章のまとめ

スレッドセーフな設計の重要性を学びました！

### できるようになったこと

✅ **スレッドセーフの概念**
- 競合状態の理解
- データ競合の回避
- 並行アクセスの制御

✅ **同期メカニズム**
- synchronized
- Atomic変数
- ロックフリーアルゴリズム

✅ **設計パターン**
- イミュータブル設計
- メッセージパッシング
- プロデューサー・コンシューマー

✅ **実践的な実装**
- 並行コレクション
- メトリクス収集
- キャッシュ実装

### スレッドセーフ設計のコツ

1. **シンプルに保つ**
    - 共有状態を最小限に
    - イミュータブル優先
    - 明確な責任分離

2. **適切なツールを選ぶ**
    - 用途に応じた同期方法
    - パフォーマンスを考慮
    - 可読性とのバランス

3. **テストを忘れずに**
    - 並行性のテスト
    - ストレステスト
    - デッドロックの検出

### 次の章では...

アクターモデル入門について詳しく学びます。メッセージベースの並行処理で、より安全な設計を実現しましょう！

### 最後に

スレッドセーフは「みんなで使う施設の安全管理」のようなものです。図書館の本を同時に借りようとしたり、同じ席に座ろうとしたりすると混乱が起きる。でも、適切なルール（貸出システムや座席予約）があれば、みんなが快適に利用できます。この「共有資源の安全な管理」こそが、堅牢な並行プログラムの基礎なのです！