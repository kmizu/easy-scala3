# 第10章 型安全なタプル

## はじめに

タプル（Tuple）は、異なる型の値を固定数だけまとめて扱うためのデータ構造です。リストが同じ型の要素を可変個数扱うのに対し、タプルは異なる型の要素を固定個数扱います。この章では、タプルの使い方と型安全性について学びます。

## タプルとは何か？

### タプルの基本概念

```scala
// TupleBasics.scala
@main def tupleBasics(): Unit =
  // 2要素のタプル（ペア）
  val person = ("太郎", 25)
  println(s"名前と年齢: ${person}")
  
  // 3要素のタプル
  val coordinate = (10.5, 20.3, 5.0)
  println(s"3D座標: ${coordinate}")
  
  // 異なる型を混在できる
  val mixed = ("Scala", 3.3, true, 'A')
  println(s"混在型: ${mixed}")
  
  // タプルの型
  val pair: (String, Int) = ("花子", 22)
  val triple: (Int, String, Boolean) = (1, "yes", true)
  
  // 最大22要素まで
  val large = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 
               11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22)
  println(s"22要素のタプル: ${large}")
}
```

### タプルへのアクセス

```scala
// TupleAccess.scala
@main def tupleAccess(): Unit =
  val person = ("山田太郎", 30, "エンジニア")
  
  // 位置でアクセス（1から始まる）
  println(s"名前: ${person._1}")
  println(s"年齢: ${person._2}")
  println(s"職業: ${person._3}")
  
  // パターンマッチで分解
  val (name, age, job) = person
  println(s"$name さん（$age 歳）は $job です")
  
  // 一部だけ取り出す
  val (personName, _, personJob) = person
  println(s"$personName の職業は $personJob")
  
  // match式での分解
  person match
    case (n, a, j) if a >= 20 => 
      println(s"$n は成人です")
    case _ => 
      println("未成年です")
}
```

## タプルの作成方法

### 様々な作成方法

```scala
// TupleCreation.scala
@main def tupleCreation(): Unit =
  // 通常の作成方法
  val tuple1 = (1, "one")
  val tuple2 = (1, "one", 1.0)
  
  // Tupleクラスを使った作成
  val tuple3 = Tuple2(1, "one")
  val tuple4 = Tuple3(1, "one", 1.0)
  
  // 矢印記法（2要素のみ）
  val pair = 1 -> "one"
  println(s"矢印記法: ${pair}")
  
  // 関数の戻り値として
  def getCoordinate(): (Double, Double) = (35.6762, 139.6503)
  val (lat, lon) = getCoordinate()
  println(s"緯度: $lat, 経度: $lon")
  
  // Option型と組み合わせ
  def divide(a: Int, b: Int): Option[(Int, Int)] =
    if b != 0 then Some((a / b, a % b))
    else None
  
  divide(10, 3) match
    case Some((quotient, remainder)) =>
      println(s"10 ÷ 3 = $quotient 余り $remainder")
    case None =>
      println("ゼロ除算エラー")
}
```

### タプルのネスト

```scala
// NestedTuples.scala
@main def nestedTuples(): Unit =
  // ネストしたタプル
  val nested = ((1, 2), (3, 4))
  println(s"ネストしたタプル: ${nested}")
  
  // アクセス
  println(s"左上: ${nested._1._1}")
  println(s"右下: ${nested._2._2}")
  
  // より複雑な構造
  val student = (
    "S12345",                    // 学籍番号
    ("山田", "太郎"),            // 姓名
    (2024, 4, 1),               // 入学年月日
    Map("数学" -> 85, "英語" -> 78)  // 成績
  )
  
  val (id, (lastName, firstName), (year, month, day), scores) = student
  println(s"$lastName $firstName さん（学籍番号: $id）")
  println(s"入学: $year年$month月$day日")
  println(s"成績: $scores")
}
```

## タプルの型安全性

### 型の保証

```scala
// TupleTypeSafety.scala
@main def tupleTypeSafety(): Unit =
  // 各要素の型が保証される
  val data: (Int, String, Double) = (100, "円", 1.1)
  
  // 型が合わないとコンパイルエラー
  // val wrong: (Int, String, Double) = (100, 200, 1.1)  // エラー！
  
  // 型推論も正確
  val inferred = (42, "answer", true)
  val num: Int = inferred._1       // OK
  val str: String = inferred._2    // OK
  val bool: Boolean = inferred._3  // OK
  
  // 関数の引数として
  def processData(data: (String, Int, Boolean)): String =
    val (name, value, active) = data
    if active then s"$name: $value" else s"$name: 無効"
  
  println(processData(("温度", 25, true)))
  println(processData(("湿度", 60, false)))
  
  // 型エイリアスでより分かりやすく
  type PersonInfo = (String, Int, String)
  type Coordinate3D = (Double, Double, Double)
  
  val person: PersonInfo = ("佐藤", 28, "営業")
  val point: Coordinate3D = (1.0, 2.0, 3.0)
}
```

