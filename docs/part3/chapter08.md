# 第8章 型安全なコレクション（基礎編）

## はじめに

プログラミングでは、複数のデータをまとめて扱うことがよくあります。例えば、生徒の名簿、商品のリスト、日々の売上データなどです。Scalaには、こうしたデータを効率的かつ安全に扱うための「コレクション」と呼ばれる仕組みがあります。この章では、コレクションの基本概念と型安全性について学びます。

## コレクションとは何か？

### 現実世界のコレクション

```scala
// RealWorldCollections.scala
@main def realWorldCollections(): Unit = {
  // 買い物リスト
  val shoppingList = List("牛乳", "パン", "卵", "りんご")
  println(s"買い物リスト: ${shoppingList}")
  
  // 生徒の点数
  val scores = List(85, 92, 78, 95, 88)
  println(s"テストの点数: ${scores}")
  
  // 曜日と予定
  val schedule = Map(
    "月曜日" -> "会議",
    "火曜日" -> "開発",
    "水曜日" -> "レビュー"
  )
  println(s"今週の予定: ${schedule}")
}
```

### なぜコレクションが必要か？

```scala
// WhyCollections.scala
@main def whyCollections(): Unit = {
  // コレクションを使わない場合（非効率）
  val student1 = "太郎"
  val student2 = "花子"
  val student3 = "次郎"
  val student4 = "桜"
  val student5 = "健太"
  
  println("生徒一覧（個別変数）:")
  println(student1)
  println(student2)
  println(student3)
  println(student4)
  println(student5)
  
  // コレクションを使う場合（効率的）
  val students = List("太郎", "花子", "次郎", "桜", "健太")
  
  println("\n生徒一覧（リスト）:")
  students.foreach(println)
  
  // さらに便利な操作
  println(s"\n生徒数: ${students.length}人")
  println(s"最初の生徒: ${students.head}")
  println(s"「太」を含む生徒: ${students.filter(_.contains("太"))}")
}
```

## 型安全性とは

### 型安全なコレクションの利点

```scala
// TypeSafeCollections.scala
@main def typeSafeCollections(): Unit = {
  // 型安全なリスト（すべて同じ型）
  val numbers: List[Int] = List(1, 2, 3, 4, 5)
  val total = numbers.sum  // 型が保証されているので計算可能
  println(s"合計: ${total}")
  
  // 型が混在する場合（Any型）
  val mixed: List[Any] = List(1, "two", 3.0, true)
  // val mixedTotal = mixed.sum  // エラー！Anyには sum メソッドがない
  
  // 型安全性により間違いを防げる
  val prices: List[Double] = List(100.0, 250.5, 80.0)
  val average = prices.sum / prices.length
  println(f"平均価格: ${average}%.2f円")
  
  // 型を間違えるとコンパイルエラー
  // prices.append("無料")  // エラー！Stringは追加できない
}
```

### 型パラメータ

```scala
// TypeParameters.scala
@main def typeParameters(): Unit = {
  // List[T]のTが型パラメータ
  val intList: List[Int] = List(1, 2, 3)
  val stringList: List[String] = List("a", "b", "c")
  val doubleList: List[Double] = List(1.1, 2.2, 3.3)
  
  // 型パラメータにより、各リストは適切な型のメソッドを使える
  println(s"数値の合計: ${intList.sum}")
  println(s"文字列の結合: ${stringList.mkString}")
  println(s"小数の平均: ${doubleList.sum / doubleList.length}")
  
  // ネストした型パラメータ
  val listOfLists: List[List[Int]] = List(
    List(1, 2, 3),
    List(4, 5, 6),
    List(7, 8, 9)
  )
  
  println("2次元リスト:")
  listOfLists.foreach { row =>
    println(row.mkString(" "))
  }
}
```

## 基本的なコレクション型

### List（リスト）

