# 第26章 型パラメータ入門

## はじめに

お弁当箱を思い出してください。同じお弁当箱でも、ご飯を入れたり、サンドイッチを入れたり、パスタを入れたりできますよね。でも「お弁当箱」という基本的な機能（食べ物を入れる、持ち運ぶ）は変わりません。

型パラメータも同じです。「何を入れるか」は後で決められる、柔軟な「入れ物」を作ることができるんです！

## 型パラメータって何だろう？

### ジェネリックな箱を作る

```scala
// GenericBoxBasics.scala
@main def genericBoxBasics(): Unit = {
  // 型パラメータを使わない場合（不便...）
  class IntBox(value: Int):
    def getValue: Int = value
  
  class StringBox(value: String):
    def getValue: String = value
  
  // 型パラメータを使う場合（便利！）
  class Box[T](value: T):
    def getValue: T = value
    def contains(item: T): Boolean = value == item
    def map[U](f: T => U): Box[U] = Box(f(value))
  
  // いろいろな型で使える
  val intBox = Box(42)
  val stringBox = Box("Hello")
  val boolBox = Box(true)
  
  println(s"整数の箱: ${intBox.getValue}")
  println(s"文字列の箱: ${stringBox.getValue}")
  println(s"真偽値の箱: ${boolBox.getValue}")
  
  // mapで変換
  val doubledBox = intBox.map(_ * 2)
  val upperBox = stringBox.map(_.toUpperCase)
  
  println(s"\n変換後:")
  println(s"2倍: ${doubledBox.getValue}")
  println(s"大文字: ${upperBox.getValue}")
```

### 複数の型パラメータ

```scala
// MultipleTypeParameters.scala
@main def multipleTypeParameters(): Unit = {
  // 2つの型パラメータを持つペア
  class Pair[A, B](val first: A, val second: B):
    def swap: Pair[B, A] = Pair(second, first)
    def map[C, D](f1: A => C, f2: B => D): Pair[C, D] = 
      Pair(f1(first), f2(second))
    override def toString: String = s"($first, $second)"
  
  val namAge = Pair("太郎", 25)
  val swapped = namAge.swap
  
  println(s"元のペア: $namAge")
  println(s"入れ替え: $swapped")
  
  // それぞれを変換
  val transformed = namAge.map(
    _.toUpperCase,
    _ * 2
  )
  println(s"変換後: $transformed")
  
  // 実用例：エラー付き結果
  class Result[E, A](value: Either[E, A]):
    def isSuccess: Boolean = value.isRight
    def isError: Boolean = value.isLeft
    
    def map[B](f: A => B): Result[E, B] = 
      Result(value.map(f))
    
    def flatMap[B](f: A => Result[E, B]): Result[E, B] =
      Result(value.flatMap(a => f(a).value))
    
    def getOrElse(default: A): A = value.getOrElse(default)
    
    def toOption: Option[A] = value.toOption
  
  object Result:
    def success[E, A](value: A): Result[E, A] = Result(Right(value))
    def error[E, A](error: E): Result[E, A] = Result(Left(error))
  
  // 使用例
  def divide(a: Int, b: Int): Result[String, Double] =
    if (b == 0) Result.error("ゼロ除算エラー")
    else Result.success(a.toDouble / b)
  
  val result1 = divide(10, 2)
  val result2 = divide(10, 0)
  
  println(s"\n10 ÷ 2 = ${result1.toOption}")
  println(s"10 ÷ 0 = ${result2.toOption}")
```

## 実践的な型パラメータ

### ジェネリックなコレクション

