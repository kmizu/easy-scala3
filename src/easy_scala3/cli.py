#!/usr/bin/env python3
"""
CLIツール for やさしいScala 3入門

このモジュールは、書籍のビルドとプレビューのためのコマンドラインツールを提供します。
"""

import os
import sys
import subprocess
import argparse
from pathlib import Path


def get_project_root():
    """プロジェクトのルートディレクトリを取得"""
    current = Path(__file__).parent
    while current.parent != current:
        if (current / "mkdocs.yml").exists():
            return current
        current = current.parent
    return Path.cwd()


def serve():
    """開発用サーバーを起動"""
    project_root = get_project_root()
    os.chdir(project_root)
    
    print("🚀 やさしいScala 3入門 開発サーバーを起動中...")
    print(f"📁 プロジェクトディレクトリ: {project_root}")
    print("🌐 ブラウザで http://127.0.0.1:8000 を開いてください")
    print("⏹️  終了するには Ctrl+C を押してください")
    
    try:
        subprocess.run(["mkdocs", "serve", "--dev-addr", "127.0.0.1:8000"], check=True)
    except subprocess.CalledProcessError as e:
        print(f"❌ サーバー起動に失敗しました: {e}")
        sys.exit(1)
    except KeyboardInterrupt:
        print("\n✅ サーバーを停止しました")


def build():
    """静的サイトをビルド"""
    project_root = get_project_root()
    os.chdir(project_root)
    
    print("📚 やさしいScala 3入門 をビルド中...")
    print(f"📁 プロジェクトディレクトリ: {project_root}")
    
    try:
        subprocess.run(["mkdocs", "build"], check=True)
        print("✅ ビルドが完了しました！")
        print(f"📄 出力先: {project_root / 'site'}")
    except subprocess.CalledProcessError as e:
        print(f"❌ ビルドに失敗しました: {e}")
        sys.exit(1)


def main():
    """メインCLI関数"""
    parser = argparse.ArgumentParser(
        description="やさしいScala 3入門 ビルドツール",
        prog="easy-scala3"
    )
    
    subparsers = parser.add_subparsers(dest="command", help="利用可能なコマンド")
    
    # serveコマンド
    serve_parser = subparsers.add_parser(
        "serve", 
        help="開発用サーバーを起動"
    )
    serve_parser.set_defaults(func=serve)
    
    # buildコマンド
    build_parser = subparsers.add_parser(
        "build", 
        help="静的サイトをビルド"
    )
    build_parser.set_defaults(func=build)
    
    args = parser.parse_args()
    
    if hasattr(args, 'func'):
        args.func()
    else:
        parser.print_help()


if __name__ == "__main__":
    main()