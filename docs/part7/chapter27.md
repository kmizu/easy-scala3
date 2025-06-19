# 第27章 境界と変位指定

## はじめに

動物園を想像してください。「哺乳類エリア」には犬も猫もライオンも入れますが、魚は入れません。「肉食動物エリア」にはライオンは入れますが、うさぎは入れません。

プログラミングでも同じように、「この型はこういう条件を満たすもの限定」という制約をつけたいことがあります。これが「境界」と「変位指定」の考え方です！

## 型境界（Type Bounds）

### 上限境界（Upper Bounds）

```scala
// UpperBounds.scala
@main def upperBounds(): Unit =
  // 動物の階層
  trait Animal:
    def name: String
    def makeSound(): String
  
  class Dog(val name: String) extends Animal:
    def makeSound(): String = "ワンワン"
    def wagTail(): String = s"${name}がしっぽを振っています"
  
  class Cat(val name: String) extends Animal:
    def makeSound(): String = "ニャー"
    def purr(): String = s"${name}がゴロゴロ言っています"
  
  class Bird(val name: String) extends Animal:
    def makeSound(): String = "チュンチュン"
  
  // 動物限定のケージ（上限境界）
  class AnimalCage[A <: Animal](val resident: A):
    def showResident(): String = 
      s"${resident.name}が入っています：${resident.makeSound()}"
    
    def feed(): String = s"${resident.name}に餌をあげました"
  
  // 使用例
  val dogCage = new AnimalCage(new Dog("ポチ"))
  val catCage = new AnimalCage(new Cat("タマ"))
  
  println("=== 動物のケージ ===")
  println(dogCage.showResident())
  println(catCage.showResident())
  
  // これはコンパイルエラー（Stringは Animal ではない）
  // val stringCage = new AnimalCage("文字列")
  
  // より具体的な型も保持される
  val myDog = new Dog("ハチ")
  val specificDogCage = new AnimalCage(myDog)
  println(specificDogCage.resident.wagTail())  // Dogのメソッドが使える！
```

### 下限境界（Lower Bounds）

```scala
// LowerBounds.scala
@main def lowerBounds(): Unit =
  trait Animal:
    def name: String
  
  class Mammal(val name: String) extends Animal
  class Dog(name: String) extends Mammal(name)
  class Cat(name: String) extends Mammal(name)
  
  // 動物の家系図
  class FamilyTree[A](val member: A):
    // 下限境界：より一般的な型を追加できる
    def addAncestor[B >: A](ancestor: B): FamilyTree[B] =
      new FamilyTree(ancestor)
    
    override def toString: String = s"FamilyTree($member)"
  
  val dogTree = new FamilyTree(new Dog("ポチ"))
  val mammalTree = dogTree.addAncestor(new Mammal("哺乳類の祖先"))
  val animalTree = mammalTree.addAncestor(new Animal { val name = "動物の祖先" })
  
  println("=== 家系図 ===")
  println(s"犬: $dogTree")
  println(s"哺乳類を追加: $mammalTree")
  println(s"動物を追加: $animalTree")
  
  // 実用例：エラーハンドリング
  sealed trait Error
  case class NetworkError(message: String) extends Error
  case class ParseError(message: String) extends Error
  
  def handleError[E <: Error](error: E): String = error match
    case NetworkError(msg) => s"ネットワークエラー: $msg"
    case ParseError(msg) => s"パースエラー: $msg"
  
  // より一般的なエラーハンドラー
  def handleAnyError[E >: NetworkError](error: E): String = error match
    case NetworkError(msg) => s"通信エラー: $msg"
    case other => s"その他のエラー: $other"
  
  println("\n=== エラーハンドリング ===")
  println(handleError(NetworkError("接続失敗")))
  println(handleAnyError(ParseError("不正な形式")))
```

## 変位指定（Variance）

### 共変（Covariant）

