# 第29章 型クラスパターン

## はじめに

料理のレシピを考えてみてください。「焼く」という調理法は、肉でも魚でも野菜でも使えますが、それぞれ焼き方が違いますよね。肉は表面を焼いて中はジューシーに、魚は皮をパリッと、野菜は焦げ目をつけて甘みを引き出す。

型クラスパターンも同じです。「同じ操作」を「違う型」に対して「それぞれの方法」で実装できる、とても柔軟な仕組みなんです！

## 型クラスって何だろう？

### 基本的な型クラス

```scala
// TypeClassBasics.scala
@main def typeClassBasics(): Unit = {
  // 型クラスの定義：「表示できる」という性質
  trait Show[A]:
    def show(value: A): String
  
  // 型クラスのインスタンス（実装）
  object Show:
    // Intの表示方法
    implicit val intShow: Show[Int] = new Show[Int]:
      def show(value: Int): String = s"整数: $value"
    
    // Stringの表示方法
    implicit val stringShow: Show[String] = new Show[String]:
      def show(value: String): String = s"文字列: \"$value\""
    
    // Booleanの表示方法
    implicit val booleanShow: Show[Boolean] = new Show[Boolean]:
      def show(value: Boolean): String = if (value) "真" else "偽"
  
  // 型クラスを使う関数
  def display[A](value: A)(implicit shower: Show[A]): String =
    shower.show(value)
  
  // より便利な構文
  def display2[A: Show](value: A): String =
    implicitly[Show[A]].show(value)
  
  import Show._
  
  // 使用例
  println(display(42))
  println(display("Hello"))
  println(display(true))
  
  // カスタム型への対応
  case class Person(name: String, age: Int)
  
  // Personの表示方法を定義
  implicit val personShow: Show[Person] = new Show[Person]:
    def show(person: Person): String = 
      s"${person.name}さん（${person.age}歳）"
  
  val person = Person("太郎", 25)
  println(display(person))
```

### 型クラスの合成

```scala
// TypeClassComposition.scala
@main def typeClassComposition(): Unit = {
  // 等価性を判定する型クラス
  trait Eq[A]:
    def equals(a1: A, a2: A): Boolean
    def notEquals(a1: A, a2: A): Boolean = !equals(a1, a2)
  
  object Eq:
    def apply[A](implicit eq: Eq[A]): Eq[A] = eq
    
    // 基本型のインスタンス
    implicit val intEq: Eq[Int] = new Eq[Int]:
      def equals(a1: Int, a2: Int): Boolean = a1 == a2
    
    implicit val stringEq: Eq[String] = new Eq[String]:
      def equals(a1: String, a2: String): Boolean = a1 == a2
    
    // オプション型の自動導出
    implicit def optionEq[A](implicit eqA: Eq[A]): Eq[Option[A]] = 
      new Eq[Option[A]]:
        def equals(o1: Option[A], o2: Option[A]): Boolean = 
          (o1, o2) match {
            case (Some(a1), Some(a2)) => eqA.equals(a1, a2)
            case (None, None) => true
            case _ => false
          }
    
    // リスト型の自動導出
    implicit def listEq[A](implicit eqA: Eq[A]): Eq[List[A]] =
      new Eq[List[A]]:
        def equals(l1: List[A], l2: List[A]): Boolean =
          l1.length == l2.length && 
          l1.zip(l2).forall { case (a1, a2) => eqA.equals(a1, a2) }
  
  // 便利な拡張メソッド
  extension [A](a: A)(using eq: Eq[A])
    def ===(other: A): Boolean = eq.equals(a, other)
    def =!=(other: A): Boolean = eq.notEquals(a, other)
  
  import Eq._
  
  // 基本型の比較
  println("=== 基本型の比較 ===")
  println(s"10 === 10: ${10 === 10}")
  println(s"10 === 20: ${10 === 20}")
  println(s"\"hello\" === \"hello\": ${"hello" === "hello"}")
  
  // 自動導出された型の比較
  println("\n=== 複合型の比較 ===")
  println(s"Some(42) === Some(42): ${Some(42) === Some(42)}")
  println(s"Some(42) === Some(99): ${Some(42) === Some(99)}")
  println(s"List(1,2,3) === List(1,2,3): ${List(1,2,3) === List(1,2,3)}")
  
  // カスタム型
  case class Point(x: Int, y: Int)
  
  implicit val pointEq: Eq[Point] = new Eq[Point]:
    def equals(p1: Point, p2: Point): Boolean =
      p1.x == p2.x && p1.y == p2.y
  
  val p1 = Point(10, 20)
  val p2 = Point(10, 20)
  val p3 = Point(30, 40)
  
  println(s"\n=== カスタム型の比較 ===")
  println(s"$p1 === $p2: ${p1 === p2}")
  println(s"$p1 === $p3: ${p1 === p3}")
```

