# 第11章 タプルで違うデータをまとめる

## はじめに

プログラミングをしていると、「名前と年齢」「緯度と経度」「成功・失敗とその理由」のように、違う種類のデータをセットで扱いたいことがよくあります。

前の章では「同じ型のデータを並べる」リストを学びました。今回は「違う型のデータをまとめる」タプルを学びましょう！

タプルは、日常生活でいえば「お弁当箱」のようなものです。ごはん、おかず、デザートなど、違うものを1つの箱にまとめて持ち運べますよね。

## タプルって何だろう？

### お弁当箱で考えてみよう

```scala
// TupleLikeBento.scala
@main def tupleLikeBento(): Unit = {
  // お弁当の中身（違うものが入っている）
  val myBento = ("おにぎり", 2, "唐揚げ", true)
  //             ↑文字    ↑数  ↑文字   ↑真偽値
  
  println(s"今日のお弁当: $myBento")
  
  // 何が入っているか確認
  println(s"主食: ${myBento._1}")  // 1番目
  println(s"個数: ${myBento._2}")  // 2番目
  println(s"おかず: ${myBento._3}") // 3番目
  println(s"デザート付き？: ${myBento._4}") // 4番目
}
```

タプルは「違う型のデータを、決まった順番で、決まった数だけ」まとめられます！

### もっと身近な例

```scala
// DailyTuples.scala
@main def dailyTuples(): Unit = {
  // 人の情報（名前と年齢）
  val person = ("田中太郎", 25)
  println(s"${person._1}さんは${person._2}歳です")
  
  // 場所の情報（地名と座標）
  val tokyo = ("東京", 35.6762, 139.6503)
  println(s"${tokyo._1}の緯度: ${tokyo._2}, 経度: ${tokyo._3}")
  
  // テストの結果（科目と点数と合格？）
  val testResult = ("数学", 85, true)
  val subject = testResult._1
  val score = testResult._2
  val passed = testResult._3
  
  if (passed) {
    println(s"${subject}は${score}点で合格です！")
  } else {
    println(s"${subject}は${score}点で不合格です...")
  }
}
```

## タプルの作り方

### 基本の作り方

```scala
// CreatingTuples.scala
@main def creatingTuples(): Unit = {
  // 2つの要素（ペア）
  val pair = ("りんご", 100)
  println(s"$pair")  // (りんご,100)
  
  // 3つの要素（トリプル）
  val triple = ("みかん", 80, 5)
  println(s"$triple")  // (みかん,80,5)
  
  // もっとたくさん（最大22個まで！）
  val many = (1, "二", 3.0, '四', true, 6)
  println(s"いろいろ: $many")
  
  // 型を明示することもできる
  val typed: (String, Int) = ("バナナ", 150)
  println(s"型付き: $typed")
}
```

### 矢印を使った書き方（ペアのみ）

```scala
// ArrowNotation.scala
@main def arrowNotation(): Unit = {
  // 2つの要素の時だけ使える特別な書き方
  val price1 = "コーヒー" -> 300
  val price2 = ("コーヒー", 300)  // 上と同じ意味！
  
  println(s"矢印記法: $price1")
  println(s"普通の記法: $price2")
  
  // マップを作るときによく使う
  val menu = Map(
    "コーヒー" -> 300,
    "紅茶" -> 250,
    "ケーキ" -> 400
  )
  
  println(s"メニュー: $menu")
}
```

## タプルの中身を取り出す

### 番号で取り出す（._1, ._2, ...）

```scala
// AccessingTuples.scala
@main def accessingTuples(): Unit = {
  val studentInfo = ("山田花子", 20, "工学部", 3.5)
  
  // 番号は1から始まる！（0からじゃない）
  println(s"名前: ${studentInfo._1}")
  println(s"年齢: ${studentInfo._2}歳")
  println(s"学部: ${studentInfo._3}")
  println(s"GPA: ${studentInfo._4}")
  
  // こんな使い方も
  val message = s"${studentInfo._1}さん（${studentInfo._2}歳）は" +
                s"${studentInfo._3}の学生で、GPAは${studentInfo._4}です"
  println(message)
}
```

### 分解して取り出す（おすすめ！）

```scala
// DestructuringTuples.scala
@main def destructuringTuples(): Unit = {
  val studentInfo = ("山田花子", 20, "工学部", 3.5)
  
  // 一度に全部取り出す（これが便利！）
  val (name, age, department, gpa) = studentInfo
  
  println(s"名前: $name")
  println(s"年齢: $age歳")
  println(s"学部: $department")
  println(s"GPA: $gpa")
  
  // 必要なものだけ取り出す（_で無視）
  val (studentName, _, studentDept, _) = studentInfo
  println(s"$studentNameさんは$studentDept所属です")
  
  // 複数のタプルを処理
  val results = List(
    ("数学", 85),
    ("英語", 92),
    ("理科", 78)
  )
  
  results.foreach { case (subject, score) =>
    println(s"$subject: $score点")
  }
}
```

