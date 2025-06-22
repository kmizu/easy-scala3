# 第20章 Future[T]で非同期処理

## はじめに

レストランで注文をしたとき、料理ができるまで席で待ちますよね。その間、スマホを見たり、友達と話したりできます。これが「非同期処理」の考え方です。

プログラムでも、時間のかかる処理（ファイル読み込み、ネットワーク通信など）を待っている間、他の作業を進められたら効率的です。Scalaの`Future`を使えば、これが簡単にできます！

## 非同期処理って何だろう？

### 同期処理 vs 非同期処理

```scala
// SyncVsAsync.scala
@main def syncVsAsync(): Unit = {
  import scala.concurrent.{Future, ExecutionContext}
  import scala.concurrent.duration.*
  import ExecutionContext.Implicits.global
  
  // 同期処理（順番に実行）
  println("=== 同期処理 ===")
  def cookSync(dish: String): String = {
    println(s"$dish の調理開始...")
    Thread.sleep(2000)  // 2秒かかる
    println(s"$dish 完成！")
    dish
  }
  
  val start1 = System.currentTimeMillis()
  cookSync("パスタ")
  cookSync("サラダ")
  cookSync("スープ")
  val end1 = System.currentTimeMillis()
  println(s"合計時間: ${end1 - start1}ms\n")
  
  // 非同期処理（同時に実行）
  println("=== 非同期処理 ===")
  def cookAsync(dish: String): Future[String] = Future {
    println(s"$dish の調理開始...")
    Thread.sleep(2000)  // 2秒かかる
    println(s"$dish 完成！")
    dish
  }
  
  val start2 = System.currentTimeMillis()
  val pastaFuture = cookAsync("パスタ")
  val saladFuture = cookAsync("サラダ")
  val soupFuture = cookAsync("スープ")
  
  // すべての料理が完成するまで待つ
  Thread.sleep(3000)
  val end2 = System.currentTimeMillis()
  println(s"合計時間: ${end2 - start2}ms")
}
```

## Futureの基本

### Futureの作成

```scala
// FutureBasics.scala
@main def futureBasics(): Unit = {
  import scala.concurrent.{Future, Await}
  import scala.concurrent.duration.*
  import scala.concurrent.ExecutionContext.Implicits.global
  
  // 単純なFuture
  val future1: Future[Int] = Future {
    Thread.sleep(1000)
    42
  }
  
  println("Futureを作成しました（まだ完了していません）")
  
  // 結果を待つ
  val result = Await.result(future1, 2.seconds)
  println(s"結果: $result")
  
  // すぐに完了するFuture
  val future2 = Future.successful(100)
  val future3 = Future.failed(new Exception("エラー！"))
  
  // 実用例：複数の計算を並行実行
  def heavyCalculation(n: Int): Future[Int] = Future {
    println(s"計算開始: $n")
    Thread.sleep(1000)
    val result = n * n
    println(s"計算完了: $n * $n = $result")
    result
  }
  
  val calculations = List(1, 2, 3, 4, 5).map(heavyCalculation)
  val allResults = Future.sequence(calculations)
  
  val results = Await.result(allResults, 3.seconds)
  println(s"すべての結果: $results")
}
```

### Futureのコールバック

```scala
// FutureCallbacks.scala
@main def futureCallbacks(): Unit = {
  import scala.concurrent.Future
  import scala.concurrent.ExecutionContext.Implicits.global
  import scala.util.{Success, Failure}
  
  // onComplete：成功でも失敗でも実行
  val future1 = Future {
    Thread.sleep(500)
    if (scala.util.Random.nextBoolean()) 42
    else throw new Exception("ランダムエラー")
  }
  
  future1.onComplete {
    case Success(value) => println(s"成功: $value")
    case Failure(error) => println(s"失敗: ${error.getMessage}")
  }
  
  // foreach：成功時のみ実行
  val future2 = Future {
    Thread.sleep(300)
    "Hello, Future!"
  }
  
  future2.foreach { message =>
    println(s"メッセージ: $message")
  }
  
  // 実用例：ファイルダウンロード通知
  def downloadFile(url: String): Future[String] = Future {
    println(s"ダウンロード開始: $url")
    Thread.sleep(1000)
    s"${url}のコンテンツ"
  }
  
  val download = downloadFile("https://example.com/data.txt")
  
  download.onComplete {
    case Success(content) =>
      println("ダウンロード成功！")
      println(s"内容: ${content.take(20)}...")
    case Failure(error) =>
      println(s"ダウンロード失敗: ${error.getMessage}")
  }
  
  Thread.sleep(1500)  // 完了まで待つ
}
```

