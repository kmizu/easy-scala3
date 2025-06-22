# 付録D 開発環境カスタマイズガイド

## はじめに

プログラマーの道具である開発環境。料理人が包丁を大切にするように、プログラマーも自分の開発環境を整えることが大切です。この付録では、快適にScalaプログラミングができる環境のカスタマイズ方法を紹介します。

## IntelliJ IDEA

### 基本設定

```scala
// 推奨設定

// 1. エディター設定
// File > Settings > Editor > General
- Show line numbers: ON
- Show whitespaces: ON（空白文字を表示）
- Show method separators: ON

// 2. コードスタイル設定
// File > Settings > Editor > Code Style > Scala
- Tab size: 2
- Indent: 2
- Continuation indent: 4

// 3. インスペクション設定
// File > Settings > Editor > Inspections > Scala
- Unused declarations: ON
- Deprecated API usage: ON
- Spelling: ON（タイポ検出）
```

### 便利なプラグイン

```scala
// 必須プラグイン
1. Scala Plugin（公式）
    - Scalaサポートの基本

2. sbt Plugin
    - sbtプロジェクトの統合

// 推奨プラグイン
3. Rainbow Brackets
    - 括弧の対応を色分け
    - ネストが深いコードで便利

4. Key Promoter X
    - ショートカットキーを学習
    - マウス操作時にキーボードショートカットを表示

5. GitToolBox
    - Git統合の強化
    - ブランチ情報、blame表示

6. String Manipulation
    - 文字列操作の効率化
    - CamelCase ⇔ snake_case変換

7. Scalafmt
    - コードフォーマッター
    - 保存時に自動フォーマット
```

### ショートカットキー

```scala
// 必須ショートカット（Windows/Linux）
Ctrl + N          // クラス検索
Ctrl + Shift + N  // ファイル検索
Ctrl + Alt + L    // コードフォーマット
Ctrl + Alt + O    // インポート最適化
Alt + Enter       // Quick Fix
Ctrl + Space      // 基本補完
Ctrl + Shift + Space // スマート補完
Ctrl + Q          // クイックドキュメント
Ctrl + P          // パラメータ情報
Ctrl + B          // 定義へジャンプ
Ctrl + Alt + B    // 実装へジャンプ
Shift + F6        // リネーム
Ctrl + /          // 行コメント
Ctrl + Shift + /  // ブロックコメント

// 便利なショートカット
Ctrl + W          // 選択範囲を拡大
Ctrl + Shift + W  // 選択範囲を縮小
Alt + J           // 次の同じ単語を選択（マルチカーソル）
Ctrl + G          // 行番号へジャンプ
Ctrl + E          // 最近使ったファイル
Ctrl + Shift + E  // 最近編集した場所
Ctrl + F12        // ファイル構造
Alt + F7          // 使用箇所を検索
```

### ライブテンプレート

```scala
// File > Settings > Editor > Live Templates > Scala

// main - メイン関数
@main def $NAME$(): Unit = {
  $END$
}

// test - テストケース
test("$DESCRIPTION$") {
  $END$
}

// match - パターンマッチ
$EXPR$ match {
  case $PATTERN$ => $END$
  case _ => 
}

// for - for式
for {
  $VAR$ <- $EXPR$
} yield $END$

// option - Option処理
$EXPR$ match {
  case Some($VAR$) => $END$
  case None => 
}

// either - Either処理
$EXPR$ match {
  case Right($VAR$) => $END$
  case Left($ERR$) => 
}

// try - Try処理
Try {
  $END$
} match {
  case Success($VAR$) => 
  case Failure($EX$) => 
}
```

## Visual Studio Code

### 基本設定

