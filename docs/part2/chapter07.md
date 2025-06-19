# 第7章 文字列を自由自在に

## はじめに

文字列は、プログラミングで最もよく使うデータ型の一つです。ユーザーへのメッセージ表示、データの保存、ファイルの読み書きなど、あらゆる場面で文字列を扱います。この章では、Scalaでの文字列操作を徹底的に学びます。

## 文字列の基本操作

### 文字列の作成と連結

```scala
// StringCreation.scala
@main def stringCreation(): Unit =
  // 文字列の作成
  val greeting = "こんにちは"
  val name = "太郎"
  
  // 文字列の連結（+演算子）
  val message1 = greeting + "、" + name + "さん"
  println(message1)
  
  // 文字列補間（推奨）
  val message2 = s"${greeting}、${name}さん"
  println(message2)
  
  // 式を埋め込む
  val age = 20
  val nextYear = s"来年は${age + 1}歳になります"
  println(nextYear)
  
  // f補間子（フォーマット付き）
  val price = 1234.5
  val formatted = f"価格: ${price}%.2f円"
  println(formatted)
  
  // raw補間子（エスケープなし）
  val path = raw"C:\Users\Documents\file.txt"
  println(path)
```

### 文字列の長さと文字へのアクセス

```scala
// StringLength.scala
@main def stringLength(): Unit =
  val text = "Hello, Scala!"
  
  // 長さの取得
  println(s"長さ: ${text.length}文字")
  
  // 文字へのアクセス
  println(s"最初の文字: ${text(0)}")
  println(s"最後の文字: ${text(text.length - 1)}")
  
  // 範囲でアクセス
  println(s"2-5文字目: ${text.substring(2, 5)}")
  
  // 日本語の扱い
  val japanese = "こんにちは"
  println(s"日本語の長さ: ${japanese.length}文字")
  
  // 文字ごとに処理
  println("文字ごとに表示:")
  japanese.foreach(char => println(s"  ${char}"))
```

## 文字列の検索と置換

### 文字列の検索

```scala
// StringSearch.scala
@main def stringSearch(): Unit =
  val text = "Scala is a powerful language. Scala is fun!"
  
  // 含まれているか確認
  println(s"'Scala'を含む？: ${text.contains("Scala")}")
  println(s"'Java'を含む？: ${text.contains("Java")}")
  
  // 開始・終了の確認
  println(s"'Scala'で始まる？: ${text.startsWith("Scala")}")
  println(s"'!'で終わる？: ${text.endsWith("!")}")
  
  // インデックスの検索
  println(s"最初の'Scala': ${text.indexOf("Scala")}")
  println(s"最後の'Scala': ${text.lastIndexOf("Scala")}")
  
  // 見つからない場合は-1
  println(s"'Python'の位置: ${text.indexOf("Python")}")
  
  // 正規表現での検索
  val pattern = "\\b\\w+ful\\b".r  // "ful"で終わる単語
  val matches = pattern.findAllIn(text).toList
  println(s"'ful'で終わる単語: ${matches}")
```

### 文字列の置換

```scala
// StringReplace.scala
@main def stringReplace(): Unit =
  val original = "I love Java. Java is great!"
  
  // 単純な置換
  val replaced1 = original.replace("Java", "Scala")
  println(s"元: ${original}")
  println(s"置換後: ${replaced1}")
  
  // 最初の一つだけ置換
  val replaced2 = original.replaceFirst("Java", "Scala")
  println(s"最初だけ: ${replaced2}")
  
  // 正規表現での置換
  val text = "私の電話番号は090-1234-5678です"
  val masked = text.replaceAll("\\d{3}-\\d{4}-\\d{4}", "***-****-****")
  println(s"マスク後: ${masked}")
  
  // 複数の置換
  val multiReplace = "apple,banana;orange:grape"
    .replace(",", " ")
    .replace(";", " ")
    .replace(":", " ")
  println(s"区切り文字を統一: ${multiReplace}")
```

## 文字列の分割と結合

### 文字列の分割

