@echo off
chcp 65001 >nul
REM ============================================
REM Neovim GitHub Copilot Chat セットアップスクリプト
REM ============================================
REM このスクリプトは以下を追加インストールします：
REM 1. plenary.nvim (依存プラグイン)
REM 2. CopilotChat.nvim (Copilot Chatプラグイン)
REM 3. telescope.nvim (オプション：履歴検索用)
REM ============================================
REM 前提条件: 
REM - Neovimがインストール済み
REM - copilot.vimがインストール済み
REM - vim-plugがインストール済み
REM ============================================

setlocal enabledelayedexpansion

echo ============================================
echo Neovim GitHub Copilot Chat セットアップ
echo ============================================
echo.

REM Neovimがインストールされているか確認
where nvim >nul 2>&1
if %errorlevel% neq 0 (
    echo [エラー] Neovimが見つかりません。
    echo 先にneovim_copilot_setup.batを実行してください。
    pause
    exit /b 1
)

set "NVIM_CONFIG_DIR=%LOCALAPPDATA%\nvim"
set "INIT_VIM=%NVIM_CONFIG_DIR%\init.vim"

REM init.vimの存在確認
if not exist "%INIT_VIM%" (
    echo [エラー] init.vimが見つかりません。
    echo 先にneovim_copilot_setup.batを実行してください。
    pause
    exit /b 1
)

echo [1/3] 既存の設定を確認しています...

REM copilot.vimの確認
findstr /C:"github/copilot.vim" "%INIT_VIM%" >nul 2>&1
if %errorlevel% neq 0 (
    echo [警告] copilot.vimが設定されていません。
    echo 先にneovim_copilot_setup.batを実行することをお勧めします。
    pause
)

REM CopilotChat.nvimが既に設定されているか確認
findstr /C:"CopilotC-Nvim/CopilotChat.nvim" "%INIT_VIM%" >nul 2>&1
if %errorlevel% equ 0 (
    echo CopilotChat.nvimは既に設定されています。
    echo 既存の設定を維持します。
    pause
    exit /b 0
)

echo [2/3] init.vimにCopilot Chat設定を追加しています...

REM バックアップ作成
copy "%INIT_VIM%" "%INIT_VIM%.backup" >nul 2>&1
echo バックアップを作成しました: %INIT_VIM%.backup

REM 一時的なプラグイン追加ファイルを作成
set "PLUGINS_ADD=%TEMP%\plugins_to_add.txt"
(
    echo.
    echo " 依存プラグイン ^(Copilot Chat用^)
    echo Plug 'nvim-lua/plenary.nvim'
    echo.
    echo " GitHub Copilot Chat
    echo Plug 'CopilotC-Nvim/CopilotChat.nvim', { 'branch': 'canary' }
    echo.
    echo " オプション: Telescope ^(履歴検索用^)
    echo Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.5' }
) > "%PLUGINS_ADD%"

REM call plug#begin()の行番号を見つけて、その後に挿入
findstr /N "call plug#begin" "%INIT_VIM%" > "%TEMP%\line_number.txt"
set /p LINE_INFO=<"%TEMP%\line_number.txt"
for /f "tokens=1 delims=:" %%a in ("%LINE_INFO%") do set LINE_NUM=%%a

if not defined LINE_NUM (
    echo [エラー] call plug#begin^(^) が見つかりません
    del "%PLUGINS_ADD%" >nul 2>&1
    del "%TEMP%\line_number.txt" >nul 2>&1
    pause
    exit /b 1
)

REM 新しいinit.vimを作成
set "NEW_INIT=%TEMP%\new_init.vim"
set /a INSERT_LINE=%LINE_NUM%
set CURRENT_LINE=0

(
    for /f "usebackq delims=" %%L in ("%INIT_VIM%") do (
        set /a CURRENT_LINE+=1
        echo %%L
        if !CURRENT_LINE! equ %INSERT_LINE% (
            type "%PLUGINS_ADD%"
        )
    )
) > "%NEW_INIT%"

REM ファイルを置き換え
move /Y "%NEW_INIT%" "%INIT_VIM%" >nul 2>&1
del "%PLUGINS_ADD%" >nul 2>&1
del "%TEMP%\line_number.txt" >nul 2>&1

REM Copilot Chatの設定を追加
(
    echo.
    echo " ============================================
    echo " GitHub Copilot Chat 設定
    echo " ============================================
    echo.
    echo " Lua設定ブロック
    echo lua ^<^<EOF
    echo require^("CopilotChat"^).setup {
    echo   debug = false,
    echo   show_help = "yes",
    echo   prompts = {
    echo     Explain = "選択したコードを日本語で説明してください",
    echo     Review = "選択したコードをレビューしてください",
    echo     Tests = "選択したコードのテストケースを作成してください",
    echo     Refactor = "選択したコードをリファクタリングしてください",
    echo     FixCode = "選択したコードのバグを修正してください",
    echo     Documentation = "選択したコードのドキュメントを作成してください",
    echo   },
    echo }
    echo EOF
    echo.
    echo " ============================================
    echo " Copilot Chat キーマッピング
    echo " ============================================
    echo.
    echo " チャットウィンドウを開く
    echo nnoremap ^<leader^>cc :CopilotChat^<CR^>
    echo.
    echo " 選択したコードについて質問
    echo vnoremap ^<leader^>ce :CopilotChatExplain^<CR^>
    echo vnoremap ^<leader^>cr :CopilotChatReview^<CR^>
    echo vnoremap ^<leader^>ct :CopilotChatTests^<CR^>
    echo vnoremap ^<leader^>cf :CopilotChatFixCode^<CR^>
    echo.
    echo " インラインチャット
    echo nnoremap ^<leader^>ci :CopilotChatInline^<CR^>
    echo.
    echo " コミットメッセージ生成
    echo nnoremap ^<leader^>cm :CopilotChatCommit^<CR^>
    echo.
    echo " チャット履歴を表示 ^(Telescope必要^)
    echo nnoremap ^<leader^>ch :Telescope copilot^<CR^>
    echo.
    echo " リーダーキーの設定 ^(デフォルトは\^)
    echo " let mapleader = " "
) >> "%INIT_VIM%"

echo init.vimの設定が完了しました。
echo.

echo [3/3] プラグインをインストールしています...
echo Neovimを起動してプラグインをインストールします。
echo.

nvim +PlugInstall +qall

if %errorlevel% neq 0 (
    echo [警告] プラグインのインストール中に問題が発生した可能性があります。
    echo 手動で :PlugInstall を実行してください。
)

echo.
echo ============================================
echo セットアップが完了しました
echo ============================================
echo.
echo 次のステップ: nvim を起動して Copilot Chat を使用
echo.
echo 便利なコマンド:
echo   :CopilotChat - チャットを開く
echo   :CopilotChatExplain - コードの説明
echo   :CopilotChatReview - コードレビュー
echo.
echo キーマッピング:
echo   \cc - チャット
echo   \ce - 説明
echo   \cr - レビュー
echo.
pause
