# 第5章 型って何だろう？（型の基礎編）

## はじめに

プログラミングにおける「型」は、データの種類を表す重要な概念です。型を理解することで、より安全で読みやすいプログラムが書けるようになります。この章では、型の基本的な考え方とScalaの型システムについて学びます。

## 型とは何か？

### 現実世界の例で考える

型は、現実世界の「分類」や「カテゴリー」に似ています：

```scala
// RealWorldTypes.scala
@main def realWorldTypes(): Unit = {
  // 現実世界の分類をプログラムで表現
  
  // 数値型：個数や量を表す
  val appleCount: Int = 5        // りんごの個数
  val temperature: Double = 23.5  // 温度
  val distance: Long = 384400L    // 距離（km）
  
  // 文字列型：名前やメッセージを表す
  val fruitName: String = "りんご"
  val message: String = "おいしいりんごです"
  
  // 真偽値型：はい/いいえを表す
  val isRipe: Boolean = true     // 熟している？
  val isSold: Boolean = false    // 売れた？
  
  println(s"${fruitName}が${appleCount}個あります")
  println(s"熟している: ${isRipe}")
  println(s"気温: ${temperature}度")
}
```

### なぜ型が必要なのか？

```scala
// WhyTypesArImportant.scala
@main def whyTypesAreImportant(): Unit = {
  // 型があることで間違いを防げる
  val price = 100
  val quantity = 3
  val total = price * quantity  // 正しい計算
  
  // もし型がなかったら...
  // val price = "100"
  // val quantity = "3"
  // val total = price * quantity  // エラー！文字列は掛け算できない
  
  // 型があることで意図が明確になる
  val userName: String = "太郎"      // 名前は文字列
  val userAge: Int = 20             // 年齢は整数
  val userHeight: Double = 170.5    // 身長は小数
  
  println(s"${userName}さん（${userAge}歳、${userHeight}cm）")
}
```

## Scalaの型階層

### 基本的な型の関係

```scala
// TypeHierarchy.scala
@main def typeHierarchy(): Unit = {
  // すべての型の親：Any
  val anything: Any = 42
  val anything2: Any = "Hello"
  val anything3: Any = true
  
  println(s"Anyには何でも入る: ${anything}, ${anything2}, ${anything3}")
  
  // 値型（AnyVal）の例
  val number: AnyVal = 123
  val decimal: AnyVal = 3.14
  val bool: AnyVal = true
  
  // 参照型（AnyRef）の例
  val text: AnyRef = "Scala"
  val list: AnyRef = List(1, 2, 3)
}
```

### 型の継承関係

```
Any（すべての型の親）
├── AnyVal（値型）
│   ├── Int
│   ├── Long
│   ├── Double
│   ├── Float
│   ├── Boolean
│   ├── Char
│   ├── Byte
│   ├── Short
│   └── Unit
└── AnyRef（参照型）
    ├── String
    ├── List
    ├── Array
    └── その他のクラス
```

## 型アノテーション

### 明示的な型指定

```scala
// TypeAnnotations.scala
@main def typeAnnotations(): Unit = {
  // 型を明示的に指定
  val name: String = "Scala"
  val version: Double = 3.3
  val year: Int = 2024
  
  // 型推論に任せる（型を書かない）
  val language = "Scala"     // Stringと推論される
  val majorVersion = 3       // Intと推論される
  val isNew = true          // Booleanと推論される
  
  // 型を指定する利点
  val price: Double = 100   // 100.0として扱われる
  val count = 100          // 100（Int）として扱われる
  
  println(s"価格: ${price}円")
  println(s"個数: ${count}個")
  
  // 計算結果の型も異なる
  val halfPrice = price / 2    // 50.0（Double）
  val halfCount = count / 2    // 50（Int）
  
  println(s"半額: ${halfPrice}円")
  println(s"半分: ${halfCount}個")
}
```

### いつ型を書くべきか

```scala
// WhenToUseTypes.scala
@main def whenToUseTypes(): Unit = {
  // 1. 公開APIやメソッドの引数・戻り値
  def calculateTax(price: Double, rate: Double): Double =
    price * rate
  
  // 2. 意図を明確にしたいとき
  val score: Double = 90  // 90.0として扱いたい
  
  // 3. 複雑な式の結果
  val result: Option[String] = Some("成功")
  
  // 4. 型推論が期待と異なる場合
  val items: List[Any] = List(1, "two", 3.0)  // 異なる型を含むリスト
  
  println(s"税額: ${calculateTax(1000, 0.1)}円")
  println(s"スコア: ${score}")
  println(s"結果: ${result}")
  println(s"アイテム: ${items}")
}
```

