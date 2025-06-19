# 第35章 アクターモデル入門

## はじめに

劇場を想像してください。舞台上の俳優（アクター）たちは、それぞれ自分の役割を持ち、台本（メッセージ）に従って演技します。他の俳優と直接話すのではなく、決められたセリフのやり取りで物語を進めていきます。

アクターモデルも同じです。それぞれのアクターが独立して動き、メッセージのやり取りだけで協調動作します。この美しいモデルで、複雑な並行処理も簡単に実現できるんです！

## アクターモデルとは？

### 基本概念

```scala
// ActorModelBasics.scala
@main def actorModelBasics(): Unit =
  import scala.concurrent.{Future, Promise}
  import scala.concurrent.ExecutionContext.Implicits.global
  import java.util.concurrent.{ConcurrentLinkedQueue, CountDownLatch}
  import java.util.concurrent.atomic.AtomicBoolean
  
  // シンプルなアクターの実装
  abstract class Actor[T]:
    private val mailbox = new ConcurrentLinkedQueue[T]()
    private val running = new AtomicBoolean(true)
    
    // メッセージ受信時の処理（サブクラスで実装）
    def receive(message: T): Unit
    
    // メッセージ送信
    def !(message: T): Unit = 
      if running.get() then
        mailbox.offer(message)
    
    // アクター開始
    def start(): Unit =
      Future {
        while running.get() || !mailbox.isEmpty do
          Option(mailbox.poll()) match
            case Some(msg) => 
              try receive(msg)
              catch case e: Exception =>
                println(s"エラー: ${e.getMessage}")
            case None => 
              Thread.sleep(10)
      }
    
    // アクター停止
    def stop(): Unit = 
      running.set(false)
  
  // 挨拶アクター
  class GreeterActor extends Actor[String]:
    override def receive(message: String): Unit = message match
      case "hello" => println("こんにちは！")
      case "goodbye" => println("さようなら！")
      case name => println(s"はじめまして、$name さん！")
  
  println("=== 基本的なアクター ===")
  
  val greeter = new GreeterActor
  greeter.start()
  
  greeter ! "hello"
  greeter ! "太郎"
  greeter ! "goodbye"
  
  Thread.sleep(100)
  greeter.stop()
  
  // カウンターアクター（状態を持つ）
  sealed trait CounterMessage
  case object Increment extends CounterMessage
  case object Decrement extends CounterMessage
  case class GetCount(replyTo: Int => Unit) extends CounterMessage
  
  class CounterActor extends Actor[CounterMessage]:
    private var count = 0
    
    override def receive(message: CounterMessage): Unit = message match
      case Increment =>
        count += 1
        println(s"カウント増加: $count")
        
      case Decrement =>
        count -= 1
        println(s"カウント減少: $count")
        
      case GetCount(replyTo) =>
        replyTo(count)
  
  println("\n=== 状態を持つアクター ===")
  
  val counter = new CounterActor
  counter.start()
  
  counter ! Increment
  counter ! Increment
  counter ! Decrement
  
  Thread.sleep(100)
  
  val promise = Promise[Int]()
  counter ! GetCount(count => promise.success(count))
  
  promise.future.foreach { count =>
    println(s"最終カウント: $count")
  }
  
  Thread.sleep(100)
  counter.stop()
```

### アクター間の通信

