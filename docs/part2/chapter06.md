# 第6章 型推論の魔法

## はじめに

Scalaの最も便利な機能の一つが「型推論」です。型推論とは、プログラマーが型を明示的に書かなくても、コンパイラが自動的に型を判断してくれる機能です。この章では、型推論の仕組みと効果的な使い方を学びます。

## 型推論とは何か？

### 基本的な型推論

```scala
// BasicTypeInference.scala
@main def basicTypeInference(): Unit = {
  // 型を書かなくても、Scalaが自動的に型を推論
  val number = 42              // Int型と推論
  val decimal = 3.14           // Double型と推論
  val text = "Hello, Scala!"   // String型と推論
  val flag = true              // Boolean型と推論
  
  // 推論された型を確認
  println(s"number: ${number.getClass.getSimpleName}")
  println(s"decimal: ${decimal.getClass.getSimpleName}")
  println(s"text: ${text.getClass.getSimpleName}")
  println(s"flag: ${flag.getClass.getSimpleName}")
  
  // 明示的に型を書いた場合と同じ
  val explicitNumber: Int = 42
  val explicitText: String = "Hello, Scala!"
  
  // 両者は完全に同じ
  println(s"推論: ${number}, 明示: ${explicitNumber}")
}
```

### 式からの型推論

```scala
// ExpressionTypeInference.scala
@main def expressionTypeInference(): Unit = {
  // 計算結果の型も推論される
  val sum = 10 + 20           // Int
  val product = 5.0 * 3       // Double（片方がDouble）
  val divided = 10 / 3        // Int（整数同士の除算）
  val precise = 10.0 / 3      // Double
  
  println(s"sum: ${sum} (${sum.getClass.getSimpleName})")
  println(s"product: ${product} (${product.getClass.getSimpleName})")
  println(s"divided: ${divided} (${divided.getClass.getSimpleName})")
  println(s"precise: ${precise} (${precise.getClass.getSimpleName})")
  
  // 複雑な式でも推論
  val complex = (10 + 5) * 2.0 / 3  // Double
  println(s"complex: ${complex} (${complex.getClass.getSimpleName})")
}
```

## 関数での型推論

### 引数の型は必須、戻り値の型は推論可能

```scala
// FunctionTypeInference.scala
@main def functionTypeInference(): Unit = {
  // 戻り値の型を推論
  def add(x: Int, y: Int) = x + y  // 戻り値はIntと推論
  
  // 明示的に書いた場合と同じ
  def addExplicit(x: Int, y: Int): Int = x + y
  
  println(s"add(3, 4) = ${add(3, 4)}")
  println(s"addExplicit(3, 4) = ${addExplicit(3, 4)}")
  
  // より複雑な例
  def greet(name: String) = s"こんにちは、${name}さん！"  // Stringと推論
  def isAdult(age: Int) = age >= 18                      // Booleanと推論
  def calculateBMI(weight: Double, height: Double) = 
    weight / (height * height)                           // Doubleと推論
  
  println(greet("太郎"))
  println(s"20歳は成人？: ${isAdult(20)}")
  println(s"BMI: ${calculateBMI(65.0, 1.70)}")
}
```

### ローカル関数での型推論

```scala
// LocalFunctionInference.scala
@main def localFunctionInference(): Unit = {
  // 関数内で定義する関数
  def processNumbers(numbers: List[Int]): String = {
    // ローカル関数の型も推論される
    def double(x: Int) = x * 2
    def isEven(x: Int) = x % 2 == 0
    def format(x: Int) = s"[${x}]"
    
    numbers
      .map(double)      // 各要素を2倍
      .filter(isEven)   // 偶数のみ選択
      .map(format)      // フォーマット
      .mkString(", ")   // 文字列に結合
  }
  
  val result = processNumbers(List(1, 2, 3, 4, 5))
  println(s"結果: ${result}")
}
```

## コレクションでの型推論

### リストの型推論

```scala
// CollectionTypeInference.scala
@main def collectionTypeInference(): Unit = {
  // 要素から型を推論
  val numbers = List(1, 2, 3, 4, 5)          // List[Int]
  val words = List("apple", "banana", "cat")  // List[String]
  val mixed = List(1, "two", 3.0, true)      // List[Any]
  
  println(s"numbers: ${numbers}")
  println(s"words: ${words}")
  println(s"mixed: ${mixed}")
  
  // Mapの型推論
  val ages = Map(
    "太郎" -> 20,
    "花子" -> 22,
    "次郎" -> 19
  )  // Map[String, Int]
  
  println(s"ages: ${ages}")
  
  // 複雑なコレクション
  val studentScores = Map(
    "数学" -> List(80, 85, 90),
    "英語" -> List(75, 80, 85),
    "理科" -> List(90, 95, 100)
  )  // Map[String, List[Int]]
  
  println(s"studentScores: ${studentScores}")
}
```

### メソッドチェーンでの型推論