## 実践的な使い方

### 関数から複数の値を返す

```scala
// ReturningMultipleValues.scala
@main def returningMultipleValues(): Unit = {
  // 割り算の商と余りを同時に返す
  def divideWithRemainder(a: Int, b: Int): (Int, Int) =
    (a / b, a % b)
  
  val (quotient, remainder) = divideWithRemainder(17, 5)
  println(s"17 ÷ 5 = $quotient 余り $remainder")
  
  // 統計情報を返す
  def getStats(numbers: List[Int]): (Int, Double, Int, Int) = {
    val sum = numbers.sum
    val avg = sum.toDouble / numbers.length
    val max = numbers.max
    val min = numbers.min
    (sum, avg, max, min)
  }
  
  val data = List(10, 20, 30, 40, 50)
  val (total, average, maximum, minimum) = getStats(data)
  
  println(s"合計: $total")
  println(s"平均: $average")
  println(s"最大: $maximum")
  println(s"最小: $minimum")
}
```

### エラー処理での活用

```scala
// TuplesForErrorHandling.scala
@main def tuplesForErrorHandling(): Unit = {
  // 成功・失敗と結果を一緒に返す
  def safeDivide(a: Int, b: Int): (Boolean, Double, String) =
    if (b == 0) {
      (false, 0.0, "ゼロで割ることはできません")
    } else {
      (true, a.toDouble / b, "計算成功")
    }
  
  // 使ってみる
  val (success1, result1, message1) = safeDivide(10, 2)
  if (success1) {
    println(s"結果: $result1")
  } else {
    println(s"エラー: $message1")
  }
  
  val (success2, result2, message2) = safeDivide(10, 0)
  if (success2) {
    println(s"結果: $result2")
  } else {
    println(s"エラー: $message2")
  }
}
```

### データの整理

```scala
// OrganizingData.scala
@main def organizingData(): Unit = {
  // 商品情報（名前、価格、在庫数）
  val products = List(
    ("ノート", 100, 50),
    ("ペン", 150, 30),
    ("消しゴム", 80, 100),
    ("定規", 200, 20)
  )
  
  // 在庫が少ない商品を探す
  println("=== 在庫が少ない商品（30個以下）===")
  products.foreach { case (name, price, stock) =>
    if (stock <= 30) {
      println(s"$name: 残り$stock個（${price}円）")
    }
  }
  
  // 売上計算（商品名、販売数）
  val sales = List(
    ("ノート", 10),
    ("ペン", 5),
    ("消しゴム", 20)
  )
  
  println("\n=== 売上レポート ===")
  sales.foreach { case (productName, quantity) =>
    // 商品情報から価格を探す
    products.find(_._1 == productName) match {
      case Some((_, price, _)) =>
        val total = price * quantity
        println(s"$productName: ${quantity}個 × ${price}円 = ${total}円")
      case None =>
        println(s"$productName: 商品情報が見つかりません")
    }
  }
}
```

## タプルの便利な機能

### swap（2要素タプルのみ）

```scala
// TupleSwap.scala
@main def tupleSwap(): Unit = {
  val original = ("先", "後")
  val swapped = original.swap  // 順番を入れ替える
  
  println(s"元: $original")    // (先,後)
  println(s"交換後: $swapped") // (後,先)
  
  // 実用例：キーと値を入れ替える
  val scores = List(
    ("太郎", 85),
    ("花子", 92),
    ("次郎", 78)
  )
  
  // 点数でソートしたい
  val sortedByScore = scores
    .map(_.swap)           // (85,太郎), (92,花子), (78,次郎)
    .sorted                // 数値でソート
    .map(_.swap)           // 元に戻す
  
  println("点数順（低い順）:")
  sortedByScore.foreach { case (name, score) =>
    println(s"  $name: $score点")
  }
}
```

### リストとタプルの変換

```scala
// ListsAndTuples.scala
@main def listsAndTuples(): Unit = {
  // 2つのリストをタプルのリストに
  val names = List("太郎", "花子", "次郎")
  val ages = List(20, 22, 19)
  
  val people = names.zip(ages)  // zip = ジッパーのように組み合わせる
  println(s"組み合わせ: $people")
  
  // タプルのリストを2つのリストに
  val (nameList, ageList) = people.unzip
  println(s"名前: $nameList")
  println(s"年齢: $ageList")
  
  // インデックス付きリスト
  val fruits = List("りんご", "バナナ", "オレンジ")
  val indexed = fruits.zipWithIndex
  
  println("\n果物リスト:")
  indexed.foreach { case (fruit, index) =>
    println(s"  ${index + 1}. $fruit")
  }
}
```

