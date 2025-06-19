# やさしいScala 3入門 - Makefile

.PHONY: help install dev serve build clean test docker-build docker-run lint format

# デフォルトターゲット
help:
	@echo "やさしいScala 3入門 - 利用可能なコマンド:"
	@echo ""
	@echo "  install     - 依存関係をインストール"
	@echo "  dev         - 開発環境をセットアップ"
	@echo "  serve       - 開発サーバーを起動"
	@echo "  build       - 静的サイトをビルド"
	@echo "  clean       - ビルド成果物を削除"
	@echo "  test        - テストを実行"
	@echo "  lint        - コードチェックを実行"
	@echo "  format      - コードフォーマットを実行"
	@echo "  docker-build - Dockerイメージをビルド"
	@echo "  docker-run  - Dockerコンテナを起動"
	@echo ""

# 依存関係のインストール
install:
	pip install -r requirements.txt
	pip install -e .

# 開発環境のセットアップ
dev:
	pip install -e .[dev]
	@echo "開発環境のセットアップが完了しました！"

# 開発サーバーの起動
serve:
	@echo "🚀 開発サーバーを起動中..."
	easy-scala3-serve

# 静的サイトのビルド
build:
	@echo "📚 静的サイトをビルド中..."
	easy-scala3-build

# クリーンアップ
clean:
	@echo "🧹 ビルド成果物を削除中..."
	rm -rf site/
	rm -rf build/
	rm -rf dist/
	rm -rf *.egg-info/
	find . -type d -name __pycache__ -exec rm -rf {} +
	find . -type f -name "*.pyc" -delete

# テストの実行
test:
	@echo "🧪 テストを実行中..."
	python -m pytest tests/ -v

# コードチェック
lint:
	@echo "🔍 コードチェックを実行中..."
	flake8 src/
	black --check src/

# コードフォーマット
format:
	@echo "✨ コードフォーマットを実行中..."
	black src/

# Dockerイメージのビルド
docker-build:
	@echo "🐳 Dockerイメージをビルド中..."
	docker build -t easy-scala3:latest .

# Dockerコンテナの起動
docker-run:
	@echo "🐳 Dockerコンテナを起動中..."
	docker run -p 8000:8000 easy-scala3:latest

# パッケージの配布準備
dist:
	@echo "📦 配布パッケージを作成中..."
	python -m build

# 依存関係の更新
update:
	@echo "📝 依存関係を更新中..."
	pip install --upgrade pip
	pip install --upgrade -r requirements.txt