```scala
// MethodChainInference.scala
@main def methodChainInference(): Unit = {
  val numbers = List(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
  
  // 各ステップで型が推論される
  val result = numbers
    .filter(_ % 2 == 0)     // List[Int]（偶数のみ）
    .map(_ * 2)             // List[Int]（2倍）
    .map(_.toString)        // List[String]（文字列に変換）
    .map("数値: " + _)      // List[String]（プレフィックス追加）
    .mkString(", ")         // String（結合）
  
  println(result)
  
  // 型を追跡してみる
  val step1 = numbers.filter(_ % 2 == 0)
  val step2 = step1.map(_ * 2)
  val step3 = step2.map(_.toString)
  
  println(s"step1: ${step1} (${step1.getClass.getSimpleName})")
  println(s"step2: ${step2} (${step2.getClass.getSimpleName})")
  println(s"step3: ${step3} (${step3.getClass.getSimpleName})")
}
```

## 型推論の限界

### 再帰関数では戻り値の型が必要

```scala
// RecursionTypeInference.scala
@main def recursionTypeInference(): Unit = {
  // 再帰関数では戻り値の型を明示する必要がある
  def factorial(n: Int): Int = {  // 戻り値の型が必要
    if (n <= 1) 1
    else n * factorial(n - 1)
  }
  
  // これはエラーになる
  // def factorialError(n: Int) =
  //   if (n <= 1) 1
  //   else n * factorialError(n - 1)
  
  println(s"5! = ${factorial(5)}")
  
  // 相互再帰も型が必要
  def isEven(n: Int): Boolean = {
    if (n == 0) true
    else isOdd(n - 1)
  }
  
  def isOdd(n: Int): Boolean = {
    if (n == 0) false
    else isEven(n - 1)
  }
  
  println(s"10は偶数？: ${isEven(10)}")
  println(s"7は奇数？: ${isOdd(7)}")
}
```

### 型パラメータの推論

```scala
// TypeParameterInference.scala
@main def typeParameterInference(): Unit = {
  // ジェネリック関数の型推論
  def identity[T](x: T): T = x
  
  // 使用時に型が推論される
  val intResult = identity(42)        // T = Int
  val stringResult = identity("Scala") // T = String
  val doubleResult = identity(3.14)   // T = Double
  
  println(s"intResult: ${intResult}")
  println(s"stringResult: ${stringResult}")
  println(s"doubleResult: ${doubleResult}")
  
  // より実用的な例
  def firstElement[T](list: List[T]): Option[T] = {
    list.headOption
  }
  
  val first1 = firstElement(List(1, 2, 3))        // Option[Int]
  val first2 = firstElement(List("a", "b", "c"))  // Option[String]
  
  println(s"first1: ${first1}")
  println(s"first2: ${first2}")
}
```

## 型推論のベストプラクティス

### いつ型を明示すべきか

```scala
// WhenToSpecifyTypes.scala
@main def whenToSpecifyTypes(): Unit = {
  // 1. パブリックAPIでは型を明示
  def calculatePrice(basePrice: Double, taxRate: Double): Double = {
    basePrice * (1 + taxRate)
  }
  
  // 2. 複雑な型や意図を明確にしたい場合
  val userDataList: List[(String, Int, Boolean)] = List(
    ("太郎", 20, true),
    ("花子", 22, false),
    ("次郎", 19, true)
  )
  
  // 3. 型を制限したい場合
  val score: Double = 90  // 90.0として扱いたい
  
  // 4. ローカル変数では推論に任せる
  val localSum = 10 + 20
  val localName = "ローカル変数"
  
  println(s"価格: ${calculatePrice(1000, 0.1)}円")
  println(s"ユーザー数: ${userDataList.length}")
  println(s"スコア: ${score}")
}
```

### 型推論を活用した読みやすいコード

```scala
// ReadableCodeWithInference.scala
@main def readableCodeWithInference(): Unit = {
  // 冗長な型指定を避ける
  // 悪い例
  val numbers1: List[Int] = List[Int](1, 2, 3, 4, 5)
  
  // 良い例
  val numbers2 = List(1, 2, 3, 4, 5)
  
  // 処理の流れが見やすい
  val report = List("apple", "banana", "apple", "cherry", "banana", "apple")
    .groupBy(identity)           // 同じ要素でグループ化
    .view.mapValues(_.size)      // 各グループのサイズを計算
    .toList                      // リストに変換
    .sortBy(-_._2)              // 出現回数で降順ソート
    .map { case (fruit, count) =>
      s"${fruit}: ${count}個"
    }
    .mkString("\n")
  
  println("果物の集計:")
  println(report)
}
```

## 実践的な例：成績管理システム