```scala
// Covariance.scala
@main def covariance(): Unit =
  // 共変的なコンテナ（+A）
  class Box[+A](val content: A):
    def get: A = content
    
    // 共変の場合、Aは戻り値にのみ使える
    def map[B](f: A => B): Box[B] = Box(f(content))
  
  class Animal(val name: String)
  class Dog(name: String, val breed: String) extends Animal(name)
  
  val dogBox: Box[Dog] = Box(new Dog("ポチ", "柴犬"))
  val animalBox: Box[Animal] = dogBox  // OK！DogはAnimalのサブタイプ
  
  println(s"動物の名前: ${animalBox.get.name}")
  
  // 実用例：イミュータブルなリスト
  sealed trait MyList[+A]:
    def head: A
    def tail: MyList[A]
    def isEmpty: Boolean
    
    def ::[B >: A](elem: B): MyList[B] = MyCons(elem, this)
    
    def map[B](f: A => B): MyList[B] = this match
      case MyNil => MyNil
      case MyCons(h, t) => MyCons(f(h), t.map(f))
  
  case object MyNil extends MyList[Nothing]:
    def head = throw new NoSuchElementException("empty list")
    def tail = throw new NoSuchElementException("empty list")
    def isEmpty = true
  
  case class MyCons[+A](head: A, tail: MyList[A]) extends MyList[A]:
    def isEmpty = false
  
  val dogs: MyList[Dog] = new Dog("ハチ", "秋田犬") :: 
                          new Dog("タロ", "ゴールデン") :: MyNil
  val animals: MyList[Animal] = dogs  // 共変なのでOK
  
  println("\n=== 共変リスト ===")
  println(s"最初の動物: ${animals.head.name}")
```

### 反変（Contravariant）

```scala
// Contravariance.scala
@main def contravariance(): Unit =
  // 反変的な関数（-A）
  trait Printer[-A]:
    def print(value: A): String
  
  class Animal(val name: String)
  class Dog(name: String, val breed: String) extends Animal(name)
  
  // 動物用プリンター
  val animalPrinter: Printer[Animal] = new Printer[Animal]:
    def print(animal: Animal): String = s"動物: ${animal.name}"
  
  // 犬用プリンターとして使える（反変）
  val dogPrinter: Printer[Dog] = animalPrinter  // OK！
  
  val myDog = new Dog("ポチ", "柴犬")
  println(dogPrinter.print(myDog))
  
  // 実用例：比較関数
  trait Comparator[-T]:
    def compare(x: T, y: T): Int
  
  // 一般的な比較
  val animalComparator: Comparator[Animal] = new Comparator[Animal]:
    def compare(x: Animal, y: Animal): Int = 
      x.name.compareTo(y.name)
  
  // より具体的な型でも使える
  val dogComparator: Comparator[Dog] = animalComparator
  
  val dog1 = new Dog("アル", "ビーグル")
  val dog2 = new Dog("ベス", "コーギー")
  
  println(s"\n犬の比較: ${dogComparator.compare(dog1, dog2)}")
  
  // 関数は引数に対して反変
  val animalHandler: Animal => String = a => s"動物 ${a.name} を処理"
  val dogHandler: Dog => String = animalHandler  // OK！
  
  println(dogHandler(myDog))
```

### 不変（Invariant）

```scala
// Invariance.scala
@main def invariance(): Unit =
  // 不変的なコンテナ（変位指定なし）
  class MutableBox[A](var content: A):
    def get: A = content
    def set(value: A): Unit = content = value
  
  class Animal(val name: String)
  class Dog(name: String) extends Animal(name)
  
  val dogBox: MutableBox[Dog] = MutableBox(new Dog("ポチ"))
  // val animalBox: MutableBox[Animal] = dogBox  // エラー！不変なので代入できない
  
  // なぜ不変が必要か？
  // もし上の代入が許されたら...
  // animalBox.set(new Cat("タマ"))  // 猫を入れてしまう！
  // val dog: Dog = dogBox.get       // 猫なのにDog型として取得...危険！
  
  println("=== 不変コンテナ ===")
  println(s"犬: ${dogBox.get.name}")
  
  // 実用例：可変配列
  class MyArray[A](size: Int):
    private val array = new Array[Any](size)
    
    def get(index: Int): A = array(index).asInstanceOf[A]
    def set(index: Int, value: A): Unit = array(index) = value
    
    def map[B](f: A => B): MyArray[B] =
      val result = MyArray[B](size)
      for i <- 0 until size do
        result.set(i, f(get(i)))
      result
  
  val intArray = MyArray[Int](3)
  intArray.set(0, 10)
  intArray.set(1, 20)
  intArray.set(2, 30)
  
  val doubled = intArray.map(_ * 2)
  
  println("\n=== 配列操作 ===")
  for i <- 0 until 3 do
    println(s"元: ${intArray.get(i)}, 2倍: ${doubled.get(i)}")
```

