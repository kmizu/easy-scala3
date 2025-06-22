# 第14章 条件分岐の基本

## はじめに

これまでのプログラムは、上から下へ一直線に実行されていました。でも、現実世界では「もし雨なら傘を持つ」「もし18歳以上なら投票できる」のように、条件によって行動を変えますよね。

プログラムも同じです！条件によって処理を変える「条件分岐」を学んで、もっと賢いプログラムを作りましょう。

## if式：「もし〜なら」を表現する

### 基本の if

```scala
// BasicIf.scala
@main def basicIf(): Unit = {
  val age = 20
  
  if (age >= 18) {
    println("成人です！選挙権があります。")
  }
  
  val temperature = 28
  
  if (temperature > 25) {
    println("暑いですね。エアコンをつけましょう。")
  }
}
```

「もし（if）〜なら（then）、これをする」という形です。日本語と同じですね！

### if-else：「そうでなければ」

```scala
// IfElse.scala
@main def ifElse(): Unit = {
  val score = 75
  
  if (score >= 80) {
    println("合格です！おめでとう！")
  } else {
    println("残念、不合格です。次回がんばりましょう。")
  }
  
  // 天気で行動を決める
  val weather = "雨"
  
  if (weather == "晴れ") {
    println("ピクニックに行きましょう！")
  } else {
    println("家で映画でも見ましょう。")
  }
}
```

### if-else if-else：複数の条件

```scala
// MultipleConditions.scala
@main def multipleConditions(): Unit = {
  val score = 85
  
  if (score >= 90) {
    println("優秀！Aランクです")
  } else if (score >= 80) {
    println("良好！Bランクです")
  } else if (score >= 70) {
    println("合格！Cランクです")
  } else {
    println("もう少しがんばりましょう")
  }
  
  // 時間帯であいさつを変える
  val hour = 14
  
  if (hour >= 5 && hour < 12) {
    println("おはようございます")
  } else if (hour >= 12 && hour < 17) {
    println("こんにちは")
  } else if (hour >= 17 && hour < 22) {
    println("こんばんは")
  } else {
    println("おやすみなさい")
  }
}
```

## 条件の書き方

### 比較演算子

```scala
// ComparisonOperators.scala
@main def comparisonOperators(): Unit = {
  val x = 10
  val y = 20
  
  println(s"x = $x, y = $y として...")
  println(s"x == y : ${x == y}")  // 等しい？
  println(s"x != y : ${x != y}")  // 等しくない？
  println(s"x < y  : ${x < y}")   // より小さい？
  println(s"x <= y : ${x <= y}")  // 以下？
  println(s"x > y  : ${x > y}")   // より大きい？
  println(s"x >= y : ${x >= y}")  // 以上？
  
  // 文字列の比較
  val name = "太郎"
  println(s"\n名前が太郎？: ${name == "太郎"}")
  println(s"名前が太郎じゃない？: ${name != "太郎"}")
}
```

### 論理演算子：条件を組み合わせる

```scala
// LogicalOperators.scala
@main def logicalOperators(): Unit = {
  val age = 25
  val hasLicense = true
  
  // && (かつ、AND)
  if (age >= 18 && hasLicense) {
    println("車を運転できます")
  }
  
  // || (または、OR)
  val isWeekend = true
  val isHoliday = false
  
  if (isWeekend || isHoliday) {
    println("今日は休みです！")
  }
  
  // ! (否定、NOT)
  val isRaining = false
  
  if (!isRaining) {
    println("雨は降っていません")
  }
  
  // 複雑な条件
  val temperature = 22
  val humidity = 60
  
  if (temperature >= 20 && temperature <= 25 && humidity < 70) {
    println("とても快適な天気です")
  }
}
```

## if式は値を返す

### 値としてのif

```scala
// IfAsExpression.scala
@main def ifAsExpression(): Unit = {
  val score = 85
  
  // ifの結果を変数に入れる
  val result = if (score >= 80) "合格" else "不合格"
  println(s"判定: $result")
  
  // 計算にも使える
  val price = 1000
  val isMember = true
  
  val finalPrice = if (isMember) price * 0.9 else price
  println(f"お支払い金額: ${finalPrice.toInt}円")
  
  // 複数行でも大丈夫
  val message = if (score >= 90) {
    "素晴らしい！" +
    "次もこの調子で！"
  } else if (score >= 80) {
    "よくできました！" +
    "もう少しで最高評価です。"
  } else {
    "もっとがんばりましょう。"
  }
  
  println(message)
}
```

