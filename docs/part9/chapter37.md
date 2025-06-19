# 第37章 ビルドツールと依存性管理

## はじめに

家を建てるとき、設計図があり、必要な材料のリストがあり、組み立て方の手順があります。プログラミングプロジェクトも同じです。どんなライブラリが必要か、どうやってコンパイルするか、どうやって配布するか。

この章では、Scalaプロジェクトの「建築管理」を担うビルドツールと依存性管理について学びましょう！

## sbtの基礎

### プロジェクトの構造

```scala
// プロジェクトのディレクトリ構造
my-scala-project/
├── build.sbt              # ビルド定義
├── project/
│   ├── build.properties   # sbtバージョン
│   └── plugins.sbt        # プラグイン設定
├── src/
│   ├── main/
│   │   ├── scala/        # メインのScalaコード
│   │   └── resources/    # リソースファイル
│   └── test/
│       ├── scala/        # テストコード
│       └── resources/    # テストリソース
├── target/               # ビルド成果物（自動生成）
└── .gitignore           # Git除外設定

// build.sbt の基本
ThisBuild / scalaVersion := "3.3.1"
ThisBuild / version      := "0.1.0"
ThisBuild / organization := "com.example"

lazy val root = (project in file("."))
  .settings(
    name := "my-scala-project",
    
    // 依存ライブラリ
    libraryDependencies ++= Seq(
      "org.typelevel" %% "cats-core" % "2.10.0",
      "com.typesafe.play" %% "play-json" % "2.10.1",
      "org.scalatest" %% "scalatest" % "3.2.17" % Test
    ),
    
    // コンパイラオプション
    scalacOptions ++= Seq(
      "-deprecation",
      "-feature",
      "-unchecked",
      "-Xfatal-warnings"
    )
  )

// project/build.properties
sbt.version=1.9.7

// project/plugins.sbt
addSbtPlugin("com.github.sbt" % "sbt-native-packager" % "1.9.16")
addSbtPlugin("org.scalameta" % "sbt-scalafmt" % "2.5.2")
```

### 基本的なタスク

```scala
// BasicSbtTasks.scala
// sbtコンソールでの操作

// コンパイル
> compile

// テスト実行
> test

// 特定のテストのみ実行
> testOnly com.example.MyClassTest

// 継続的なコンパイル（ファイル変更を監視）
> ~compile

// REPL起動
> console
scala> import com.example._
scala> val result = MyClass.doSomething()

// 実行
> run
> run arg1 arg2  // 引数付き

// クリーン
> clean

// パッケージング
> package       // JARファイル作成
> packageBin    // バイナリJAR
> packageDoc    // JavadocJAR
> packageSrc    // ソースJAR

// 依存関係の確認
> dependencyTree
> evicted       // 競合して除外された依存関係

// タスクの説明を見る
> help compile
> tasks         // 利用可能なタスク一覧
```

## 依存性管理

### ライブラリの追加と管理

```scala
// DependencyManagement.scala
// build.sbt

lazy val versions = new {
  val scala = "3.3.1"
  val akka = "2.8.5"
  val akkaHttp = "10.5.3"
  val circe = "0.14.6"
  val scalaTest = "3.2.17"
  val logback = "1.4.11"
}

lazy val dependencies = new {
  // Akka
  val akkaActor = "com.typesafe.akka" %% "akka-actor-typed" % versions.akka
  val akkaStream = "com.typesafe.akka" %% "akka-stream" % versions.akka
  val akkaHttp = "com.typesafe.akka" %% "akka-http" % versions.akkaHttp
  
  // JSON処理
  val circeCore = "io.circe" %% "circe-core" % versions.circe
  val circeGeneric = "io.circe" %% "circe-generic" % versions.circe
  val circeParser = "io.circe" %% "circe-parser" % versions.circe
  
  // ロギング
  val slf4j = "org.slf4j" % "slf4j-api" % "2.0.9"
  val logback = "ch.qos.logback" % "logback-classic" % versions.logback
  
  // テスト
  val scalaTest = "org.scalatest" %% "scalatest" % versions.scalaTest % Test
  val akkaTestkit = "com.typesafe.akka" %% "akka-actor-testkit-typed" % versions.akka % Test
}

lazy val commonSettings = Seq(
  scalaVersion := versions.scala,
  
  // リゾルバー（カスタムリポジトリ）
  resolvers ++= Seq(
    "Sonatype OSS Snapshots" at "https://oss.sonatype.org/content/repositories/snapshots",
    "Typesafe Repository" at "https://repo.typesafe.com/typesafe/releases/"
  ),
  
  // 除外設定
  excludeDependencies ++= Seq(
    ExclusionRule("org.slf4j", "slf4j-log4j12"),
    ExclusionRule("log4j", "log4j")
  )
)

// マルチプロジェクト構成
lazy val root = (project in file("."))
  .aggregate(core, web, cli)
  .settings(
    name := "my-app",
    publish / skip := true
  )

lazy val core = (project in file("core"))
  .settings(commonSettings)
  .settings(
    name := "my-app-core",
    libraryDependencies ++= Seq(
      dependencies.circeCore,
      dependencies.circeGeneric,
      dependencies.slf4j,
      dependencies.scalaTest
    )
  )

lazy val web = (project in file("web"))
  .dependsOn(core)
  .settings(commonSettings)
  .settings(
    name := "my-app-web",
    libraryDependencies ++= Seq(
      dependencies.akkaHttp,
      dependencies.akkaStream,
      dependencies.circeParser,
      dependencies.logback
    )
  )

lazy val cli = (project in file("cli"))
  .dependsOn(core)
  .settings(commonSettings)
  .settings(
    name := "my-app-cli",
    libraryDependencies ++= Seq(
      "com.github.scopt" %% "scopt" % "4.1.0",
      dependencies.logback
    )
  )
```