```scala
// StringSplit.scala
@main def stringSplit(): Unit =
  // カンマで分割
  val csv = "りんご,バナナ,オレンジ,ぶどう"
  val fruits = csv.split(",")
  println("果物リスト:")
  fruits.foreach(fruit => println(s"  - ${fruit}"))
  
  // 空白で分割
  val sentence = "Scala  is   awesome"
  val words = sentence.split("\\s+")  // 連続する空白も考慮
  println(s"単語数: ${words.length}")
  words.foreach(println)
  
  // 複数の区切り文字
  val mixed = "apple,banana;orange:grape"
  val items = mixed.split("[,;:]")
  println(s"アイテム: ${items.mkString(", ")}")
  
  // 行で分割
  val multiline = """第1行
    |第2行
    |第3行""".stripMargin
  val lines = multiline.split("\n")
  println(s"行数: ${lines.length}")
```

### 文字列の結合

```scala
// StringJoin.scala
@main def stringJoin(): Unit =
  val words = List("Scala", "is", "awesome")
  
  // mkStringで結合
  val sentence1 = words.mkString(" ")
  val sentence2 = words.mkString(", ")
  val sentence3 = words.mkString("[", ", ", "]")
  
  println(s"スペース区切り: ${sentence1}")
  println(s"カンマ区切り: ${sentence2}")
  println(s"括弧付き: ${sentence3}")
  
  // StringBuilderで効率的に結合
  val builder = new StringBuilder()
  builder.append("Hello")
  builder.append(", ")
  builder.append("World")
  builder.append("!")
  println(s"StringBuilder: ${builder.toString}")
  
  // 大量の文字列結合
  val numbers = (1 to 10000).map(_.toString)
  val efficient = numbers.mkString(",")  // 効率的
  println(s"大量結合の長さ: ${efficient.length}")
```

## 文字列のフォーマット

### printf形式のフォーマット

```scala
// StringFormat.scala
@main def stringFormat(): Unit =
  // f補間子を使ったフォーマット
  val name = "太郎"
  val age = 20
  val height = 170.5
  val score = 85.333333
  
  // 基本的なフォーマット
  println(f"名前: ${name}%s, 年齢: ${age}%d歳")
  println(f"身長: ${height}%.1fcm")
  println(f"スコア: ${score}%.2f点")
  
  // 幅指定
  println(f"${name}%10s")  // 右寄せ
  println(f"${name}%-10s") // 左寄せ
  println(f"${age}%05d")   // ゼロ埋め
  
  // 表形式での表示
  println("\n成績表:")
  println(f"${"科目"}%-10s ${"点数"}%5s ${"評価"}%s")
  println("-" * 25)
  println(f"${"数学"}%-10s ${85}%5d ${"B"}%s")
  println(f"${"英語"}%-10s ${92}%5d ${"A"}%s")
  println(f"${"理科"}%-10s ${78}%5d ${"C"}%s")
```

### 数値のフォーマット

```scala
// NumberFormat.scala
@main def numberFormat(): Unit =
  val price = 1234567.89
  val percentage = 0.1234
  val scientific = 1234.5678
  
  // 通貨形式
  println(f"価格: ¥${price}%,.0f")
  
  // パーセント表示
  println(f"割合: ${percentage * 100}%.2f%%")
  
  // 指数表記
  println(f"科学表記: ${scientific}%e")
  println(f"短い方: ${scientific}%g")
  
  // 16進数、8進数
  val number = 255
  println(f"10進数: ${number}%d")
  println(f"16進数: ${number}%x")
  println(f"8進数: ${number}%o")
  
  // 日付のフォーマット（簡易版）
  import java.time.LocalDateTime
  val now = LocalDateTime.now()
  println(f"現在時刻: ${now.getYear}%d年${now.getMonthValue}%02d月${now.getDayOfMonth}%02d日")
```

## 文字列の変換

### 大文字・小文字変換

