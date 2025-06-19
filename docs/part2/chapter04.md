# 第4章 いろいろな種類のデータ

## はじめに

プログラミングでは数値以外にも様々な種類のデータを扱います。この章では、文字列、真偽値、文字など、Scalaで使える基本的なデータ型について学びます。

## 基本的なデータ型の一覧

Scalaには以下のような基本的なデータ型があります：

| 型名 | 説明 | 例 |
|------|------|-----|
| Int | 整数 | 42, -100, 0 |
| Long | 大きな整数 | 1234567890L |
| Double | 小数 | 3.14, -0.5 |
| Float | 単精度小数 | 3.14f |
| String | 文字列 | "Hello", "こんにちは" |
| Char | 1文字 | 'A', 'あ' |
| Boolean | 真偽値 | true, false |
| Unit | 値なし | () |

## 文字列（String）

### 文字列の基本

```scala
// StringBasics.scala
@main def stringBasics(): Unit =
  val greeting = "こんにちは"
  val name = "太郎"
  
  // 文字列の連結
  val message1 = greeting + "、" + name + "さん"
  println(message1)
  
  // 文字列補間（推奨）
  val message2 = s"${greeting}、${name}さん"
  println(message2)
  
  // 複数行の文字列
  val poem = """春はあけぼの
    |やうやう白くなりゆく
    |山ぎは少し明かりて""".stripMargin
  println(poem)
```

### 文字列の操作

```scala
// StringOperations.scala
@main def stringOperations(): Unit =
  val text = "Hello, Scala!"
  
  // 長さを取得
  println(s"長さ: ${text.length}")
  
  // 大文字・小文字変換
  println(s"大文字: ${text.toUpperCase}")
  println(s"小文字: ${text.toLowerCase}")
  
  // 文字列の一部を取得
  println(s"最初の5文字: ${text.substring(0, 5)}")
  println(s"7文字目から: ${text.substring(7)}")
  
  // 文字列の検索
  println(s"Scalaを含む？: ${text.contains("Scala")}")
  println(s"Helloで始まる？: ${text.startsWith("Hello")}")
  println(s"!で終わる？: ${text.endsWith("!")}")
  
  // 空白の削除
  val spacedText = "  Scala  "
  println(s"元: '${spacedText}'")
  println(s"trim後: '${spacedText.trim}'")
```

### 文字列の分割と結合

```scala
// StringSplitJoin.scala
@main def stringSplitJoin(): Unit =
  // 文字列の分割
  val csv = "りんご,みかん,ぶどう,もも"
  val fruits = csv.split(",")
  
  println("果物リスト:")
  fruits.foreach(fruit => println(s"- ${fruit}"))
  
  // 配列を文字列に結合
  val joined = fruits.mkString(" と ")
  println(s"結合: ${joined}")
  
  // 改行で分割
  val lines = """第1行
    |第2行
    |第3行""".stripMargin
  
  val lineArray = lines.split("\n")
  println(s"行数: ${lineArray.length}")
```

## 真偽値（Boolean）

### Booleanの基本

```scala
// BooleanBasics.scala
@main def booleanBasics(): Unit =
  val isStudent = true
  val isWorking = false
  
  println(s"学生ですか？: ${isStudent}")
  println(s"働いていますか？: ${isWorking}")
  
  // 比較の結果はBoolean
  val age = 20
  val isAdult = age >= 18
  val isTeenager = age >= 13 && age <= 19
  
  println(s"${age}歳は成人？: ${isAdult}")
  println(s"${age}歳はティーンエイジャー？: ${isTeenager}")
```

### 論理演算

```scala
// LogicalOperations.scala
@main def logicalOperations(): Unit =
  val hasLicense = true
  val hasExperience = false
  val age = 25
  
  // AND演算（&&）
  val canDrive = hasLicense && age >= 18
  println(s"運転できる？: ${canDrive}")
  
  // OR演算（||）
  val canApply = hasLicense || hasExperience
  println(s"応募できる？: ${canApply}")
  
  // NOT演算（!）
  val needsTraining = !hasExperience
  println(s"研修が必要？: ${needsTraining}")
  
  // 複雑な条件
  val isEligible = (hasLicense || hasExperience) && age >= 20
  println(s"条件を満たす？: ${isEligible}")
```