```scala
// ActorCommunication.scala
@main def actorCommunication(): Unit =
  import scala.concurrent.ExecutionContext.Implicits.global
  import java.util.concurrent.ConcurrentLinkedQueue
  import java.util.concurrent.atomic.AtomicBoolean
  
  // 改良版アクターベースクラス
  abstract class ImprovedActor[T]:
    self =>
    
    private val mailbox = new ConcurrentLinkedQueue[T]()
    private val running = new AtomicBoolean(false)
    private var thread: Option[Thread] = None
    
    def receive: PartialFunction[T, Unit]
    
    final def !(message: T): Unit = 
      mailbox.offer(message)
      
    def start(): ImprovedActor[T] =
      if running.compareAndSet(false, true) then
        thread = Some(new Thread(() => {
          while running.get() || !mailbox.isEmpty do
            Option(mailbox.poll()) match
              case Some(msg) if receive.isDefinedAt(msg) =>
                try receive(msg)
                catch case e: Exception =>
                  println(s"エラー処理: $e")
              case _ =>
                Thread.sleep(10)
        }))
        thread.foreach(_.start())
      this
    
    def stop(): Unit =
      running.set(false)
      thread.foreach(_.join(1000))
  
  // Ping-Pongアクター
  case class Ping(replyTo: ImprovedActor[Pong])
  case class Pong(replyTo: ImprovedActor[Ping])
  case object Start
  case object Stop
  
  class PingActor extends ImprovedActor[Ping | Start | Stop]:
    private var pongActor: Option[ImprovedActor[Pong]] = None
    private var count = 0
    
    def receive: PartialFunction[Ping | Start | Stop, Unit] =
      case Start =>
        println("Ping: ゲーム開始！")
        pongActor.foreach(_ ! Pong(this))
        
      case Ping(replyTo) =>
        count += 1
        println(s"Ping: ピン！ (${count}回目)")
        if count < 5 then
          Thread.sleep(500)
          replyTo ! Pong(this)
        else
          println("Ping: ゲーム終了！")
          replyTo ! Stop
          self.stop()
          
      case Stop =>
        self.stop()
    
    def setPongActor(pong: ImprovedActor[Pong]): Unit =
      pongActor = Some(pong)
  
  class PongActor extends ImprovedActor[Pong | Stop]:
    def receive: PartialFunction[Pong | Stop, Unit] =
      case Pong(replyTo) =>
        println("Pong: ポン！")
        Thread.sleep(500)
        replyTo ! Ping(this)
        
      case Stop =>
        println("Pong: お疲れ様！")
        self.stop()
  
  println("=== Ping-Pong アクター ===")
  
  val ping = new PingActor().start()
  val pong = new PongActor().start()
  
  ping.setPongActor(pong)
  ping ! Start
  
  Thread.sleep(6000)
```

## アクターによる並行処理

### ワーカープール