## 実践的な型クラス

### JSONエンコーダー

```scala
// JsonTypeClass.scala
@main def jsonTypeClass(): Unit = {
  import scala.collection.mutable.StringBuilder
  
  // JSON値の表現
  sealed trait Json
  case class JsonString(value: String) extends Json
  case class JsonNumber(value: Double) extends Json
  case class JsonBoolean(value: Boolean) extends Json
  case class JsonArray(values: List[Json]) extends Json
  case class JsonObject(fields: Map[String, Json]) extends Json
  case object JsonNull extends Json
  
  // JSONエンコーダー型クラス
  trait JsonEncoder[A]:
    def encode(value: A): Json
  
  object JsonEncoder:
    def apply[A](implicit encoder: JsonEncoder[A]): JsonEncoder[A] = encoder
    
    // 基本型のエンコーダー
    implicit val stringEncoder: JsonEncoder[String] = 
      (value: String) => JsonString(value)
    
    implicit val intEncoder: JsonEncoder[Int] = 
      (value: Int) => JsonNumber(value.toDouble)
    
    implicit val doubleEncoder: JsonEncoder[Double] = 
      (value: Double) => JsonNumber(value)
    
    implicit val booleanEncoder: JsonEncoder[Boolean] = 
      (value: Boolean) => JsonBoolean(value)
    
    // コレクション型のエンコーダー
    implicit def listEncoder[A](implicit encoder: JsonEncoder[A]): JsonEncoder[List[A]] =
      (values: List[A]) => JsonArray(values.map(encoder.encode))
    
    implicit def optionEncoder[A](implicit encoder: JsonEncoder[A]): JsonEncoder[Option[A]] =
      (value: Option[A]) => value match {
        case Some(v) => encoder.encode(v)
        case None => JsonNull
      }
    
    implicit def mapEncoder[A](implicit encoder: JsonEncoder[A]): JsonEncoder[Map[String, A]] =
      (map: Map[String, A]) => JsonObject(
        map.map { case (k, v) => k -> encoder.encode(v) }
      )
  
  // 拡張メソッド
  extension [A](value: A)(using encoder: JsonEncoder[A])
    def toJson: Json = encoder.encode(value)
  
  // JSON文字列への変換
  def jsonToString(json: Json): String = json match {
    case JsonString(s) => s""""$s""""
    case JsonNumber(n) => n.toString
    case JsonBoolean(b) => b.toString
    case JsonArray(values) => 
      values.map(jsonToString).mkString("[", ", ", "]")
    case JsonObject(fields) =>
      fields.map { case (k, v) => 
        s""""$k": ${jsonToString(v)}"""
      }.mkString("{", ", ", "}")
    case JsonNull => "null"
  }
  
  // カスタム型
  case class User(
    id: Int,
    name: String,
    email: String,
    active: Boolean,
    tags: List[String]
  )
  
  case class Post(
    title: String,
    content: String,
    author: User,
    likes: Int
  )
  
  // カスタム型のエンコーダー
  implicit val userEncoder: JsonEncoder[User] = (user: User) =>
    JsonObject(Map(
      "id" -> user.id.toJson,
      "name" -> user.name.toJson,
      "email" -> user.email.toJson,
      "active" -> user.active.toJson,
      "tags" -> user.tags.toJson
    ))
  
  implicit val postEncoder: JsonEncoder[Post] = (post: Post) =>
    JsonObject(Map(
      "title" -> post.title.toJson,
      "content" -> post.content.toJson,
      "author" -> post.author.toJson,
      "likes" -> post.likes.toJson
    ))
  
  // 使用例
  val user = User(
    id = 1,
    name = "田中太郎",
    email = "tanaka@example.com",
    active = true,
    tags = List("scala", "関数型")
  )
  
  val post = Post(
    title = "型クラスの紹介",
    content = "型クラスはとても便利です",
    author = user,
    likes = 42
  )
  
  println("=== JSONエンコード ===")
  println(jsonToString(user.toJson))
  println()
  println(jsonToString(post.toJson))
  
  // リストのエンコード
  val users = List(
    User(1, "太郎", "taro@example.com", true, List("scala")),
    User(2, "花子", "hanako@example.com", false, List("java", "kotlin"))
  )
  
  println("\n=== リストのエンコード ===")
  println(jsonToString(users.toJson))
```

