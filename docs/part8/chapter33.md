# 第33章 並行プログラミング入門

## はじめに

レストランの厨房を想像してください。一人のシェフがすべての料理を順番に作るより、複数のシェフが同時に違う料理を作った方が効率的ですよね。でも、同じフライパンを同時に使おうとしたり、調味料の順番を間違えたりすると、大変なことになります。

並行プログラミングも同じです。複数の処理を同時に実行して効率を上げますが、適切に管理しないと問題が起きます。この章で、安全で効率的な並行プログラミングを学びましょう！

## スレッドとFuture

### スレッドの基本

```scala
// ThreadBasics.scala
@main def threadBasics(): Unit = {
  // 基本的なスレッド作成
  println("=== スレッドの基本 ===")
  
  val thread1 = new Thread(() => {
    for (i <- 1 to 5) {
      println(s"スレッド1: $i")
      Thread.sleep(100)
  })
  
  val thread2 = new Thread(() => {
    for (i <- 1 to 5) {
      println(s"  スレッド2: $i")
      Thread.sleep(100)
  })
  
  // スレッドを開始
  thread1.start()
  thread2.start()
  
  // スレッドの終了を待つ
  thread1.join()
  thread2.join()
  
  println("\nすべてのスレッドが完了しました")
  
  // スレッドプールの使用
  println("\n=== スレッドプール ===")
  
  import java.util.concurrent.Executors
  
  val executor = Executors.newFixedThreadPool(3)
  
  for (i <- 1 to 10) {
    executor.submit(() => {
      println(s"タスク$i 開始 (${Thread.currentThread.getName})")
      Thread.sleep(500)
      println(s"タスク$i 完了")
    })
  
  executor.shutdown()
  while !executor.isTerminated do
    Thread.sleep(100)
  
  println("すべてのタスクが完了しました")
```

### Futureによる非同期処理

```scala
// FutureBasics.scala
@main def futureBasics(): Unit = {
  import scala.concurrent.{Future, Promise
}
  import scala.concurrent.ExecutionContext.Implicits.global
  import scala.concurrent.duration._
  import scala.util.{Success, Failure
}
  
  // 基本的なFuture
  println("=== Futureの基本 ===")
  
  val future1 = Future {
    println("計算開始...")
    Thread.sleep(1000)
    42

}
  
  future1.onComplete {
    case Success(value) => println(s"結果: $value")
    case Failure(error) => println(s"エラー: $error")

}
  
  // 複数のFutureの合成
  println("\n=== Futureの合成 ===")
  
  def fetchUserName(id: Int): Future[String] = Future {
    Thread.sleep(500)
    s"User$id"

}
  
  def fetchUserScore(name: String): Future[Int] = Future {
    Thread.sleep(300)
    name.length * 10

}
  
  val result = for
    name <- fetchUserName(123)
    score <- fetchUserScore(name)
  yield s"$name: $score points"
  
  result.foreach(println)
  
  // 並列実行
  println("\n=== 並列実行 ===")
  
  val start = System.currentTimeMillis()
  
  val f1 = Future { Thread.sleep(1000); "Task1"
}
  val f2 = Future { Thread.sleep(1000); "Task2"
}
  val f3 = Future { Thread.sleep(1000); "Task3"
}
  
  val combined = for
    r1 <- f1
    r2 <- f2
    r3 <- f3
  yield List(r1, r2, r3)
  
  combined.foreach { results =>
    val elapsed = System.currentTimeMillis() - start
    println(s"結果: $results (${elapsed}ms)")

}
  
  // エラーハンドリング
  println("\n=== エラーハンドリング ===")
  
  def riskyOperation(n: Int): Future[Int] = Future {
    if (n < 0) { throw new IllegalArgumentException("負の数は不可")
    n * 2

}
  
  val futures = List(
    riskyOperation(10),
    riskyOperation(-5),
    riskyOperation(20)
  )
  
  futures.foreach { f =>
    f.recover {
      case _: IllegalArgumentException => -1
    }.foreach(r => println(s"結果: $r"))

}
  
  Thread.sleep(2000)  // 結果を待つ
```

## 同期とロック

### 共有状態の問題