## 型の互換性

### 数値型の変換

```scala
// NumericTypeCompatibility.scala
@main def numericTypeCompatibility(): Unit = {
  // 小さい型から大きい型への自動変換
  val smallInt: Int = 100
  val bigLong: Long = smallInt      // OK: Int → Long
  val bigDouble: Double = smallInt   // OK: Int → Double
  
  println(s"Int: ${smallInt}")
  println(s"Long: ${bigLong}")
  println(s"Double: ${bigDouble}")
  
  // 大きい型から小さい型は明示的な変換が必要
  val doubleVal = 3.14
  // val intVal: Int = doubleVal    // エラー！
  val intVal: Int = doubleVal.toInt // OK: 明示的な変換
  
  println(s"Double: ${doubleVal} → Int: ${intVal}")
  
  // 精度の損失に注意
  val bigNumber = 1234567890123456789L
  val smallNumber = bigNumber.toInt
  println(s"Long: ${bigNumber} → Int: ${smallNumber}")  // データが失われる！
}
```

### 型の昇格

```scala
// TypePromotion.scala
@main def typePromotion(): Unit = {
  // 異なる数値型の計算では、より大きな型に昇格
  val intNum = 10
  val doubleNum = 3.14
  
  val result1 = intNum + doubleNum  // 結果はDouble
  val result2 = intNum * doubleNum  // 結果はDouble
  
  println(s"${intNum} + ${doubleNum} = ${result1} (${result1.getClass.getSimpleName})")
  println(s"${intNum} * ${doubleNum} = ${result2} (${result2.getClass.getSimpleName})")
  
  // 型を維持したい場合
  val intResult = (intNum + doubleNum).toInt
  println(s"Int結果: ${intResult}")
}
```

## Nothing型とNull型

### Nothing型

```scala
// NothingType.scala
@main def nothingType(): Unit = {
  // Nothing型は全ての型のサブタイプ
  def error(message: String): Nothing =
    throw new Exception(message)
  
  // Nothingは決して値を返さない
  def infiniteLoop(): Nothing = {
    while (true) {
      println("無限ループ...")
      Thread.sleep(1000)
    }
  }
  
  // 条件によってエラーを投げる
  def divide(a: Int, b: Int): Int =
    if (b == 0) {
      error("ゼロで除算はできません")  // Nothing型
    } else {
      a / b  // Int型
    }
  
  println(divide(10, 2))
  // println(divide(10, 0))  // エラーが発生
}
```

### Null型

```scala
// NullType.scala
@main def nullType(): Unit = {
  // Scalaではnullの使用は推奨されない
  var name: String = "太郎"
  println(s"名前: ${name}")
  
  // nullを代入できる（非推奨）
  name = null
  // println(s"長さ: ${name.length}")  // NullPointerException!
  
  // Optionを使った安全な方法（推奨）
  var safeName: Option[String] = Some("花子")
  println(s"安全な名前: ${safeName}")
  
  safeName = None  // 値がないことを表現
  println(s"値なし: ${safeName}")
  
  // 安全にアクセス
  safeName match {
    case Some(n) => println(s"名前は${n}です")
    case None => println("名前がありません")
  }
}
```

## 型エイリアス

### 型に別名をつける

```scala
// TypeAlias.scala
@main def typeAlias(): Unit = {
  // 型エイリアスの定義
  type UserID = Int
  type UserName = String
  type Age = Int
  type Email = String
  
  // 型エイリアスを使った変数定義
  val id: UserID = 12345
  val name: UserName = "山田太郎"
  val age: Age = 25
  val email: Email = "yamada@example.com"
  
  // 関数でも使える
  def createUser(id: UserID, name: UserName, age: Age): String =
    s"ユーザー#${id}: ${name}（${age}歳）"
  
  println(createUser(id, name, age))
  
  // より複雑な型エイリアス
  type UserData = (UserID, UserName, Age, Email)
  val user: UserData = (id, name, age, email)
  
  println(s"ユーザー情報: ${user}")
}
```

## 型安全性の利点

### コンパイル時のエラー検出

