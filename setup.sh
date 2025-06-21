#!/bin/bash

# やさしいScala 3入門 - 自動セットアップスクリプト
# Python仮想環境の構築からビルドまで一括実行

set -e  # エラーが発生したら停止

# 色付き出力用の定数
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ロゴ表示
echo -e "${PURPLE}"
echo "=============================================="
echo "    やさしいScala 3入門 セットアップ"
echo "=============================================="
echo -e "${NC}"

# 引数の処理
SERVE_MODE=false
BUILD_ONLY=false
CLEAN_INSTALL=false

while [[ $# -gt 0 ]]; do
    case $1 in
        --serve|-s)
            SERVE_MODE=true
            shift
            ;;
        --build-only|-b)
            BUILD_ONLY=true
            shift
            ;;
        --clean|-c)
            CLEAN_INSTALL=true
            shift
            ;;
        --help|-h)
            echo "使用方法: $0 [オプション]"
            echo ""
            echo "オプション:"
            echo "  --serve, -s      ビルド後に開発サーバーを起動"
            echo "  --build-only, -b ビルドのみ実行（サーバー起動なし）"
            echo "  --clean, -c      既存の仮想環境を削除してクリーンインストール"
            echo "  --help, -h       このヘルプを表示"
            echo ""
            echo "例:"
            echo "  $0                # 基本セットアップ"
            echo "  $0 --serve        # セットアップ後にサーバー起動"
            echo "  $0 --clean --serve # クリーンインストール後にサーバー起動"
            exit 0
            ;;
        *)
            echo -e "${RED}不明なオプション: $1${NC}"
            echo "ヘルプを表示するには $0 --help を実行してください"
            exit 1
            ;;
    esac
done

# Pythonの確認
echo -e "${BLUE}🔍 Python環境をチェック中...${NC}"
if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ python3が見つかりません。Python 3.8以上をインストールしてください。${NC}"
    exit 1
fi

PYTHON_VERSION=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
echo -e "${GREEN}✅ Python $PYTHON_VERSION を発見${NC}"

# Python 3.8以上かチェック
if python3 -c 'import sys; sys.exit(0 if sys.version_info >= (3, 8) else 1)'; then
    echo -e "${GREEN}✅ Python バージョンOK${NC}"
else
    echo -e "${RED}❌ Python 3.8以上が必要です。現在のバージョン: $PYTHON_VERSION${NC}"
    exit 1
fi

# 仮想環境の設定
VENV_DIR="venv"

if [ "$CLEAN_INSTALL" = true ] && [ -d "$VENV_DIR" ]; then
    echo -e "${YELLOW}🧹 既存の仮想環境を削除中...${NC}"
    rm -rf "$VENV_DIR"
fi

if [ ! -d "$VENV_DIR" ]; then
    echo -e "${BLUE}📦 Python仮想環境を作成中...${NC}"
    python3 -m venv "$VENV_DIR"
    echo -e "${GREEN}✅ 仮想環境を作成しました${NC}"
else
    echo -e "${YELLOW}📦 既存の仮想環境を使用${NC}"
fi

# 仮想環境をアクティベート
echo -e "${BLUE}🔧 仮想環境をアクティベート中...${NC}"
source "$VENV_DIR/bin/activate"

# pipのアップグレード
echo -e "${BLUE}⬆️  pipを最新版にアップグレード中...${NC}"
pip install --upgrade pip --quiet

# 依存関係のインストール
echo -e "${BLUE}📚 依存関係をインストール中...${NC}"
pip install -r requirements.txt --quiet

# プロジェクトのインストール
echo -e "${BLUE}🔧 プロジェクトをインストール中...${NC}"
pip install -e . --quiet

echo -e "${GREEN}✅ インストール完了！${NC}"

# ビルド実行
if [ "$BUILD_ONLY" = false ]; then
    echo -e "${BLUE}📖 ドキュメントをビルド中...${NC}"
    easy-scala3-build
fi

# 完了メッセージ
echo -e "${GREEN}"
echo "=============================================="
echo "    🎉 セットアップ完了！"
echo "=============================================="
echo -e "${NC}"

echo -e "${CYAN}📁 プロジェクトディレクトリ:${NC} $(pwd)"
echo -e "${CYAN}🐍 仮想環境:${NC} $VENV_DIR"
echo -e "${CYAN}📄 ビルド出力:${NC} site/"

echo ""
echo -e "${YELLOW}💡 利用可能なコマンド:${NC}"
echo "  source venv/bin/activate    # 仮想環境をアクティベート"
echo "  easy-scala3-serve           # 開発サーバーを起動"
echo "  easy-scala3-build           # 静的サイトをビルド"
echo "  mkdocs serve                # MkDocsサーバーを直接起動"
echo "  deactivate                  # 仮想環境を終了"

echo ""
echo -e "${YELLOW}🌐 ブラウザで確認:${NC}"
echo "  http://127.0.0.1:8000"

# サーバー起動オプション
if [ "$SERVE_MODE" = true ]; then
    echo ""
    echo -e "${BLUE}🚀 開発サーバーを起動中...${NC}"
    echo -e "${YELLOW}⏹️  終了するには Ctrl+C を押してください${NC}"
    echo ""
    easy-scala3-serve
else
    echo ""
    echo -e "${CYAN}🚀 開発サーバーを起動するには:${NC}"
    echo "  source venv/bin/activate && easy-scala3-serve"
    echo ""
    echo -e "${CYAN}または:${NC}"
    echo "  $0 --serve"
fi