## 文字（Char）

### Charの基本

```scala
// CharBasics.scala
@main def charBasics(): Unit =
  val letter = 'A'
  val digit = '5'
  val symbol = '@'
  val japanese = 'あ'
  
  println(s"文字: ${letter}")
  println(s"数字: ${digit}")
  println(s"記号: ${symbol}")
  println(s"日本語: ${japanese}")
  
  // CharとStringの違い
  val charA = 'A'      // Char型（シングルクォート）
  val stringA = "A"    // String型（ダブルクォート）
  
  println(s"Char型: ${charA.getClass.getSimpleName}")
  println(s"String型: ${stringA.getClass.getSimpleName}")
```

### Charの操作

```scala
// CharOperations.scala
@main def charOperations(): Unit =
  val ch = 'A'
  
  // 文字コードの取得
  println(s"'${ch}'の文字コード: ${ch.toInt}")
  
  // 文字の判定
  println(s"文字？: ${ch.isLetter}")
  println(s"数字？: ${ch.isDigit}")
  println(s"大文字？: ${ch.isUpper}")
  println(s"小文字？: ${ch.isLower}")
  
  // 大文字・小文字変換
  val lower = ch.toLower
  println(s"小文字に変換: ${lower}")
  
  // 文字コードから文字を作成
  val charFromCode = 65.toChar
  println(s"文字コード65の文字: ${charFromCode}")
  
  // 連続する文字
  val nextChar = (ch.toInt + 1).toChar
  println(s"'${ch}'の次の文字: ${nextChar}")
```

## Unit型

### Unitとは

```scala
// UnitType.scala
@main def unitType(): Unit =
  // printlnはUnit型を返す
  val result = println("Hello")
  println(s"printlnの戻り値: ${result}")
  println(s"型: ${result.getClass.getSimpleName}")
  
  // Unit型を返す関数
  def greet(name: String): Unit =
    println(s"こんにちは、${name}さん")
  
  val greetResult = greet("太郎")
  println(s"greet関数の戻り値: ${greetResult}")
```

## 型変換

### 自動的な型変換と明示的な型変換

```scala
// TypeConversion.scala
@main def typeConversion(): Unit =
  // 数値型の変換
  val intNum: Int = 42
  val longNum: Long = intNum     // IntからLongは自動変換
  val doubleNum: Double = intNum  // IntからDoubleも自動変換
  
  println(s"Int: ${intNum}")
  println(s"Long: ${longNum}")
  println(s"Double: ${doubleNum}")
  
  // 明示的な変換が必要な場合
  val doubleValue = 3.14
  val intValue = doubleValue.toInt  // 小数点以下は切り捨て
  println(s"${doubleValue} → ${intValue}")
  
  // 文字列との変換
  val numStr = "123"
  val num = numStr.toInt
  println(s"文字列\"${numStr}\" → 数値${num}")
  
  val backToStr = num.toString
  println(s"数値${num} → 文字列\"${backToStr}\"")
```

### 安全な型変換

```scala
// SafeConversion.scala
@main def safeConversion(): Unit =
  // 変換可能な文字列
  val validStr = "456"
  val validNum = validStr.toInt
  println(s"\"${validStr}\" → ${validNum}")
  
  // 変換できない文字列はエラーになる
  // val invalidStr = "abc"
  // val invalidNum = invalidStr.toInt  // 実行時エラー！
  
  // toIntOptionを使った安全な変換
  val str1 = "789"
  val str2 = "xyz"
  
  val opt1 = str1.toIntOption
  val opt2 = str2.toIntOption
  
  println(s"\"${str1}\".toIntOption: ${opt1}")
  println(s"\"${str2}\".toIntOption: ${opt2}")
  
  // Optionの値を取り出す
  opt1 match
    case Some(n) => println(s"変換成功: ${n}")
    case None => println("変換失敗")
```

## 特殊な文字（エスケープシーケンス）

```scala
// EscapeSequences.scala
@main def escapeSequences(): Unit =
  // 改行
  println("1行目\n2行目\n3行目")
  
  // タブ
  println("名前\t年齢\t職業")
  println("太郎\t25\t会社員")
  println("花子\t22\t学生")
  
  // クォーテーション
  println("彼は\"こんにちは\"と言った")
  println('\'A\'')
  
  // バックスラッシュ
  println("C:\\Users\\Documents")
  
  // Unicodeエスケープ
  println("\u3042\u3044\u3046")  // あいう
```