```json
// settings.json
{
  // エディター設定
  "editor.fontSize": 14,
  "editor.fontFamily": "'Fira Code', 'JetBrains Mono', monospace",
  "editor.fontLigatures": true,
  "editor.tabSize": 2,
  "editor.detectIndentation": false,
  "editor.renderWhitespace": "boundary",
  "editor.rulers": [80, 120],
  "editor.minimap.enabled": true,
  "editor.bracketPairColorization.enabled": true,
  
  // Scala設定
  "files.watcherExclude": {
    "**/target": true,
    "**/.bsp": true,
    "**/.metals": true
  },
  
  // Metals設定
  "metals.serverVersion": "1.2.0",
  "metals.showImplicitArguments": true,
  "metals.showImplicitConversionsAndClasses": true,
  "metals.showInferredType": true,
  
  // フォーマット設定
  "editor.formatOnSave": true,
  "[scala]": {
    "editor.defaultFormatter": "scalameta.metals"
  },
  
  // ターミナル設定
  "terminal.integrated.defaultProfile.windows": "Git Bash",
  "terminal.integrated.fontSize": 13
}
```

### 必須拡張機能

```scala
// 1. Scala (Metals)
// - Scala言語サポート
// - 自動補完、定義ジャンプ、リファクタリング

// 2. Scala Syntax (official)
// - シンタックスハイライト

// 推奨拡張機能
// 3. Error Lens
// - エラーをインラインで表示

// 4. GitLens
// - Git履歴の可視化

// 5. Bracket Pair Colorizer
// - 括弧の対応を色分け

// 6. Better Comments
// - コメントの種類で色分け
// TODO: タスク
// FIXME: 修正必要
// NOTE: 注意事項

// 7. Code Runner
// - 簡単にコード実行

// 8. indent-rainbow
// - インデントレベルを色分け
```

### キーボードショートカット

```json
// keybindings.json
[
  {
    "key": "ctrl+shift+o",
    "command": "editor.action.organizeImports",
    "when": "editorTextFocus && !editorReadonly"
  },
  {
    "key": "ctrl+shift+i",
    "command": "editor.action.formatDocument",
    "when": "editorTextFocus && !editorReadonly"
  },
  {
    "key": "f2",
    "command": "editor.action.rename",
    "when": "editorHasRenameProvider && editorTextFocus && !editorReadonly"
  },
  {
    "key": "ctrl+`",
    "command": "workbench.action.terminal.toggleTerminal"
  }
]
```

### スニペット

```json
// scala.json (User Snippets)
{
  "Main Method": {
    "prefix": "main",
    "body": [
      "@main def ${1:main}(): Unit = {",
      "  $0",
      "}"
    ],
    "description": "Main method"
  },
  
  "Case Class": {
    "prefix": "cc",
    "body": [
      "case class ${1:Name}(",
      "  ${2:field}: ${3:Type}",
      ")"
    ],
    "description": "Case class"
  },
  
  "Pattern Match": {
    "prefix": "match",
    "body": [
      "${1:expr} match {",
      "  case ${2:pattern} => $0",
      "  case _ => ",
      "}"
    ],
    "description": "Pattern matching"
  },
  
  "For Comprehension": {
    "prefix": "for",
    "body": [
      "for {",
      "  ${1:x} <- ${2:xs}",
      "} yield $0"
    ],
    "description": "For comprehension"
  },
  
  "Test Case": {
    "prefix": "test",
    "body": [
      "test(\"${1:description}\") {",
      "  $0",
      "}"
    ],
    "description": "ScalaTest test case"
  }
}
```

## ターミナル環境

### シェル設定

```bash
# ~/.bashrc または ~/.zshrc

# sbt エイリアス
alias sbtc='sbt compile'
alias sbtt='sbt test'
alias sbtr='sbt run'
alias sbtcc='sbt clean compile'
alias sbtf='sbt scalafmtAll'

# Scala REPL
alias scala-repl='scala -Xprint:typer'

# プロジェクト作成
new-scala() {
  mkdir -p "$1"/{src/{main,test}/scala,project}
  cd "$1"
  echo 'scalaVersion := "3.3.1"' > build.sbt
  echo 'sbt.version=1.9.7' > project/build.properties
  echo "# $1" > README.md
  git init
}

