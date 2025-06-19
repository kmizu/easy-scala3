# 第9章 リストで同じデータを並べる

## はじめに

リスト（List）は、Scalaで最もよく使われるコレクションです。順序を保持し、同じ型の要素を並べて管理できます。この章では、リストの詳細な使い方と、実践的な活用方法を学びます。

## リストの基本

### リストの作成と特徴

```scala
// ListCreation.scala
@main def listCreation(): Unit =
  // リストの作成方法
  val list1 = List(1, 2, 3, 4, 5)
  val list2 = 1 :: 2 :: 3 :: 4 :: 5 :: Nil  // ::演算子を使った方法
  val list3 = List.range(1, 6)              // 範囲から作成
  val list4 = List.fill(5)(0)               // 同じ値で埋める
  
  println(s"List(): ${list1}")
  println(s":: 演算子: ${list2}")
  println(s"range: ${list3}")
  println(s"fill: ${list4}")
  
  // リストの特徴
  // 1. イミュータブル（変更不可）
  // 2. 順序を保持
  // 3. 同じ型の要素のみ
  // 4. 先頭への追加が高速
  
  // 型安全性の確認
  val intList: List[Int] = List(1, 2, 3)
  val stringList: List[String] = List("a", "b", "c")
  // val mixedList: List[Int] = List(1, "2", 3)  // エラー！型が違う
}
```

### Cons（::）演算子の理解

```scala
// ConsOperator.scala
@main def consOperator(): Unit =
  // ::（cons）は要素をリストの先頭に追加
  val list = List(2, 3, 4)
  val newList = 1 :: list
  
  println(s"元のリスト: ${list}")
  println(s"1を先頭に追加: ${newList}")
  
  // リストの構造を理解
  val step1 = Nil           // 空のリスト
  val step2 = 3 :: step1    // List(3)
  val step3 = 2 :: step2    // List(2, 3)
  val step4 = 1 :: step3    // List(1, 2, 3)
  
  println(s"Step 1: ${step1}")
  println(s"Step 2: ${step2}")
  println(s"Step 3: ${step3}")
  println(s"Step 4: ${step4}")
  
  // パターンマッチでの分解
  list match
    case head :: tail =>
      println(s"先頭: ${head}, 残り: ${tail}")
    case Nil =>
      println("空のリスト")
}
```

## リストの基本操作

### 要素へのアクセス

```scala
// ListAccess.scala
@main def listAccess(): Unit =
  val fruits = List("りんご", "バナナ", "オレンジ", "ぶどう", "メロン")
  
  // 基本的なアクセス
  println(s"最初の要素: ${fruits.head}")
  println(s"最後の要素: ${fruits.last}")
  println(s"最初以外: ${fruits.tail}")
  println(s"最後以外: ${fruits.init}")
  
  // インデックスアクセス
  println(s"0番目: ${fruits(0)}")
  println(s"2番目: ${fruits(2)}")
  
  // 安全なアクセス
  println(s"headOption: ${fruits.headOption}")
  println(s"lastOption: ${fruits.lastOption}")
  
  val emptyList = List[String]()
  println(s"空リストのheadOption: ${emptyList.headOption}")
  
  // lift メソッドで安全にインデックスアクセス
  println(s"存在する要素: ${fruits.lift(1)}")
  println(s"存在しない要素: ${fruits.lift(10)}")
  
  // 部分リストの取得
  println(s"最初の3つ: ${fruits.take(3)}")
  println(s"最後の2つ: ${fruits.takeRight(2)}")
  println(s"最初の2つを除く: ${fruits.drop(2)}")
  println(s"最後の1つを除く: ${fruits.dropRight(1)}")
}
```

### リストの結合と分割