## 実践的な例：型安全なイベントシステム

```scala
// TypeSafeEventSystem.scala
@main def typeSafeEventSystem(): Unit =
  // イベントの階層
  trait Event:
    def timestamp: Long = System.currentTimeMillis()
  
  trait UserEvent extends Event:
    def userId: String
  
  case class LoginEvent(userId: String, device: String) extends UserEvent
  case class LogoutEvent(userId: String) extends UserEvent
  case class SystemEvent(message: String) extends Event
  
  // イベントハンドラー（反変）
  trait EventHandler[-E <: Event]:
    def handle(event: E): Unit
  
  // イベントバス（共変）
  class EventBus[+E <: Event]:
    private var handlers: List[EventHandler[_ >: E]] = List.empty
    
    def subscribe[F >: E](handler: EventHandler[F]): Unit =
      handlers = handler :: handlers
    
    def publish[F >: E](event: F): Unit =
      handlers.foreach(_.handle(event))
  
  // 汎用的なイベントハンドラー
  val generalHandler = new EventHandler[Event]:
    def handle(event: Event): Unit =
      println(f"[${event.timestamp}%tT] イベント発生")
  
  // ユーザーイベント専用ハンドラー
  val userHandler = new EventHandler[UserEvent]:
    def handle(event: UserEvent): Unit =
      println(s"ユーザー ${event.userId} のアクション")
  
  // ログイン専用ハンドラー
  val loginHandler = new EventHandler[LoginEvent]:
    def handle(event: LoginEvent): Unit =
      println(s"${event.userId} が ${event.device} からログイン")
  
  // イベントバスの設定
  val userEventBus = new EventBus[UserEvent]
  userEventBus.subscribe(generalHandler)  // より一般的なハンドラーもOK
  userEventBus.subscribe(userHandler)
  userEventBus.subscribe(loginHandler)
  
  // イベント発行
  println("=== イベント処理 ===")
  userEventBus.publish(LoginEvent("user123", "iPhone"))
  println()
  userEventBus.publish(LogoutEvent("user123"))
```

## 境界と変位の組み合わせ

```scala
// BoundsAndVariance.scala
@main def boundsAndVariance(): Unit =
  // 順序付け可能な要素のコンテナ
  trait Container[+A]:
    def elements: List[A]
    
    def max[B >: A](implicit ord: Ordering[B]): Option[B] =
      if elements.isEmpty then None
      else Some(elements.max(ord))
    
    def sorted[B >: A](implicit ord: Ordering[B]): Container[B]
  
  class ListContainer[+A](val elements: List[A]) extends Container[A]:
    def sorted[B >: A](implicit ord: Ordering[B]): Container[B] =
      new ListContainer(elements.sorted(ord))
    
    override def toString: String = s"Container(${elements.mkString(", ")})"
  
  // 数値コンテナ
  val numbers = new ListContainer(List(3, 1, 4, 1, 5, 9))
  println("=== 数値コンテナ ===")
  println(s"元: $numbers")
  println(s"最大値: ${numbers.max}")
  println(s"ソート済み: ${numbers.sorted}")
  
  // 文字列コンテナ
  val strings = new ListContainer(List("banana", "apple", "cherry"))
  println("\n=== 文字列コンテナ ===")
  println(s"元: $strings")
  println(s"ソート済み: ${strings.sorted}")
  
  // F-bounded polymorphism
  trait Comparable[A <: Comparable[A]]:
    def compareTo(that: A): Int
    
    def <(that: A): Boolean = compareTo(that) < 0
    def >(that: A): Boolean = compareTo(that) > 0
    def <=(that: A): Boolean = compareTo(that) <= 0
    def >=(that: A): Boolean = compareTo(that) >= 0
  
  case class Person(name: String, age: Int) extends Comparable[Person]:
    def compareTo(that: Person): Int = 
      val nameComp = this.name.compareTo(that.name)
      if nameComp != 0 then nameComp
      else this.age.compareTo(that.age)
  
  val person1 = Person("Alice", 30)
  val person2 = Person("Bob", 25)
  val person3 = Person("Alice", 25)
  
  println("\n=== 比較可能な人 ===")
  println(s"$person1 < $person2 ? ${person1 < person2}")
  println(s"$person1 > $person3 ? ${person1 > person3}")
```

