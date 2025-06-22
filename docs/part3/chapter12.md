# 第12章 型安全なマップ

## はじめに

「辞書」を使ったことはありますか？単語を調べると、その意味が出てきますよね。プログラミングの「マップ（Map）」も同じような仕組みです。

「キー（鍵）」を使って「値」を取り出す、まるで宝箱のようなデータ構造です。この章では、Scalaの型安全なマップについて、楽しく学んでいきましょう！

## マップって何だろう？

### 身近な例で考えてみよう

```scala
// MapLikeDictionary.scala
@main def mapLikeDictionary(): Unit = {
  // 電話帳のようなマップ
  val phoneBook = Map(
    "田中太郎" -> "090-1234-5678",
    "山田花子" -> "080-9876-5432",
    "佐藤次郎" -> "070-1111-2222"
  )
  
  // 名前（キー）で電話番号（値）を調べる
  println(s"田中太郎の電話番号: ${phoneBook("田中太郎")}")
  
  // 英和辞典のようなマップ
  val dictionary = Map(
    "apple" -> "りんご",
    "banana" -> "バナナ",
    "orange" -> "オレンジ"
  )
  
  println(s"appleの意味: ${dictionary("apple")}")
}
```

マップは「何か」と「何か」を結びつける、便利な道具です！

### もっと実用的な例

```scala
// PracticalMaps.scala
@main def practicalMaps(): Unit = {
  // 商品と価格
  val prices = Map(
    "コーヒー" -> 300,
    "紅茶" -> 250,
    "ケーキ" -> 400,
    "サンドイッチ" -> 350
  )
  
  println("=== カフェメニュー ===")
  prices.foreach { case (item, price) =>
    println(s"$item: ${price}円")
  }
  
  // 学生と成績
  val grades = Map(
    "A001" -> 85,
    "A002" -> 92,
    "A003" -> 78,
    "A004" -> 88
  )
  
  println("\n=== 成績一覧 ===")
  grades.foreach { case (id, score) =>
    println(s"学籍番号$id: $score点")
  }
}
```

## マップの作り方

### 基本の作り方

```scala
// CreatingMaps.scala
@main def creatingMaps(): Unit = {
  // 方法1：矢印記法（おすすめ！）
  val fruits = Map(
    "apple" -> "りんご",
    "banana" -> "バナナ",
    "grape" -> "ぶどう"
  )
  
  // 方法2：タプルを使う
  val numbers = Map(
    ("one", 1),
    ("two", 2),
    ("three", 3)
  )
  
  // 方法3：空のマップから始める
  val emptyMap = Map[String, Int]()
  val withOne = emptyMap + ("first" -> 1)
  val withTwo = withOne + ("second" -> 2)
  
  println(s"果物: $fruits")
  println(s"数字: $numbers")
  println(s"追加後: $withTwo")
}
```

### 型を明示する

```scala
// TypedMaps.scala
@main def typedMaps(): Unit = {
  // 型を明示的に指定
  val ages: Map[String, Int] = Map(
    "太郎" -> 20,
    "花子" -> 22,
    "次郎" -> 19
  )
  
  // 型推論に任せる（通常はこれでOK）
  val cities = Map(
    "東京" -> "日本",
    "ニューヨーク" -> "アメリカ",
    "ロンドン" -> "イギリス"
  )
  
  // 複雑な型のマップ
  val studentInfo: Map[String, (Int, String)] = Map(
    "A001" -> (20, "工学部"),
    "A002" -> (21, "理学部"),
    "A003" -> (19, "文学部")
  )
  
  studentInfo.foreach { case (id, (age, dept)) =>
    println(s"$id: ${age}歳, $dept")
  }
}
```

## 値を取り出す

### 基本的な取り出し方

```scala
// GettingValues.scala
@main def gettingValues(): Unit = {
  val inventory = Map(
    "ペン" -> 50,
    "ノート" -> 30,
    "消しゴム" -> 100
  )
  
  // 直接取り出す（キーが必ず存在する場合）
  val penCount = inventory("ペン")
  println(s"ペンの在庫: $penCount個")
  
  // 存在しないキーを指定するとエラー！
  // val rulerCount = inventory("定規")  // エラー！
  
  // 安全に取り出す（getメソッド）
  inventory.get("ノート") match {
    case Some(count) => println(s"ノートの在庫: ${count}個")
    case None => println("ノートは在庫にありません")
  }
  
  inventory.get("定規") match {
    case Some(count) => println(s"定規の在庫: ${count}個")
    case None => println("定規は在庫にありません")
  }
}
```