```scala
// ActorWorkerPool.scala
@main def actorWorkerPool(): Unit =
  import scala.concurrent.Promise
  import java.util.concurrent.atomic.AtomicInteger
  import scala.collection.concurrent.TrieMap
  
  // ジョブとその結果
  case class Job(id: Int, data: String)
  case class JobResult(jobId: Int, result: String)
  
  // メッセージ定義
  sealed trait WorkerMessage
  case class ProcessJob(job: Job) extends WorkerMessage
  case object Shutdown extends WorkerMessage
  
  sealed trait MasterMessage
  case class SubmitJob(job: Job) extends MasterMessage
  case class JobCompleted(result: JobResult) extends MasterMessage
  case class GetResults(replyTo: Map[Int, String] => Unit) extends MasterMessage
  
  // ワーカーアクター
  class WorkerActor(id: Int, master: ImprovedActor[MasterMessage]) 
    extends ImprovedActor[WorkerMessage]:
    
    def receive: PartialFunction[WorkerMessage, Unit] =
      case ProcessJob(job) =>
        println(s"Worker-$id: ジョブ ${job.id} を処理中...")
        Thread.sleep(1000) // 処理時間をシミュレート
        
        val result = job.data.toUpperCase + s" (by Worker-$id)"
        master ! JobCompleted(JobResult(job.id, result))
        
      case Shutdown =>
        println(s"Worker-$id: シャットダウン")
        stop()
  
  // マスターアクター（ワーカープール管理）
  class MasterActor(workerCount: Int) extends ImprovedActor[MasterMessage]:
    private val workers = (1 to workerCount).map { i =>
      new WorkerActor(i, this).start()
    }.toVector
    
    private val pendingJobs = scala.collection.mutable.Queue[Job]()
    private val busyWorkers = scala.collection.mutable.Set[Int]()
    private val results = TrieMap[Int, String]()
    private var nextWorker = 0
    
    def receive: PartialFunction[MasterMessage, Unit] =
      case SubmitJob(job) =>
        println(s"Master: ジョブ ${job.id} を受付")
        
        // 空いているワーカーを探す
        val availableWorker = findAvailableWorker()
        if availableWorker >= 0 then
          workers(availableWorker) ! ProcessJob(job)
          busyWorkers += availableWorker
        else
          pendingJobs.enqueue(job)
          
      case JobCompleted(result) =>
        results.put(result.jobId, result.result)
        println(s"Master: ジョブ ${result.jobId} 完了")
        
        // ワーカーを解放
        val workerId = result.result.split("Worker-")(1).split("\\)")(0).toInt - 1
        busyWorkers -= workerId
        
        // 待機中のジョブがあれば割り当て
        if pendingJobs.nonEmpty then
          val nextJob = pendingJobs.dequeue()
          workers(workerId) ! ProcessJob(nextJob)
          busyWorkers += workerId
          
      case GetResults(replyTo) =>
        replyTo(results.toMap)
    
    private def findAvailableWorker(): Int =
      (0 until workerCount).find(!busyWorkers.contains(_)).getOrElse(-1)
    
    def shutdown(): Unit =
      workers.foreach(_ ! Shutdown)
      Thread.sleep(100)
      stop()
  
  println("=== ワーカープール ===")
  
  val master = new MasterActor(3).start()
  
  // ジョブを投入
  val jobs = (1 to 10).map { i =>
    Job(i, s"データ-$i")
  }
  
  jobs.foreach { job =>
    master ! SubmitJob(job)
    Thread.sleep(200) // 投入間隔
  }
  
  // 結果を待つ
  Thread.sleep(5000)
  
  val promise = Promise[Map[Int, String]]()
  master ! GetResults(results => promise.success(results))
  
  promise.future.foreach { results =>
    println("\n=== 処理結果 ===")
    results.toList.sortBy(_._1).foreach { case (id, result) =>
      println(s"ジョブ $id: $result")
    }
  }
  
  Thread.sleep(1000)
  master.shutdown()
```

## 監督アクター

### エラーハンドリングと再起動