### 依存性の競合解決

```scala
// ConflictResolution.scala
// build.sbt

// 依存性の競合を解決する方法

// 1. 明示的なバージョン指定
libraryDependencies ++= Seq(
  "com.fasterxml.jackson.core" % "jackson-databind" % "2.15.3",
  // 他のライブラリが古いバージョンを要求しても、これを使う
)

// 2. force を使った強制
libraryDependencies ++= Seq(
  "org.scala-lang.modules" %% "scala-xml" % "2.2.0" force()
)

// 3. dependencyOverrides を使った上書き
dependencyOverrides ++= Seq(
  "org.scala-lang.modules" %% "scala-xml" % "2.2.0",
  "com.google.guava" % "guava" % "32.1.3-jre"
)

// 4. 除外ルール
libraryDependencies ++= Seq(
  ("com.example" %% "some-library" % "1.0.0")
    .exclude("org.slf4j", "slf4j-log4j12")
    .exclude("commons-logging", "commons-logging")
)

// 5. 競合戦略の設定
ThisBuild / conflictManager := ConflictManager.latestRevision

// 6. カスタム競合解決
conflictManager := {
  case ("com.google.guava", "guava") => ConflictManager.latestRevision
  case ("org.scala-lang.modules", _) => ConflictManager.latestRevision
  case _ => ConflictManager.default
}
```

## カスタムタスクとプラグイン

### カスタムタスクの作成

```scala
// CustomTasks.scala
// build.sbt

import sbt._
import sbt.Keys._

// シンプルなタスク
lazy val hello = taskKey[Unit]("Prints 'Hello, World!'")

hello := {
  println("Hello, World!")
}

// 他のタスクに依存するタスク
lazy val packageAndRun = taskKey[Unit]("Package and run the application")

packageAndRun := {
  val _ = (Compile / packageBin).value
  (Compile / run).toTask("").value
}

// 入力を受け取るタスク
lazy val greet = inputKey[Unit]("Greet someone")

greet := {
  import complete.DefaultParsers._
  val name = spaceDelimited("<name>").parsed.headOption.getOrElse("World")
  println(s"Hello, $name!")
}

// ファイル生成タスク
lazy val generateVersion = taskKey[File]("Generate version file")

generateVersion := {
  val file = (Compile / sourceManaged).value / "Version.scala"
  val content = 
    s"""package com.example
       |
       |object Version {
       |  val version = "${version.value}"
       |  val buildTime = "${java.time.Instant.now()}"
       |  val gitCommit = "${git.gitHeadCommit.value.getOrElse("unknown")}"
       |}
       |""".stripMargin
  
  IO.write(file, content)
  file
}

// ソース生成をコンパイルに追加
Compile / sourceGenerators += generateVersion.taskValue

// 環境ごとの設定
lazy val deployEnvironment = settingKey[String]("Deployment environment")

deployEnvironment := sys.env.getOrElse("DEPLOY_ENV", "development")

lazy val deploy = taskKey[Unit]("Deploy the application")

deploy := {
  val env = deployEnvironment.value
  val jar = (Compile / packageBin).value
  
  println(s"Deploying to $env environment...")
  env match {
    case "production" =>
      // 本番環境へのデプロイ
      println(s"Uploading ${jar.getName} to production server...")
    case "staging" =>
      // ステージング環境へのデプロイ
      println(s"Uploading ${jar.getName} to staging server...")
    case _ =>
      // 開発環境
      println(s"Copying ${jar.getName} to local directory...")
  }
}
```