```scala
// ListBasics.scala
@main def listBasics(): Unit = {
  // リストの作成
  val fruits = List("りんご", "バナナ", "オレンジ")
  val numbers = List(10, 20, 30, 40, 50)
  val empty = List[String]()  // 空のリスト
  
  // 基本的な操作
  println(s"最初の要素: ${fruits.head}")
  println(s"最後の要素: ${fruits.last}")
  println(s"最初以外: ${fruits.tail}")
  println(s"要素数: ${fruits.length}")
  println(s"空？: ${fruits.isEmpty}")
  
  // 要素の追加（新しいリストを作成）
  val moreFruits = "ぶどう" :: fruits  // 先頭に追加
  val evenMore = fruits :+ "メロン"    // 末尾に追加
  
  println(s"元のリスト: ${fruits}")
  println(s"先頭に追加: ${moreFruits}")
  println(s"末尾に追加: ${evenMore}")
}
```
```

### Set（集合）

```scala
// SetBasics.scala
@main def setBasics(): Unit = {
  // Setの作成（重複する要素は自動的に除去）
  val numbers = Set(1, 2, 3, 2, 1, 4)
  println(s"Set: ${numbers}")  // 重複が除去される
  
  // 集合演算
  val set1 = Set(1, 2, 3, 4)
  val set2 = Set(3, 4, 5, 6)
  
  println(s"和集合: ${set1 | set2}")      // 1, 2, 3, 4, 5, 6
  println(s"積集合: ${set1 & set2}")      // 3, 4
  println(s"差集合: ${set1 -- set2}")     // 1, 2
  
  // 要素の確認
  println(s"3を含む？: ${set1.contains(3)}")
  println(s"7を含む？: ${set1.contains(7)}")
  
  // 要素の追加・削除
  val added = numbers + 5
  val removed = numbers - 2
  println(s"5を追加: ${added}")
  println(s"2を削除: ${removed}")
}
```

### Map（マップ）

```scala
// MapBasics.scala
@main def mapBasics(): Unit = {
  // Mapの作成
  val ages = Map(
    "太郎" -> 20,
    "花子" -> 22,
    "次郎" -> 19
  )
  
  // 値の取得
  println(s"太郎の年齢: ${ages("太郎")}")
  
  // 安全な値の取得
  ages.get("花子") match {
    case Some(age) => println(s"花子は${age}歳です")
    case None => println("花子が見つかりません")
  }
  
  // キーと値の一覧
  println(s"名前一覧: ${ages.keys}")
  println(s"年齢一覧: ${ages.values}")
  
  // 要素の追加・更新
  val updated = ages + ("桜" -> 21)
  val modified = updated + ("太郎" -> 21)  // 更新
  
  println(s"桜を追加: ${updated}")
  println(s"太郎を更新: ${modified}")
}
```

## イミュータブルとミュータブル

### イミュータブル（変更不可）コレクション

```scala
// ImmutableCollections.scala
@main def immutableCollections(): Unit = {
  // デフォルトはイミュータブル
  val list = List(1, 2, 3)
  val newList = list :+ 4  // 新しいリストを作成
  
  println(s"元のリスト: ${list}")      // 変わらない
  println(s"新しいリスト: ${newList}")  // 新しいリスト
  
  // イミュータブルの利点
  def processData(data: List[Int]): List[Int] =
    data.map(_ * 2).filter(_ > 5)
  
  val original = List(1, 2, 3, 4, 5)
  val processed = processData(original)
  
  println(s"処理前: ${original}")  // 元のデータは変わらない
  println(s"処理後: ${processed}")
}
```

### ミュータブル（変更可能）コレクション

```scala
// MutableCollections.scala
@main def mutableCollections(): Unit = {
  import scala.collection.mutable
  
  // ミュータブルなリスト（ListBuffer）
  val buffer = mutable.ListBuffer(1, 2, 3)
  buffer += 4        // 要素を追加
  buffer.append(5)   // 別の追加方法
  buffer.remove(0)   // インデックス0を削除
  
  println(s"ListBuffer: ${buffer}")
  
  // ミュータブルなMap
  val scores = mutable.Map("数学" -> 80)
  scores("英語") = 75       // 要素を追加
  scores("数学") = 85       // 要素を更新
  scores.remove("英語")     // 要素を削除
  
  println(s"成績: ${scores}")
  
  // 使い分けの指針
  // - 基本的にはイミュータブルを使う
  // - パフォーマンスが重要な場合のみミュータブル
}
}
```

## コレクションの基本操作

### 要素へのアクセス

```scala
// AccessingElements.scala
@main def accessingElements(): Unit = {
  val list = List("A", "B", "C", "D", "E")
  
  // インデックスでアクセス
  println(s"0番目: ${list(0)}")
  println(s"2番目: ${list(2)}")
  
  // 安全なアクセス
  list.lift(10) match {
    case Some(elem) => println(s"10番目: ${elem}")
    case None => println("10番目は存在しません")
  }
  
  // 条件に合う要素を探す
  val numbers = List(1, 3, 5, 7, 9)
  numbers.find(_ > 5) match {
    case Some(n) => println(s"5より大きい最初の数: ${n}")
    case None => println("見つかりません")
  }
  
  // 複数の要素を取得
  println(s"最初の3つ: ${list.take(3)}")
  println(s"最後の2つ: ${list.takeRight(2)}")
  println(s"2番目から4番目: ${list.slice(1, 4)}")
}
```

### フィルタリングと変換

```scala
// FilteringAndTransforming.scala
@main def filteringAndTransforming(): Unit = {
  val numbers = List(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
  
  // フィルタリング
  val evens = numbers.filter(_ % 2 == 0)
  val odds = numbers.filterNot(_ % 2 == 0)
  val large = numbers.filter(_ > 5)
  
  println(s"偶数: ${evens}")
  println(s"奇数: ${odds}")
  println(s"5より大: ${large}")
  
  // 変換（map）
  val doubled = numbers.map(_ * 2)
  val strings = numbers.map(n => s"数値${n}")
  
  println(s"2倍: ${doubled}")
  println(s"文字列化: ${strings}")
  
  // フィルタと変換の組み合わせ
  val result = numbers
    .filter(_ % 2 == 0)
    .map(_ * 3)
    .filter(_ > 10)
  
  println(s"偶数を3倍して10より大: ${result}")
}
```

## 実践的な例：成績管理システム

```scala
// GradeManagement.scala
@main def gradeManagement(): Unit = {
  // 学生の成績データ
  case class Student(name: String, id: Int, scores: Map[String, Int])
  
  val students = List(
    Student("山田太郎", 101, Map("数学" -> 85, "英語" -> 78, "理科" -> 92)),
    Student("鈴木花子", 102, Map("数学" -> 92, "英語" -> 88, "理科" -> 85)),
    Student("佐藤次郎", 103, Map("数学" -> 78, "英語" -> 95, "理科" -> 80)),
    Student("田中桜", 104, Map("数学" -> 95, "英語" -> 82, "理科" -> 88))
  )
  
  // 各学生の平均点を計算
  val averages = students.map { student =>
    val avg = student.scores.values.sum.toDouble / student.scores.size
    (student.name, avg)
  }
  
  println("=== 平均点 ===")
  averages.foreach { case (name, avg) =>
    println(f"${name}: ${avg}%.1f点")
  }
  
  // 科目別の統計
  val subjects = List("数学", "英語", "理科")
  
  println("\n=== 科目別統計 ===")
  subjects.foreach { subject =>
    val scores = students.map(_.scores(subject))
    val avg = scores.sum.toDouble / scores.length
    val max = scores.max
    val min = scores.min
    
    println(f"${subject}: 平均${avg}%.1f点, 最高${max}点, 最低${min}点")
  }
  
  // 優秀な学生（平均85点以上）
  val excellent = students.filter { student =>
    val avg = student.scores.values.sum.toDouble / student.scores.size
    avg >= 85
  }
  
  println("\n=== 優秀な学生 ===")
  excellent.foreach(s => println(s.name))
}
```

## パフォーマンスの考慮

```scala
// CollectionPerformance.scala
@main def collectionPerformance(): Unit = {
  // Listの特性
  // - 先頭への追加: O(1)
  // - 末尾への追加: O(n)
  // - ランダムアクセス: O(n)
  
  val list = List(1, 2, 3, 4, 5)
  val prepended = 0 :: list      // 高速
  val appended = list :+ 6        // 低速（大きなリストでは）
  
  // Vectorの特性
  // - ランダムアクセス: O(log n)
  // - 追加: O(log n)
  val vector = Vector(1, 2, 3, 4, 5)
  val vecAppended = vector :+ 6   // 比較的高速
  
  // 大量データの処理
  val largeList = (1 to 100000).toList
  val largeVector = (1 to 100000).toVector
  
  // ビューを使った遅延評価
  val view = largeList.view
    .filter(_ % 2 == 0)
    .map(_ * 2)
    .take(10)
  
  println(s"遅延評価の結果: ${view.toList}")
}
```

## よくあるエラーと対処法

### エラー例1：IndexOutOfBoundsException

```scala
val list = List(1, 2, 3)
// val item = list(5)  // エラー！
```

**対処法**: liftメソッドやheadOptionを使う

### エラー例2：NoSuchElementException

```scala
val empty = List[Int]()
// val first = empty.head  // エラー！
```

**対処法**: headOptionやfirstOptionを使う

### エラー例3：型の不一致

```scala
val numbers: List[Int] = List(1, 2, 3)
// numbers :+ "4"  // エラー！型が違う
```

**対処法**: 正しい型の要素を追加する

## 練習問題

### 問題1：ショッピングカート

商品名と価格のMapを使って、ショッピングカートを実装してください：
- 商品の追加・削除
- 合計金額の計算
- 最も高い商品の表示

### 問題2：重複の除去

文字列のリストから重複を除去し、アルファベット順に並べ替える関数を作成してください。

### 問題3：グループ化

学生のリストを学年でグループ化し、各学年の人数を表示するプログラムを作成してください。

### 問題4：統計計算

数値のリストを受け取り、以下を計算する関数を作成してください：
- 平均値
- 中央値
- 最頻値

### 問題5：エラーを修正

```scala
@main def broken(): Unit = {
  val list = List(1, 2, 3)
  list.add(4)
  
  val map = Map("a" -> 1)
  val value = map["a"]
  
  val set = Set(1, 2, 3)
  val first = set.head
  set.remove(first)
}
```

## まとめ

この章では以下のことを学びました：

1. **コレクションの基本概念**
    - 複数のデータをまとめて扱う仕組み
    - 型安全性による安全なプログラミング
    - 型パラメータの使い方

2. **基本的なコレクション型**
    - List：順序付きリスト
    - Set：重複のない集合
    - Map：キーと値のペア

3. **イミュータブルとミュータブル**
    - デフォルトはイミュータブル（推奨）
    - 必要に応じてミュータブルを使用
    - それぞれの利点と使い分け

4. **基本的な操作**
    - 要素へのアクセス
    - フィルタリングと変換
    - 安全な操作方法

5. **パフォーマンスの考慮**
    - 各コレクションの特性
    - 適切なコレクションの選択
    - 遅延評価の活用

次の章では、最も重要なコレクションであるListについて詳しく学んでいきます！