## 実践的な例

### 料金計算システム

```scala
// PriceCalculator.scala
@main def priceCalculator(): Unit = {
  // 映画館の料金計算
  def calculateTicketPrice(age: Int, dayOfWeek: String): Int = {
    val basePrice = 1800
    
    if (age < 6) {
      0  // 幼児無料
    } else if (age <= 12) {
      1000  // 子供料金
    } else if (age >= 60) {
      1200  // シニア料金
    } else if (dayOfWeek == "水曜日") {
      1000  // レディースデー（誰でも）
    } else {
      basePrice  // 通常料金
    }
  }
  
  // いろいろな条件で試してみる
  println("=== 映画館料金表 ===")
  println(s"5歳・月曜日: ${calculateTicketPrice(5, "月曜日")}円")
  println(s"10歳・火曜日: ${calculateTicketPrice(10, "火曜日")}円")
  println(s"25歳・水曜日: ${calculateTicketPrice(25, "水曜日")}円")
  println(s"65歳・金曜日: ${calculateTicketPrice(65, "金曜日")}円")
  
  // 割引の組み合わせ
  def calculateWithDiscounts(
    age: Int, 
    isMember: Boolean, 
    hasСoupon: Boolean
  ): Int = {
    var price = calculateTicketPrice(age, "月曜日")
    
    // 会員割引（10%オフ）
    if (isMember && price > 0) {
      price = (price * 0.9).toInt
    }
    
    // クーポン割引（200円引き）
    if (hasСoupon && price > 200) {
      price = price - 200
    }
    
    price
  }
  
  println("\n=== 割引適用例 ===")
  println(s"一般・会員・クーポンあり: ${calculateWithDiscounts(30, true, true)}円")
}
```

### BMI計算と健康アドバイス

```scala
// BMICalculator.scala
@main def bmiCalculator(): Unit = {
  def calculateBMI(weight: Double, height: Double): Double =
    weight / (height * height)
  
  def getHealthAdvice(bmi: Double): String = {
    if (bmi < 18.5) {
      "低体重です。バランスの良い食事を心がけましょう。"
    } else if (bmi < 25.0) {
      "標準体重です。この調子を維持しましょう！"
    } else if (bmi < 30.0) {
      "肥満（1度）です。適度な運動を始めましょう。"
    } else {
      "肥満（2度以上）です。医師に相談することをお勧めします。"
    }
  }
  
  // テストケース
  val people = List(
    ("太郎", 70.0, 1.75),
    ("花子", 50.0, 1.60),
    ("次郎", 85.0, 1.70)
  )
  
  people.foreach { case (name, weight, height) =>
    val bmi = calculateBMI(weight, height)
    println(f"$name さん: BMI = $bmi%.1f")
    println(s"  → ${getHealthAdvice(bmi)}")
    println()
  }
}
```

### ゲーム：じゃんけん判定

```scala
// RockPaperScissors.scala
@main def rockPaperScissors(): Unit = {
  def judge(player1: String, player2: String): String = {
    if (player1 == player2) {
      "引き分け"
    } else if ((player1 == "グー" && player2 == "チョキ") ||
               (player1 == "チョキ" && player2 == "パー") ||
               (player1 == "パー" && player2 == "グー")) {
      "プレイヤー1の勝ち！"
    } else {
      "プレイヤー2の勝ち！"
    }
  }
  
  // 対戦
  println("=== じゃんけん大会 ===")
  val matches = List(
    ("グー", "チョキ"),
    ("パー", "パー"),
    ("チョキ", "グー"),
    ("パー", "グー")
  )
  
  matches.foreach { case (p1, p2) =>
    println(s"$p1 vs $p2 → ${judge(p1, p2)}")
  }
  
  // コンピュータと対戦
  import scala.util.Random
  
  val hands = List("グー", "チョキ", "パー")
  val playerHand = "グー"  // プレイヤーの手
  val computerHand = hands(Random.nextInt(3))  // ランダムに選ぶ
  
  println(s"\nあなた: $playerHand")
  println(s"コンピュータ: $computerHand")
  println(s"結果: ${judge(playerHand, computerHand)}")
}
```

## ネストした条件分岐