### 便利なプラグイン

```scala
// UsefulPlugins.scala
// project/plugins.sbt

// コードフォーマッター
addSbtPlugin("org.scalameta" % "sbt-scalafmt" % "2.5.2")

// ネイティブパッケージャー
addSbtPlugin("com.github.sbt" % "sbt-native-packager" % "1.9.16")

// リリース管理
addSbtPlugin("com.github.sbt" % "sbt-release" % "1.1.0")

// 依存関係の更新チェック
addSbtPlugin("com.timushev.sbt" % "sbt-updates" % "0.6.4")

// カバレッジ測定
addSbtPlugin("org.scoverage" % "sbt-scoverage" % "2.0.9")

// Assembly（fat JAR作成）
addSbtPlugin("com.eed3si9n" % "sbt-assembly" % "2.1.5")

// build.sbt でのプラグイン設定

// Scalafmt
scalafmtOnCompile := true

// Native Packager
enablePlugins(JavaAppPackaging)

packageName := "my-app"
maintainer := "your-email@example.com"
packageDescription := "My Scala Application"

// Docker設定
enablePlugins(DockerPlugin)
Docker / packageName := "my-app"
Docker / version := version.value
dockerBaseImage := "openjdk:11-jre-slim"
dockerExposedPorts := Seq(8080)

// Assembly設定
assembly / assemblyMergeStrategy := {
  case PathList("META-INF", xs @ _*) => MergeStrategy.discard
  case "reference.conf" => MergeStrategy.concat
  case x => MergeStrategy.first
}

assembly / assemblyJarName := s"${name.value}-${version.value}.jar"

// Coverage設定
coverageEnabled := true
coverageMinimumStmtTotal := 80
coverageFailOnMinimum := true

// 依存関係の更新チェック
// > dependencyUpdates
```

## 実践的なプロジェクト設定

### Webアプリケーションプロジェクト

```scala
// WebAppProject.scala
// build.sbt

import com.typesafe.sbt.packager.docker._

ThisBuild / scalaVersion := "3.3.1"
ThisBuild / organization := "com.example"

lazy val commonSettings = Seq(
  scalacOptions ++= Seq(
    "-deprecation",
    "-feature",
    "-unchecked",
    "-Ymacro-annotations",
    "-Xfatal-warnings"
  ),
  
  Test / fork := true,
  Test / parallelExecution := false
)

lazy val root = (project in file("."))
  .aggregate(api, domain, infra)
  .settings(
    name := "web-app",
    publish / skip := true
  )

lazy val domain = (project in file("modules/domain"))
  .settings(commonSettings)
  .settings(
    name := "web-app-domain",
    libraryDependencies ++= Seq(
      "org.typelevel" %% "cats-core" % "2.10.0",
      "org.typelevel" %% "cats-effect" % "3.5.2",
      "org.scalatest" %% "scalatest" % "3.2.17" % Test
    )
  )

lazy val infra = (project in file("modules/infra"))
  .dependsOn(domain)
  .settings(commonSettings)
  .settings(
    name := "web-app-infra",
    libraryDependencies ++= Seq(
      "com.typesafe.slick" %% "slick" % "3.5.0-M4",
      "org.postgresql" % "postgresql" % "42.6.0",
      "com.zaxxer" % "HikariCP" % "5.1.0",
      "org.flywaydb" % "flyway-core" % "9.22.3"
    )
  )

lazy val api = (project in file("modules/api"))
  .enablePlugins(JavaAppPackaging, DockerPlugin)
  .dependsOn(domain, infra)
  .settings(commonSettings)
  .settings(
    name := "web-app-api",
    
    libraryDependencies ++= Seq(
      "com.typesafe.akka" %% "akka-http" % "10.5.3",
      "de.heikoseeberger" %% "akka-http-circe" % "1.39.2",
      "com.typesafe.akka" %% "akka-actor-typed" % "2.8.5",
      "com.typesafe.akka" %% "akka-stream" % "2.8.5",
      "ch.qos.logback" % "logback-classic" % "1.4.11",
      "com.typesafe" % "config" % "1.4.3",
      "com.typesafe.akka" %% "akka-http-testkit" % "10.5.3" % Test
    ),
    
    // アプリケーション設定
    Compile / mainClass := Some("com.example.api.Main"),
    
    // Docker設定
    Docker / packageName := "web-app-api",
    Docker / version := version.value,
    dockerBaseImage := "eclipse-temurin:11-jre",
    dockerExposedPorts := Seq(8080),
    dockerExposedVolumes := Seq("/opt/app/logs"),
    
    dockerCommands := dockerCommands.value.flatMap {
      case cmd@Cmd("FROM", _) => List(
        cmd,
        Cmd("RUN", "apt-get update && apt-get install -y curl && rm -rf /var/lib/apt/lists/*"),
        Cmd("HEALTHCHECK", "--interval=30s", "--timeout=3s", "--start-period=40s", "--retries=3",
          "CMD", "curl -f http://localhost:8080/health || exit 1")
      )
      case other => List(other)
    },
    
    // 環境変数
    Universal / javaOptions ++= Seq(
      "-Dconfig.file=/opt/app/conf/application.conf",
      "-Dlogback.configurationFile=/opt/app/conf/logback.xml"
    )
  )

// プロファイル別の設定
lazy val dev = (project in file("dev"))
  .dependsOn(api)
  .settings(
    libraryDependencies += "org.testcontainers" % "postgresql" % "1.19.3",
    run / fork := true,
    run / javaOptions ++= Seq(
      "-Dconfig.resource=application-dev.conf",
      "-Xmx1g"
    )
  )
```