```scala
// CaseConversion.scala
@main def caseConversion(): Unit =
  val text = "Hello, Scala Programming!"
  
  // 大文字・小文字変換
  println(s"元: ${text}")
  println(s"大文字: ${text.toUpperCase}")
  println(s"小文字: ${text.toLowerCase}")
  
  // 最初の文字を大文字に
  val word = "scala"
  val capitalized = word.capitalize
  println(s"${word} → ${capitalized}")
  
  // キャメルケースとスネークケースの変換
  val camelCase = "firstName"
  val snakeCase = camelCase
    .replaceAll("([A-Z])", "_$1")
    .toLowerCase
  println(s"${camelCase} → ${snakeCase}")
  
  // タイトルケース（各単語の最初を大文字）
  val title = "the quick brown fox"
  val titleCase = title.split(" ")
    .map(_.capitalize)
    .mkString(" ")
  println(s"タイトルケース: ${titleCase}")
```

### 空白の処理

```scala
// WhitespaceHandling.scala
@main def whitespaceHandling(): Unit =
  val messy = "  Hello   Scala   World  "
  
  // 前後の空白を削除
  println(s"元: '${messy}'")
  println(s"trim: '${messy.trim}'")
  
  // 左側のみ削除
  println(s"左trim: '${messy.stripLeading}'")
  
  // 右側のみ削除
  println(s"右trim: '${messy.stripTrailing}'")
  
  // 連続する空白を1つに
  val normalized = messy.trim.replaceAll("\\s+", " ")
  println(s"正規化: '${normalized}'")
  
  // 改行を含む文字列
  val multiline = """
    |  第1行
    |    第2行  
    |  第3行
  """.stripMargin
  
  val trimmedLines = multiline
    .split("\n")
    .map(_.trim)
    .filter(_.nonEmpty)
    .mkString("\n")
  
  println("整形後:")
  println(trimmedLines)
```

## 正規表現

### 基本的な正規表現

```scala
// RegexBasics.scala
@main def regexBasics(): Unit =
  // 正規表現パターンの作成
  val emailPattern = "\\w+@\\w+\\.\\w+".r
  val phonePattern = "\\d{3}-\\d{4}-\\d{4}".r
  
  // マッチング
  val email = "user@example.com"
  val phone = "090-1234-5678"
  
  emailPattern.findFirstIn(email) match
    case Some(found) => println(s"メールアドレス: ${found}")
    case None => println("メールアドレスが見つかりません")
  
  phonePattern.findFirstIn(phone) match
    case Some(found) => println(s"電話番号: ${found}")
    case None => println("電話番号が見つかりません")
  
  // 複数のマッチを検索
  val text = "連絡先: user1@example.com, user2@test.com"
  val emails = emailPattern.findAllIn(text).toList
  println(s"見つかったメール: ${emails}")
```

### パターンマッチングと抽出

```scala
// RegexExtraction.scala
@main def regexExtraction(): Unit =
  // グループを使った抽出
  val datePattern = "(\\d{4})-(\\d{2})-(\\d{2})".r
  val logPattern = "\\[(\\w+)\\] (.+)".r
  
  // 日付の抽出
  "2024-03-15" match
    case datePattern(year, month, day) =>
      println(s"年: ${year}, 月: ${month}, 日: ${day}")
    case _ =>
      println("日付形式が正しくありません")
  
  // ログの解析
  val logs = List(
    "[INFO] アプリケーションを開始しました",
    "[ERROR] ファイルが見つかりません",
    "[DEBUG] 変数xの値: 42"
  )
  
  logs.foreach { log =>
    log match
      case logPattern(level, message) =>
        println(s"${level}: ${message}")
      case _ =>
        println(s"不明な形式: ${log}")
  }
```

## 実践的な例：テキスト処理ツール