### 便利な取り出し方

```scala
// ConvenientGetters.scala
@main def convenientGetters(): Unit = {
  val settings = Map(
    "fontSize" -> 14,
    "theme" -> "dark",
    "autoSave" -> "true"
  )
  
  // デフォルト値を指定して取得
  val fontSize = settings.getOrElse("fontSize", 12)
  val lineHeight = settings.getOrElse("lineHeight", 20)  // 存在しない
  
  println(s"フォントサイズ: $fontSize")
  println(s"行の高さ: $lineHeight（デフォルト値）")
  
  // キーの存在確認
  if (settings.contains("theme")) {
    println(s"テーマ設定: ${settings("theme")}")
  } else {
    println("テーマは未設定です")
  }
  
  // すべてのキーと値を取得
  println("\n=== すべての設定 ===")
  println(s"キー一覧: ${settings.keys}")
  println(s"値一覧: ${settings.values}")
}
```

## マップの更新

### イミュータブルマップの更新

```scala
// UpdatingMaps.scala
@main def updatingMaps(): Unit = {
  val originalPrices = Map(
    "コーヒー" -> 300,
    "紅茶" -> 250
  )
  
  // 要素を追加（新しいマップを作成）
  val withCake = originalPrices + ("ケーキ" -> 400)
  
  // 複数追加
  val fullMenu = originalPrices ++ Map(
    "ケーキ" -> 400,
    "サンドイッチ" -> 350
  )
  
  // 値を更新（同じキーで上書き）
  val newPrices = originalPrices + ("コーヒー" -> 350)
  
  // 要素を削除
  val withoutTea = fullMenu - "紅茶"
  
  println(s"元の価格: $originalPrices")
  println(s"ケーキ追加: $withCake")
  println(s"フルメニュー: $fullMenu")
  println(s"値上げ後: $newPrices")
  println(s"紅茶なし: $withoutTea")
}
```

### ミュータブルマップ

```scala
// MutableMaps.scala
@main def mutableMaps(): Unit = {
  import scala.collection.mutable
  
  // ミュータブルマップの作成
  val scores = mutable.Map(
    "太郎" -> 80,
    "花子" -> 85
  )
  
  // 直接更新できる
  scores("太郎") = 90  // 更新
  scores("次郎") = 75  // 追加
  
  println(s"更新後: $scores")
  
  // 削除
  scores.remove("花子")
  println(s"花子を削除: $scores")
  
  // 一括更新
  scores ++= Map("桜" -> 88, "健太" -> 92)
  println(s"複数追加: $scores")
}
```

## 実践的な使い方

### 在庫管理システム

```scala
// InventorySystem.scala
@main def inventorySystem(): Unit = {
  // 商品の在庫管理
  var inventory = Map(
    "ペン" -> 100,
    "ノート" -> 50,
    "消しゴム" -> 200,
    "定規" -> 30
  )
  
  // 在庫を表示
  def showInventory(): Unit = {
    println("=== 現在の在庫 ===")
    inventory.foreach { case (item, count) =>
      val status = if (count < 50) "⚠️ 在庫少" else "✓"
      println(f"$item%-10s: $count%3d個 $status")
    }
  }
  
  // 商品を販売
  def sell(item: String, quantity: Int): Unit =
    inventory.get(item) match {
      case Some(current) if current >= quantity =>
        inventory = inventory + (item -> (current - quantity))
        println(s"✓ $item を${quantity}個販売しました")
      case Some(current) =>
        println(s"❌ 在庫不足！${item}は${current}個しかありません")
      case None =>
        println(s"❌ ${item}は取り扱っていません")
    }
  
  // 在庫を補充
  def restock(item: String, quantity: Int): Unit = {
    val current = inventory.getOrElse(item, 0)
    inventory = inventory + (item -> (current + quantity))
    println(s"✓ $item を${quantity}個補充しました")
  }
  
  // 使ってみる
  showInventory()
  
  println("\n--- 販売処理 ---")
  sell("ペン", 30)
  sell("ノート", 60)  // 在庫不足
  sell("はさみ", 5)   // 存在しない
  
  println("\n--- 補充処理 ---")
  restock("ノート", 100)
  restock("はさみ", 50)  // 新商品
  
  println()
  showInventory()
}
```