## 実践的な例：ユーザー登録フォーム

```scala
// UserRegistration.scala
@main def userRegistration(): Unit =
  // ユーザー情報
  val firstName = "太郎"
  val lastName = "山田"
  val email = "taro.yamada@example.com"
  val age = 25
  val isStudent = false
  val gender = 'M'  // M: 男性, F: 女性, O: その他
  
  // フルネームの作成
  val fullName = s"${lastName} ${firstName}"
  
  // メールアドレスの検証（簡易版）
  val isValidEmail = email.contains("@") && email.contains(".")
  
  // 年齢カテゴリの判定
  val ageCategory = if age < 20 then "未成年" 
                    else if age < 30 then "20代"
                    else if age < 40 then "30代"
                    else "40代以上"
  
  // 性別の表示
  val genderStr = gender match
    case 'M' => "男性"
    case 'F' => "女性"
    case 'O' => "その他"
    case _ => "不明"
  
  // 登録情報の表示
  println("=== ユーザー登録情報 ===")
  println(s"名前: ${fullName}")
  println(s"メール: ${email}")
  println(s"メール検証: ${if isValidEmail then "有効" else "無効"}")
  println(s"年齢: ${age}歳（${ageCategory}）")
  println(s"学生: ${if isStudent then "はい" else "いいえ"}")
  println(s"性別: ${genderStr}")
  
  // パスワード生成（簡易版）
  val password = s"${firstName.take(2)}${age}${email.take(3)}"
  println(s"仮パスワード: ${password}")
```

## よくあるエラーと対処法

### エラー例1：型の不一致

```scala
val text: String = 123  // エラー！
```

エラーメッセージ：
```
error: type mismatch;
 found   : Int(123)
 required: String
```

**対処法**: toStringを使って変換する
```scala
val text: String = 123.toString
```

### エラー例2：CharとStringの混同

```scala
val ch: Char = "A"  // エラー！ダブルクォート
```

**対処法**: Charにはシングルクォートを使う
```scala
val ch: Char = 'A'
```

### エラー例3：文字列を数値に変換できない

```scala
val num = "abc".toInt  // 実行時エラー！
```

**対処法**: toIntOptionを使って安全に変換する

## 練習問題

### 問題1：文字列操作

以下の要件を満たすプログラムを作成してください：
- メールアドレスから@より前の部分（ユーザー名）を取り出す
- ユーザー名の最初の文字を大文字にする
- 例：`"john.doe@example.com"` → `"John.doe"`

### 問題2：真偽値の組み合わせ

以下の条件を判定するプログラムを作成してください：
- 年齢が18歳以上かつ65歳未満
- 学生または65歳以上（割引対象）
- 平日（月〜金）かつ営業時間内（9〜18時）

### 問題3：文字の操作

アルファベットのAからZまでを順番に表示するプログラムを作成してください。

### 問題4：型変換

以下のデータを適切に変換して計算するプログラムを作成してください：
- 文字列`"100"`と文字列`"200"`を数値に変換して足し算
- 結果を文字列に変換して`"合計: xxx円"`の形式で表示

### 問題5：エラーを修正

```scala
@main def broken(): Unit =
  val name = 'Scala'
  val age = "25"
  val isValid = "true"
  
  if age >= 20 then
    println(name + "は成人です")
  
  if isValid then
    println("有効です")
```

## まとめ

この章では以下のことを学びました：

1. **文字列（String）**
   - 文字列の連結と文字列補間
   - 様々な文字列操作メソッド
   - 複数行文字列

2. **真偽値（Boolean）**
   - true/falseの2つの値
   - 論理演算（AND、OR、NOT）
   - 比較演算の結果

3. **文字（Char）**
   - 1文字を表す型
   - シングルクォートで囲む
   - 文字コードとの変換

4. **Unit型**
   - 値を返さない処理の型
   - 主に副作用のある処理で使用

5. **型変換**
   - 自動変換と明示的変換
   - toXxxメソッドによる変換
   - 安全な変換方法

次の章では、Scalaの強力な型システムについて詳しく学んでいきます！