```scala
// SharedStateProblems.scala
@main def sharedStateProblems(): Unit = {
  import scala.concurrent.ExecutionContext.Implicits.global
  import java.util.concurrent.atomic.AtomicInteger
  
  // 問題のあるコード（競合状態）
  println("=== 競合状態の例 ===")
  
  var unsafeCounter = 0
  
  val futures1 = (1 to 10000).map { _ =>
    Future {
      unsafeCounter += 1  // 安全でない！

}

}
  
  Future.sequence(futures1).foreach { _ =>
    println(s"安全でないカウンター: $unsafeCounter （10000になるはず）")

}
  
  Thread.sleep(1000)
  
  // 解決策1：synchronized
  println("\n=== synchronizedによる解決 ===")
  
  var syncCounter = 0
  val lock = new Object
  
  val futures2 = (1 to 10000).map { _ =>
    Future {
      lock.synchronized {
        syncCounter += 1

}

}

}
  
  Future.sequence(futures2).foreach { _ =>
    println(s"同期カウンター: $syncCounter")

}
  
  Thread.sleep(1000)
  
  // 解決策2：Atomic
  println("\n=== Atomicによる解決 ===")
  
  val atomicCounter = new AtomicInteger(0)
  
  val futures3 = (1 to 10000).map { _ =>
    Future {
      atomicCounter.incrementAndGet()

}

}
  
  Future.sequence(futures3).foreach { _ =>
    println(s"Atomicカウンター: ${atomicCounter.get}")

}
  
  Thread.sleep(1000)
  
  // 解決策3：イミュータブル + メッセージパッシング
  println("\n=== イミュータブルな解決 ===")
  
  case class CounterState(value: Int)
  
  def updateCounter(states: List[Future[CounterState]]): Future[CounterState] =
    Future.sequence(states).map { list =>
      CounterState(list.map(_.value).sum)

}
  
  val initialStates = (1 to 100).map(_ => Future(CounterState(1))).toList
  
  updateCounter(initialStates).foreach { finalState =>
    println(s"イミュータブルカウンター: ${finalState.value}")

}
  
  Thread.sleep(1000)
```

### デッドロックの回避

```scala
// DeadlockAvoidance.scala
@main def deadlockAvoidance(): Unit = {
  import scala.concurrent.ExecutionContext.Implicits.global
  
  // デッドロックが起きる例（実行しないこと！）
  println("=== デッドロックの危険性 ===")
  
  class BankAccount(var balance: Double):
    def transfer(to: BankAccount, amount: Double): Unit =
      this.synchronized {
        Thread.sleep(10)  // 処理時間をシミュレート
        to.synchronized {
          if (this.balance >= amount) {
            this.balance -= amount
            to.balance += amount

}

}
  
  // デッドロックを避ける方法
  println("\n=== デッドロック回避 ===")
  
  class SafeBankAccount(val id: Int, var balance: Double):
    def transfer(to: SafeBankAccount, amount: Double): Unit =
      // 常に同じ順序でロック
      val (first, second) = if (this.id < to.id) { (this, to) else (to, this)
      
      first.synchronized {
        second.synchronized {
          if (this.balance >= amount) {
            this.balance -= amount
            to.balance += amount
            println(s"送金成功: ${this.id} -> ${to.id}, $amount 円")
          } else {
            println(s"送金失敗: 残高不足")

}

}
  
  val account1 = new SafeBankAccount(1, 1000)
  val account2 = new SafeBankAccount(2, 1000)
  
  val transfer1 = Future {
    for (i <- 1 to 5) {
      account1.transfer(account2, 100)
      Thread.sleep(50)

}
  
  val transfer2 = Future {
    for (i <- 1 to 5) {
      account2.transfer(account1, 150)
      Thread.sleep(50)

}
  
  Future.sequence(List(transfer1, transfer2)).foreach { _ =>
    println(s"\n最終残高:")
    println(s"  アカウント1: ${account1.balance}")
    println(s"  アカウント2: ${account2.balance}")

}
  
  Thread.sleep(1000)
```

## アクターモデル

### 簡単なアクター実装

