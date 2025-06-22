# 第30章 for式の内部動作

## はじめに

電車の乗り換えを考えてみてください。「新宿から渋谷へ行く」とき、いくつかの路線の選択肢があります。それぞれの路線で、それぞれの駅を経由して、最終的に目的地に着く。途中で乗り換えに失敗したら、そこで終了です。

Scalaのfor式も同じです。一見シンプルな構文の裏側で、複雑な処理の連鎖を美しく表現しているんです！

## for式の基本を振り返る

### シンプルなfor式

```scala
// ForExpressionBasics.scala
@main def forExpressionBasics(): Unit = {
  // 基本的なfor式
  val numbers = List(1, 2, 3, 4, 5)
  
  println("=== 基本的なfor式 ===")
  for (n <- numbers) {
    println(s"数値: $n")
  }
  
  // これは実際には以下と同じ
  println("\n=== mapを使った同等の処理 ===")
  numbers.foreach(n => println(s"数値: $n"))
  
  // yield付きfor式
  val doubled = for n <- numbers yield n * 2
  println(s"\n2倍: $doubled")
  
  // これは実際には以下と同じ
  val doubled2 = numbers.map(n => n * 2)
  println(s"mapの結果: $doubled2")
  
  // 複数のジェネレータ
  val pairs = for {
    x <- List(1, 2, 3)
    y <- List('a', 'b')
  } yield (x, y)
  
  println(s"\nペア: $pairs")
  
  // これは実際には以下と同じ
  val pairs2 = List(1, 2, 3).flatMap(x =>
    List('a', 'b').map(y => (x, y))
  )
  println(s"flatMap/mapの結果: $pairs2")
```

### フィルタ付きfor式

```scala
// ForWithFilters.scala
@main def forWithFilters(): Unit = {
  // フィルタ（if条件）付きfor式
  val numbers = 1 to 10
  
  val evens = for {
    n <- numbers
    if n % 2 == 0
  } yield n
  
  println(s"偶数: $evens")
  
  // これは実際には以下と同じ
  val evens2 = numbers
    .filter(n => n % 2 == 0)
    .map(n => n)
  
  println(s"filter/mapの結果: $evens2")
  
  // 複数の条件
  val result = for {
    x <- 1 to 5
    y <- 1 to 5
    if x < y
    if x + y > 5
  } yield (x, y)
  
  println(s"\n条件を満たすペア: $result")
  
  // これは実際には以下と同じ
  val result2 = (1 to 5).flatMap(x =>
    (1 to 5)
      .filter(y => x < y)
      .filter(y => x + y > 5)
      .map(y => (x, y))
  )
  
  println(s"展開した結果: $result2")
```

## for式の変換規則

### 基本的な変換

```scala
// ForTransformation.scala
@main def forTransformation(): Unit = {
  // 1. 単一ジェネレータ + yield
  // for x <- expr yield f(x)
  // => expr.map(x => f(x))
  
  val list1 = for x <- List(1, 2, 3) yield x * x
  val list2 = List(1, 2, 3).map(x => x * x)
  println(s"単一ジェネレータ: $list1 == $list2")
  
  // 2. 単一ジェネレータ（yieldなし）
  // for x <- expr do action(x)
  // => expr.foreach(x => action(x))
  
  var sum1 = 0
  for (x <- List(1, 2, 3)) {
    sum1 += x
  }
  
  var sum2 = 0
  List(1, 2, 3).foreach(x => sum2 += x)
  println(s"副作用: sum1=$sum1, sum2=$sum2")
  
  // 3. 複数ジェネレータ
  // for x <- expr1; y <- expr2 yield f(x, y)
  // => expr1.flatMap(x => expr2.map(y => f(x, y)))
  
  val pairs1 = for {
    x <- List(1, 2)
    y <- List('a', 'b')
  } yield s"$x$y"
  
  val pairs2 = List(1, 2).flatMap(x =>
    List('a', 'b').map(y => s"$x$y")
  )
  println(s"複数ジェネレータ: $pairs1 == $pairs2")
  
  // 4. フィルタ付き
  // for x <- expr if p(x) yield f(x)
  // => expr.filter(p).map(f)
  
  val filtered1 = for {
    x <- 1 to 10
    if x % 3 == 0
  } yield x * 2
  
  val filtered2 = (1 to 10)
    .filter(x => x % 3 == 0)
    .map(x => x * 2)
  
  println(s"フィルタ付き: $filtered1 == $filtered2")
```