### 成績管理と分析

```scala
// GradeAnalysis.scala
@main def gradeAnalysis(): Unit = {
  // 学生の成績（学籍番号 -> (名前, 点数のマップ)）
  val students = Map(
    "S001" -> ("田中太郎", Map("数学" -> 85, "英語" -> 78, "理科" -> 92)),
    "S002" -> ("山田花子", Map("数学" -> 92, "英語" -> 88, "理科" -> 85)),
    "S003" -> ("佐藤次郎", Map("数学" -> 78, "英語" -> 95, "理科" -> 80))
  )
  
  // 個人成績表
  def showStudentGrades(id: String): Unit =
    students.get(id) match {
      case Some((name, grades)) =>
        println(s"=== $name さんの成績 ===")
        var total = 0
        grades.foreach { case (subject, score) =>
          println(s"$subject: $score点")
          total += score
        }
        val average = total.toDouble / grades.size
        println(f"平均: $average%.1f点")
        
      case None =>
        println(s"学籍番号 $id の学生は見つかりません")
    }
  
  // 科目別統計
  def subjectStats(subject: String): Unit = {
    println(s"\n=== $subject の統計 ===")
    val scores = students.values.flatMap { case (_, grades) =>
      grades.get(subject)
    }.toList
    
    if (scores.nonEmpty) {
      val average = scores.sum.toDouble / scores.length
      val max = scores.max
      val min = scores.min
      
      println(f"平均点: $average%.1f")
      println(s"最高点: $max")
      println(s"最低点: $min")
    }
  }
  
  // 使ってみる
  showStudentGrades("S001")
  showStudentGrades("S004")  // 存在しない
  
  subjectStats("数学")
  subjectStats("英語")
}
```

### 単語カウンター

```scala
// WordCounter.scala
@main def wordCounter(): Unit = {
  val text = """
    Scalaは楽しい言語です。
    Scalaで関数型プログラミングを学びましょう。
    Scalaは型安全です。
  """
  
  // 単語を数える
  val words = text.split("\\s+|。|、").filter(_.nonEmpty)
  
  var wordCount = Map[String, Int]()
  
  words.foreach { word =>
    val current = wordCount.getOrElse(word, 0)
    wordCount = wordCount + (word -> (current + 1))
  }
  
  // 結果を表示
  println("=== 単語の出現回数 ===")
  wordCount.toList
    .sortBy(-_._2)  // 回数の多い順
    .foreach { case (word, count) =>
      println(s"$word: $count回")
    }
}
```

## マップの便利な操作

### フィルタリングと変換

```scala
// MapOperations.scala
@main def mapOperations(): Unit = {
  val products = Map(
    "ペン" -> 100,
    "ノート" -> 200,
    "消しゴム" -> 80,
    "定規" -> 150,
    "はさみ" -> 300
  )
  
  // 150円以上の商品を抽出
  val expensive = products.filter { case (_, price) => price >= 150 }
  println(s"150円以上: $expensive")
  
  // 価格を10%値上げ
  val increased = products.map { case (name, price) =>
    (name, (price * 1.1).toInt)
  }
  println(s"10%値上げ後: $increased")
  
  // キーだけ変換（商品名を大文字に）
  val upperCase = products.map { case (name, price) =>
    (name.toUpperCase, price)
  }
  println(s"大文字: $upperCase")
}
```

### マップの結合

```scala
// MergingMaps.scala
@main def mergingMaps(): Unit = {
  val shop1 = Map("りんご" -> 100, "バナナ" -> 80)
  val shop2 = Map("バナナ" -> 90, "オレンジ" -> 120)
  
  // 単純な結合（後の値で上書き）
  val merged1 = shop1 ++ shop2
  println(s"shop2優先: $merged1")
  
  val merged2 = shop2 ++ shop1
  println(s"shop1優先: $merged2")
  
  // カスタム結合（安い方を選ぶ）
  val bestPrices = (shop1.keySet ++ shop2.keySet).map { fruit =>
    val price1 = shop1.getOrElse(fruit, Int.MaxValue)
    val price2 = shop2.getOrElse(fruit, Int.MaxValue)
    fruit -> math.min(price1, price2)
  }.toMap
  
  println(s"最安値: $bestPrices")
}
```