```scala
// SimpleActor.scala
@main def simpleActor(): Unit = {
  import scala.concurrent.ExecutionContext.Implicits.global
  import java.util.concurrent.{LinkedBlockingQueue, TimeUnit
}
  
  // シンプルなアクターの実装
  trait Message
  case class Deposit(amount: Double) extends Message
  case class Withdraw(amount: Double) extends Message
  case class GetBalance(replyTo: SimpleActor[BalanceReply]) extends Message
  case class BalanceReply(balance: Double) extends Message
  case object Stop extends Message
  
  class SimpleActor[T]:
    private val mailbox = new LinkedBlockingQueue[T]()
    @volatile private var running = true
    
    def send(message: T): Unit = mailbox.offer(message)
    
    def receive(handler: T => Unit): Unit =
      val thread = new Thread(() => {
        while running do
          Option(mailbox.poll(100, TimeUnit.MILLISECONDS)).foreach(handler)
      })
      thread.start()
    
    def stop(): Unit = running = false
  
  // 銀行口座アクター
  class BankAccountActor(initialBalance: Double):
    private var balance = initialBalance
    private val actor = new SimpleActor[Message]
    
    actor.receive {
      case Deposit(amount) =>
        balance += amount
        println(s"入金: $amount 円, 残高: $balance 円")
        
      case Withdraw(amount) =>
        if (balance >= amount) {
          balance -= amount
          println(s"出金: $amount 円, 残高: $balance 円")
        } else {
          println(s"出金失敗: 残高不足")
          
      case GetBalance(replyTo) =>
        replyTo.send(BalanceReply(balance))
        
      case Stop =>
        println("アクター停止")
        actor.stop()

}
    
    def deposit(amount: Double): Unit = actor.send(Deposit(amount))
    def withdraw(amount: Double): Unit = actor.send(Withdraw(amount))
    def getBalance(replyTo: SimpleActor[BalanceReply]): Unit = 
      actor.send(GetBalance(replyTo))
    def stop(): Unit = actor.send(Stop)
  
  // 使用例
  println("=== アクターモデル ===")
  
  val account = new BankAccountActor(1000)
  
  // 並行してメッセージを送信
  Future { 
    for (i <- 1 to 5) {
      account.deposit(100)
      Thread.sleep(100)

}
  
  Future {
    for (i <- 1 to 3) {
      account.withdraw(200)
      Thread.sleep(150)

}
  
  Thread.sleep(1000)
  
  // 残高確認
  val replyActor = new SimpleActor[BalanceReply]
  replyActor.receive {
    case BalanceReply(balance) =>
      println(s"\n最終残高: $balance 円")
      replyActor.stop()

}
  
  account.getBalance(replyActor)
  Thread.sleep(500)
  
  account.stop()
```

## 実践例：並行Webクローラー