### パターンマッチとfor式

```scala
// ForPatternMatching.scala
@main def forPatternMatching(): Unit = {
  val pairs = List((1, "one"), (2, "two"), (3, "three"))
  
  // パターンマッチを使ったfor式
  val result1 = for (num, word) <- pairs yield s"$num: $word"
  println(s"パターンマッチ: $result1")
  
  // 実際の変換
  val result2 = pairs.map { case (num, word) => s"$num: $word" }
  println(s"展開後: $result2")
  
  // 部分的なマッチ
  val mixed = List(
    Some(1),
    None,
    Some(2),
    Some(3),
    None
  )
  
  val values1 = for Some(x) <- mixed yield x * 2
  println(s"\nSomeのみ: $values1")
  
  // 実際の変換（フィルタ付き）
  val values2 = mixed.collect { case Some(x) => x * 2 }
  println(s"collect使用: $values2")
  
  // ネストしたパターン
  val nested = List(
    ("A", Some(1)),
    ("B", None),
    ("C", Some(3))
  )
  
  val extracted = for {
    (label, Some(value)) <- nested
  } yield s"$label=$value"
  
  println(s"\nネストパターン: $extracted")
```

## Option、Either、Tryでのfor式

### Optionとfor式

```scala
// ForWithOption.scala
@main def forWithOption(): Unit = {
  // Optionを使った安全な計算
  def parseInt(s: String): Option[Int] =
    try {
      Some(s.toInt)
    } catch {
      case _: NumberFormatException => None
    }
  
  def divide(a: Int, b: Int): Option[Double] =
    if (b != 0) Some(a.toDouble / b) else None
  
  // for式で連鎖
  val result1 = for {
    a <- parseInt("10")
    b <- parseInt("2")
    c <- divide(a, b)
  } yield c
  
  println(s"成功ケース: $result1")
  
  // 実際の変換
  val result2 = parseInt("10").flatMap(a =>
    parseInt("2").flatMap(b =>
      divide(a, b).map(c => c)
    )
  )
  
  println(s"展開後: $result2")
  
  // エラーケース
  val error1 = for {
    a <- parseInt("10")
    b <- parseInt("0")
    c <- divide(a, b)  // ここで失敗
  } yield c
  
  println(s"\nエラーケース: $error1")
  
  // 複雑な例
  case class User(id: Int, name: String)
  case class Account(userId: Int, balance: Double)
  
  def findUser(id: Int): Option[User] =
    if (id > 0) Some(User(id, s"User$id")) else None
  
  def findAccount(userId: Int): Option[Account] =
    if (userId > 0) Some(Account(userId, 1000.0 * userId)) else None
  
  def checkBalance(account: Account, amount: Double): Option[Boolean] =
    Some(account.balance >= amount)
  
  val transaction = for {
    user <- findUser(123)
    account <- findAccount(user.id)
    canWithdraw <- checkBalance(account, 500)
  } yield (user.name, account.balance, canWithdraw)
  
  println(s"\nトランザクション: $transaction")
```

### Eitherとfor式

```scala
// ForWithEither.scala
@main def forWithEither(): Unit = {
  // エラーハンドリング付き計算
  type Result[A] = Either[String, A]
  
  def parseIntE(s: String): Result[Int] =
    try {
      Right(s.toInt)
    } catch {
      case _: NumberFormatException => Left(s"'$s'は数値ではありません")
    }
  
  def divideE(a: Int, b: Int): Result[Double] =
    if (b != 0) Right(a.toDouble / b)
    else Left("ゼロ除算エラー")
  
  def sqrtE(x: Double): Result[Double] =
    if (x >= 0) Right(math.sqrt(x))
    else Left(s"負の数の平方根: $x")
  
  // 成功ケース
  val success = for {
    a <- parseIntE("100")
    b <- parseIntE("4")
    divided <- divideE(a, b)
    result <- sqrtE(divided)
  } yield result
  
  println(s"成功: $success")
  
  // エラーケース（最初のエラーで停止）
  val error = for {
    a <- parseIntE("abc")  // ここでエラー
    b <- parseIntE("4")
    divided <- divideE(a, b)
    result <- sqrtE(divided)
  } yield result
  
  println(s"エラー: $error")
  
  // 実際の変換を理解する
  val manual = parseIntE("100").flatMap { a =>
    parseIntE("4").flatMap { b =>
      divideE(a, b).flatMap { divided =>
        sqrtE(divided).map { result =>
          result
        }
      }
    }
  }
  
  println(s"手動展開: $manual")
```