### 順序付け型クラス

```scala
// OrderingTypeClass.scala
@main def orderingTypeClass(): Unit = {
  // 順序付け型クラス
  trait Ordering[A]:
    def compare(a1: A, a2: A): Int
    
    def lt(a1: A, a2: A): Boolean = compare(a1, a2) < 0
    def lte(a1: A, a2: A): Boolean = compare(a1, a2) <= 0
    def gt(a1: A, a2: A): Boolean = compare(a1, a2) > 0
    def gte(a1: A, a2: A): Boolean = compare(a1, a2) >= 0
    def equiv(a1: A, a2: A): Boolean = compare(a1, a2) == 0
    
    def max(a1: A, a2: A): A = if (gte(a1, a2)) a1 else a2
    def min(a1: A, a2: A): A = if (lte(a1, a2)) a1 else a2
  
  object Ordering:
    // 基本型の順序
    implicit val intOrdering: Ordering[Int] = new Ordering[Int]:
      def compare(a1: Int, a2: Int): Int = a1 - a2
    
    implicit val stringOrdering: Ordering[String] = new Ordering[String]:
      def compare(a1: String, a2: String): Int = a1.compareTo(a2)
    
    // 逆順
    def reverse[A](implicit ord: Ordering[A]): Ordering[A] = new Ordering[A]:
      def compare(a1: A, a2: A): Int = -ord.compare(a1, a2)
    
    // タプルの順序
    implicit def tuple2Ordering[A, B](implicit 
      ordA: Ordering[A], 
      ordB: Ordering[B]
    ): Ordering[(A, B)] = new Ordering[(A, B)]:
      def compare(t1: (A, B), t2: (A, B)): Int = {
        val cmp1 = ordA.compare(t1._1, t2._1)
        if (cmp1 != 0) cmp1
        else ordB.compare(t1._2, t2._2)
      }
  
  // ソート関数
  def quickSort[A](list: List[A])(implicit ord: Ordering[A]): List[A] = 
    list match {
      case Nil => Nil
      case pivot :: tail =>
        val (smaller, larger) = tail.partition(ord.lt(_, pivot))
        quickSort(smaller) ++ List(pivot) ++ quickSort(larger)
    }
  
  // カスタム型
  case class Person(name: String, age: Int)
  case class Product(name: String, price: Double, rating: Double)
  
  // カスタム型の順序
  object Person:
    implicit val byAge: Ordering[Person] = new Ordering[Person]:
      def compare(p1: Person, p2: Person): Int = p1.age - p2.age
    
    val byName: Ordering[Person] = new Ordering[Person]:
      def compare(p1: Person, p2: Person): Int = p1.name.compareTo(p2.name)
  
  object Product:
    implicit val byPrice: Ordering[Product] = new Ordering[Product]:
      def compare(p1: Product, p2: Product): Int = 
        p1.price.compareTo(p2.price)
    
    val byRating: Ordering[Product] = new Ordering[Product]:
      def compare(p1: Product, p2: Product): Int = 
        p2.rating.compareTo(p1.rating)  // 高い順
  
  // 使用例
  val numbers = List(3, 1, 4, 1, 5, 9, 2, 6)
  println("=== 数値のソート ===")
  println(s"元: $numbers")
  println(s"昇順: ${quickSort(numbers)}")
  println(s"降順: ${quickSort(numbers)(using Ordering.reverse[Int])}")
  
  val people = List(
    Person("太郎", 25),
    Person("花子", 30),
    Person("次郎", 20)
  )
  
  println("\n=== 人物のソート ===")
  println(s"年齢順: ${quickSort(people)}")
  println(s"名前順: ${quickSort(people)(using Person.byName)}")
  
  val products = List(
    Product("ノートPC", 80000, 4.5),
    Product("マウス", 3000, 4.0),
    Product("キーボード", 10000, 4.8)
  )
  
  println("\n=== 商品のソート ===")
  println("価格順（安い順）:")
  quickSort(products).foreach(p => 
    println(f"  ${p.name}%-10s ¥${p.price}%,8.0f ★${p.rating}")
  )
  
  println("\n評価順（高い順）:")
  quickSort(products)(using Product.byRating).foreach(p => 
    println(f"  ${p.name}%-10s ★${p.rating} ¥${p.price}%,8.0f")
  )
```

## 高度な型クラスパターン

### モノイド型クラス