### ケースクラスとの比較

```scala
// TupleVsCaseClass.scala
@main def tupleVsCaseClass(): Unit =
  // タプルを使った場合
  val personTuple = ("田中", 35, "デザイナー")
  println(s"名前: ${personTuple._1}")  // 意味が分かりづらい
  
  // ケースクラスを使った場合
  case class Person(name: String, age: Int, job: String)
  val personClass = Person("田中", 35, "デザイナー")
  println(s"名前: ${personClass.name}")  // 意味が明確
  
  // タプルが適している場合
  // 1. 一時的なデータの組み合わせ
  def getMinMax(numbers: List[Int]): (Int, Int) =
    (numbers.min, numbers.max)
  
  // 2. 複数の値を返す関数
  def divmod(a: Int, b: Int): (Int, Int) =
    (a / b, a % b)
  
  // 3. キーと値のペア
  val entries = List(
    "apple" -> 100,
    "banana" -> 80,
    "orange" -> 120
  )
  
  // ケースクラスが適している場合
  // 1. ドメインモデル
  case class Product(name: String, price: Int, stock: Int)
  
  // 2. 再利用される構造
  case class Address(zip: String, prefecture: String, city: String)
}
```

## タプルの操作

### タプルの変換

```scala
// TupleOperations.scala
@main def tupleOperations(): Unit =
  // swap（2要素タプルのみ）
  val pair = (1, "one")
  val swapped = pair.swap
  println(s"元: $pair, 交換後: $swapped")
  
  // タプルからリストへ
  val triple = (10, 20, 30)
  val list = List(triple._1, triple._2, triple._3)
  println(s"リスト化: $list")
  
  // productIteratorを使った汎用的な変換
  val tuple = ("A", "B", "C", "D")
  val elements = tuple.productIterator.toList
  println(s"要素のリスト: $elements")
  
  // タプルの要素を変換
  val numbers = (1, 2, 3)
  val doubled = (numbers._1 * 2, numbers._2 * 2, numbers._3 * 2)
  println(s"2倍: $doubled")
  
  // より汎用的な変換（ただし型情報は失われる）
  def multiplyTuple3(t: (Int, Int, Int), factor: Int): (Int, Int, Int) =
    (t._1 * factor, t._2 * factor, t._3 * factor)
  
  println(s"3倍: ${multiplyTuple3(numbers, 3)}")
}
```

### タプルとコレクション

```scala
// TupleWithCollections.scala
@main def tupleWithCollections(): Unit =
  // タプルのリスト
  val students = List(
    ("山田", 85),
    ("鈴木", 92),
    ("佐藤", 78),
    ("田中", 88)
  )
  
  // ソート
  val sortedByScore = students.sortBy(_._2).reverse
  println("成績順:")
  sortedByScore.foreach { case (name, score) =>
    println(s"  $name: $score点")
  }
  
  // フィルタリング
  val highScorers = students.filter(_._2 >= 85)
  println(s"85点以上: $highScorers")
  
  // マップに変換
  val scoreMap = students.toMap
  println(s"マップ化: $scoreMap")
  
  // unzipでリストを分解
  val (names, scores) = students.unzip
  println(s"名前: $names")
  println(s"点数: $scores")
  println(s"平均点: ${scores.sum.toDouble / scores.length}")
}
```

## 実践的な例：データ分析

```scala
// DataAnalysisWithTuples.scala
@main def dataAnalysisWithTuples(): Unit =
  // 売上データ（日付、商品名、数量、単価）
  val salesData = List(
    ("2024-01-01", "商品A", 5, 1000),
    ("2024-01-01", "商品B", 3, 1500),
    ("2024-01-02", "商品A", 8, 1000),
    ("2024-01-02", "商品C", 2, 2000),
    ("2024-01-03", "商品B", 6, 1500),
    ("2024-01-03", "商品C", 4, 2000)
  )
  
  // 売上金額を計算
  val salesWithAmount = salesData.map { case (date, product, qty, price) =>
    (date, product, qty, price, qty * price)
  }
  
  println("=== 売上明細 ===")
  salesWithAmount.foreach { case (date, product, qty, price, amount) =>
    println(f"$date: $product × $qty個 = $amount%,d円")
  }
  
  // 日別集計
  val dailySales = salesWithAmount
    .groupBy(_._1)  // 日付でグループ化
    .view.mapValues(_.map(_._5).sum)  // 売上合計
    .toMap
  
  println("\n=== 日別売上 ===")
  dailySales.toList.sorted.foreach { case (date, total) =>
    println(f"$date: $total%,d円")
  }
  
  // 商品別集計
  val productSales = salesWithAmount
    .groupBy(_._2)  // 商品でグループ化
    .view.mapValues { sales =>
      val totalQty = sales.map(_._3).sum
      val totalAmount = sales.map(_._5).sum
      (totalQty, totalAmount)
    }
    .toMap
  
  println("\n=== 商品別売上 ===")
  productSales.foreach { case (product, (qty, amount)) =>
    println(f"$product: $qty個, $amount%,d円")
  }
  
  // 統計情報
  val amounts = salesWithAmount.map(_._5)
  val stats = (
    amounts.sum,                          // 合計
    amounts.sum.toDouble / amounts.length, // 平均
    amounts.max,                          // 最大
    amounts.min                           // 最小
  )
  
  val (total, avg, max, min) = stats
  println(f"\n=== 統計情報 ===")
  println(f"売上合計: $total%,d円")
  println(f"平均売上: $avg%,.1f円")
  println(f"最大売上: $max%,d円")
  println(f"最小売上: $min%,d円")
}
```