```scala
// GenericCollections.scala
@main def genericCollections(): Unit = {
  // 簡単なスタックの実装
  class Stack[A]:
    private var elements: List[A] = List.empty
    
    def push(elem: A): Unit =
      elements = elem :: elements
    
    def pop(): Option[A] =
      elements match {
        case head :: tail =>
          elements = tail
          Some(head)
        case Nil =>
          None
      }
    
    def peek: Option[A] = elements.headOption
    
    def isEmpty: Boolean = elements.isEmpty
    
    def size: Int = elements.length
    
    def map[B](f: A => B): Stack[B] =
      val newStack = Stack[B]()
      elements.reverse.foreach(elem => newStack.push(f(elem)))
      newStack
    
    override def toString: String = 
      s"Stack(${elements.mkString(", ")})"
  
  // 整数のスタック
  val intStack = Stack[Int]()
  intStack.push(1)
  intStack.push(2)
  intStack.push(3)
  
  println("=== 整数スタック ===")
  println(s"現在: $intStack")
  println(s"ポップ: ${intStack.pop()}")
  println(s"ポップ後: $intStack")
  
  // 文字列のスタック
  val stringStack = Stack[String]()
  stringStack.push("Hello")
  stringStack.push("World")
  
  println("\n=== 文字列スタック ===")
  println(s"現在: $stringStack")
  
  // スタックの変換
  val upperStack = stringStack.map(_.toUpperCase)
  println(s"大文字化: $upperStack")
  
  // キューの実装
  class Queue[A]:
    private var front: List[A] = List.empty
    private var back: List[A] = List.empty
    
    def enqueue(elem: A): Unit =
      back = elem :: back
    
    def dequeue(): Option[A] =
      front match {
        case head :: tail =>
          front = tail
          Some(head)
        case Nil =>
          if (back.nonEmpty) {
            front = back.reverse
            back = List.empty
            dequeue()
          } else {
            None
          }
      }
    
    def isEmpty: Boolean = front.isEmpty && back.isEmpty
    
    override def toString: String =
      s"Queue(${(front ++ back.reverse).mkString(", ")})"
  
  // キューの使用例
  val queue = Queue[String]()
  queue.enqueue("A")
  queue.enqueue("B")
  queue.enqueue("C")
  
  println("\n=== キュー ===")
  println(s"現在: $queue")
  println(s"デキュー: ${queue.dequeue()}")
  println(s"デキュー後: $queue")
```

### ジェネリックなツリー構造

```scala
// GenericTree.scala
@main def genericTree(): Unit = {
  // 二分木の定義
  enum BinaryTree[+A]:
    case Empty
    case Node(value: A, left: BinaryTree[A], right: BinaryTree[A])
  
  import BinaryTree.*
  
  // ツリー操作のヘルパーオブジェクト
  object BinaryTree:
    def leaf[A](value: A): BinaryTree[A] = Node(value, Empty, Empty)
    
    def size[A](tree: BinaryTree[A]): Int = tree match {
      case Empty => 0
      case Node(_, left, right) => 1 + size(left) + size(right)
    }
    
    def depth[A](tree: BinaryTree[A]): Int = tree match {
      case Empty => 0
      case Node(_, left, right) => 1 + math.max(depth(left), depth(right))
    }
    
    def map[A, B](tree: BinaryTree[A])(f: A => B): BinaryTree[B] = 
      tree match {
        case Empty => Empty
        case Node(value, left, right) =>
          Node(f(value), map(left)(f), map(right)(f))
      }
    
    def contains[A](tree: BinaryTree[A])(value: A): Boolean =
      tree match {
        case Empty => false
        case Node(v, left, right) =>
          v == value || contains(left)(value) || contains(right)(value)
      }
    
    def toList[A](tree: BinaryTree[A]): List[A] = tree match {
      case Empty => List.empty
      case Node(value, left, right) =>
        toList(left) ++ List(value) ++ toList(right)
    }
  
  // サンプルツリー
  val intTree = Node(
    10,
    Node(5, leaf(3), leaf(7)),
    Node(15, leaf(12), leaf(20))
  )
  
  println("=== 整数の二分木 ===")
  println(s"サイズ: ${BinaryTree.size(intTree)}")
  println(s"深さ: ${BinaryTree.depth(intTree)}")
  println(s"要素: ${BinaryTree.toList(intTree)}")
  println(s"7を含む？: ${BinaryTree.contains(intTree)(7)}")
  
  // ツリーの変換
  val doubledTree = BinaryTree.map(intTree)(_ * 2)
  println(s"\n2倍したツリー: ${BinaryTree.toList(doubledTree)}")
  
  // 文字列のツリー
  val stringTree = Node(
    "B",
    Node("A", Empty, Empty),
    Node("C", Empty, Empty)
  )
  
  val lowerTree = BinaryTree.map(stringTree)(_.toLowerCase)
  println(s"\n小文字化: ${BinaryTree.toList(lowerTree)}")
```