```scala
// SupervisorActor.scala
@main def supervisorActor(): Unit =
  import scala.util.{Try, Success, Failure}
  import java.util.concurrent.atomic.AtomicInteger
  
  // 監督戦略
  sealed trait SupervisorStrategy
  case object Restart extends SupervisorStrategy
  case object Stop extends SupervisorStrategy
  case object Escalate extends SupervisorStrategy
  
  // 監督アクター
  abstract class SupervisedActor[T] extends ImprovedActor[T]:
    private val restartCount = new AtomicInteger(0)
    
    def preRestart(reason: Throwable): Unit = ()
    def postRestart(): Unit = ()
    
    override def start(): SupervisedActor[T] =
      super.start()
      this
  
  class Supervisor[T](
    childProps: () => SupervisedActor[T],
    strategy: Throwable => SupervisorStrategy
  ) extends ImprovedActor[SupervisorMessage[T]]:
    
    private var child: Option[SupervisedActor[T]] = None
    private val childRestarts = new AtomicInteger(0)
    
    override def start(): Supervisor[T] =
      super.start()
      createChild()
      this
    
    def receive: PartialFunction[SupervisorMessage[T], Unit] =
      case Forward(msg) =>
        child.foreach(_ ! msg)
        
      case ChildFailed(error) =>
        println(s"Supervisor: 子アクターでエラー発生 - ${error.getMessage}")
        
        strategy(error) match
          case Restart =>
            if childRestarts.incrementAndGet() <= 3 then
              println("Supervisor: 子アクターを再起動します")
              restartChild()
            else
              println("Supervisor: 再起動回数が上限に達しました。停止します。")
              stopChild()
              
          case Stop =>
            println("Supervisor: 子アクターを停止します")
            stopChild()
            
          case Escalate =>
            println("Supervisor: エラーを上位にエスカレートします")
            throw error
    
    private def createChild(): Unit =
      child = Some(childProps().start())
      child.foreach(watchChild)
    
    private def restartChild(): Unit =
      stopChild()
      createChild()
    
    private def stopChild(): Unit =
      child.foreach(_.stop())
      child = None
    
    private def watchChild(actor: SupervisedActor[T]): Unit =
      // 実際の実装では、子アクターの監視メカニズムが必要
      ()
  
  // メッセージ定義
  sealed trait SupervisorMessage[T]
  case class Forward[T](message: T) extends SupervisorMessage[T]
  case class ChildFailed[T](error: Throwable) extends SupervisorMessage[T]
  
  // 不安定なワーカーアクター
  sealed trait WorkerMessage
  case class Calculate(expression: String) extends WorkerMessage
  case class Result(value: Double) extends WorkerMessage
  
  class UnstableWorker extends SupervisedActor[WorkerMessage]:
    private var processedCount = 0
    
    def receive: PartialFunction[WorkerMessage, Unit] =
      case Calculate(expr) =>
        processedCount += 1
        println(s"Worker: 計算実行 #$processedCount - $expr")
        
        // 時々エラーを起こす
        if processedCount % 3 == 0 then
          throw new RuntimeException("計算エラー！")
        
        Try(eval(expr)) match
          case Success(result) =>
            println(s"Worker: 結果 = $result")
          case Failure(e) =>
            println(s"Worker: 計算失敗 - ${e.getMessage}")
    
    private def eval(expr: String): Double =
      // 簡単な計算式の評価（実際は適切なパーサーを使用）
      expr match
        case "1+1" => 2.0
        case "10/2" => 5.0
        case "2*3" => 6.0
        case _ => throw new IllegalArgumentException("不明な式")
    
    override def preRestart(reason: Throwable): Unit =
      println(s"Worker: 再起動前処理 - ${reason.getMessage}")
      processedCount = 0
    
    override def postRestart(): Unit =
      println("Worker: 再起動完了")
  
  println("=== 監督アクター ===")
  
  // 再起動戦略
  val supervisor = new Supervisor[WorkerMessage](
    () => new UnstableWorker,
    {
      case _: RuntimeException => Restart
      case _: IllegalArgumentException => Stop
      case _ => Escalate
    }
  ).start()
  
  // 計算リクエストを送信
  val calculations = List("1+1", "10/2", "2*3", "1+1", "10/2", "unknown")
  
  calculations.foreach { calc =>
    supervisor ! Forward(Calculate(calc))
    Thread.sleep(1000)
  }
  
  Thread.sleep(2000)
  supervisor.stop()
```

## 実践例：チャットルーム