### CI/CD統合

```scala
// CICDIntegration.scala
// build.sbt

// GitHub Actions用の設定
lazy val githubWorkflowGenerate = taskKey[Unit]("Generate GitHub Actions workflow")

githubWorkflowGenerate := {
  val file = file(".github/workflows/ci.yml")
  val content = """name: CI
    |
    |on:
    |  push:
    |    branches: [ main, develop ]
    |  pull_request:
    |    branches: [ main ]
    |
    |jobs:
    |  test:
    |    runs-on: ubuntu-latest
    |    steps:
    |    - uses: actions/checkout@v3
    |    - uses: actions/setup-java@v3
    |      with:
    |        distribution: 'temurin'
    |        java-version: '11'
    |    
    |    - name: Cache SBT
    |      uses: actions/cache@v3
    |      with:
    |        path: |
    |          ~/.ivy2/cache
    |          ~/.sbt
    |        key: ${{ runner.os }}-sbt-${{ hashFiles('**/build.sbt') }}
    |    
    |    - name: Run tests
    |      run: sbt clean coverage test coverageReport
    |    
    |    - name: Upload coverage
    |      uses: codecov/codecov-action@v3
    |      with:
    |        file: ./target/scala-3.3.1/scoverage-report/scoverage.xml
    |    
    |    - name: Build Docker image
    |      if: github.ref == 'refs/heads/main'
    |      run: sbt docker:publishLocal
    |""".stripMargin
    
  IO.write(file, content)
  println(s"Generated $file")
}

// リリースプロセス
import sbtrelease.ReleaseStateTransformations._

releaseProcess := Seq[ReleaseStep](
  checkSnapshotDependencies,
  inquireVersions,
  runClean,
  runTest,
  setReleaseVersion,
  commitReleaseVersion,
  tagRelease,
  publishArtifacts,
  setNextVersion,
  commitNextVersion,
  pushChanges
)

// 公開設定
publishTo := {
  val nexus = "https://oss.sonatype.org/"
  if (isSnapshot.value)
    Some("snapshots" at nexus + "content/repositories/snapshots")
  else
    Some("releases" at nexus + "service/local/staging/deploy/maven2")
}

publishMavenStyle := true
Test / publishArtifact := false
pomIncludeRepository := { _ => false }

pomExtra := (
  <url>https://github.com/yourname/your-project</url>
  <licenses>
    <license>
      <name>Apache 2.0</name>
      <url>http://www.apache.org/licenses/LICENSE-2.0</url>
    </license>
  </licenses>
  <scm>
    <url>git@github.com:yourname/your-project.git</url>
    <connection>scm:git:git@github.com:yourname/your-project.git</connection>
  </scm>
  <developers>
    <developer>
      <id>yourname</id>
      <name>Your Name</name>
      <url>https://github.com/yourname</url>
    </developer>
  </developers>
)
```

### プロジェクトテンプレート