## 型パラメータとメソッド

```scala
// GenericMethods.scala
@main def genericMethods(): Unit = {
  // ジェネリックなメソッド
  def swap[A, B](pair: (A, B)): (B, A) = (pair._2, pair._1)
  
  def first[A](list: List[A]): Option[A] = list.headOption
  
  def repeat[A](elem: A, times: Int): List[A] = 
    List.fill(times)(elem)
  
  def zipWith[A, B, C](list1: List[A], list2: List[B])(f: (A, B) => C): List[C] =
    list1.zip(list2).map { case (a, b) => f(a, b) }
  
  // 使用例
  println("=== ジェネリックメソッド ===")
  println(s"swap((1, 'a')) = ${swap((1, 'a'))}")
  println(s"first(List(1,2,3)) = ${first(List(1,2,3))}")
  println(s"repeat('X', 5) = ${repeat('X', 5)}")
  
  val numbers = List(1, 2, 3)
  val strings = List("one", "two", "three")
  val combined = zipWith(numbers, strings)((n, s) => s"$n:$s")
  println(s"zipWith = $combined")
  
  // より実用的な例：キャッシュ
  class Cache[K, V]:
    private val store = scala.collection.mutable.Map[K, V]()
    private val accessTime = scala.collection.mutable.Map[K, Long]()
    
    def put(key: K, value: V): Unit =
      store(key) = value
      accessTime(key) = System.currentTimeMillis()
    
    def get(key: K): Option[V] =
      store.get(key).map { value =>
        accessTime(key) = System.currentTimeMillis()
        value
      }
    
    def getOrCompute(key: K)(compute: => V): V =
      get(key).getOrElse {
        val value = compute
        put(key, value)
        value
      }
    
    def evictOldest(keep: Int): Unit =
      if (store.size > keep) {
        val toRemove = accessTime.toList
          .sortBy(_._2)
          .take(store.size - keep)
          .map(_._1)
        
        toRemove.foreach { key =>
          store.remove(key)
          accessTime.remove(key)
        }
      }
    
    def size: Int = store.size
    
    override def toString: String = 
      s"Cache(${store.mkString(", ")})"
  
  // キャッシュの使用
  val cache = Cache[String, Int]()
  
  println("\n=== キャッシュ ===")
  println(s"計算結果: ${cache.getOrCompute("expensive")(42)}")
  println(s"キャッシュから: ${cache.get("expensive")}")
  
  cache.put("a", 1)
  cache.put("b", 2)
  cache.put("c", 3)
  
  println(s"現在のキャッシュ: $cache")
  
  Thread.sleep(10)
  cache.get("a")  // aにアクセス
  
  cache.evictOldest(2)
  println(s"古いものを削除後: $cache")
```

## 実践例：ジェネリックなパーサー