```scala
// ChatRoomActor.scala
@main def chatRoomActor(): Unit =
  import scala.collection.mutable
  import java.time.LocalDateTime
  import java.time.format.DateTimeFormatter
  
  // メッセージ定義
  sealed trait ChatMessage
  case class Join(userId: String, userActor: ImprovedActor[UserMessage]) extends ChatMessage
  case class Leave(userId: String) extends ChatMessage
  case class Broadcast(from: String, message: String) extends ChatMessage
  case class PrivateMessage(from: String, to: String, message: String) extends ChatMessage
  case class GetHistory(replyTo: List[String] => Unit) extends ChatMessage
  
  sealed trait UserMessage
  case class ReceiveMessage(from: String, message: String, timestamp: String) extends UserMessage
  case class SystemMessage(message: String) extends UserMessage
  case class PrivateReceived(from: String, message: String) extends UserMessage
  
  // チャットルームアクター
  class ChatRoomActor(roomName: String) extends ImprovedActor[ChatMessage]:
    private val users = mutable.Map[String, ImprovedActor[UserMessage]]()
    private val history = mutable.ListBuffer[String]()
    private val formatter = DateTimeFormatter.ofPattern("HH:mm:ss")
    
    def receive: PartialFunction[ChatMessage, Unit] =
      case Join(userId, userActor) =>
        users.put(userId, userActor)
        val message = s"$userId さんが入室しました"
        addToHistory(message)
        
        // 既存ユーザーに通知
        users.foreach { case (id, actor) =>
          if id != userId then
            actor ! SystemMessage(message)
        }
        
        // 新規ユーザーにウェルカムメッセージ
        userActor ! SystemMessage(s"$roomName へようこそ！")
        userActor ! SystemMessage(s"現在のユーザー: ${users.keys.mkString(", ")}")
        
      case Leave(userId) =>
        users.remove(userId)
        val message = s"$userId さんが退室しました"
        addToHistory(message)
        
        // 残りのユーザーに通知
        users.foreach { case (_, actor) =>
          actor ! SystemMessage(message)
        }
        
      case Broadcast(from, message) =>
        val timestamp = LocalDateTime.now().format(formatter)
        val fullMessage = s"[$timestamp] $from: $message"
        addToHistory(fullMessage)
        
        // 全ユーザーに配信
        users.foreach { case (id, actor) =>
          if id != from then
            actor ! ReceiveMessage(from, message, timestamp)
        }
        
      case PrivateMessage(from, to, message) =>
        users.get(to) match
          case Some(actor) =>
            actor ! PrivateReceived(from, message)
          case None =>
            users.get(from).foreach { actor =>
              actor ! SystemMessage(s"$to さんは存在しません")
            }
            
      case GetHistory(replyTo) =>
        replyTo(history.toList)
    
    private def addToHistory(message: String): Unit =
      history += s"[${LocalDateTime.now().format(formatter)}] $message"
      if history.size > 100 then history.remove(0) // 履歴の上限
  
  // ユーザーアクター
  class UserActor(userId: String) extends ImprovedActor[UserMessage]:
    def receive: PartialFunction[UserMessage, Unit] =
      case ReceiveMessage(from, message, timestamp) =>
        println(s"[$userId] $from: $message ($timestamp)")
        
      case SystemMessage(message) =>
        println(s"[$userId] [システム] $message")
        
      case PrivateReceived(from, message) =>
        println(s"[$userId] [プライベート] $from: $message")
  
  // 簡単なクライアント
  class ChatClient(userId: String, room: ImprovedActor[ChatMessage]):
    private val userActor = new UserActor(userId).start()
    
    def join(): Unit =
      room ! Join(userId, userActor)
    
    def sendMessage(message: String): Unit =
      room ! Broadcast(userId, message)
    
    def sendPrivate(to: String, message: String): Unit =
      room ! PrivateMessage(userId, to, message)
    
    def leave(): Unit =
      room ! Leave(userId)
      userActor.stop()
  
  println("=== チャットルーム ===")
  
  val chatRoom = new ChatRoomActor("Scala勉強会").start()
  
  // ユーザーが参加
  val alice = new ChatClient("Alice", chatRoom)
  val bob = new ChatClient("Bob", chatRoom)
  val charlie = new ChatClient("Charlie", chatRoom)
  
  alice.join()
  Thread.sleep(500)
  
  bob.join()
  Thread.sleep(500)
  
  charlie.join()
  Thread.sleep(500)
  
  // メッセージのやり取り
  alice.sendMessage("こんにちは、みなさん！")
  Thread.sleep(500)
  
  bob.sendMessage("こんにちは、Alice！")
  Thread.sleep(500)
  
  charlie.sendMessage("よろしくお願いします")
  Thread.sleep(500)
  
  // プライベートメッセージ
  alice.sendPrivate("Bob", "後で個別に相談があります")
  Thread.sleep(500)
  
  // 誰かが退室
  bob.leave()
  Thread.sleep(500)
  
  alice.sendMessage("Bob さん、お疲れ様でした")
  Thread.sleep(500)
  
  // 履歴を取得
  val promise = Promise[List[String]]()
  chatRoom ! GetHistory(history => promise.success(history))
  
  promise.future.foreach { history =>
    println("\n=== チャット履歴 ===")
    history.foreach(println)
  }
  
  Thread.sleep(1000)
  
  // クリーンアップ
  alice.leave()
  charlie.leave()
  chatRoom.stop()
```

## 実践例：分散タスク処理