# sbt プロジェクトのクリーンアップ
sbt-clean-all() {
  find . -name target -type d -exec rm -rf {} + 2>/dev/null
  find . -name .bsp -type d -exec rm -rf {} + 2>/dev/null
  find . -name .metals -type d -exec rm -rf {} + 2>/dev/null
}
```

### Git設定

```bash
# .gitignore for Scala
target/
.bsp/
.metals/
.bloop/
.idea/
.vscode/
*.class
*.log
.DS_Store

# sbt specific
dist/*
lib_managed/
src_managed/
project/boot/
project/plugins/project/
.cache
.lib/

# Scala-IDE specific
.scala_dependencies
.worksheet
.sc

# VS Code specific
.vscode/*
!.vscode/settings.json
!.vscode/tasks.json
!.vscode/launch.json
```

## REPL カスタマイズ

### 初期化ファイル

```scala
// ~/.scala/init.scala

// インポート
import scala.concurrent._
import scala.concurrent.duration._
import scala.util.{Try, Success, Failure}
import ExecutionContext.Implicits.global
import java.time._
import java.nio.file._

// 便利な関数
def time[T](label: String = "Execution time")(block: => T): T = {
  val start = System.nanoTime()
  val result = block
  val end = System.nanoTime()
  println(s"$label: ${(end - start) / 1000000.0} ms")
  result
}

def pp(x: Any): Unit = {
  import pprint._
  pprint.pprintln(x, height = 100)
}

// 便利な値
val now = LocalDateTime.now()
val today = LocalDate.now()

// 起動メッセージ
println(s"""
|Welcome to Scala ${util.Properties.versionString}
|JVM: ${System.getProperty("java.version")}
|Current time: $now
|
|Custom functions available:
|  - time(label)(block): Measure execution time
|  - pp(x): Pretty print any value
|""".stripMargin)
```

### REPLの起動オプション

```bash
# ~/.sbtrc
alias repl="console"
alias r="reload"
alias c="compile" 
alias t="test"
alias to="testOnly"
alias tq="testQuick"
alias it="IntegrationTest/test"
alias fmt="scalafmtAll"

# カスタムREPL起動
alias myrepl="set console / initialCommands := \"\"\"
  |import scala.concurrent._
  |import scala.concurrent.duration._
  |import scala.util._
  |import ExecutionContext.Implicits.global
  |println(\"Custom REPL initialized!\")
\"\"\"; console"
```

## デバッグ設定

### IntelliJ IDEAのデバッグ

```scala
// ブレークポイントの条件設定
// 右クリック > More > Condition

// 例：特定の値の時だけ停止
i == 42

// 例：複雑な条件
user.age > 18 && user.name.startsWith("A")

// ログ出力（停止しない）
// 右クリック > More > Log evaluated expression
s"Current value: $value"
```

### リモートデバッグ

```bash
# sbt起動時のデバッグオプション
sbt -jvm-debug 5005

# または build.sbt に設定
fork := true
javaOptions += "-agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=5005"
```

## パフォーマンスチューニング

### JVMオプション

```scala
// build.sbt
javaOptions ++= Seq(
  "-Xmx2g",                    // 最大ヒープサイズ
  "-Xms1g",                    // 初期ヒープサイズ
  "-XX:+UseG1GC",              // G1ガベージコレクタ
  "-XX:MaxGCPauseMillis=200",  // GC停止時間の目標
  "-XX:+PrintGCDetails",       // GCログ出力
  "-XX:+PrintGCTimeStamps",
  "-Xlog:gc:file=gc.log"       // GCログファイル
)

// コンパイラオプション
scalacOptions ++= Seq(
  "-opt:l:inline",             // インライン最適化
  "-opt-inline-from:**",       // すべてからインライン
  "-opt-warnings",             // 最適化の警告
  "-Ystatistics:typer"         // コンパイル統計
)
```

### sbtの高速化

```scala
// project/build.properties
sbt.version=1.9.7

// ~/.sbt/1.0/global.sbt
Global / onChangedBuildSource := ReloadOnSourceChanges
Global / excludeLintKeys += evictionWarningOptions

// メモリ設定
// ~/.sbtopts または SBT_OPTS環境変数
-J-Xmx4g
-J-Xms1g
-J-XX:ReservedCodeCacheSize=512m
-J-XX:+CMSClassUnloadingEnabled
```

## 統合開発環境の比較

### 各IDEの特徴

```scala
/*
IntelliJ IDEA
長所：
- 最も高機能で安定
- 優れたリファクタリング機能
- デバッガーが強力
- 大規模プロジェクトに最適

短所：
- 重い（メモリ使用量大）
- 有料版が必要な機能あり

VS Code + Metals
長所：
- 軽量で高速
- 無料
- 拡張機能が豊富
- クロスプラットフォーム

短所：
- IntelliJより機能が少ない
- 設定が必要

Vim/Neovim + Metals
長所：
- 最も軽量
- キーボード操作効率最高
- サーバーでも使える

短所：
- 学習曲線が急
- GUI機能なし
*/
```

## プロジェクトテンプレート

### カスタムテンプレート作成

```scala
// g8テンプレート: src/main/g8/build.sbt
ThisBuild / scalaVersion := "$scala_version$"
ThisBuild / version := "0.1.0-SNAPSHOT"
ThisBuild / organization := "$organization$"

