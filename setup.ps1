# やさしいScala 3入門 - PowerShell自動セットアップスクリプト
# Python仮想環境の構築からビルドまで一括実行

param(
    [switch]$Serve,
    [switch]$BuildOnly,
    [switch]$Clean,
    [switch]$Help
)

function Write-ColorOutput {
    param(
        [string]$Message,
        [string]$Color = "White"
    )
    Write-Host $Message -ForegroundColor $Color
}

function Show-Help {
    Write-ColorOutput "使用方法: .\setup.ps1 [オプション]" "Yellow"
    Write-Host ""
    Write-Host "オプション:"
    Write-Host "  -Serve        ビルド後に開発サーバーを起動"
    Write-Host "  -BuildOnly    ビルドのみ実行（サーバー起動なし）"
    Write-Host "  -Clean        既存の仮想環境を削除してクリーンインストール"
    Write-Host "  -Help         このヘルプを表示"
    Write-Host ""
    Write-Host "例:"
    Write-Host "  .\setup.ps1                # 基本セットアップ"
    Write-Host "  .\setup.ps1 -Serve         # セットアップ後にサーバー起動"
    Write-Host "  .\setup.ps1 -Clean -Serve  # クリーンインストール後にサーバー起動"
    exit
}

if ($Help) {
    Show-Help
}

# エラー時に停止
$ErrorActionPreference = "Stop"

# ロゴ表示
Write-ColorOutput "=============================================="  "Magenta"
Write-ColorOutput "    やさしいScala 3入門 セットアップ"          "Magenta"
Write-ColorOutput "=============================================="  "Magenta"

# Pythonの確認
Write-ColorOutput "🔍 Python環境をチェック中..." "Blue"

try {
    $pythonVersion = python --version 2>&1
    if ($LASTEXITCODE -ne 0) {
        throw "Python not found"
    }
    Write-ColorOutput "✅ $pythonVersion を発見" "Green"
} catch {
    Write-ColorOutput "❌ Pythonが見つかりません。Python 3.8以上をインストールしてください。" "Red"
    Read-Host "Enterキーを押して終了"
    exit 1
}

# Python 3.8以上かチェック
try {
    python -c "import sys; sys.exit(0 if sys.version_info >= (3, 8) else 1)"
    if ($LASTEXITCODE -ne 0) {
        throw "Python version too old"
    }
    Write-ColorOutput "✅ Python バージョンOK" "Green"
} catch {
    Write-ColorOutput "❌ Python 3.8以上が必要です。" "Red"
    Read-Host "Enterキーを押して終了"
    exit 1
}

# 仮想環境の設定
$venvDir = "venv"

if ($Clean -and (Test-Path $venvDir)) {
    Write-ColorOutput "🧹 既存の仮想環境を削除中..." "Yellow"
    Remove-Item -Recurse -Force $venvDir
}

if (-not (Test-Path $venvDir)) {
    Write-ColorOutput "📦 Python仮想環境を作成中..." "Blue"
    python -m venv $venvDir
    Write-ColorOutput "✅ 仮想環境を作成しました" "Green"
} else {
    Write-ColorOutput "📦 既存の仮想環境を使用" "Yellow"
}

# 仮想環境をアクティベート
Write-ColorOutput "🔧 仮想環境をアクティベート中..." "Blue"
& "$venvDir\Scripts\Activate.ps1"

# pipのアップグレード
Write-ColorOutput "⬆️  pipを最新版にアップグレード中..." "Blue"
python -m pip install --upgrade pip --quiet

# 依存関係のインストール
Write-ColorOutput "📚 依存関係をインストール中..." "Blue"
pip install -r requirements.txt --quiet

# プロジェクトのインストール
Write-ColorOutput "🔧 プロジェクトをインストール中..." "Blue"
pip install -e . --quiet

Write-ColorOutput "✅ インストール完了！" "Green"

# ビルド実行
if (-not $BuildOnly) {
    Write-ColorOutput "📖 ドキュメントをビルド中..." "Blue"
    easy-scala3-build
}

# 完了メッセージ
Write-ColorOutput "=============================================="  "Green"
Write-ColorOutput "    🎉 セットアップ完了！"                    "Green"
Write-ColorOutput "=============================================="  "Green"

Write-ColorOutput "📁 プロジェクトディレクトリ: $(Get-Location)" "Cyan"
Write-ColorOutput "🐍 仮想環境: $venvDir" "Cyan"
Write-ColorOutput "📄 ビルド出力: site\" "Cyan"

Write-Host ""
Write-ColorOutput "💡 利用可能なコマンド:" "Yellow"
Write-Host "  .\$venvDir\Scripts\Activate.ps1  # 仮想環境をアクティベート"
Write-Host "  easy-scala3-serve                # 開発サーバーを起動"
Write-Host "  easy-scala3-build                # 静的サイトをビルド"
Write-Host "  mkdocs serve                     # MkDocsサーバーを直接起動"
Write-Host "  deactivate                       # 仮想環境を終了"

Write-Host ""
Write-ColorOutput "🌐 ブラウザで確認:" "Yellow"
Write-Host "  http://127.0.0.1:8000"

# サーバー起動オプション
if ($Serve) {
    Write-Host ""
    Write-ColorOutput "🚀 開発サーバーを起動中..." "Blue"
    Write-ColorOutput "⏹️  終了するには Ctrl+C を押してください" "Yellow"
    Write-Host ""
    easy-scala3-serve
} else {
    Write-Host ""
    Write-ColorOutput "🚀 開発サーバーを起動するには:" "Cyan"
    Write-Host "  .\$venvDir\Scripts\Activate.ps1; easy-scala3-serve"
    Write-Host ""
    Write-ColorOutput "または:" "Cyan"
    Write-Host "  .\setup.ps1 -Serve"
    Write-Host ""
    Read-Host "Enterキーを押して終了"
}