```scala
// GenericParser.scala
@main def genericParser(): Unit = {
  // パーサーの結果
  case class ParseResult[+A](value: A, remaining: String)
  
  // パーサーの型
  trait Parser[+A]:
    def parse(input: String): Option[ParseResult[A]]
    
    def map[B](f: A => B): Parser[B] = new Parser[B] {
      def parse(input: String): Option[ParseResult[B]] =
        Parser.this.parse(input).map { result =>
          ParseResult(f(result.value), result.remaining)
        }
    }
    
    def flatMap[B](f: A => Parser[B]): Parser[B] = new Parser[B] {
      def parse(input: String): Option[ParseResult[B]] =
        Parser.this.parse(input).flatMap { result =>
          f(result.value).parse(result.remaining)
        }
    }
    
    def ~[B](other: Parser[B]): Parser[(A, B)] = 
      for {
        a <- this
        b <- other
      } yield (a, b)
    
    def |[B >: A](other: Parser[B]): Parser[B] = new Parser[B] {
      def parse(input: String): Option[ParseResult[B]] =
        Parser.this.parse(input).orElse(other.parse(input))
    }
  
  // 基本的なパーサー
  object Parser {
    def char(c: Char): Parser[Char] = new Parser[Char] {
      def parse(input: String): Option[ParseResult[Char]] =
        if (input.nonEmpty && input.head == c) {
          Some(ParseResult(c, input.tail))
        } else {
          None
        }
    }
    
    def string(s: String): Parser[String] = new Parser[String] {
      def parse(input: String): Option[ParseResult[String]] =
        if (input.startsWith(s)) {
          Some(ParseResult(s, input.drop(s.length)))
        } else {
          None
        }
    }
    
    def digit: Parser[Char] = new Parser[Char] {
      def parse(input: String): Option[ParseResult[Char]] =
        if (input.nonEmpty && input.head.isDigit) {
          Some(ParseResult(input.head, input.tail))
        } else {
          None
        }
    }
    
    def letter: Parser[Char] = new Parser[Char] {
      def parse(input: String): Option[ParseResult[Char]] =
        if (input.nonEmpty && input.head.isLetter) {
          Some(ParseResult(input.head, input.tail))
        } else {
          None
        }
    }
    
    def many[A](p: Parser[A]): Parser[List[A]] = new Parser[List[A]] {
      def parse(input: String): Option[ParseResult[List[A]]] = {
        var remaining = input
        val results = scala.collection.mutable.ListBuffer[A]()
        
        while ({
          p.parse(remaining) match {
            case Some(ParseResult(value, rest)) =>
              results += value
              remaining = rest
              true
            case None =>
              false
          }
        }) {}
        
        Some(ParseResult(results.toList, remaining))
      }
    }
    
    def many1[A](p: Parser[A]): Parser[List[A]] =
      for {
        first <- p
        rest <- many(p)
      } yield first :: rest
  }
  
  import Parser.*
  
  // 数値パーサー
  val number: Parser[Int] = many1(digit).map(_.mkString.toInt)
  
  // 識別子パーサー
  val identifier: Parser[String] = 
    for {
      first <- letter
      rest <- many(letter | digit)
    } yield (first :: rest).mkString
  
  // 使用例
  println("=== パーサーの実行 ===")
  
  number.parse("123abc") match {
    case Some(ParseResult(value, remaining)) =>
      println(s"数値: $value, 残り: '$remaining'")
    case None =>
      println("パース失敗")
  }
  
  identifier.parse("hello123world") match {
    case Some(ParseResult(value, remaining)) =>
      println(s"識別子: $value, 残り: '$remaining'")
    case None =>
      println("パース失敗")
  }
  
  // より複雑な例：代入文のパーサー
  val assign = 
    for {
      id <- identifier
      _ <- string(" = ")
      num <- number
    } yield (id, num)
  
  assign.parse("count = 42") match {
    case Some(ParseResult((id, value), remaining)) =>
      println(s"代入: $id = $value")
    case None =>
      println("パース失敗")
  }
```

## 型パラメータの実践活用