## Futureの変換と合成

### map、flatMap、filter

```scala
// FutureTransformations.scala
@main def futureTransformations(): Unit = {
  import scala.concurrent.{Future, Await}
  import scala.concurrent.duration.*
  import scala.concurrent.ExecutionContext.Implicits.global
  
  // map：値を変換
  val future1 = Future(10)
  val doubled = future1.map(_ * 2)
  
  println(s"2倍: ${Await.result(doubled, 1.second)}")
  
  // flatMap：Futureを返す関数と組み合わせ
  def getUserId(name: String): Future[Int] = Future {
    Thread.sleep(500)
    name.length  // 仮のID
  }
  
  def getUserScore(id: Int): Future[Int] = Future {
    Thread.sleep(500)
    id * 100  // 仮のスコア
  }
  
  val scoresFuture = for {
    id <- getUserId("太郎")
    score <- getUserScore(id)
  } yield score
  
  println(s"スコア: ${Await.result(scoresFuture, 2.seconds)}")
  
  // filter：条件を満たさない場合は失敗
  val numbers = Future(42)
  val filtered = numbers.filter(_ > 50)
  
  try {
    Await.result(filtered, 1.second)
  } catch {
    case _: NoSuchElementException =>
      println("条件を満たしませんでした")
  }
}
```

### 複数のFutureを組み合わせる

```scala
// CombiningFutures.scala
@main def combiningFutures(): Unit = {
  import scala.concurrent.{Future, Await}
  import scala.concurrent.duration.*
  import scala.concurrent.ExecutionContext.Implicits.global
  
  // 複数のAPIを同時に呼ぶ
  def fetchUserData(userId: Int): Future[String] = Future {
    Thread.sleep(800)
    s"ユーザー$userId のデータ"
  }
  
  def fetchUserPosts(userId: Int): Future[List[String]] = Future {
    Thread.sleep(1000)
    List(s"投稿1", s"投稿2", s"投稿3")
  }
  
  def fetchUserFriends(userId: Int): Future[List[String]] = Future {
    Thread.sleep(600)
    List("友達A", "友達B")
  }
  
  // すべてのデータを同時に取得
  val userId = 123
  
  val allDataFuture = for {
    userData <- fetchUserData(userId)
    posts <- fetchUserPosts(userId)
    friends <- fetchUserFriends(userId)
  } yield (userData, posts, friends)
  
  val (userData, posts, friends) = Await.result(allDataFuture, 2.seconds)
  println(s"ユーザーデータ: $userData")
  println(s"投稿: $posts")
  println(s"友達: $friends")
  
  // Future.sequence：リストのFutureをFutureのリストに
  val userIds = List(1, 2, 3)
  val allUsersFuture = Future.sequence(
    userIds.map(fetchUserData)
  )
  
  val allUsers = Await.result(allUsersFuture, 2.seconds)
  println(s"全ユーザー: $allUsers")
}
```

## エラーハンドリング

### recoverとrecoverWith

