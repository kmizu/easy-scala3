# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Important
- ステップごとにチェックリストを確認
- 進捗したらチェックリストにチェックを入れる
- ビルドが通ることをステップごとに確認

## Communication Language

Please respond in Japanese (日本語) when working with this codebase.

## Project Overview

This is a Scala 3 book writing project named "easy-scala3" - creating a beginner-friendly Scala 3 programming book for complete programming newcomers.

## Book Structure and Progress

プログラミング初心者向け「やさしいScala 3入門」執筆進捗チェックリスト

### 第I部：プログラミングの世界へようこそ
- [x] 第0章：プログラミングをはじめる前に
- [x] 第1章：Scalaと出会おう
- [x] 第2章：数値で遊んでみよう

### 第II部：データと型の基本を理解しよう
- [x] 第3章：値と変数の基本
- [x] 第4章：いろいろな種類のデータ
- [x] 第5章：型って何だろう？（型の基礎編）
- [x] 第6章：型推論の魔法
- [x] 第7章：文字列を自由自在に

### 第III部：型を意識してデータをまとめよう
- [x] 第8章：型安全なコレクション（基礎編）
- [x] 第9章：リストで同じデータを並べる
- [x] 第10章：型安全なタプル
- [x] 第11章：タプルで違うデータをまとめる
- [x] 第12章：型安全なマップ
- [x] 第13章：マップで関連付けて保存

### 第IV部：プログラムに判断力を持たせよう
- [x] 第14章：条件分岐の基本
- [x] 第15章：パターンマッチングの威力
- [x] 第16章：関数の定義と利用
- [x] 第17章：関数の引数をもっと賢く
- [x] 第18章：高階関数とは何か
- [x] 第19章：OptionとEitherで安全に

### 第V部：非同期処理とエラーハンドリング
- [x] 第20章：Future[T]で非同期処理
- [x] 第21章：Try[T]で例外を扱う

### 第VI部：型で設計するデータ構造
- [x] 第22章：ケースクラスの便利さ
- [x] 第23章：シールドトレイトで網羅的に
- [x] 第24章：イミュータブルなデータ設計

### 第VII部：関数型プログラミングの基礎
- [x] 第25章：関数合成で処理を組み立てる
- [x] 第26章：型パラメータ入門
- [x] 第27章：境界と変位指定
- [x] 第28章：暗黙の引数とは
- [x] 第29章：型クラスパターン
- [x] 第30章：for式の内部動作

### 第VIII部：コレクションの使いこなし
- [x] 第31章：コレクションの選び方
- [x] 第32章：効率的なコレクション操作
- [x] 第33章：並行プログラミング入門

### 第IX部：実用的なプログラミング技術
- [x] 第34章：スレッドセーフを意識する
- [x] 第35章：アクターモデル入門
- [x] 第36章：テストを書こう
- [x] 第37章：ビルドツールと依存性管理

### 付録
- [x] 付録A：よくあるエラーメッセージ完全ガイド
- [x] 付録B：REPL完全活用法
- [x] 付録C：便利なメソッド・関数リファレンス
- [x] 付録D：開発環境カスタマイズガイド
- [x] 付録E：練習問題解答集
- [x] 付録F：次に読むべき書籍・資料

## 現在の執筆状況

**完了した章数**: 37章 / 37章 (100%)
**完了した付録数**: 6付録 / 6付録 (100%)

**最新の執筆状況**:
- 全37章の執筆完了
- 全6付録の執筆完了
- MkDocsでのビルド設定完了

**執筆完了項目**:
- プロジェクト構造設定
- 第I部〜第IX部（全37章）
- 付録A〜付録F（全6付録）
- MkDocsビルド設定とテーマ適用

**完了**: すべての章と付録の執筆、MkDocsでの出版設定も完了！

## Development Commands

### ビルド & 出版コマンド

```bash
# 🚀 自動セットアップ（推奨）
./setup.sh --serve

# 🐳 Docker使用
make docker-build && make docker-run

# 📚 通常のビルド
mkdocs build

# 🌐 開発サーバー
mkdocs serve
```

### 開発環境
- Scala 3.3.1
- sbt 1.9.7
- mkdocs 1.6.1

## Writing Guidelines

- 完全プログラミング初心者向けアプローチ
- Java知識ゼロ前提
- 型安全性と関数型プログラミングを段階的に学習
- 豊富なコード例とハンズオン練習
- エラーメッセージ解説を重視
    - エラーを出させるコード例を練習問題として掲載
