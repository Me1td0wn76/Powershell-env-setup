@echo off
chcp 65001 >nul
REM ============================================
REM Neovim GitHub Copilot セットアップスクリプト
REM ============================================
REM このスクリプトは以下をインストールします：
REM 1. Neovim (Scoop経由)
REM 2. vim-plug (プラグインマネージャー)
REM 3. GitHub Copilot for Vim (copilot.vim)
REM ============================================

setlocal enabledelayedexpansion

echo ============================================
echo Neovim GitHub Copilot セットアップ
echo ============================================
echo.

REM Scoopがインストールされているか確認
where scoop >nul 2>&1
if %errorlevel% neq 0 (
    echo [エラー] Scoopが見つかりません。
    echo 先にScoopをインストールしてください。
    echo https://scoop.sh/
    pause
    exit /b 1
)

echo [1/5] Neovimのインストール確認...
where nvim >nul 2>&1
if %errorlevel% neq 0 (
    echo Neovimをインストールしています...
    scoop install neovim
    if %errorlevel% neq 0 (
        echo [エラー] Neovimのインストールに失敗しました。
        pause
        exit /b 1
    )
    echo Neovimのインストールが完了しました。
) else (
    echo Neovimは既にインストールされています。
)
echo.

REM Neovim設定ディレクトリ作成
set "NVIM_CONFIG_DIR=%LOCALAPPDATA%\nvim"
if not exist "%NVIM_CONFIG_DIR%" (
    echo [2/5] Neovim設定ディレクトリを作成しています...
    mkdir "%NVIM_CONFIG_DIR%"
) else (
    echo [2/5] Neovim設定ディレクトリは既に存在します。
)
echo.

REM vim-plugのインストール
set "PLUG_VIM=%LOCALAPPDATA%\nvim-data\site\autoload\plug.vim"
if not exist "%PLUG_VIM%" (
    echo [3/5] vim-plugをインストールしています...
    powershell -Command "iwr -useb https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim | ni $env:LOCALAPPDATA/nvim-data/site/autoload/plug.vim -Force"
    if %errorlevel% neq 0 (
        echo [エラー] vim-plugのインストールに失敗しました。
        pause
        exit /b 1
    )
    echo vim-plugのインストールが完了しました。
) else (
    echo [3/5] vim-plugは既にインストールされています。
)
echo.

REM init.vimの作成/更新
set "INIT_VIM=%NVIM_CONFIG_DIR%\init.vim"
echo [4/5] init.vimを設定しています...

if exist "%INIT_VIM%" (
    echo 既存のinit.vimが見つかりました。
    findstr /C:"github/copilot.vim" "%INIT_VIM%" >nul 2>&1
    if %errorlevel% equ 0 (
        echo GitHub Copilotの設定は既に存在します。
    ) else (
        echo GitHub Copilotの設定を追加しています...
        echo. >> "%INIT_VIM%"
        echo " GitHub Copilot >> "%INIT_VIM%"
        echo call plug#begin() >> "%INIT_VIM%"
        echo Plug 'github/copilot.vim' >> "%INIT_VIM%"
        echo call plug#end() >> "%INIT_VIM%"
    )
) else (
    echo 新しいinit.vimを作成しています...
    (
        echo " ============================================
        echo " Neovim 設定ファイル
        echo " ============================================
        echo.
        echo " プラグインマネージャー: vim-plug
        echo call plug#begin^(^)
        echo.
        echo " GitHub Copilot
        echo Plug 'github/copilot.vim'
        echo.
        echo " その他のプラグインをここに追加
        echo " 例: Plug 'preservim/nerdtree'
        echo.
        echo call plug#end^(^)
        echo.
        echo " 基本設定
        echo set number
        echo set relativenumber
        echo set tabstop=4
        echo set shiftwidth=4
        echo set expandtab
        echo set autoindent
        echo set smartindent
        echo syntax on
        echo.
        echo " Copilot設定
        echo " Copilotを有効化 ^(デフォルトで有効^)
        echo let g:copilot_enabled = 1
        echo.
        echo " Copilotのキーマッピング
        echo " Tab で候補を受け入れる ^(デフォルト^)
        echo " Ctrl+] で候補を拒否
        echo " Alt+] で次の候補
        echo " Alt+[ で前の候補
    ) > "%INIT_VIM%"
)
echo init.vimの設定が完了しました。
echo.

echo [5/5] プラグインをインストールしています...
echo Neovimを起動してプラグインをインストールします。
echo ^(自動的に:PlugInstallを実行します^)
echo.
nvim +PlugInstall +qall
echo.

echo ============================================
echo セットアップが完了しました！
echo ============================================
echo.
echo 次のステップ:
echo 1. Neovimを起動: nvim
echo 2. GitHub Copilotにサインイン: :Copilot setup
echo 3. 認証コードをブラウザで入力してください
echo.
echo 設定ファイルの場所:
echo %INIT_VIM%
echo.
echo 便利なコマンド:
echo   :Copilot setup   - Copilotの初期設定
echo   :Copilot enable  - Copilotを有効化
echo   :Copilot disable - Copilotを無効化
echo   :Copilot status  - Copilotの状態確認
echo.
pause