## よくある間違いと対処法

### 間違い1：存在しないキー

```scala
// MapMistakes1.scala
@main def mapMistakes1(): Unit = {
  val ages = Map("太郎" -> 20, "花子" -> 22)
  
  // 間違い：存在しないキーに直接アクセス
  // val jiroAge = ages("次郎")  // エラー！
  
  // 正しい方法1：getを使う
  ages.get("次郎") match {
    case Some(age) => println(s"次郎は${age}歳")
    case None => println("次郎のデータはありません")
  }
  
  // 正しい方法2：getOrElseを使う
  val jiroAge = ages.getOrElse("次郎", 0)
  println(s"次郎の年齢: $jiroAge（デフォルト値）")
  
  // 正しい方法3：事前にチェック
  if (ages.contains("次郎")) {
    println(s"次郎は${ages("次郎")}歳")
  } else {
    println("次郎のデータはありません")
  }
}
```

### 間違い2：型の不一致

```scala
// MapMistakes2.scala
@main def mapMistakes2(): Unit = {
  // 型が明確なマップ
  val prices: Map[String, Int] = Map(
    "コーヒー" -> 300,
    "紅茶" -> 250
  )
  
  // 間違い：違う型の値を追加しようとする
  // val wrong = prices + ("ケーキ" -> "400円")  // エラー！
  
  // 正しい：同じ型で追加
  val correct = prices + ("ケーキ" -> 400)
  println(correct)
}
```

## 練習してみよう！

### 練習1：メニュー計算機

カフェのメニューと注文リストから、合計金額を計算してください。

```scala
@main def practice1(): Unit = {
  val menu = Map(
    "コーヒー" -> 300,
    "紅茶" -> 250,
    "ケーキ" -> 400,
    "サンドイッチ" -> 350
  )
  
  val orders = List(
    "コーヒー", "コーヒー", "ケーキ", "紅茶"
  )
  
  // ここに合計金額を計算するコードを書いてください
}
```

### 練習2：投票集計

投票結果のリストから、各候補者の得票数を集計してください。

```scala
@main def practice2(): Unit = {
  val votes = List(
    "山田", "田中", "山田", "佐藤", 
    "田中", "山田", "田中", "田中"
  )
  
  // ここに集計コードを書いてください
  // 期待する結果: Map("山田" -> 3, "田中" -> 4, "佐藤" -> 1)
}
```

### 練習3：在庫チェック

注文リストに対して、在庫が足りるかチェックしてください。

```scala
@main def practice3(): Unit = {
  val inventory = Map(
    "ペン" -> 50,
    "ノート" -> 30,
    "消しゴム" -> 100
  )
  
  val orders = Map(
    "ペン" -> 20,
    "ノート" -> 40,  // 在庫不足！
    "定規" -> 10     // 在庫にない！
  )
  
  // ここにチェックコードを書いてください
}
```

## この章のまとめ

マップについて、本当にたくさんのことを学びましたね！

### できるようになったこと

✅ **マップの基本**
- キーと値のペアでデータを管理
- 型安全な宣言と操作
- 効率的なデータの検索

✅ **マップの操作**
- 値の取得（get、getOrElse）
- 要素の追加・更新・削除
- 安全なアクセス方法

✅ **実践的な使い方**
- 在庫管理システム
- 成績の集計と分析
- 単語のカウント

✅ **便利な機能**
- フィルタリングと変換
- マップの結合
- キーと値の操作

### マップを使うべき場面

1. **検索が必要なとき**
    - 名前から電話番号を調べる
    - 商品名から価格を調べる
    - IDからデータを取得する

2. **関連付けが必要なとき**
    - 単語と意味
    - 人と属性
    - キーと設定値

3. **集計や分析**
    - 出現回数のカウント
    - グループごとの集計
    - データの分類

### 次の章では...

マップを使った、より高度なデータ処理について学びます。複雑なデータ構造の操作も、怖くありませんよ！

### 最後に

マップは「魔法の辞書」のようなものです。何でも入れられて、すぐに取り出せる。この便利さを活用して、もっと楽しいプログラムを作っていきましょう！