```scala
// GradeManagementSystem.scala
@main def gradeManagementSystem(): Unit = {
  // 学生の成績データ（型推論を活用）
  case class Student(name: String, scores: Map[String, Int])
  
  val students = List(
    Student("山田太郎", Map("数学" -> 85, "英語" -> 78, "理科" -> 92)),
    Student("鈴木花子", Map("数学" -> 92, "英語" -> 88, "理科" -> 85)),
    Student("佐藤次郎", Map("数学" -> 78, "英語" -> 95, "理科" -> 80))
  )
  
  // 平均点を計算する関数（戻り値の型は推論）
  def average(scores: Iterable[Int]) = 
    scores.sum.toDouble / scores.size
  
  // 成績評価（型推論を活用）
  def grade(score: Double) = score match {
    case s if s >= 90 => "A"
    case s if s >= 80 => "B"
    case s if s >= 70 => "C"
    case s if s >= 60 => "D"
    case _ => "F"
  }
  
  // レポート生成
  println("=== 成績レポート ===")
  
  students.foreach { student =>
    val avg = average(student.scores.values)
    val gradeLevel = grade(avg)
    
    println(s"\n${student.name}")
    student.scores.foreach { (subject, score) =>
      println(s"  ${subject}: ${score}点 (${grade(score)})")
    }
    println(s"  平均: ${avg.round}点 (${gradeLevel})")
  }
  
  // 科目別の統計
  println("\n=== 科目別統計 ===")
  val subjects = List("数学", "英語", "理科")
  
  subjects.foreach { subject =>
    val scores = students.map(_.scores(subject))
    val avg = average(scores)
    val max = scores.max
    val min = scores.min
    
    println(s"${subject}: 平均${avg.round}点, 最高${max}点, 最低${min}点")
  }
}
```

## よくある間違いと対処法

### 間違い1：過度な型指定

```scala
// 悪い例
val list: List[String] = List[String]("a", "b", "c")
val map: Map[String, Int] = Map[String, Int]("one" -> 1)

// 良い例
val list = List("a", "b", "c")
val map = Map("one" -> 1)
```

### 間違い2：型推論の誤解

```scala
// 意図しない型推論
val numbers = List(1, 2, 3.0)  // List[Double]になる！

// 明示的に型を指定
val intNumbers: List[Int] = List(1, 2, 3)
```

### 間違い3：varでの型変更

```scala
var value = 10      // Int型として推論
// value = "text"   // エラー！型は変更できない

// 異なる型を扱いたい場合
var anyValue: Any = 10
anyValue = "text"   // OK
```

## 型推論のデバッグ

```scala
// TypeInferenceDebugging.scala
@main def typeInferenceDebugging(): Unit = {
  // 推論された型を確認する方法
  
  // 1. IDEのホバー機能を使う（最も簡単）
  
  // 2. 明示的に型を書いて確認
  val mystery = List(1, 2, 3).map(_.toString)
  // val check: List[Int] = mystery  // エラーで型が分かる
  
  // 3. 実行時に型を確認
  println(s"型: ${mystery.getClass}")
  println(s"要素の型: ${mystery.headOption.map(_.getClass)}")
  
  // 4. 型を一時的に明示して確認
  val explicit: List[String] = List(1, 2, 3).map(_.toString)
  
  // 5. コンパイラオプションで型を表示
  // scalac -Xprint:typer MyFile.scala
}
```

## 練習問題

### 問題1：型推論の確認

以下の変数の推論される型を答えてください：
```scala
val a = 42
val b = 42L
val c = 42.0
val d = "42"
val e = List(1, 2, 3)
val f = Map("a" -> 1, "b" -> 2)
```

### 問題2：関数の型推論

以下の関数の戻り値の型を答えてください：
```scala
def double(x: Int) = x * 2
def concat(a: String, b: String) = a + b
def compare(x: Int, y: Int) = x > y
```

### 問題3：型推論を活用

型を一切書かずに、数値のリストから偶数のみを抽出し、それぞれを2倍にして文字列のリストとして返す関数を作成してください。

### 問題4：型推論の修正

以下のコードで意図しない型推論が起きています。修正してください：
```scala
val prices = List(100, 200, 300.5)  // すべてIntにしたい
val result = 10 / 3                 // 小数の結果が欲しい
```

### 問題5：再帰関数

型推論を考慮して、フィボナッチ数列を計算する再帰関数を作成してください。

## まとめ

この章では以下のことを学びました：

1. **型推論の基本**
    - Scalaが自動的に型を判断
    - 値や式から適切な型を推論
    - コードがシンプルで読みやすくなる

2. **関数での型推論**
    - 戻り値の型は多くの場合推論可能
    - 引数の型は明示的に指定が必要
    - 再帰関数では戻り値の型が必須

3. **コレクションでの型推論**
    - 要素から自動的に型を判断
    - メソッドチェーンでも型を追跡
    - 複雑な構造でも適切に推論

4. **型推論のベストプラクティス**
    - パブリックAPIでは型を明示
    - ローカル変数では推論を活用
    - 意図を明確にしたい場合は型を書く

5. **型推論の限界と注意点**
    - 再帰関数での制限
    - 意図しない型推論への対処
    - デバッグ方法の理解

次の章では、文字列の操作について詳しく学んでいきます！