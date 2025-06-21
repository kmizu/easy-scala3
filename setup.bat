@echo off
setlocal enabledelayedexpansion

REM やさしいScala 3入門 - Windows自動セットアップスクリプト
REM Python仮想環境の構築からビルドまで一括実行

echo ============================================== 
echo     やさしいScala 3入門 セットアップ
echo ==============================================

REM 引数の処理
set SERVE_MODE=false
set BUILD_ONLY=false
set CLEAN_INSTALL=false

:parse_args
if "%~1"=="" goto args_done
if "%~1"=="--serve" set SERVE_MODE=true && shift && goto parse_args
if "%~1"=="-s" set SERVE_MODE=true && shift && goto parse_args
if "%~1"=="--build-only" set BUILD_ONLY=true && shift && goto parse_args
if "%~1"=="-b" set BUILD_ONLY=true && shift && goto parse_args
if "%~1"=="--clean" set CLEAN_INSTALL=true && shift && goto parse_args
if "%~1"=="-c" set CLEAN_INSTALL=true && shift && goto parse_args
if "%~1"=="--help" goto show_help
if "%~1"=="-h" goto show_help
echo 不明なオプション: %~1
echo ヘルプを表示するには %0 --help を実行してください
exit /b 1

:show_help
echo 使用方法: %0 [オプション]
echo.
echo オプション:
echo   --serve, -s      ビルド後に開発サーバーを起動
echo   --build-only, -b ビルドのみ実行（サーバー起動なし）
echo   --clean, -c      既存の仮想環境を削除してクリーンインストール
echo   --help, -h       このヘルプを表示
echo.
echo 例:
echo   %0                # 基本セットアップ
echo   %0 --serve        # セットアップ後にサーバー起動
echo   %0 --clean --serve # クリーンインストール後にサーバー起動
exit /b 0

:args_done

REM Pythonの確認
echo 🔍 Python環境をチェック中...
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Pythonが見つかりません。Python 3.8以上をインストールしてください。
    pause
    exit /b 1
)

for /f "tokens=2" %%i in ('python --version') do set PYTHON_VERSION=%%i
echo ✅ Python %PYTHON_VERSION% を発見

REM Python 3.8以上かチェック
python -c "import sys; sys.exit(0 if sys.version_info >= (3, 8) else 1)" >nul 2>&1
if errorlevel 1 (
    echo ❌ Python 3.8以上が必要です。現在のバージョン: %PYTHON_VERSION%
    pause
    exit /b 1
)
echo ✅ Python バージョンOK

REM 仮想環境の設定
set VENV_DIR=venv

if "%CLEAN_INSTALL%"=="true" (
    if exist "%VENV_DIR%" (
        echo 🧹 既存の仮想環境を削除中...
        rmdir /s /q "%VENV_DIR%"
    )
)

if not exist "%VENV_DIR%" (
    echo 📦 Python仮想環境を作成中...
    python -m venv "%VENV_DIR%"
    echo ✅ 仮想環境を作成しました
) else (
    echo 📦 既存の仮想環境を使用
)

REM 仮想環境をアクティベート
echo 🔧 仮想環境をアクティベート中...
call "%VENV_DIR%\Scripts\activate.bat"

REM pipのアップグレード
echo ⬆️  pipを最新版にアップグレード中...
python -m pip install --upgrade pip --quiet

REM 依存関係のインストール
echo 📚 依存関係をインストール中...
pip install -r requirements.txt --quiet

REM プロジェクトのインストール
echo 🔧 プロジェクトをインストール中...
pip install -e . --quiet

echo ✅ インストール完了！

REM ビルド実行
if not "%BUILD_ONLY%"=="true" (
    echo 📖 ドキュメントをビルド中...
    easy-scala3-build
)

REM 完了メッセージ
echo ==============================================
echo     🎉 セットアップ完了！
echo ==============================================

echo 📁 プロジェクトディレクトリ: %cd%
echo 🐍 仮想環境: %VENV_DIR%
echo 📄 ビルド出力: site\

echo.
echo 💡 利用可能なコマンド:
echo   %VENV_DIR%\Scripts\activate.bat  # 仮想環境をアクティベート
echo   easy-scala3-serve                # 開発サーバーを起動
echo   easy-scala3-build                # 静的サイトをビルド
echo   mkdocs serve                     # MkDocsサーバーを直接起動
echo   deactivate                       # 仮想環境を終了

echo.
echo 🌐 ブラウザで確認:
echo   http://127.0.0.1:8000

REM サーバー起動オプション
if "%SERVE_MODE%"=="true" (
    echo.
    echo 🚀 開発サーバーを起動中...
    echo ⏹️  終了するには Ctrl+C を押してください
    echo.
    easy-scala3-serve
) else (
    echo.
    echo 🚀 開発サーバーを起動するには:
    echo   %VENV_DIR%\Scripts\activate.bat ^&^& easy-scala3-serve
    echo.
    echo または:
    echo   %0 --serve
    pause
)