```scala
// ConcurrentWebCrawler.scala
@main def concurrentWebCrawler(): Unit = {
  import scala.concurrent.{Future, Promise
}
  import scala.concurrent.ExecutionContext.Implicits.global
  import scala.collection.concurrent.TrieMap
  import java.util.concurrent.{Semaphore, ConcurrentLinkedQueue
}
  import scala.util.{Success, Failure, Random
}
  
  // 仮想的なWebページ
  case class WebPage(url: String, content: String, links: Set[String])
  
  // Webページを取得する（シミュレーション）
  def fetchPage(url: String): Future[WebPage] = Future {
    Thread.sleep(Random.nextInt(500) + 100)  // ネットワーク遅延
    
    // ダミーデータ生成
    val links = (1 to Random.nextInt(5) + 1).map { i =>
      s"$url/link$i"
    }.toSet
    
    WebPage(url, s"Content of $url", links)

}
  
  // 並行クローラー
  class ConcurrentCrawler(maxConcurrency: Int, maxDepth: Int):
    private val visited = TrieMap[String, WebPage]()
    private val semaphore = new Semaphore(maxConcurrency)
    private val queue = new ConcurrentLinkedQueue[(String, Int)]()
    
    def crawl(startUrl: String): Future[Map[String, WebPage]] =
      val promise = Promise[Map[String, WebPage]]()
      
      queue.offer((startUrl, 0))
      processQueue(promise)
      
      promise.future
    
    private def processQueue(promise: Promise[Map[String, WebPage]]): Unit =
      Future {
        while !queue.isEmpty || semaphore.availablePermits() < maxConcurrency do
          Option(queue.poll()) match {
            case Some((url, depth)) if !visited.contains(url) && depth <= maxDepth =>
              semaphore.acquire()
              
              fetchPage(url).onComplete {
                case Success(page) =>
                  visited.put(url, page)
                  println(s"取得: $url (深さ: $depth)")
                  
                  // 新しいリンクをキューに追加
                  page.links.foreach { link =>
                    queue.offer((link, depth + 1))

}
                  
                  semaphore.release()
                  
                case Failure(error) =>
                  println(s"エラー: $url - $error")
                  semaphore.release()

}
              
            case Some(_) => // 既に訪問済みか深さ制限
            case None => Thread.sleep(10)  // キューが空
        
        promise.success(visited.toMap)

}
  
  // クローラーの実行
  println("=== 並行Webクローラー ===")
  
  val crawler = new ConcurrentCrawler(maxConcurrency = 3, maxDepth = 2)
  val startTime = System.currentTimeMillis()
  
  crawler.crawl("http://example.com").foreach { results =>
    val elapsed = System.currentTimeMillis() - startTime
    
    println(s"\n=== クロール完了 ===")
    println(s"ページ数: ${results.size}")
    println(s"所要時間: ${elapsed}ms")
    
    println("\n取得したページ:")
    results.keys.toList.sorted.foreach { url =>
      val page = results(url)
      println(s"  $url (リンク数: ${page.links.size})")

}

}
  
  Thread.sleep(5000)  // 完了を待つ
  
  // プロデューサー・コンシューマーパターン
  println("\n\n=== プロデューサー・コンシューマー ===")
  
  class Pipeline[T](bufferSize: Int):
    private val buffer = new LinkedBlockingQueue[T](bufferSize)
    @volatile private var producing = true
    
    def produce(item: T): Boolean = 
      if (producing) { buffer.offer(item, 100, TimeUnit.MILLISECONDS)
      else false
    
    def consume(): Option[T] = 
      Option(buffer.poll(100, TimeUnit.MILLISECONDS))
    
    def stopProducing(): Unit = producing = false
    
    def isDone: Boolean = !producing && buffer.isEmpty
  
  // データ処理パイプライン
  val pipeline = new Pipeline[String](10)
  
  // プロデューサー
  val producer = Future {
    for (i <- 1 to 20) {
      val data = s"Data-$i"
      if pipeline.produce(data) then
        println(s"生成: $data")
      Thread.sleep(100)
    pipeline.stopProducing()

}
  
  // コンシューマー（複数）
  def consumer(id: Int) = Future {
    while !pipeline.isDone do
      pipeline.consume().foreach { data =>
        println(s"  消費[$id]: $data を処理中...")
        Thread.sleep(Random.nextInt(300) + 100)
        println(s"  消費[$id]: $data 完了")

}

}
  
  val consumers = (1 to 3).map(consumer)
  
  Future.sequence(producer :: consumers.toList).foreach { _ =>
    println("\nパイプライン処理完了")

}
  
  Thread.sleep(5000)
```

## 実践例：リアクティブシステム