```scala
// ProjectTemplate.scala
// src/main/g8/build.sbt (Giter8テンプレート)

// テンプレート変数
// $name$ - プロジェクト名
// $organization$ - 組織名
// $scala_version$ - Scalaバージョン

ThisBuild / scalaVersion := "$scala_version$"
ThisBuild / version := "0.1.0-SNAPSHOT"
ThisBuild / organization := "$organization$"

lazy val root = (project in file("."))
  .settings(
    name := "$name$",
    
    libraryDependencies ++= Seq(
      // ロギング
      "ch.qos.logback" % "logback-classic" % "1.4.11",
      "com.typesafe.scala-logging" %% "scala-logging" % "3.9.5",
      
      // 設定
      "com.typesafe" % "config" % "1.4.3",
      "com.github.pureconfig" %% "pureconfig-core" % "0.17.4",
      
      // テスト
      "org.scalatest" %% "scalatest" % "3.2.17" % Test,
      "org.scalamock" %% "scalamock" % "5.2.0" % Test
    ),
    
    // アプリケーション設定
    Compile / mainClass := Some("$organization$.$name;format="norm"$.Main"),
    
    // テスト設定
    Test / testOptions += Tests.Argument(TestFrameworks.ScalaTest, "-oDF"),
    
    // コンパイラ設定
    scalacOptions ++= Seq(
      "-deprecation",
      "-feature",
      "-unchecked",
      "-Xfatal-warnings",
      "-language:higherKinds",
      "-language:implicitConversions"
    )
  )

// プロジェクト構造を生成するタスク
lazy val initProject = taskKey[Unit]("Initialize project structure")

initProject := {
  val dirs = Seq(
    "src/main/scala/$organization;format="packaged"$/$name;format="norm"$",
    "src/main/resources",
    "src/test/scala/$organization;format="packaged"$/$name;format="norm"$",
    "src/test/resources"
  )
  
  dirs.foreach { dir =>
    val path = file(dir)
    if (!path.exists()) {
      IO.createDirectory(path)
      println(s"Created: $dir")
    }
  }
  
  // Main.scalaの生成
  val mainFile = file("src/main/scala/$organization;format="packaged"$/$name;format="norm"$/Main.scala")
  if (!mainFile.exists()) {
    val mainContent = """package $organization$.$name;format="norm"$
      |
      |object Main extends App {
      |  println("Hello, $name$!")
      |}
      |""".stripMargin
    
    IO.write(mainFile, mainContent)
    println(s"Created: ${mainFile.getPath}")
  }
}
```

## 練習してみよう！

### 練習1：マルチモジュールプロジェクト

以下の構成のプロジェクトを作成してください：
- core: ビジネスロジック
- web: REST API
- batch: バッチ処理

### 練習2：カスタムタスク

プロジェクトの統計情報を表示するタスクを作成してください：
- ソースコードの行数
- テストカバレッジ
- 依存ライブラリ数

### 練習3：CI/CDパイプライン

GitHub ActionsでのCI/CDパイプラインを設定してください：
- テスト実行
- カバレッジレポート
- Dockerイメージのビルド

## この章のまとめ

ビルドツールと依存性管理の実践的な知識を習得しました！

### できるようになったこと

✅ **sbtの基本**
- プロジェクト構造
- 基本的なタスク
- 設定の書き方

✅ **依存性管理**
- ライブラリの追加
- バージョン管理
- 競合の解決

✅ **カスタマイズ**
- カスタムタスク
- プラグインの活用
- 環境別設定

✅ **実践的な設定**
- マルチプロジェクト
- Docker統合
- CI/CD連携

### ビルド管理のコツ

1. **整理された構造**
   - 明確なモジュール分割
   - 共通設定の抽出
   - 適切な命名

2. **再現可能性**
   - バージョンの固定
   - 環境の明示
   - ビルドの自動化

3. **効率的な開発**
   - インクリメンタルビルド
   - 並列実行
   - キャッシュの活用

### 最後に

ビルドツールは「プロジェクトの指揮者」です。たくさんの楽器（ライブラリ）を束ね、正しい順序で演奏させ、美しいハーモニー（アプリケーション）を作り出す。この指揮者の使い方をマスターすれば、どんな大規模なプロジェクトも効率的に管理できるようになります。

これで、初心者向けScala 3入門書の全37章が完成しました！プログラミングの世界への第一歩から、実践的なプロジェクト管理まで、幅広く学んできました。この知識を活かして、素晴らしいScalaアプリケーションを作ってください！