```scala
// DistributedTaskProcessing.scala
@main def distributedTaskProcessing(): Unit =
  import scala.concurrent.duration._
  import scala.util.Random
  import java.util.UUID
  
  // タスクとその状態
  case class Task(
    id: String,
    payload: String,
    priority: Int,
    createdAt: Long = System.currentTimeMillis()
  )
  
  sealed trait TaskStatus
  case object Pending extends TaskStatus
  case object Running extends TaskStatus
  case object Completed extends TaskStatus
  case object Failed extends TaskStatus
  
  case class TaskResult(taskId: String, result: String, completedAt: Long)
  
  // メッセージ定義
  sealed trait CoordinatorMessage
  case class SubmitTask(task: Task) extends CoordinatorMessage
  case class WorkerAvailable(workerId: String) extends CoordinatorMessage
  case class TaskCompleted(workerId: String, result: TaskResult) extends CoordinatorMessage
  case class TaskFailed(workerId: String, taskId: String, error: String) extends CoordinatorMessage
  case class GetStatus(replyTo: Map[String, TaskStatus] => Unit) extends CoordinatorMessage
  
  sealed trait WorkerMessage
  case class ProcessTask(task: Task) extends WorkerMessage
  case object Stop extends WorkerMessage
  
  // タスクコーディネーター
  class TaskCoordinator extends ImprovedActor[CoordinatorMessage]:
    private val pendingTasks = mutable.PriorityQueue[Task]()(
      Ordering.by(t => (t.priority, -t.createdAt))
    )
    private val runningTasks = mutable.Map[String, (Task, String)]() // taskId -> (task, workerId)
    private val taskStatus = mutable.Map[String, TaskStatus]()
    private val taskResults = mutable.Map[String, TaskResult]()
    private val availableWorkers = mutable.Queue[String]()
    private val workers = mutable.Map[String, ImprovedActor[WorkerMessage]]()
    
    def receive: PartialFunction[CoordinatorMessage, Unit] =
      case SubmitTask(task) =>
        println(s"Coordinator: タスク ${task.id} を受付 (優先度: ${task.priority})")
        pendingTasks.enqueue(task)
        taskStatus(task.id) = Pending
        assignTasks()
        
      case WorkerAvailable(workerId) =>
        availableWorkers.enqueue(workerId)
        assignTasks()
        
      case TaskCompleted(workerId, result) =>
        runningTasks.remove(result.taskId)
        taskStatus(result.taskId) = Completed
        taskResults(result.taskId) = result
        println(s"Coordinator: タスク ${result.taskId} 完了")
        
        availableWorkers.enqueue(workerId)
        assignTasks()
        
      case TaskFailed(workerId, taskId, error) =>
        runningTasks.get(taskId).foreach { case (task, _) =>
          println(s"Coordinator: タスク $taskId 失敗 - $error")
          taskStatus(taskId) = Failed
          
          // リトライ（優先度を下げて）
          if task.priority > 1 then
            val retryTask = task.copy(priority = task.priority - 1)
            pendingTasks.enqueue(retryTask)
            println(s"Coordinator: タスク $taskId をリトライキューに追加")
        }
        
        availableWorkers.enqueue(workerId)
        assignTasks()
        
      case GetStatus(replyTo) =>
        replyTo(taskStatus.toMap)
    
    private def assignTasks(): Unit =
      while availableWorkers.nonEmpty && pendingTasks.nonEmpty do
        val workerId = availableWorkers.dequeue()
        val task = pendingTasks.dequeue()
        
        workers.get(workerId).foreach { worker =>
          worker ! ProcessTask(task)
          runningTasks(task.id) = (task, workerId)
          taskStatus(task.id) = Running
          println(s"Coordinator: タスク ${task.id} を Worker-$workerId に割当")
        }
    
    def registerWorker(workerId: String, worker: ImprovedActor[WorkerMessage]): Unit =
      workers(workerId) = worker
      availableWorkers.enqueue(workerId)
  
  // ワーカー
  class TaskWorker(
    workerId: String,
    coordinator: ImprovedActor[CoordinatorMessage]
  ) extends ImprovedActor[WorkerMessage]:
    
    def receive: PartialFunction[WorkerMessage, Unit] =
      case ProcessTask(task) =>
        println(s"Worker-$workerId: タスク ${task.id} の処理開始")
        
        try
          // 処理時間をシミュレート
          val processingTime = Random.nextInt(2000) + 1000
          Thread.sleep(processingTime)
          
          // 時々失敗する
          if Random.nextDouble() < 0.2 then
            throw new RuntimeException("処理エラー")
          
          val result = TaskResult(
            task.id,
            s"${task.payload.toUpperCase} (processed by $workerId)",
            System.currentTimeMillis()
          )
          
          coordinator ! TaskCompleted(workerId, result)
          
        catch
          case e: Exception =>
            coordinator ! TaskFailed(workerId, task.id, e.getMessage)
        
      case Stop =>
        println(s"Worker-$workerId: 停止")
        stop()
  
  println("=== 分散タスク処理 ===")
  
  val coordinator = new TaskCoordinator().start()
  
  // ワーカーを起動
  val workerCount = 3
  val workers = (1 to workerCount).map { i =>
    val workerId = s"W$i"
    val worker = new TaskWorker(workerId, coordinator).start()
    coordinator.registerWorker(workerId, worker)
    (workerId, worker)
  }
  
  // タスクを投入
  val tasks = (1 to 15).map { i =>
    Task(
      id = UUID.randomUUID().toString.take(8),
      payload = s"データ-$i",
      priority = Random.nextInt(5) + 1
    )
  }
  
  println("\n=== タスク投入 ===")
  tasks.foreach { task =>
    coordinator ! SubmitTask(task)
    Thread.sleep(200)
  }
  
  // 処理完了を待つ
  Thread.sleep(10000)
  
  // ステータス確認
  val statusPromise = Promise[Map[String, TaskStatus]]()
  coordinator ! GetStatus(status => statusPromise.success(status))
  
  statusPromise.future.foreach { status =>
    println("\n=== 最終ステータス ===")
    val grouped = status.groupBy(_._2).mapValues(_.size)
    grouped.foreach { case (status, count) =>
      println(s"$status: $count 件")
    }
  }
  
  Thread.sleep(1000)
  
  // クリーンアップ
  workers.foreach { case (_, worker) => worker ! Stop }
  coordinator.stop()
```