```scala
// TypeSafety.scala
@main def typeSafety(): Unit = {
  // 型があることで間違いを早期発見
  def addNumbers(a: Int, b: Int): Int = a + b
  
  // 正しい使い方
  val sum = addNumbers(10, 20)
  println(s"合計: ${sum}")
  
  // 間違った使い方はコンパイルエラー
  // val wrong = addNumbers("10", "20")  // エラー！
  // val wrong2 = addNumbers(10.5, 20.5) // エラー！
  
  // 型によって意図が明確
  case class Product(name: String, price: Double, quantity: Int)
  
  val apple = Product("りんご", 150.0, 5)
  val total = apple.price * apple.quantity
  
  println(s"${apple.name}: ${apple.price}円 × ${apple.quantity}個 = ${total}円")
}
```

## 実践的な例：図書管理システム

```scala
// LibrarySystem.scala
@main def librarySystem(): Unit = {
  // 型エイリアスで意味を明確に
  type ISBN = String
  type Title = String
  type Author = String
  type Year = Int
  type Available = Boolean
  
  // 本の情報を表す型
  case class Book(
    isbn: ISBN,
    title: Title,
    author: Author,
    year: Year,
    available: Available
  )
  
  // 図書館の蔵書
  val books = List(
    Book("978-4-123456-78-9", "Scalaプログラミング", "山田太郎", 2024, true),
    Book("978-4-234567-89-0", "関数型入門", "鈴木花子", 2023, false),
    Book("978-4-345678-90-1", "型システム詳解", "佐藤次郎", 2024, true)
  )
  
  // 利用可能な本を検索
  def findAvailableBooks(books: List[Book]): List[Book] =
    books.filter(_.available)
  
  // 著者で検索
  def findByAuthor(books: List[Book], author: Author): List[Book] =
    books.filter(_.author == author)
  
  // 新しい本の追加
  def addBook(books: List[Book], book: Book): List[Book] =
    books :+ book
  
  println("=== 図書管理システム ===")
  println("\n利用可能な本:")
  findAvailableBooks(books).foreach { book =>
    println(s"- ${book.title} (${book.author}, ${book.year}年)")
  }
  
  println("\n山田太郎の著書:")
  findByAuthor(books, "山田太郎").foreach { book =>
    println(s"- ${book.title}")
  }
}
```

## よくあるエラーと対処法

### エラー例1：型の不一致

```scala
def double(x: Int): Int = x * 2
val result = double(3.14)  // エラー！
```

エラーメッセージ：
```
error: type mismatch;
 found   : Double(3.14)
 required: Int
```

**対処法**: 正しい型を渡すか、型を変換する

### エラー例2：Any型の誤用

```scala
val items: List[Any] = List(1, "two", 3.0)
val sum = items(0) + items(2)  // エラー！
```

**対処法**: 具体的な型を使うか、パターンマッチで処理

### エラー例3：null参照

```scala
var text: String = null
val length = text.length  // 実行時エラー！
```

**対処法**: Optionを使って安全に扱う

## 練習問題

### 問題1：型の判定

以下の値の型を答えてください：
- `42`
- `"Hello"`
- `true`
- `3.14`
- `'A'`

### 問題2：型エイリアス

学生情報を管理するプログラムで使う型エイリアスを定義してください：
- 学籍番号
- 氏名
- 学年
- GPA（成績平均）

### 問題3：型安全な関数

年齢を受け取って、年代（10代、20代など）を返す関数を作成してください。型を明示的に指定すること。

### 問題4：型変換

以下の変換を行うプログラムを作成してください：
- String "123" を Int に変換
- Double 45.67 を Int に変換
- Int 100 を String に変換

### 問題5：エラーを修正

```scala
@main def broken(): Unit = {
  val price: Int = 99.99
  val quantity: String = 3
  val total = price * quantity
  
  val message: Any = "合計金額"
  val length = message.length
  
  println(s"${message}: ${total}円")
}
```

## まとめ

この章では以下のことを学びました：

1. **型の基本概念**
    - 型はデータの種類を表す
    - 型があることで安全なプログラムが書ける
    - 型によって意図が明確になる

2. **Scalaの型階層**
    - Any型がすべての型の親
    - AnyVal（値型）とAnyRef（参照型）
    - Nothing型とNull型

3. **型アノテーション**
    - 明示的な型指定の方法
    - いつ型を書くべきか
    - 型推論との使い分け

4. **型の互換性**
    - 数値型の自動変換
    - 明示的な型変換
    - 型の昇格

5. **型安全性**
    - コンパイル時のエラー検出
    - 実行時エラーの防止
    - より良いコード設計

次の章では、Scalaの強力な型推論機能について詳しく学んでいきます！