## パターンマッチングの活用

```scala
// TuplePatternMatching.scala
@main def tuplePatternMatching(): Unit =
  // 基本的なパターンマッチ
  val data = (42, "answer")
  
  data match
    case (n, s) => println(s"数値: $n, 文字列: $s")
  
  // 条件付きパターン
  val scores = List(
    ("Alice", 95),
    ("Bob", 82),
    ("Carol", 76),
    ("Dave", 68)
  )
  
  scores.foreach {
    case (name, score) if score >= 90 => 
      println(s"$name: 優秀！")
    case (name, score) if score >= 80 => 
      println(s"$name: 良好")
    case (name, score) if score >= 70 => 
      println(s"$name: 可")
    case (name, _) => 
      println(s"$name: 要努力")
  }
  
  // ネストしたタプルのパターンマッチ
  val nested = ((1, 2), (3, 4))
  
  nested match
    case ((a, b), (c, d)) =>
      println(s"合計: ${a + b + c + d}")
  
  // 部分的なマッチ
  val triple = (100, "test", true)
  
  triple match
    case (n, _, true) if n > 50 =>
      println("50より大きく、有効")
    case (n, _, false) =>
      println(s"無効（値: $n）")
    case _ =>
      println("その他")
}
```

## よくあるエラーと対処法

### エラー例1：インデックスの間違い

```scala
val pair = (1, 2)
// val third = pair._3  // エラー！存在しない
```

**対処法**: タプルのサイズを確認し、適切なインデックスを使用

### エラー例2：型の不一致

```scala
val tuple: (Int, String) = (100, "test")
// val num: String = tuple._1  // エラー！型が違う
```

**対処法**: 正しい型を指定するか、型変換を行う

### エラー例3：可変長データへの誤用

```scala
// val data = (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23)  // エラー！23要素
```

**対処法**: 22要素を超える場合はリストやケースクラスを使用

## 練習問題

### 問題1：座標計算

2次元座標を表すタプル(Double, Double)を受け取り、以下を計算する関数を作成してください：
- 2点間の距離
- 中点の座標
- 原点からの距離

### 問題2：データ集計

(日付: String, 売上: Int, 費用: Int)のリストから以下を計算してください：
- 利益（売上 - 費用）が最大の日
- 利益率（利益 / 売上）の平均
- 赤字の日数

### 問題3：タプルの変換

(String, Int, Boolean)のリストを、条件に応じて変換してください：
- Booleanがtrueの要素のみ抽出
- Stringを大文字に、Intを2倍に変換
- IntでソートしてStringのリストを返す

### 問題4：複雑なデータ構造

学生の成績データ(学籍番号: String, (数学: Int, 英語: Int, 理科: Int))のリストから：
- 3科目の合計点でランキング
- 各科目の最高得点者
- 全科目80点以上の学生

### 問題5：エラーを修正

```scala
@main def broken(): Unit =
  val data = (1, "two", 3.0)
  val sum = data._1 + data._2 + data._3
  
  val pair = (10, 20)
  val (a, b, c) = pair
  
  val list = List((1, "a"), (2, "b"))
  val first = list.head._3
```

## まとめ

この章では以下のことを学びました：

1. **タプルの基本**
   - 異なる型の要素を固定数まとめる
   - 最大22要素まで扱える
   - イミュータブルなデータ構造

2. **要素へのアクセス**
   - _1, _2などの位置アクセス
   - パターンマッチによる分解
   - 型安全なアクセス

3. **タプルの作成と操作**
   - 様々な作成方法
   - swapやproductIterator
   - コレクションとの組み合わせ

4. **型安全性**
   - 各要素の型が保証される
   - コンパイル時の型チェック
   - 型推論の活用

5. **使いどころ**
   - 一時的なデータの組み合わせ
   - 複数値の返却
   - 軽量なデータ構造として

次の章では、タプルを使って異なるデータをまとめる実践的な方法を学んでいきます！