```scala
// ListConcatenation.scala
@main def listConcatenation(): Unit =
  val list1 = List(1, 2, 3)
  val list2 = List(4, 5, 6)
  val list3 = List(7, 8, 9)
  
  // リストの結合
  val combined1 = list1 ++ list2
  val combined2 = list1 ::: list2  // リスト専用の結合演算子
  val combined3 = List.concat(list1, list2, list3)
  
  println(s"++ 演算子: ${combined1}")
  println(s"::: 演算子: ${combined2}")
  println(s"concat: ${combined3}")
  
  // リストの分割
  val numbers = List(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
  
  val (firstHalf, secondHalf) = numbers.splitAt(5)
  println(s"前半: ${firstHalf}, 後半: ${secondHalf}")
  
  val (evens, odds) = numbers.partition(_ % 2 == 0)
  println(s"偶数: ${evens}, 奇数: ${odds}")
  
  // グループ化
  val grouped = numbers.grouped(3).toList
  println(s"3つずつグループ化: ${grouped}")
  
  // sliding window
  val sliding = numbers.sliding(3).toList
  println(s"スライディング窓: ${sliding}")
}
```

## 高度なリスト操作

### map、filter、flatMap

```scala
// ListTransformations.scala
@main def listTransformations(): Unit =
  val numbers = List(1, 2, 3, 4, 5)
  
  // map: 各要素を変換
  val doubled = numbers.map(_ * 2)
  val strings = numbers.map(n => s"数値: $n")
  
  println(s"2倍: ${doubled}")
  println(s"文字列化: ${strings}")
  
  // filter: 条件に合う要素を選択
  val evens = numbers.filter(_ % 2 == 0)
  val largeNumbers = numbers.filter(_ > 3)
  
  println(s"偶数: ${evens}")
  println(s"3より大: ${largeNumbers}")
  
  // flatMap: mapして平坦化
  val nested = List(List(1, 2), List(3, 4), List(5))
  val flattened = nested.flatten
  val flatMapped = numbers.flatMap(n => List(n, n * 10))
  
  println(s"flatten: ${flattened}")
  println(s"flatMap: ${flatMapped}")
  
  // 組み合わせ
  val result = numbers
    .filter(_ % 2 == 1)      // 奇数のみ
    .map(_ * 3)              // 3倍
    .filter(_ > 5)           // 5より大きい
  
  println(s"組み合わせ: ${result}")
}
```

### fold と reduce

```scala
// ListFoldReduce.scala
@main def listFoldReduce(): Unit =
  val numbers = List(1, 2, 3, 4, 5)
  
  // sum は fold の特殊な例
  val sum1 = numbers.sum
  val sum2 = numbers.fold(0)(_ + _)
  val sum3 = numbers.foldLeft(0)(_ + _)
  
  println(s"sum: ${sum1}")
  println(s"fold: ${sum2}")
  println(s"foldLeft: ${sum3}")
  
  // 文字列の結合
  val words = List("Scala", "is", "awesome")
  val sentence = words.foldLeft("")((acc, word) => 
    if acc.isEmpty then word else s"$acc $word"
  )
  println(s"文章: ${sentence}")
  
  // reduce（初期値なし）
  val product = numbers.reduce(_ * _)
  val max = numbers.reduce((a, b) => if a > b then a else b)
  
  println(s"積: ${product}")
  println(s"最大値: ${max}")
  
  // foldLeft vs foldRight
  val chars = List("A", "B", "C")
  val left = chars.foldLeft("X")(_ + _)   // "XABC"
  val right = chars.foldRight("X")(_ + _) // "ABCX"
  
  println(s"foldLeft: ${left}")
  println(s"foldRight: ${right}")
}
```

### zip と unzip

```scala
// ListZip.scala
@main def listZip(): Unit =
  val names = List("太郎", "花子", "次郎")
  val ages = List(20, 22, 19)
  val cities = List("東京", "大阪", "名古屋", "福岡")  // 長いリスト
  
  // zip: 2つのリストをペアにする
  val pairs = names.zip(ages)
  println(s"名前と年齢: ${pairs}")
  
  // 長さが違う場合は短い方に合わせる
  val nameCity = names.zip(cities)
  println(s"名前と都市: ${nameCity}")
  
  // zipWithIndex: インデックス付き
  val indexed = names.zipWithIndex
  println(s"インデックス付き: ${indexed}")
  
  // unzip: ペアのリストを2つのリストに分解
  val (nameList, ageList) = pairs.unzip
  println(s"名前: ${nameList}, 年齢: ${ageList}")
  
  // 3つ組の場合
  val triples = names.zip(ages).zip(cities).map {
    case ((name, age), city) => (name, age, city)
  }
  val (names2, ages2, cities2) = triples.unzip3
  println(s"3つ組: ${triples}")
}
```