```scala
// PracticalTypeParameters.scala
@main def practicalTypeParameters(): Unit = {
  // イベントエミッター
  class EventEmitter[E]:
    private var listeners: List[E => Unit] = List.empty
    
    def on(listener: E => Unit): Unit =
      listeners = listener :: listeners
    
    def off(listener: E => Unit): Unit =
      listeners = listeners.filterNot(_ == listener)
    
    def emit(event: E): Unit =
      listeners.foreach(_.apply(event))
  
  // イベントの定義
  sealed trait UserEvent
  case class Login(userId: String, timestamp: Long) extends UserEvent
  case class Logout(userId: String, timestamp: Long) extends UserEvent
  case class Error(message: String) extends UserEvent
  
  // 使用例
  val userEvents = EventEmitter[UserEvent]()
  
  val loginHandler: UserEvent => Unit = {
    case Login(id, time) => println(s"ユーザー $id がログイン（$time）")
    case _ => ()
  }
  
  val errorHandler: UserEvent => Unit = {
    case Error(msg) => println(s"エラー: $msg")
    case _ => ()
  }
  
  userEvents.on(loginHandler)
  userEvents.on(errorHandler)
  
  println("=== イベント発行 ===")
  userEvents.emit(Login("user123", System.currentTimeMillis()))
  userEvents.emit(Error("接続失敗"))
  userEvents.emit(Logout("user123", System.currentTimeMillis()))
  
  // ジェネリックなビルダーパターン
  class Builder[T]:
    private var instance: Option[T] = None
    
    def build(f: => T): Builder[T] =
      instance = Some(f)
      this
    
    def configure(f: T => T): Builder[T] =
      instance = instance.map(f)
      this
    
    def get: Option[T] = instance
    
    def getOrElse(default: T): T = instance.getOrElse(default)
  
  case class Config(
    host: String = "localhost",
    port: Int = 8080,
    ssl: Boolean = false
  )
  
  val config = Builder[Config]()
    .build(Config())
    .configure(_.copy(host = "example.com"))
    .configure(_.copy(port = 443))
    .configure(_.copy(ssl = true))
    .get
  
  println(s"\n設定: $config")
```

## 練習してみよう！

### 練習1：ジェネリックなリンクリスト

単方向リンクリストを実装してください：
- 要素の追加、削除
- map、filter、foldの実装
- reverseメソッド

### 練習2：ジェネリックなOption

独自のOption型を実装してください：
- Some[A]とNoneの実装
- map、flatMap、filterメソッド
- getOrElseメソッド

### 練習3：ジェネリックなメモ化

任意の関数をメモ化する仕組みを作ってください：
- 引数と結果のキャッシュ
- キャッシュサイズの制限
- 統計情報（ヒット率など）

## この章のまとめ

型パラメータの基礎を学びました！

### できるようになったこと

✅ **型パラメータの基本**
- ジェネリッククラス
- 型安全な汎用コード
- 複数の型パラメータ

✅ **実践的な使い方**
- コレクションの実装
- ツリー構造
- パーサーコンビネータ

✅ **ジェネリックメソッド**
- 型推論の活用
- 高階関数との組み合わせ
- 再利用可能なユーティリティ

✅ **設計パターン**
- ビルダーパターン
- イベントエミッター
- キャッシュの実装

### 型パラメータを使うコツ

1. **意味のある名前**
    - T: Type（一般的な型）
    - K, V: Key, Value
    - E: Element/Event/Error
    - A, B: 関数の入出力

2. **適切な抽象度**
    - 必要十分な制約
    - 過度な一般化を避ける
    - 使いやすさを重視

3. **型推論の活用**
    - 明示的な型指定を最小限に
    - コンパイラに推論させる
    - 必要な箇所のみ明示

### 次の章では...

境界と変位指定について学びます。型パラメータにより柔軟な制約を設定する方法を習得しましょう！

### 最後に

型パラメータは「万能の道具箱」のようなものです。中身は後で決められるけど、道具箱としての機能は変わらない。この柔軟性が、同じコードを様々な場面で使い回せる秘訣です。一度書いたら、どこでも使える。これがジェネリックプログラミングの醍醐味です！