```scala
// NestedIf.scala
@main def nestedIf(): Unit = {
  // 遊園地の乗り物制限
  def canRide(age: Int, height: Int, withParent: Boolean): String = {
    if (age < 6) {
      if (withParent) {
        "保護者同伴で乗れます"
      } else {
        "保護者の同伴が必要です"
      }
    } else if (age < 12) {
      if (height >= 120) {
        "乗れます！"
      } else {
        "身長が120cm以上必要です"
      }
    } else {
      if (height >= 140) {
        "乗れます！"
      } else {
        "身長が140cm以上必要です"
      }
    }
  }
  
  // テスト
  println("=== ジェットコースター乗車判定 ===")
  println(s"5歳・110cm・親なし: ${canRide(5, 110, false)}")
  println(s"5歳・110cm・親あり: ${canRide(5, 110, true)}")
  println(s"10歳・125cm・親なし: ${canRide(10, 125, false)}")
  println(s"15歳・135cm・親なし: ${canRide(15, 135, false)}")
}
```

## よくある間違いと注意点

### 間違い1：=と==を混同

```scala
// CommonMistakes1.scala
@main def commonMistakes1(): Unit = {
  val x = 10
  
  // 間違い（これは代入になってしまう）
  // if x = 10 then  // エラー！
  
  // 正しい（比較）
  if (x == 10) {
    println("xは10です")
  }
  
  // 否定の場合
  if (x != 5) {
    println("xは5ではありません")
  }
}
```

### 間違い2：条件の範囲

```scala
// CommonMistakes2.scala
@main def commonMistakes2(): Unit = {
  val score = 75
  
  // 間違い：条件が重複している
  if (score >= 70) {
    println("C")
  } else if (score >= 80) {  // この条件には到達しない！
    println("B")
  }
  
  // 正しい：大きい値から順に
  if (score >= 80) {
    println("B")
  } else if (score >= 70) {
    println("C")
  }
}
```

### 間違い3：型の不一致

```scala
// CommonMistakes3.scala
@main def commonMistakes3(): Unit = {
  val age = "20"  // 文字列
  
  // 間違い：文字列と数値を比較
  // if age > 18 then  // エラー！
  
  // 正しい：数値に変換してから比較
  if (age.toInt > 18) {
    println("成人です")
  }
  
  // または最初から数値で扱う
  val ageNum = 20
  if (ageNum > 18) {
    println("成人です")
  }
}
```

## 練習してみよう！

### 練習1：成績評価

点数（0-100）を受け取って、以下の評価を返す関数を作ってください：
- 90以上：S
- 80以上：A  
- 70以上：B
- 60以上：C
- 60未満：D

### 練習2：電気料金計算

使用量に応じて電気料金を計算する関数を作ってください：
- 基本料金：1000円
- 0-100kWh：1kWhあたり20円
- 101-200kWh：1kWhあたり25円
- 201kWh以上：1kWhあたり30円

### 練習3：曜日判定

日付（1-31）を受け取って、今月の第何週の何曜日かを判定してください。
（1日が月曜日と仮定）

## この章のまとめ

条件分岐について学びました！

### できるようになったこと

✅ **if式の基本**
- if-then で条件実行
- if-else で二者択一
- if-else if-else で複数条件

✅ **条件の書き方**
- 比較演算子（==, !=, <, >, <=, >=）
- 論理演算子（&&, ||, !）
- 複合条件の組み立て

✅ **値としてのif**
- if式は値を返す
- 変数への代入
- 式の中での利用

✅ **実践的な使い方**
- 料金計算
- 判定ロジック
- 複雑な条件の整理

### 条件分岐を使うコツ

1. **シンプルに始める**
    - まず単純な条件から
    - 必要に応じて複雑化
    - 読みやすさを重視

2. **条件の順序**
    - 特殊なケースを先に
    - 範囲は大きい方から
    - デフォルトは最後に

3. **適切な粒度**
    - 条件が多すぎたら整理
    - 関数に分割
    - パターンマッチング（次章）の検討

### 次の章では...

もっと強力な条件分岐「パターンマッチング」を学びます。Scalaの真骨頂の一つです！

### 最後に

条件分岐は「プログラムの頭脳」です。これで、あなたのプログラムは状況に応じて賢く振る舞えるようになりました。まるでプログラムに知能を与えたようですね！