```scala
// MonoidTypeClass.scala
@main def monoidTypeClass(): Unit =
  // モノイド：結合法則を満たす二項演算と単位元を持つ
  trait Monoid[A]:
    def empty: A  // 単位元
    def combine(a1: A, a2: A): A  // 結合演算
    
    // 便利なメソッド
    def combineAll(as: List[A]): A = 
      as.foldLeft(empty)(combine)
  
  object Monoid:
    def apply[A](implicit m: Monoid[A]): Monoid[A] = m
    
    // 基本型のモノイド
    implicit val intAddMonoid: Monoid[Int] = new Monoid[Int]:
      def empty: Int = 0
      def combine(a1: Int, a2: Int): Int = a1 + a2
    
    implicit val stringMonoid: Monoid[String] = new Monoid[String]:
      def empty: String = ""
      def combine(a1: String, a2: String): String = a1 + a2
    
    implicit def listMonoid[A]: Monoid[List[A]] = new Monoid[List[A]]:
      def empty: List[A] = List.empty
      def combine(a1: List[A], a2: List[A]): List[A] = a1 ++ a2
    
    // タプルのモノイド
    implicit def tuple2Monoid[A, B](implicit 
      ma: Monoid[A], 
      mb: Monoid[B]
    ): Monoid[(A, B)] = new Monoid[(A, B)]:
      def empty: (A, B) = (ma.empty, mb.empty)
      def combine(t1: (A, B), t2: (A, B)): (A, B) = 
        (ma.combine(t1._1, t2._1), mb.combine(t1._2, t2._2))
  
  // 拡張メソッド
  extension [A](a: A)(using m: Monoid[A])
    def |+|(other: A): A = m.combine(a, other)
  
  // 実用例：統計情報の集計
  case class Stats(
    count: Int,
    sum: Double,
    min: Double,
    max: Double
  ):
    def mean: Option[Double] = 
      if count > 0 then Some(sum / count) else None
  
  object Stats:
    def single(value: Double): Stats = 
      Stats(1, value, value, value)
    
    implicit val statsMonoid: Monoid[Stats] = new Monoid[Stats]:
      def empty: Stats = Stats(0, 0.0, Double.MaxValue, Double.MinValue)
      def combine(s1: Stats, s2: Stats): Stats = Stats(
        count = s1.count + s2.count,
        sum = s1.sum + s2.sum,
        min = math.min(s1.min, s2.min),
        max = math.max(s1.max, s2.max)
      )
  
  // マップのモノイド
  implicit def mapMonoid[K, V](implicit mv: Monoid[V]): Monoid[Map[K, V]] = 
    new Monoid[Map[K, V]]:
      def empty: Map[K, V] = Map.empty
      def combine(m1: Map[K, V], m2: Map[K, V]): Map[K, V] =
        m2.foldLeft(m1) { case (acc, (k, v)) =>
          acc.updatedWith(k) {
            case Some(v1) => Some(mv.combine(v1, v))
            case None => Some(v)
          }
        }
  
  // 使用例
  println("=== 基本的なモノイド ===")
  println(s"1 |+| 2 |+| 3 = ${1 |+| 2 |+| 3}")
  println(s"\"Hello\" |+| \" \" |+| \"World\" = ${"Hello" |+| " " |+| "World"}")
  
  val lists = List(List(1, 2), List(3, 4), List(5))
  println(s"リストの結合: ${Monoid[List[Int]].combineAll(lists)}")
  
  println("\n=== 統計情報の集計 ===")
  val measurements = List(10.5, 20.3, 15.8, 25.1, 18.9)
  val stats = measurements.map(Stats.single).reduce(_ |+| _)
  
  println(f"件数: ${stats.count}")
  println(f"合計: ${stats.sum}%.1f")
  println(f"最小: ${stats.min}%.1f")
  println(f"最大: ${stats.max}%.1f")
  stats.mean.foreach(m => println(f"平均: $m%.1f"))
  
  println("\n=== 単語カウント ===")
  val texts = List(
    "scala is fun",
    "scala is powerful",
    "fun and powerful"
  )
  
  val wordCounts = texts.map { text =>
    text.split(" ").groupBy(identity).map { case (word, occurrences) =>
      word -> occurrences.length
    }
  }
  
  val totalCounts = Monoid[Map[String, Int]].combineAll(wordCounts)
  totalCounts.toList.sortBy(-_._2).foreach { case (word, count) =>
    println(f"$word%-10s : $count 回")
  }
```

### 関手（Functor）型クラス