## パターンマッチングとリスト

```scala
// ListPatternMatching.scala
@main def listPatternMatching(): Unit =
  // 基本的なパターンマッチ
  def describe(list: List[Int]): String = list match
    case Nil => "空のリスト"
    case head :: Nil => s"要素が1つ: $head"
    case head :: tail => s"先頭: $head, 残り: $tail"
  
  println(describe(List()))
  println(describe(List(1)))
  println(describe(List(1, 2, 3)))
  
  // より複雑なパターン
  def sumFirstTwo(list: List[Int]): Option[Int] = list match
    case first :: second :: _ => Some(first + second)
    case _ => None
  
  println(s"最初の2つの和: ${sumFirstTwo(List(10, 20, 30))}")
  println(s"要素不足: ${sumFirstTwo(List(10))}")
  
  // 再帰的な処理
  def sum(list: List[Int]): Int = list match
    case Nil => 0
    case head :: tail => head + sum(tail)
  
  println(s"再帰的な合計: ${sum(List(1, 2, 3, 4, 5))}")
  
  // 条件付きパターン
  def findFirstEven(list: List[Int]): Option[Int] = list match
    case Nil => None
    case head :: tail if head % 2 == 0 => Some(head)
    case _ :: tail => findFirstEven(tail)
  
  println(s"最初の偶数: ${findFirstEven(List(1, 3, 5, 4, 6))}")
}
```

## 実践的な例：TODOリスト管理

```scala
// TodoListManager.scala
@main def todoListManager(): Unit =
  // TODOアイテムの定義
  case class Todo(
    id: Int,
    title: String,
    completed: Boolean = false,
    priority: Int = 3  // 1:高, 2:中, 3:低
  )
  
  // 初期のTODOリスト
  var todos = List(
    Todo(1, "Scalaの勉強", false, 1),
    Todo(2, "買い物に行く", false, 2),
    Todo(3, "メールの返信", true, 3),
    Todo(4, "運動する", false, 2),
    Todo(5, "本を読む", false, 3)
  )
  
  // TODOの表示
  def displayTodos(list: List[Todo]): Unit =
    list.foreach { todo =>
      val status = if todo.completed then "✓" else "○"
      val priority = "★" * (4 - todo.priority)
      println(f"$status ${todo.id}%2d. ${todo.title}%-20s $priority")
    }
  
  println("=== 現在のTODO ===")
  displayTodos(todos)
  
  // 未完了のTODOを取得
  val pending = todos.filterNot(_.completed)
  println(s"\n未完了: ${pending.length}件")
  
  // 優先度順にソート
  val sorted = todos.sortBy(todo => (todo.completed, todo.priority))
  println("\n=== 優先度順 ===")
  displayTodos(sorted)
  
  // TODOを完了にする
  def completeTodo(id: Int, list: List[Todo]): List[Todo] =
    list.map { todo =>
      if todo.id == id then todo.copy(completed = true)
      else todo
    }
  
  todos = completeTodo(2, todos)
  println("\n=== ID:2を完了 ===")
  displayTodos(todos)
  
  // 統計情報
  val stats = todos.groupBy(_.completed).view.mapValues(_.length)
  println(s"\n完了: ${stats.getOrElse(true, 0)}件")
  println(s"未完了: ${stats.getOrElse(false, 0)}件")
}
```

## リストのパフォーマンス最適化