## 実践例：型安全なビルダー

```scala
// TypeSafeBuilder.scala
@main def typeSafeBuilder(): Unit =
  // ビルダーの状態を型で表現
  sealed trait BuilderState
  trait Empty extends BuilderState
  trait WithName extends BuilderState
  trait WithEmail extends BuilderState
  trait Complete extends WithName with WithEmail
  
  // 型安全なユーザービルダー
  class UserBuilder[State <: BuilderState] private (
    name: Option[String] = None,
    email: Option[String] = None,
    age: Option[Int] = None
  ):
    def withName(name: String): UserBuilder[State with WithName] =
      new UserBuilder[State with WithName](Some(name), email, age)
    
    def withEmail(email: String): UserBuilder[State with WithEmail] =
      new UserBuilder[State with WithEmail](name, Some(email), age)
    
    def withAge(age: Int): UserBuilder[State] =
      new UserBuilder[State](name, email, Some(age))
    
    // buildは必須フィールドが揃った時のみ呼べる
    def build(implicit ev: State <:< Complete): User =
      User(name.get, email.get, age.getOrElse(0))
  
  object UserBuilder:
    def apply(): UserBuilder[Empty] = new UserBuilder[Empty]()
  
  case class User(name: String, email: String, age: Int)
  
  // 使用例
  val user = UserBuilder()
    .withName("太郎")
    .withEmail("taro@example.com")
    .withAge(25)
    .build  // すべての必須フィールドが設定されているのでOK
  
  println(s"ユーザー: $user")
  
  // これはコンパイルエラー（emailが未設定）
  // val incomplete = UserBuilder()
  //   .withName("花子")
  //   .build
  
  // 順序は自由
  val user2 = UserBuilder()
    .withAge(30)
    .withEmail("hanako@example.com")
    .withName("花子")
    .build
  
  println(s"ユーザー2: $user2")
```

## 練習してみよう！

### 練習1：動物園システム

以下の要件を満たす動物園システムを作ってください：
- 動物の階層（Animal > Mammal > Dog/Cat）
- 共変的な檻（Cage[+A]）
- 反変的な飼育員（Keeper[-A]）

### 練習2：ソート可能なコレクション

型境界を使って、要素がComparableな場合のみソートできるコレクションを実装してください。

### 練習3：型安全なメッセージキュー

送信者と受信者の型を考慮した、型安全なメッセージキューシステムを作ってください。

## この章のまとめ

境界と変位指定について深く学びました！

### できるようになったこと

✅ **型境界**
- 上限境界（<:）
- 下限境界（>:）
- 型の制約

✅ **変位指定**
- 共変（+）
- 反変（-）
- 不変（デフォルト）

✅ **実践的な応用**
- 型安全なAPI設計
- F-bounded polymorphism
- ビルダーパターン

✅ **設計の考え方**
- 適切な変位の選択
- 型安全性の確保
- 柔軟性と安全性のバランス

### 境界と変位を使うコツ

1. **変位の原則**
   - 出力は共変（+）
   - 入力は反変（-）
   - 入出力両方は不変

2. **境界の使い分け**
   - 上限：特定の型以下に制限
   - 下限：特定の型以上を許可
   - 組み合わせて柔軟に

3. **安全性の確保**
   - コンパイル時チェック
   - 実行時エラーの防止
   - 型の健全性

### 次の章では...

暗黙の引数について学びます。文脈に応じた値の自動解決で、より表現力豊かなコードを書けるようになりましょう！

### 最後に

境界と変位指定は「型の交通ルール」のようなものです。どの型がどこに行けるか、どの型同士が一緒にできるか、すべてルールで決まっています。最初は複雑に感じるかもしれませんが、このルールを理解すれば、より安全で柔軟なプログラムが書けるようになります。型システムを味方につけて、バグの少ないコードを書きましょう！