```scala
// FunctorTypeClass.scala
@main def functorTypeClass(): Unit =
  // Functor：mapメソッドを持つコンテナ
  trait Functor[F[_]]:
    def map[A, B](fa: F[A])(f: A => B): F[B]
  
  object Functor:
    // リストのFunctor
    implicit val listFunctor: Functor[List] = new Functor[List]:
      def map[A, B](fa: List[A])(f: A => B): List[B] = fa.map(f)
    
    // OptionのFunctor
    implicit val optionFunctor: Functor[Option] = new Functor[Option]:
      def map[A, B](fa: Option[A])(f: A => B): Option[B] = fa.map(f)
    
    // EitherのFunctor（右側のみ）
    implicit def eitherFunctor[E]: Functor[Either[E, *]] = 
      new Functor[Either[E, *]]:
        def map[A, B](fa: Either[E, A])(f: A => B): Either[E, B] = 
          fa.map(f)
  
  // カスタムコンテナ
  case class Box[A](value: A)
  case class Pair[A](first: A, second: A)
  
  object Box:
    implicit val boxFunctor: Functor[Box] = new Functor[Box]:
      def map[A, B](fa: Box[A])(f: A => B): Box[B] = Box(f(fa.value))
  
  object Pair:
    implicit val pairFunctor: Functor[Pair] = new Functor[Pair]:
      def map[A, B](fa: Pair[A])(f: A => B): Pair[B] = 
        Pair(f(fa.first), f(fa.second))
  
  // 汎用的な関数
  def double[F[_]: Functor](fa: F[Int]): F[Int] =
    implicitly[Functor[F]].map(fa)(_ * 2)
  
  def toUpperCase[F[_]: Functor](fa: F[String]): F[String] =
    implicitly[Functor[F]].map(fa)(_.toUpperCase)
  
  // Functorの法則を確認する関数
  def checkFunctorLaws[F[_]: Functor, A](fa: F[A]): Unit =
    val functor = implicitly[Functor[F]]
    
    // 恒等法則: map(fa)(identity) == fa
    val identity = functor.map(fa)(x => x)
    println(s"恒等法則: ${fa} == ${identity}")
  
  // 使用例
  println("=== リストのFunctor ===")
  val numbers = List(1, 2, 3, 4, 5)
  println(s"元: $numbers")
  println(s"2倍: ${double(numbers)}")
  
  println("\n=== OptionのFunctor ===")
  val someValue = Some(10)
  val noneValue = None: Option[Int]
  println(s"Some(10)の2倍: ${double(someValue)}")
  println(s"Noneの2倍: ${double(noneValue)}")
  
  println("\n=== カスタム型のFunctor ===")
  val box = Box("hello")
  val pair = Pair("scala", "java")
  
  println(s"Box: ${toUpperCase(box)}")
  println(s"Pair: ${toUpperCase(pair)}")
  
  println("\n=== Functorの法則 ===")
  checkFunctorLaws(List(1, 2, 3))
  checkFunctorLaws(Some("test"))
  checkFunctorLaws(Box(42))
```

## 練習してみよう！

### 練習1：Showable型クラス

様々な型を美しく表示する型クラスを作ってください：
- 基本型（Int, String, Boolean）
- コレクション型（List, Set, Map）
- カスタム型（Person, Address）

### 練習2：Validation型クラス

データ検証のための型クラスを実装してください：
- メールアドレスの検証
- 年齢の検証
- パスワード強度の検証

### 練習3：Serializable型クラス

データのシリアライズ/デシリアライズを行う型クラスを作ってください：
- バイナリ形式
- JSON形式
- XML形式

## この章のまとめ

型クラスパターンの強力さを実感できましたね！

### できるようになったこと

✅ **型クラスの基本**
- trait定義
- インスタンス実装
- 暗黙の解決

✅ **型クラスの合成**
- 自動導出
- 高階型クラス
- 再帰的な構造

✅ **実践的な型クラス**
- Show, Eq, Ordering
- JsonEncoder
- Monoid, Functor

✅ **設計パターン**
- 拡張メソッド
- コンテキスト境界
- 型クラスの法則

### 型クラスを使うコツ

1. **小さく始める**
    - 単一の責任
    - 明確な法則
    - テスト可能

2. **合成可能にする**
    - 自動導出の活用
    - 既存の型への対応
    - 新しい型への拡張

3. **使いやすくする**
    - 拡張メソッド
    - 便利な構文
    - 良いデフォルト

### 次の章では...

for式の内部動作について学びます。モナドの世界への入り口を開きましょう！

### 最後に

型クラスは「後付けできる能力」です。既存の型に新しい機能を追加できる、まるで魔法のような仕組み。この柔軟性と拡張性が、大規模なプログラムでも整理された設計を可能にします。型クラスマスターへの道は開かれました！