```scala
// ListPerformance.scala
@main def listPerformance(): Unit =
  // リストの構築：末尾への追加は避ける
  def buildListBad(n: Int): List[Int] =
    var list = List[Int]()
    for i <- 1 to n do
      list = list :+ i  // O(n) - 遅い！
    list
  
  def buildListGood(n: Int): List[Int] =
    var list = List[Int]()
    for i <- 1 to n do
      list = i :: list  // O(1) - 速い！
    list.reverse      // 最後に一度だけ反転
  
  // さらに良い方法
  def buildListBest(n: Int): List[Int] =
    (1 to n).toList
  
  // 大きなリストでの操作
  val largeList = (1 to 10000).toList
  
  // 遅延評価を活用
  val result = largeList.view
    .filter(_ % 2 == 0)
    .map(_ * 2)
    .take(10)
    .toList
  
  println(s"遅延評価の結果: ${result}")
  
  // tail recursion で stack overflow を防ぐ
  @annotation.tailrec
  def sumTailRec(list: List[Int], acc: Int = 0): Int = list match
    case Nil => acc
    case head :: tail => sumTailRec(tail, acc + head)
  
  val sum = sumTailRec((1 to 100000).toList)
  println(s"末尾再帰の合計: ${sum}")
}
```

## よくある使用パターン

```scala
// CommonListPatterns.scala
@main def commonListPatterns(): Unit =
  val data = List(1, 2, 3, 4, 5, 6, 7, 8, 9, 10)
  
  // 存在チェック
  println(s"5を含む？: ${data.contains(5)}")
  println(s"偶数が存在？: ${data.exists(_ % 2 == 0)}")
  println(s"すべて正？: ${data.forall(_ > 0)}")
  
  // 検索
  println(s"最初の偶数: ${data.find(_ % 2 == 0)}")
  println(s"5のインデックス: ${data.indexOf(5)}")
  
  // 集計
  println(s"合計: ${data.sum}")
  println(s"平均: ${data.sum.toDouble / data.length}")
  println(s"最大: ${data.max}")
  println(s"最小: ${data.min}")
  
  // 変換と収集
  val (evens, odds) = data.partition(_ % 2 == 0)
  val grouped = data.groupBy(_ % 3)
  
  println(s"偶数と奇数: $evens, $odds")
  println(s"3で割った余りでグループ化: $grouped")
  
  // distinct と重複
  val duplicates = List(1, 2, 2, 3, 3, 3, 4, 4, 4, 4)
  println(s"重複除去: ${duplicates.distinct}")
  
  // カウント
  val counts = duplicates.groupBy(identity).view.mapValues(_.size)
  println(s"出現回数: ${counts.toMap}")
}
```

## 練習問題

### 問題1：リストの操作

以下の操作を行う関数を作成してください：
- リストの要素を逆順にする（reverseを使わずに）
- リストから重複を除去する（distinctを使わずに）
- 2つのソート済みリストをマージする

### 問題2：統計関数

数値のリストを受け取り、以下を計算する関数を作成してください：
- 分散
- 標準偏差
- 中央値

### 問題3：文字列処理

文字列のリストを受け取り、以下の処理を行ってください：
- 各文字列の最初の文字を大文字にする
- 空文字列を除去する
- 長さ順にソートする

### 問題4：ネストしたリスト

List[List[Int]]を受け取り、以下を計算してください：
- 全要素の合計
- 各内部リストの最大値のリスト
- 転置（行と列を入れ替え）

### 問題5：エラーを修正

```scala
@main def broken(): Unit =
  val list = List(1, 2, 3)
  list(0) = 10  // リストを変更しようとしている
  
  val empty = List()
  val first = empty.head
  
  val result = list.map(_ + 1).filter(_ > 2).sum()
```

## まとめ

この章では以下のことを学びました：

1. **リストの基本**
   - イミュータブルな順序付きコレクション
   - ::演算子による効率的な構築
   - 型安全性の保証

2. **基本的な操作**
   - 要素へのアクセス（head、tail、apply）
   - リストの結合と分割
   - 安全な操作方法

3. **高度な操作**
   - map、filter、flatMapによる変換
   - foldとreduceによる集約
   - zipによる複数リストの結合

4. **パターンマッチング**
   - リストの構造による分岐
   - 再帰的な処理
   - 条件付きパターン

5. **パフォーマンスの考慮**
   - 先頭への追加の活用
   - 遅延評価の利用
   - 末尾再帰の重要性

次の章では、異なる型の要素をまとめられるタプルについて学んでいきます！