## よくある間違いと対処法

### 間違い1：番号を間違える

```scala
// CommonMistakes1.scala
@main def commonMistakes1(): Unit = {
  val pair = ("A", "B")
  
  // よくある間違い
  // val first = pair._0   // エラー！0番はない
  // val third = pair._3   // エラー！2要素しかない
  
  // 正しい方法
  val first = pair._1   // OK
  val second = pair._2  // OK
  
  println(s"1番目: $first, 2番目: $second")
}
```

### 間違い2：型を間違える

```scala
// CommonMistakes2.scala
@main def commonMistakes2(): Unit = {
  val data: (String, Int) = ("年齢", 25)
  
  // よくある間違い
  // val age: String = data._2  // エラー！Intなのに String として扱おうとしている
  
  // 正しい方法
  val label: String = data._1  // OK
  val age: Int = data._2       // OK
  
  println(s"$label: $age")
}
```

### 間違い3：要素数を間違える

```scala
// CommonMistakes3.scala
@main def commonMistakes3(): Unit = {
  val triple = ("A", "B", "C")
  
  // よくある間違い
  // val (a, b) = triple        // エラー！3要素なのに2つしか受け取っていない
  // val (a, b, c, d) = triple  // エラー！3要素なのに4つ受け取ろうとしている
  
  // 正しい方法
  val (a, b, c) = triple      // OK：ちょうど3つ
  val (x, y, _) = triple      // OK：3つ目は無視
  
  println(s"全部: $a, $b, $c")
  println(s"2つだけ: $x, $y")
}
```

## 練習してみよう！

### 練習1：座標計算

2次元座標を表すタプル(Double, Double)を使って、2点間の距離を計算するプログラムを作ってください。

```scala
@main def practice1(): Unit = {
  val point1 = (0.0, 0.0)
  val point2 = (3.0, 4.0)
  
  // ここに距離を計算するコードを書いてください
  // ヒント: 距離 = √((x2-x1)² + (y2-y1)²)
}
```

### 練習2：成績管理

生徒の成績データ（名前、数学、英語、理科）のタプルのリストから、3科目の平均点が最も高い生徒を見つけてください。

```scala
@main def practice2(): Unit = {
  val students = List(
    ("太郎", 80, 75, 85),
    ("花子", 90, 85, 80),
    ("次郎", 70, 90, 75),
    ("桜", 85, 80, 90)
  )
  
  // ここにコードを書いてください
}
```

### 練習3：買い物計算

商品名と単価のタプルのリストと、商品名と購入数のタプルのリストから、合計金額を計算してください。

```scala
@main def practice3(): Unit = {
  val prices = List(
    ("りんご", 100),
    ("バナナ", 80),
    ("オレンジ", 120)
  )
  
  val purchases = List(
    ("りんご", 3),
    ("バナナ", 5),
    ("オレンジ", 2)
  )
  
  // ここに合計金額を計算するコードを書いてください
}
```

## この章のまとめ

タプルについて、たくさんのことを学びましたね！

### できるようになったこと

✅ **タプルの基本**
- 違う型のデータをまとめられる
- 最大22個まで要素を入れられる
- 順番と個数が決まっている

✅ **タプルの作り方**
- 普通の書き方：`(要素1, 要素2, ...)`
- 矢印記法（2要素のみ）：`要素1 -> 要素2`

✅ **要素の取り出し方**
- 番号で：`._1`, `._2`, ...（1から始まる）
- 分解して：`val (a, b, c) = tuple`
- 不要な要素は`_`で無視

✅ **実践的な使い方**
- 関数から複数の値を返す
- 関連するデータをまとめる
- リストと組み合わせて使う

### タプルを使うべき場面

1. **少数の関連データ**
    - 名前と年齢
    - 緯度と経度
    - 成功/失敗と結果

2. **一時的なデータの組み合わせ**
    - 計算の中間結果
    - 関数の戻り値
    - ループ内での処理

3. **型が違うデータを扱う**
    - 文字列と数値
    - 複数の異なる型の組み合わせ

### 次の章では...

タプルの応用編として、より実践的な使い方を学びます。特に、マップ（Map）と組み合わせた使い方を詳しく見ていきましょう！

### 最後に

タプルは「データの小包」のようなものです。関連するものをまとめて、必要なときに取り出す。この考え方は、プログラミングのあらゆる場面で役立ちます。

最初は`._1`や`._2`という書き方に違和感があるかもしれませんが、使っているうちに自然に書けるようになりますよ！