```scala
// FutureErrorHandling.scala
@main def futureErrorHandling(): Unit = {
  import scala.concurrent.{Future, Await}
  import scala.concurrent.duration.*
  import scala.concurrent.ExecutionContext.Implicits.global
  
  // エラーが起きるかもしれない処理
  def riskyOperation(n: Int): Future[Int] = Future {
    if (n < 0) throw new IllegalArgumentException("負の数は禁止")
    else if (n == 0) throw new ArithmeticException("ゼロは特別")
    else n * 10
  }
  
  // recover：エラーを値に変換
  val recovered1 = riskyOperation(-5).recover {
    case _: IllegalArgumentException => 0
    case _: ArithmeticException => 1
  }
  
  println(s"リカバー1: ${Await.result(recovered1, 1.second)}")
  
  // recoverWith：エラーを別のFutureに変換
  def fallbackOperation(n: Int): Future[Int] = Future {
    println(s"フォールバック処理: $n")
    100
  }
  
  val recovered2 = riskyOperation(0).recoverWith {
    case _: ArithmeticException => fallbackOperation(0)
  }
  
  println(s"リカバー2: ${Await.result(recovered2, 1.second)}")
  
  // transform：成功と失敗の両方を変換
  val transformed = riskyOperation(5).transform(
    success = value => value + 1,
    failure = {
      case _: IllegalArgumentException => new Exception("不正な引数")
      case other => other
    }
  )
  
  println(s"変換後: ${Await.result(transformed, 1.second)}")
}
```

## 実践例：Web APIクライアント

```scala
// WebApiClient.scala
@main def webApiClient(): Unit = {
  import scala.concurrent.{Future, Promise}
  import scala.concurrent.duration.*
  import scala.concurrent.ExecutionContext.Implicits.global
  import scala.util.{Try, Success, Failure}
  
  // 模擬的なHTTPクライアント
  object HttpClient {
    def get(url: String): Future[String] = Future {
      Thread.sleep(scala.util.Random.nextInt(1000))
      if (scala.util.Random.nextDouble() > 0.8) {
        throw new Exception(s"接続エラー: $url")
      } else {
        s"""{"status": "ok", "data": "Response from $url"}"""
      }
    }
  }
  
  // APIクライアント
  class ApiClient {
    def fetchWithRetry(url: String, maxRetries: Int = 3): Future[String] = {
      def attempt(retriesLeft: Int): Future[String] =
        HttpClient.get(url).recoverWith {
          case error if retriesLeft > 0 =>
            println(s"リトライします（残り${retriesLeft}回）: ${error.getMessage}")
            Thread.sleep(500)
            attempt(retriesLeft - 1)
          case error =>
            Future.failed(error)
        }
      
      attempt(maxRetries)
    }
    
    def fetchMultiple(urls: List[String]): Future[List[String]] = {
      val futures = urls.map(fetchWithRetry(_, 2))
      Future.sequence(futures)
    }
    
    def fetchFirstSuccessful(urls: List[String]): Future[String] =
      Future.firstCompletedOf(urls.map(HttpClient.get))
  }
  
  val client = new ApiClient
  
  // 単一のAPIコール（リトライ付き）
  println("=== 単一APIコール ===")
  client.fetchWithRetry("https://api.example.com/user/123").onComplete {
    case Success(response) => println(s"成功: $response")
    case Failure(error) => println(s"最終的に失敗: ${error.getMessage}")
  }
  
  // 複数のAPIコール
  println("\n=== 複数APIコール ===")
  val urls = List(
    "https://api.example.com/data1",
    "https://api.example.com/data2",
    "https://api.example.com/data3"
  )
  
  client.fetchMultiple(urls).onComplete {
    case Success(responses) =>
      println("すべて成功:")
      responses.foreach(println)
    case Failure(error) =>
      println(s"いずれかが失敗: ${error.getMessage}")
  }
  
  Thread.sleep(5000)  // 完了まで待つ
}
```

## タイムアウトとキャンセル