## カスタム型でfor式を使う

### 独自のコンテナ型

```scala
// CustomForComprehension.scala
@main def customForComprehension(): Unit = {
  // 独自のMaybe型
  sealed trait Maybe[+A]:
    def map[B](f: A => B): Maybe[B]
    def flatMap[B](f: A => Maybe[B]): Maybe[B]
    def filter(p: A => Boolean): Maybe[A]
  
  case class Just[A](value: A) extends Maybe[A]:
    def map[B](f: A => B): Maybe[B] = Just(f(value))
    def flatMap[B](f: A => Maybe[B]): Maybe[B] = f(value)
    def filter(p: A => Boolean): Maybe[A] = 
      if (p(value)) this else Empty
  
  case object Empty extends Maybe[Nothing]:
    def map[B](f: Nothing => B): Maybe[B] = Empty
    def flatMap[B](f: Nothing => Maybe[B]): Maybe[B] = Empty
    def filter(p: Nothing => Boolean): Maybe[Nothing] = Empty
  
  // for式が使える！
  val result = for {
    x <- Just(10)
    y <- Just(20)
    if x < y
  } yield x + y
  
  println(s"Maybe型でのfor式: $result")
  
  // ログ付きコンテナ
  case class Logged[A](value: A, log: List[String]):
    def map[B](f: A => B): Logged[B] =
      Logged(f(value), log)
    
    def flatMap[B](f: A => Logged[B]): Logged[B] =
      val Logged(newValue, newLog) = f(value)
      Logged(newValue, log ++ newLog)
    
    def withFilter(p: A => Boolean): Logged[A] =
      if p(value) then this
      else Logged(value, log :+ s"フィルタ失敗: $value")
  
  def addWithLog(x: Int, y: Int): Logged[Int] =
    Logged(x + y, List(s"$x + $y = ${x + y}"))
  
  def multiplyWithLog(x: Int, y: Int): Logged[Int] =
    Logged(x * y, List(s"$x * $y = ${x * y}"))
  
  val calculation = for
    a <- Logged(10, List("初期値: 10"))
    b <- addWithLog(a, 5)
    c <- multiplyWithLog(b, 2)
  yield c
  
  println(s"\n計算結果: ${calculation.value}")
  println("ログ:")
  calculation.log.foreach(msg => println(s"  $msg"))
```

### モナド則

```scala
// MonadLaws.scala
@main def monadLaws(): Unit =
  // モナド則を確認
  trait Monad[F[_]]:
    def pure[A](a: A): F[A]
    def flatMap[A, B](fa: F[A])(f: A => F[B]): F[B]
    
    // map はflatMapとpureから導出
    def map[A, B](fa: F[A])(f: A => B): F[B] =
      flatMap(fa)(a => pure(f(a)))
  
  // Optionのモナドインスタンス
  given optionMonad: Monad[Option] with
    def pure[A](a: A): Option[A] = Some(a)
    def flatMap[A, B](fa: Option[A])(f: A => Option[B]): Option[B] =
      fa.flatMap(f)
  
  // モナド則の確認
  def checkMonadLaws[F[_]: Monad, A, B, C](
    a: A,
    f: A => F[B],
    g: B => F[C]
  )(fa: F[A]): Unit =
    val m = summon[Monad[F]]
    
    // 左単位元則: pure(a).flatMap(f) == f(a)
    val law1Left = m.flatMap(m.pure(a))(f)
    val law1Right = f(a)
    println(s"左単位元則: $law1Left == $law1Right")
    
    // 右単位元則: fa.flatMap(pure) == fa
    val law2Left = m.flatMap(fa)(m.pure)
    val law2Right = fa
    println(s"右単位元則: $law2Left == $law2Right")
    
    // 結合則: fa.flatMap(f).flatMap(g) == fa.flatMap(x => f(x).flatMap(g))
    val law3Left = m.flatMap(m.flatMap(fa)(f))(g)
    val law3Right = m.flatMap(fa)(x => m.flatMap(f(x))(g))
    println(s"結合則: $law3Left == $law3Right")
  
  // テスト
  println("=== Optionのモナド則 ===")
  checkMonadLaws[Option, Int, String, Int](
    42,
    x => Some(x.toString),
    s => Some(s.length)
  )(Some(10))
  
  // for式での確認
  println("\n=== for式とモナド則 ===")
  
  // 左単位元則のfor式表現
  val a = 42
  val f: Int => Option[String] = x => Some(x.toString)
  
  val forResult1 = for
    x <- Some(a)
    y <- f(x)
  yield y
  
  val directResult1 = f(a)
  println(s"for式: $forResult1 == 直接: $directResult1")
  
  // 結合則のfor式表現
  val g: String => Option[Int] = s => Some(s.length)
  
  val forResult2 = for
    x <- Some(10)
    y <- f(x)
    z <- g(y)
  yield z
  
  val nestedResult = Some(10).flatMap(x => 
    f(x).flatMap(y => g(y))
  )
  println(s"for式: $forResult2 == ネスト: $nestedResult")
```