## 練習してみよう！

### 練習1：銀行システム

アクターモデルで銀行システムを実装してください：
- 口座アクター（残高管理）
- 送金処理
- トランザクションログ

### 練習2：在庫管理システム

商品在庫を管理するシステムを作ってください：
- 在庫の増減
- 複数倉庫の管理
- 在庫不足の通知

### 練習3：ゲームサーバー

マルチプレイヤーゲームのサーバーを実装してください：
- プレイヤーアクター
- ゲームルームアクター
- マッチメイキング

## この章のまとめ

アクターモデルの素晴らしさを体験できました！

### できるようになったこと

✅ **アクターの基本**
- メッセージパッシング
- 状態のカプセル化
- 非同期通信

✅ **アクターパターン**
- ワーカープール
- スーパーバイザー
- パブリッシュ・サブスクライブ

✅ **実践的な応用**
- チャットシステム
- タスク分散処理
- エラーハンドリング

✅ **設計の原則**
- 単一責任
- 位置透過性
- 耐障害性

### アクターモデルを使うコツ

1. **メッセージ設計**
   - イミュータブルに
   - 明確な意図
   - 適切な粒度

2. **エラー処理**
   - Let it crash
   - 監督階層
   - 適切な再起動戦略

3. **パフォーマンス**
   - メールボックスサイズ
   - 背圧制御
   - 適切な並行度

### 次の章では...

テストを書く方法について学びます。品質の高いコードを書くための必須スキルを身につけましょう！

### 最後に

アクターモデルは「独立した職人たちの協働」です。それぞれが自分の仕事に集中し、必要な時だけメッセージで連絡を取り合う。この美しいモデルは、複雑な並行処理を驚くほどシンプルに表現できます。舞台上の俳優のように、それぞれのアクターが輝く、そんなシステムを作れるようになりました！