```scala
// TimeoutAndCancel.scala
@main def timeoutAndCancel(): Unit = {
  import scala.concurrent.{Future, Promise, TimeoutException}
  import scala.concurrent.duration.*
  import scala.concurrent.ExecutionContext.Implicits.global
  import java.util.concurrent.Executors
  import java.util.concurrent.ScheduledExecutorService
  
  // タイムアウト付きFuture
  def withTimeout[T](future: Future[T], duration: Duration): Future[T] = {
    val promise = Promise[T]()
    
    future.onComplete(promise.tryComplete)
    
    val scheduler = Executors.newScheduledThreadPool(1)
    scheduler.schedule(
      () => promise.tryFailure(new TimeoutException(s"${duration}でタイムアウト")),
      duration.toMillis,
      java.util.concurrent.TimeUnit.MILLISECONDS
    )
    
    promise.future
  }
  
  // 遅い処理
  def slowOperation(): Future[String] = Future {
    Thread.sleep(3000)  // 3秒かかる
    "完了！"
  }
  
  // 2秒でタイムアウト
  val timedOut = withTimeout(slowOperation(), 2.seconds)
  
  timedOut.onComplete {
    case Success(result) => println(s"成功: $result")
    case Failure(_: TimeoutException) => println("タイムアウトしました")
    case Failure(error) => println(s"エラー: ${error.getMessage}")
  }
  
  Thread.sleep(4000)
}
```

## 実用的なパターン

### 並行実行の制限

```scala
// ConcurrencyControl.scala
@main def concurrencyControl(): Unit = {
  import scala.concurrent.{Future, ExecutionContext}
  import scala.concurrent.duration.*
  import java.util.concurrent.Executors
  
  // 同時実行数を制限したExecutionContext
  val limitedEC = ExecutionContext.fromExecutor(
    Executors.newFixedThreadPool(2)  // 最大2並列
  )
  
  def task(id: Int): Future[Int] = Future {
    println(s"タスク$id 開始")
    Thread.sleep(1000)
    println(s"タスク$id 完了")
    id
  }(limitedEC)  // 制限付きECを使用
  
  // 5つのタスクを実行（同時に2つまで）
  val tasks = (1 to 5).map(task)
  val allTasks = Future.sequence(tasks)(ExecutionContext.global)
  
  Thread.sleep(3000)
  
  // バッチ処理
  def processBatch[T, R](
    items: List[T], 
    batchSize: Int
  )(f: T => Future[R]): Future[List[R]] = {
    items.grouped(batchSize).foldLeft(Future.successful(List.empty[R])) {
      (accFuture, batch) =>
        accFuture.flatMap { acc =>
          Future.sequence(batch.map(f)).map(acc ++ _)
        }
    }(ExecutionContext.global)
  }
}
}
```

## 練習してみよう！

### 練習1：並行ダウンロード

複数のURLから同時にデータをダウンロードし、すべてのダウンロードが完了したら結果をまとめる関数を作ってください。

### 練習2：タイムアウト付きリトライ

指定された回数までリトライし、各試行にタイムアウトを設定できる関数を作ってください。

### 練習3：プログレスバー

複数の非同期タスクの進行状況を表示するシステムを作ってください。

## この章のまとめ

非同期処理の基本を学びました！

### できるようになったこと

✅ **Futureの基本**
- 非同期処理の作成
- 結果の取得
- コールバックの設定

✅ **Futureの操作**
- map, flatMapでの変換
- 複数Futureの組み合わせ
- エラーハンドリング

✅ **実践的な使い方**
- Web APIクライアント
- リトライ機構
- タイムアウト処理

✅ **並行制御**
- 実行数の制限
- バッチ処理
- 効率的な並行実行

### 非同期処理のコツ

1. **ブロッキングを避ける**
    - Await.resultは最小限に
    - コールバックやmapを活用
    - 非同期の連鎖を保つ

2. **エラーハンドリング**
    - recoverで優雅に回復
    - タイムアウトの設定
    - リトライの実装

3. **リソース管理**
    - ExecutionContextの適切な選択
    - 並行数の制限
    - リソースのクリーンアップ

### 次の章では...

Try[T]を使った例外処理について詳しく学びます。エラーを値として扱う、より安全なプログラミングを習得しましょう！

### 最後に

非同期処理は「並行作業の達人」です。レストランの厨房で、複数の料理人が同時に違う料理を作るように、プログラムも複数の処理を同時に進められます。最初は混乱するかもしれませんが、マスターすれば処理速度が劇的に向上します。未来（Future）は明るいですよ！