## 実践例：非同期処理の合成

```scala
// AsyncForComprehension.scala
@main def asyncForComprehension(): Unit =
  import scala.concurrent.{Future, Promise}
  import scala.concurrent.ExecutionContext.Implicits.global
  import scala.concurrent.duration._
  import scala.util.{Success, Failure}
  
  // 非同期API
  def fetchUser(id: Int): Future[String] = Future {
    Thread.sleep(100)
    s"User$id"
  }
  
  def fetchScore(user: String): Future[Int] = Future {
    Thread.sleep(100)
    user.length * 10
  }
  
  def fetchRank(score: Int): Future[String] = Future {
    Thread.sleep(100)
    if score > 50 then "Gold" 
    else if score > 30 then "Silver"
    else "Bronze"
  }
  
  // for式で非同期処理を合成
  val result = for
    user <- fetchUser(123)
    score <- fetchScore(user)
    rank <- fetchRank(score)
  yield s"$user: $score points ($rank)"
  
  // 実際の変換
  val manual = fetchUser(123).flatMap { user =>
    fetchScore(user).flatMap { score =>
      fetchRank(score).map { rank =>
        s"$user: $score points ($rank)"
      }
    }
  }
  
  // 結果を待つ
  result.onComplete {
    case Success(value) => println(s"成功: $value")
    case Failure(error) => println(s"エラー: $error")
  }
  
  Thread.sleep(500)
  
  // 並列実行
  println("\n=== 並列実行 ===")
  
  val parallel = for
    (user1, user2) <- fetchUser(1).zip(fetchUser(2))
    (score1, score2) <- fetchScore(user1).zip(fetchScore(user2))
  yield s"$user1=$score1, $user2=$score2"
  
  parallel.onComplete {
    case Success(value) => println(s"並列結果: $value")
    case Failure(error) => println(s"エラー: $error")
  }
  
  Thread.sleep(300)
```

## 練習してみよう！

### 練習1：Stateモナド

状態を持つ計算を表現するStateモナドを実装して、for式で使えるようにしてください：
- 状態の読み取り
- 状態の更新
- 計算の連鎖

### 練習2：Writerモナド

ログを蓄積しながら計算するWriterモナドを作ってください：
- 値とログの組み合わせ
- ログの結合
- for式での使用

### 練習3：IO モナド

副作用を表現するIOモナドを実装してください：
- 遅延評価
- 副作用の合成
- エラーハンドリング

## この章のまとめ

for式の内部動作を深く理解できました！

### できるようになったこと

✅ **for式の変換規則**
- map、flatMap、filter への変換
- yield の有無による違い
- パターンマッチの展開

✅ **様々な型での使用**
- Option、Either、Try
- Future での非同期処理
- カスタム型の実装

✅ **モナドの理解**
- モナド則
- flatMap の重要性
- 計算の合成

✅ **実践的な応用**
- エラーハンドリング
- 非同期処理
- ログ付き計算

### for式を使いこなすコツ

1. **内部動作を理解する**
    - map、flatMap への変換
    - どこで失敗するか
    - パフォーマンスへの影響

2. **適切な型を選ぶ**
    - Option：値の有無
    - Either：エラー情報
    - Future：非同期処理

3. **読みやすさを重視**
    - ネストを避ける
    - 意味のある変数名
    - 適度な分割

### 次の部では...

第VIII部では、コレクションの使いこなしについて学びます。効率的なデータ処理のテクニックを習得しましょう！

### 最後に

for式は「モナドの糖衣構文」と呼ばれます。難しそうに聞こえますが、実は「計算の連鎖を美しく書く方法」なんです。map、flatMapの連鎖を、まるで普通の手続き的なコードのように書ける。この魔法を使いこなせば、複雑な処理も驚くほどシンプルに表現できるようになります！