```scala
// ReactiveSystem.scala
@main def reactiveSystem(): Unit = {
  import scala.concurrent.{Future, Promise
}
  import scala.concurrent.ExecutionContext.Implicits.global
  import scala.collection.mutable
  import java.util.concurrent.ConcurrentLinkedQueue
  
  // イベント駆動アーキテクチャ
  trait Event
  case class TemperatureReading(sensorId: String, celsius: Double) extends Event
  case class Alert(message: String, severity: String) extends Event
  case class Command(action: String) extends Event
  
  // イベントバス
  class EventBus:
    private val subscribers = mutable.Map[Class[_], mutable.Set[Event => Unit]]()
    
    def subscribe[T <: Event](eventType: Class[T])(handler: T => Unit): Unit =
      subscribers.synchronized {
        val handlers = subscribers.getOrElseUpdate(eventType, mutable.Set.empty)
        handlers += handler.asInstanceOf[Event => Unit]

}
    
    def publish(event: Event): Unit =
      Future {
        subscribers.synchronized {
          subscribers.get(event.getClass).foreach { handlers =>
            handlers.foreach(_(event))

}

}

}
  
  // センサーシミュレーター
  class TemperatureSensor(id: String, bus: EventBus):
    @volatile private var running = true
    
    def start(): Unit = Future {
      while running do
        val temp = 20 + scala.util.Random.nextGaussian() * 5
        bus.publish(TemperatureReading(id, temp))
        Thread.sleep(1000)

}
    
    def stop(): Unit = running = false
  
  // 温度モニター
  class TemperatureMonitor(bus: EventBus):
    private val readings = mutable.Map[String, Double]()
    
    bus.subscribe(classOf[TemperatureReading]) { reading =>
      readings.synchronized {
        readings(reading.sensorId) = reading.celsius
        
        if (reading.celsius > 30) {
          bus.publish(Alert(
            s"高温警告: ${reading.sensorId} = ${reading.celsius}°C",
            "WARNING"
          ))
        else if (reading.celsius < 10) {
          bus.publish(Alert(
            s"低温警告: ${reading.sensorId} = ${reading.celsius}°C",
            "WARNING"
          ))

}
      
      println(f"温度: ${reading.sensorId} = ${reading.celsius}%.1f°C")

}
    
    def getAverageTemperature: Option[Double] =
      readings.synchronized {
        if (readings.nonEmpty) {
          Some(readings.values.sum / readings.size)
        else None

}
  
  // アラートハンドラー
  class AlertHandler(bus: EventBus):
    bus.subscribe(classOf[Alert]) { alert =>
      println(s"⚠️  ${alert.severity}: ${alert.message}")
      
      // 自動対応
      if alert.message.contains("高温") then
        bus.publish(Command("COOLING_ON"))
      else if alert.message.contains("低温") then
        bus.publish(Command("HEATING_ON"))

}
  
  // コマンド実行器
  class CommandExecutor(bus: EventBus):
    bus.subscribe(classOf[Command]) { command =>
      println(s"🔧 コマンド実行: ${command.action}")

}
  
  // システムの起動
  println("=== リアクティブ温度監視システム ===")
  
  val eventBus = new EventBus
  val monitor = new TemperatureMonitor(eventBus)
  val alertHandler = new AlertHandler(eventBus)
  val executor = new CommandExecutor(eventBus)
  
  // 複数のセンサーを起動
  val sensors = List(
    new TemperatureSensor("Sensor-A", eventBus),
    new TemperatureSensor("Sensor-B", eventBus),
    new TemperatureSensor("Sensor-C", eventBus)
  )
  
  sensors.foreach(_.start())
  
  // 10秒間実行
  Thread.sleep(10000)
  
  // 統計情報
  println("\n=== 統計情報 ===")
  monitor.getAverageTemperature.foreach { avg =>
    println(f"平均温度: $avg%.1f°C")

}
  
  // センサー停止
  sensors.foreach(_.stop())
  println("\nシステム停止")
```

## 練習してみよう！

### 練習1：並行ダウンローダー

複数のファイルを並行してダウンロードするシステムを作ってください：
- 同時ダウンロード数の制限
- 進捗表示
- エラーリトライ

### 練習2：チャットシステム

複数ユーザーのチャットシステムを実装してください：
- メッセージの配信
- ユーザーの入退室
- メッセージ履歴

### 練習3：タスクスケジューラー

定期的なタスクを実行するスケジューラーを作ってください：
- cron式のスケジュール
- 並行実行制御
- 実行結果の記録

## この章のまとめ

並行プログラミングの基礎を習得しました！

### できるようになったこと

✅ **基本概念の理解**
- スレッドとFuture
- 非同期処理
- 並行と並列の違い

✅ **同期の重要性**
- 競合状態の回避
- デッドロックの防止
- スレッドセーフな設計

✅ **設計パターン**
- アクターモデル
- プロデューサー・コンシューマー
- イベント駆動

✅ **実践的な応用**
- Webクローラー
- リアクティブシステム
- 非同期パイプライン

### 並行プログラミングのコツ

1. **シンプルに保つ**
    - 共有状態を最小限に
    - イミュータブルを活用
    - 明確な責任分離

2. **適切な抽象化**
    - Future で非同期
    - アクターでメッセージング
    - ストリームで流れ

3. **テストとデバッグ**
    - 並行性のテスト
    - ログで状態追跡
    - タイムアウトの設定

### 次の部では...

第IX部では、実用的なプログラミング技術について学びます。実際のアプリケーション開発で必要な知識を身につけましょう！

### 最後に

並行プログラミングは「複数の料理を同時に作る技術」です。一つの鍋で順番に作るより、複数のコンロで同時に作った方が速い。でも、調理の順序や道具の共有には注意が必要。この「同時進行の技術」をマスターすれば、どんな大規模なシステムも効率的に動かせるようになります。マルチコアの時代に必須の技術を、あなたは手に入れました！