```scala
// TextProcessor.scala
@main def textProcessor(): Unit =
  // サンプルテキスト
  val article = """
    |Scalaは2003年に登場したプログラミング言語です。
    |JavaVM上で動作し、オブジェクト指向と関数型の特徴を持ちます。
    |
    |主な特徴：
    |1. 型推論により、コードが簡潔に書ける
    |2. パターンマッチングが強力
    |3. 並行処理が得意
    |
    |連絡先: info@scala-lang.org
    |詳細: https://www.scala-lang.org/
  """.stripMargin.trim
  
  // 統計情報の収集
  val lines = article.split("\n")
  val words = article.split("\\s+")
  val chars = article.length
  
  println("=== テキスト統計 ===")
  println(s"行数: ${lines.length}")
  println(s"単語数: ${words.length}")
  println(s"文字数: ${chars}")
  
  // キーワード検索
  val keywords = List("Scala", "型", "関数")
  println("\n=== キーワード出現回数 ===")
  keywords.foreach { keyword =>
    val count = article.split(keyword).length - 1
    println(s"${keyword}: ${count}回")
  }
  
  // URL抽出
  val urlPattern = "https?://[\\w/.-]+".r
  val urls = urlPattern.findAllIn(article).toList
  println(s"\n=== 見つかったURL ===")
  urls.foreach(println)
  
  // メールアドレス抽出
  val emailPattern = "[\\w.+-]+@[\\w.-]+\\.[\\w]+".r
  val emails = emailPattern.findAllIn(article).toList
  println(s"\n=== 見つかったメール ===")
  emails.foreach(println)
  
  // 見出し作成（最初の文を抽出）
  val firstSentence = article.split("[。！？]").headOption.getOrElse("")
  println(s"\n=== 見出し ===")
  println(firstSentence)
}
```

## 文字列のエンコーディング

```scala
// StringEncoding.scala
@main def stringEncoding(): Unit =
  val text = "こんにちは、Scala!"
  
  // バイト配列への変換
  val utf8Bytes = text.getBytes("UTF-8")
  val sjisBytes = text.getBytes("Shift_JIS")
  
  println(s"元の文字列: ${text}")
  println(s"UTF-8バイト数: ${utf8Bytes.length}")
  println(s"Shift-JISバイト数: ${sjisBytes.length}")
  
  // バイト配列から文字列へ
  val restored = new String(utf8Bytes, "UTF-8")
  println(s"復元: ${restored}")
  
  // Base64エンコード（Java標準ライブラリ使用）
  import java.util.Base64
  val encoded = Base64.getEncoder.encodeToString(utf8Bytes)
  val decoded = new String(Base64.getDecoder.decode(encoded), "UTF-8")
  
  println(s"Base64: ${encoded}")
  println(s"デコード: ${decoded}")
}
```

## よくあるエラーと対処法

### エラー例1：IndexOutOfBoundsException

```scala
val text = "Hello"
// val char = text(10)  // エラー！範囲外
```

**対処法**: 長さをチェックするか、liftメソッドを使う

### エラー例2：NullPointerException

```scala
var text: String = null
// val length = text.length  // エラー！
```

**対処法**: Optionを使って安全に処理

### エラー例3：正規表現のエラー

```scala
// val pattern = "[".r  // エラー！不完全な正規表現
```

**対処法**: 正規表現を正しく記述し、エスケープが必要な文字に注意

## 練習問題

### 問題1：メールアドレスの検証

メールアドレスが有効かどうかを判定する関数を作成してください。
- @を含む
- @の前後に1文字以上
- ドメイン部分に.を含む

### 問題2：文字列の整形

以下の処理を行う関数を作成してください：
- 前後の空白を削除
- 連続する空白を1つに
- 各単語の最初を大文字に

### 問題3：CSVパーサー

CSV形式の文字列を解析して、List[List[String]]に変換する関数を作成してください。

### 問題4：パスワード強度チェック

パスワードの強度をチェックする関数を作成してください：
- 8文字以上
- 大文字・小文字を含む
- 数字を含む
- 特殊文字を含む

### 問題5：テンプレート処理

文字列テンプレート内の`${変数名}`を実際の値に置換する関数を作成してください。

## まとめ

この章では以下のことを学びました：

1. **文字列の基本操作**
   - 作成、連結、補間
   - 長さと文字へのアクセス
   - 様々な文字列補間子

2. **検索と置換**
   - contains、indexOf等の検索メソッド
   - replace系メソッドでの置換
   - 正規表現を使った高度な検索

3. **分割と結合**
   - splitでの分割
   - mkStringでの結合
   - StringBuilderでの効率的な処理

4. **フォーマット**
   - f補間子でのprintf形式
   - 数値や日付のフォーマット
   - 表形式での出力

5. **正規表現**
   - パターンの作成と使用
   - マッチングと抽出
   - 実用的なパターン例

次の章では、型安全なコレクションについて学んでいきます！