lazy val root = (project in file("."))
  .settings(
    name := "$name$",
    
    libraryDependencies ++= Seq(
      // 標準ライブラリ
      "org.typelevel" %% "cats-core" % "$cats_version$",
      "org.typelevel" %% "cats-effect" % "$cats_effect_version$",
      
      // JSON
      "io.circe" %% "circe-core" % "$circe_version$",
      "io.circe" %% "circe-generic" % "$circe_version$",
      "io.circe" %% "circe-parser" % "$circe_version$",
      
      // HTTP
      "com.softwaremill.sttp.client3" %% "core" % "$sttp_version$",
      
      // ログ
      "ch.qos.logback" % "logback-classic" % "$logback_version$",
      "com.typesafe.scala-logging" %% "scala-logging" % "$scala_logging_version$",
      
      // テスト
      "org.scalatest" %% "scalatest" % "$scalatest_version$" % Test,
      "org.scalatestplus" %% "scalacheck-1-17" % "$scalatest_plus_version$" % Test
    ),
    
    // スカラコンパイラ設定
    scalacOptions ++= Seq(
      "-deprecation",
      "-feature",
      "-unchecked",
      "-language:higherKinds",
      "-language:implicitConversions",
      "-Xfatal-warnings"
    ),
    
    // テスト設定
    Test / testOptions += Tests.Argument(TestFrameworks.ScalaTest, "-oDF"),
    Test / parallelExecution := false
  )

// default.properties
scala_version=3.3.1
cats_version=2.10.0
cats_effect_version=3.5.2
circe_version=0.14.6
sttp_version=3.9.1
logback_version=1.4.11
scala_logging_version=3.9.5
scalatest_version=3.2.17
scalatest_plus_version=3.2.17.0
```

## トラブルシューティング

### よくある問題と解決策

```scala
// 1. インポートが解決されない
// 解決策：
// - sbt reload
// - File > Invalidate Caches and Restart (IntelliJ)
// - Metals: Restart server (VS Code)

// 2. メモリ不足
// IntelliJ: Help > Change Memory Settings
// VS Code: metals.javaHome でJVMオプション設定

// 3. コンパイルが遅い
// - incremental compilation を有効化
// - 並列コンパイルを設定
Global / concurrentRestrictions := Seq(
  Tags.limit(Tags.CPU, math.min(4, java.lang.Runtime.getRuntime.availableProcessors))
)

// 4. ライブラリの競合
// - dependencyOverrides を使用
// - evictionWarningOptions で警告を管理

// 5. Metalsが動かない
// - .metals/, .bloop/ を削除
// - metals.log を確認
// - Java version を確認（11以上推奨）
```

## まとめ

開発環境は、プログラマーの「作業場」です。自分に合った環境を整えることで、生産性が大きく向上します。

**カスタマイズのポイント**：
- 基本的な設定から始める
- ショートカットキーを覚える
- 必要に応じて拡張機能を追加
- 定期的に設定を見直す

快適な開発環境で、楽しくScalaプログラミングを続けましょう！